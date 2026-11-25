import 'dart:async';
import 'package:material_ui/material_ui.dart';

class ViagemScreen extends StatefulWidget {
  const ViagemScreen({super.key});

  @override
  State<ViagemScreen> createState() => _ViagemScreenState();
}

class _ViagemScreenState extends State<ViagemScreen> {
  final Stopwatch _cronometro = Stopwatch();
  Timer? _timer;

  bool get _aGravar => _cronometro.isRunning;

  void _iniciar() {
    _cronometro
      ..reset()
      ..start();
    // A cada segundo, pede ao Flutter para redesenhar o ecrã
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
    setState(() {});
  }

  void _parar() {
    _cronometro.stop();
    _timer?.cancel();
    setState(() {});
  }

  String _formatar(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel(); // limpa o timer quando o ecrã fecha
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