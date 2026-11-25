import 'package:material_ui/material_ui.dart';
import '../database.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  String _data(DateTime t) {
    String d(int n) => n.toString().padLeft(2, '0');
    return '${d(t.day)}/${d(t.month)}/${t.year} · ${d(t.hour)}:${d(t.minute)}';
  }

  String _duracao(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0 ? '$h h $m min' : '$m min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: StreamBuilder<List<Viagem>>(
        stream: db.verViagens(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final viagens = snapshot.data!;
          if (viagens.isEmpty) {
            return const Center(
              child: Text(
                'Ainda não há viagens.\nGrava a primeira no separador Viagem.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            itemCount: viagens.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final v = viagens[index];
              final duracao = v.fim.difference(v.inicio);
              final km = v.distanciaMetros / 1000;
              final horas = duracao.inSeconds / 3600;
              final media = horas == 0 ? 0.0 : km / horas;
              return ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text(
                  v.rotaId == null ? 'Rota sem nome' : 'Rota #${v.rotaId}',
                ),
                subtitle: Text(
                  '${_data(v.inicio)}\n'
                  '${km.toStringAsFixed(2)} km · ${_duracao(duracao)} · '
                  '${media.toStringAsFixed(0)} km/h',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}