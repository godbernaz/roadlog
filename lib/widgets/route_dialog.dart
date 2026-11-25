import 'package:material_ui/material_ui.dart';
import '../database.dart';

/// Mostra uma janela para escolher uma rota existente ou criar uma nova.
/// Devolve o id da rota, ou null se o utilizador carregar em "Agora não".
Future<int?> escolherRota(
  BuildContext context, {
  String titulo = 'Guardar como rota?',
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _RotaDialog(titulo: titulo),
  );
}

class _RotaDialog extends StatefulWidget {
  const _RotaDialog({required this.titulo});

  final String titulo;

  @override
  State<_RotaDialog> createState() => _RotaDialogState();
}

class _RotaDialogState extends State<_RotaDialog> {
  final _nome = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    final nome = _nome.text.trim();
    if (nome.isEmpty) return;
    final id = await db.criarRota(nome);
    if (mounted) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: StreamBuilder<List<Rota>>(
        stream: db.verRotas(),
        builder: (context, snapshot) {
          final rotas = snapshot.data ?? [];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rotas.isNotEmpty) ...[
                const Text('Rotas guardadas:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in rotas)
                      ActionChip(
                        label: Text(r.nome),
                        onPressed: () => Navigator.pop(context, r.id),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _nome,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nova rota',
                  hintText: 'ex.: Café Jota3',
                ),
                onSubmitted: (_) => _criar(),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Agora não'),
        ),
        FilledButton(
          onPressed: _criar,
          child: const Text('Criar rota'),
        ),
      ],
    );
  }
}