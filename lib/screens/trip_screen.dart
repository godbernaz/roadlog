import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ViagemScreen extends StatefulWidget {
  const ViagemScreen({super.key});

  @override
  State<ViagemScreen> createState() => _ViagemScreenState();
}

class _ViagemScreenState extends State<ViagemScreen> {
  final Stopwatch _cronometro = Stopwatch();
  Timer? _timer;
  StreamSubscription<Position>? _gps;

  final List<Position> _pontos = [];
  double _distanciaMetros = 0;
  double _velocidadeAtualKmh = 0;
  DateTime? _inicio;

  bool get _aGravar => _cronometro.isRunning;

  double get _velocidadeMediaKmh {
    final horas = _cronometro.elapsed.inSeconds / 3600;
    if (horas == 0) return 0;
    return (_distanciaMetros / 1000) / horas;
  }

  // 1. Confirma que o GPS está ligado e que temos permissão
  Future<bool> _temPermissaoGps() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _aviso('Liga a localização do telemóvel.');
      return false;
    }
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      _aviso('O Roadlog precisa da localização para gravar a viagem.');
      return false;
    }
    return true;
  }

  void _aviso(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  // 2. Começa a viagem: cronómetro + GPS + ecrã sempre ligado
  Future<void> _iniciar() async {
    if (!await _temPermissaoGps()) return;

    _pontos.clear();
    _distanciaMetros = 0;
    _velocidadeAtualKmh = 0;
    _inicio = DateTime.now();

    _cronometro
      ..reset()
      ..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
    WakelockPlus.enable();

    _gps = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // novo ponto a cada 5 metros
      ),
    ).listen(_novoPonto);

    setState(() {});
  }

  // 3. Chamado sempre que o GPS envia uma posição nova
  void _novoPonto(Position p) {
    if (p.accuracy > 30) return; // ignora pontos com erro > 30 m
    if (_pontos.isNotEmpty) {
      final ultimo = _pontos.last;
      _distanciaMetros += Geolocator.distanceBetween(
        ultimo.latitude, ultimo.longitude, p.latitude, p.longitude,
      );
    }
    _pontos.add(p);
    setState(() {
      _velocidadeAtualKmh = p.speed < 0 ? 0 : p.speed * 3.6; // m/s -> km/h
    });
  }

  // 4. Termina a viagem
  void _parar() {
    _cronometro.stop();
    _timer?.cancel();
    _gps?.cancel();
    WakelockPlus.disable();
    setState(() {});
  }

  String _formatar(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _hora(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    _gps?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova viagem')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatar(_cronometro.elapsed),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            if (_inicio != null) Text('Partida às ${_hora(_inicio!)}'),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Indicador('Distância',
                    '${(_distanciaMetros / 1000).toStringAsFixed(2)} km'),
                _Indicador('Média',
                    '${_velocidadeMediaKmh.toStringAsFixed(0)} km/h'),
                _Indicador('Agora',
                    '${_velocidadeAtualKmh.toStringAsFixed(0)} km/h'),
              ],
            ),
            const SizedBox(height: 8),
            Text('${_pontos.length} pontos GPS',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _aGravar ? _parar : _iniciar,
              icon: Icon(_aGravar ? Icons.stop : Icons.play_arrow),
              label: Text(_aGravar ? 'Terminar viagem' : 'Iniciar viagem'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(240, 64),
                backgroundColor: _aGravar ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pequeno widget reutilizável: um título e um valor
class _Indicador extends StatelessWidget {
  const _Indicador(this.titulo, this.valor);

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(titulo, style: Theme.of(context).textTheme.labelMedium),
        Text(valor, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}