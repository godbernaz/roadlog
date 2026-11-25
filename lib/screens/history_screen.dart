import 'package:material_ui/material_ui.dart';
import '../database.dart';
import '../widgets/route_dialog.dart';
import 'trip_detail_screen.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  int? _rotaId; // null = todas as rotas
  bool _semRota = false; // true = só viagens sem nome

  String _data(DateTime t) {
    String d(int n) => n.toString().padLeft(2, '0');
    return '${d(t.day)}/${d(t.month)}/${t.year} · ${d(t.hour)}:${d(t.minute)}';
  }

  String _duracao(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0 ? '$h h $m min' : '$m min';
  }

  void _filtrar({int? rotaId, bool semRota = false}) {
    setState(() {
      _rotaId = rotaId;
      _semRota = semRota;
    });
  }

  Future<bool> _confirmarApagar() async {
    final resposta = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar viagem?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    return resposta ?? false;
  }

  // Menu que aparece ao tocar numa viagem
  Future<void> _opcoes(Viagem v) async {
    final escolha = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_road),
              title: const Text('Dar nome / mudar de rota'),
              onTap: () => Navigator.pop(context, 'rota'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Apagar viagem'),
              onTap: () => Navigator.pop(context, 'apagar'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (escolha == 'rota') {
      final rotaId = await escolherRota(context, titulo: 'Escolher rota');
      if (rotaId != null) await db.associarRota(v.id, rotaId);
    } else if (escolha == 'apagar') {
      if (await _confirmarApagar()) await db.apagarViagem(v.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: StreamBuilder<List<Rota>>(
        stream: db.verRotas(),
        builder: (context, snapRotas) {
          final rotas = snapRotas.data ?? [];
          final nomes = {for (final r in rotas) r.id: r.nome};
          return Column(
            children: [
              _filtros(rotas),
              Expanded(child: _lista(nomes)),
            ],
          );
        },
      ),
    );
  }

  // Fila de filtros no topo, com scroll horizontal
  Widget _filtros(List<Rota> rotas) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Todas'),
            selected: _rotaId == null && !_semRota,
            onSelected: (_) => _filtrar(),
          ),
          const SizedBox(width: 8),
          for (final r in rotas) ...[
            ChoiceChip(
              label: Text(r.nome),
              selected: _rotaId == r.id,
              onSelected: (_) => _filtrar(rotaId: r.id),
            ),
            const SizedBox(width: 8),
          ],
          ChoiceChip(
            label: const Text('Sem nome'),
            selected: _semRota,
            onSelected: (_) => _filtrar(semRota: true),
          ),
        ],
      ),
    );
  }

  Widget _lista(Map<int, String> nomes) {
    return StreamBuilder<List<Viagem>>(
      stream: db.verViagens(rotaId: _rotaId, semRota: _semRota),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final viagens = snapshot.data!;
        if (viagens.isEmpty) {
          return const Center(child: Text('Não há viagens para mostrar.'));
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
              title: Text(nomes[v.rotaId] ?? 'Rota sem nome'),
              subtitle: Text(
                '${_data(v.inicio)}\n'
                '${km.toStringAsFixed(2)} km · ${_duracao(duracao)} · '
                '${media.toStringAsFixed(0)} km/h',
              ),
              isThreeLine: true,
                            trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _opcoes(v),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalheViagemScreen(
                    viagem: v,
                    titulo: nomes[v.rotaId] ?? 'Rota sem nome',
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}