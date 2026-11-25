import 'dart:async';
import 'dart:convert';
import 'package:material_ui/material_ui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import '../database.dart';
import '../widgets/route_dialog.dart';

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

  // Mapa
  mb.MapboxMap? _mapa;
  bool _rastoCriado = false;
  bool _seguir = true;

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

  // --- Mapa -------------------------------------------------------------

  // O mapa foi criado: liga o ponto azul e centra na última posição conhecida
  Future<void> _mapaCriado(mb.MapboxMap mapa) async {
    _mapa = mapa;
    await mapa.location.updateSettings(mb.LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
      puckBearingEnabled: true,
      puckBearing: mb.PuckBearing.COURSE, // seta no sentido do movimento
    ));
    try {
      final ultima = await Geolocator.getLastKnownPosition();
      if (ultima != null) _centrar(ultima, animar: false);
    } catch (_) {
      // Ainda sem permissão: o mapa fica no Porto até começares a viagem
    }
  }

  // Move a câmara para a posição, inclinada e virada no sentido em que vais
  void _centrar(Position p, {bool animar = true}) {
    final camera = mb.CameraOptions(
      center: mb.Point(coordinates: mb.Position(p.longitude, p.latitude)),
      zoom: 16.5,
      pitch: 45,
      bearing: p.speed > 2 ? p.heading : null, // parado, o rumo não é fiável
    );
    if (animar) {
      _mapa?.easeTo(camera, mb.MapAnimationOptions(duration: 900));
    } else {
      _mapa?.setCamera(camera);
    }
  }

  void _alternarSeguir() {
    setState(() => _seguir = !_seguir);
    if (_seguir && _pontos.isNotEmpty) _centrar(_pontos.last);
  }

  // Desenha (da primeira vez) ou atualiza a linha do percurso já feito
  Future<void> _atualizarRasto() async {
    final mapa = _mapa;
    if (mapa == null || _pontos.length < 2) return;

    final rasto = mb.Feature(
      id: 1,
      geometry: mb.LineString(coordinates: [
        for (final p in _pontos) mb.Position(p.longitude, p.latitude),
      ]),
    );

    if (!_rastoCriado) {
      _rastoCriado = true;
      await mapa.addSource(
        mb.GeoJsonSource(id: 'rasto', data: jsonEncode(rasto.toJson())),
      );
      await mapa.addLayer(mb.LineLayer(
        id: 'rasto-linha',
        sourceId: 'rasto',
        lineWidth: 6.0,
        lineCap: mb.LineCap.ROUND,
        lineJoin: mb.LineJoin.ROUND,
        lineEmissiveStrength: 1.0,
        lineColor: const Color(0xFF1E88E5).toARGB32(), // azul
      ));
    } else {
      await mapa.updateGeoJSONSourceFeatures('rasto', 'rasto-dados', [rasto]);
    }
  }

  // Apaga a linha da viagem anterior
  Future<void> _limparRasto() async {
    if (!_rastoCriado) return;
    await _mapa?.removeStyleLayer('rasto-linha');
    await _mapa?.removeStyleSource('rasto');
    _rastoCriado = false;
  }

  // --- Viagem -----------------------------------------------------------

  // 2. Começa a viagem: cronómetro + GPS + ecrã sempre ligado
  Future<void> _iniciar() async {
    if (!await _temPermissaoGps()) return;
    await _limparRasto();

    _pontos.clear();
    _distanciaMetros = 0;
    _velocidadeAtualKmh = 0;
    _inicio = DateTime.now();
    _seguir = true;

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
    if (_seguir) _centrar(p);
    _atualizarRasto();
  }

  // 4. Termina a viagem, guarda-a e pergunta a rota
  Future<void> _parar() async {
    _cronometro.stop();
    _timer?.cancel();
    await _gps?.cancel();
    WakelockPlus.disable();
    setState(() {});

    // TODO: antes de publicar, voltar a ignorar viagens com menos de 2 pontos

    final viagemId = await db.guardarViagem(
      ViagensCompanion.insert(
        inicio: _inicio!,
        fim: DateTime.now(),
        distanciaMetros: _distanciaMetros,
      ),
      _pontos
          .map((p) => PontosCompanion(
                hora: Value(p.timestamp),
                latitude: Value(p.latitude),
                longitude: Value(p.longitude),
                velocidade: Value(p.speed),
                precisao: Value(p.accuracy),
              ))
          .toList(),
    );

    if (!mounted) return;
    final rotaId = await escolherRota(context);
    if (rotaId != null) {
      await db.associarRota(viagemId, rotaId);
      _aviso('Viagem guardada na rota.');
    } else {
      _aviso('Viagem guardada no histórico.');
    }
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
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Nova viagem')),
      body: Column(
        children: [
          // Mapa em cima, com o botão de seguir no canto
          Expanded(
            child: Stack(
              children: [
                mb.MapWidget(
                  key: const ValueKey('mapa-viagem'),
                  styleUri: mb.MapboxStyles.STANDARD,
                  viewport: mb.CameraViewportState(
                    center: mb.Point(coordinates: mb.Position(-8.61, 41.15)),
                    zoom: 12, // Porto, até haver posição
                  ),
                  onMapCreated: _mapaCriado,
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'seguir',
                    tooltip: _seguir ? 'Deixar de seguir' : 'Seguir a minha posição',
                    onPressed: _alternarSeguir,
                    child: Icon(
                      _seguir ? Icons.navigation : Icons.navigation_outlined,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Painel em baixo: tempo, velocidades e botão
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_formatar(_cronometro.elapsed), style: texto.displayMedium),
                  if (_inicio != null) Text('Partida às ${_hora(_inicio!)}'),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 4),
                  Text('${_pontos.length} pontos GPS', style: texto.bodySmall),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _aGravar ? _parar : _iniciar,
                    icon: Icon(_aGravar ? Icons.stop : Icons.play_arrow),
                    label: Text(_aGravar ? 'Terminar viagem' : 'Iniciar viagem'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: _aGravar ? Colors.red : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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