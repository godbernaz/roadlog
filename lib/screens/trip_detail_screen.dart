import 'dart:convert';
import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import '../database.dart';

class DetalheViagemScreen extends StatefulWidget {
  const DetalheViagemScreen({
    super.key,
    required this.viagem,
    required this.titulo,
  });

  final Viagem viagem;
  final String titulo;

  @override
  State<DetalheViagemScreen> createState() => _DetalheViagemScreenState();
}

class _DetalheViagemScreenState extends State<DetalheViagemScreen> {
  MapboxMap? _mapa;
  Size _tamanhoMapa = Size.zero;
  bool _estiloPronto = false;
  bool _desenhado = false;
  bool _em3d = false;
  List<Ponto> _pontos = [];
  
  // Inclina ou endireita a câmara, com animação
  Future<void> _alternar3d() async {
    setState(() => _em3d = !_em3d);
    await _mapa?.flyTo(
      CameraOptions(pitch: _em3d ? 60 : 0),
      MapAnimationOptions(duration: 1000),
    );
  }

    // Cor de cada troço consoante a velocidade (km/h)
  String _corPara(double kmh) {
    if (kmh < 15) return '#E53935'; // vermelho: parado / trânsito
    if (kmh < 40) return '#FB8C00'; // laranja: lento
    return '#43A047'; // verde: a andar bem
  }

  Map<String, dynamic> _troco(List<List<double>> coords, String cor) {
    return {
      'type': 'Feature',
      'properties': {'cor': cor},
      'geometry': {'type': 'LineString', 'coordinates': coords},
    };
  }

  // Parte o percurso em troços, cada um com a sua cor
  Map<String, dynamic> _percursoColorido() {
    final trocos = <Map<String, dynamic>>[];
    var cor = '';
    var coords = <List<double>>[];

    for (var i = 1; i < _pontos.length; i++) {
      final a = _pontos[i - 1];
      final b = _pontos[i];
      final va = a.velocidade < 0 ? 0.0 : a.velocidade; // -1 = desconhecida
      final vb = b.velocidade < 0 ? 0.0 : b.velocidade;
      final c = _corPara((va + vb) / 2 * 3.6);

      if (c != cor) {
        // A cor mudou: fecha o troço anterior e começa outro em "a"
        if (coords.length > 1) trocos.add(_troco(coords, cor));
        coords = [
          [a.longitude, a.latitude],
        ];
        cor = c;
      }
      coords.add([b.longitude, b.latitude]);
    }
    if (coords.length > 1) trocos.add(_troco(coords, cor));

    return {'type': 'FeatureCollection', 'features': trocos};
  }

  @override
  void initState() {
    super.initState();
    _carregarPontos();
  }

  Future<void> _carregarPontos() async {
    final pontos = await db.pontosDaViagem(widget.viagem.id);
    if (!mounted) return;
    setState(() => _pontos = pontos);
    if (pontos.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Esta viagem não tem pontos GPS suficientes.'),
      ));
    }
    await _desenharPercurso();
  }

  void _mapaCriado(MapboxMap mapa) {
    _mapa = mapa;
  }

  Future<void> _estiloCarregado(StyleLoadedEventData data) async {
    _estiloPronto = true;
    await _desenharPercurso();
  }

  // Só desenha quando o mapa, o estilo e os pontos estiverem todos prontos.
  Future<void> _desenharPercurso() async {
    final mapa = _mapa;
    if (mapa == null || !_estiloPronto || _pontos.length < 2 || _desenhado) {
      return;
    }
    _desenhado = true;

    await mapa.style.addSource(
      GeoJsonSource(id: 'percurso', data: jsonEncode(_percursoColorido())),
    );

    // 1. Contorno branco, mais largo, por baixo
    await mapa.style.addLayer(LineLayer(
      id: 'percurso-contorno',
      sourceId: 'percurso',
      lineWidth: 10.0,
      lineCap: LineCap.ROUND,
      lineJoin: LineJoin.ROUND,
      lineEmissiveStrength: 1.0,
      lineColor: Colors.white.toARGB32(),
    ));

    // 2. A linha colorida por cima: cada troço usa a sua propriedade "cor"
    await mapa.style.addLayer(LineLayer(
      id: 'percurso-linha',
      sourceId: 'percurso',
      lineWidth: 6.0,
      lineCap: LineCap.ROUND,
      lineJoin: LineJoin.ROUND,
      lineEmissiveStrength: 1.0,
      lineColorExpression: ['get', 'cor'],
    ));

    await _enquadrar();
  }

  // Move a câmara para mostrar o percurso inteiro
  Future<void> _enquadrar() async {
    final mapa = _mapa;
    if (mapa == null || _pontos.isEmpty) return;
    final camera = await mapa.cameraForCoordinatesCameraOptions(
      [
        for (final p in _pontos)
          Point(coordinates: Position(p.longitude, p.latitude)),
      ],
      CameraOptions(pitch: _em3d ? 60 : 0, bearing: 0),
      ScreenBox(
        min: ScreenCoordinate(x: 32, y: 32),
        max: ScreenCoordinate(
          x: _tamanhoMapa.width - 32,
          y: _tamanhoMapa.height - 32,
        ),
      ),
    );
    await mapa.flyTo(camera, MapAnimationOptions(duration: 1200));
  }

  double get _velocidadeMaxKmh {
    if (_pontos.isEmpty) return 0;
    final max = _pontos.map((p) => p.velocidade).reduce((a, b) => math.max(a, b));
    return max * 3.6;
  }

  // Soma o tempo dos troços feitos a menos de 15 km/h
  Duration get _tempoLento {
    var segundos = 0;
    for (var i = 1; i < _pontos.length; i++) {
      final a = _pontos[i - 1];
      final b = _pontos[i];
      final kmh = (a.velocidade + b.velocidade) / 2 * 3.6;
      if (kmh < 15) segundos += b.hora.difference(a.hora).inSeconds;
    }
    return Duration(seconds: segundos);
  }

  String _formatar(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.viagem;
    final duracao = v.fim.difference(v.inicio);
    final km = v.distanciaMetros / 1000;
    final horas = duracao.inSeconds / 3600;
    final media = horas == 0 ? 0.0 : km / horas;

    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _tamanhoMapa = constraints.biggest; // usado no _enquadrar
                return Stack(
                  children: [
                    MapWidget(
                      key: const ValueKey('mapa-detalhe'),
                      styleUri: MapboxStyles.STANDARD,
                      viewport: CameraViewportState(
                        center: Point(coordinates: Position(-8.61, 41.15)),
                        zoom: 11, // Porto, só até o percurso carregar
                      ),
                      onMapCreated: _mapaCriado,
                      onStyleLoadedListener: _estiloCarregado,
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'enquadrar',
                            tooltip: 'Ver o percurso inteiro',
                            onPressed: _enquadrar,
                            child: const Icon(Icons.center_focus_strong),
                          ),
                          const SizedBox(height: 12),
                          FloatingActionButton.extended(
                            heroTag: 'vista-3d',
                            onPressed: _alternar3d,
                            icon: Icon(_em3d ? Icons.map_outlined : Icons.view_in_ar),
                            label: Text(_em3d ? '2D' : '3D'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 24,
                runSpacing: 12,
                children: [
                  _Dado('Duração', _formatar(duracao)),
                  _Dado('Distância', '${km.toStringAsFixed(2)} km'),
                  _Dado('Média', '${media.toStringAsFixed(0)} km/h'),
                  _Dado('Máxima', '${_velocidadeMaxKmh.toStringAsFixed(0)} km/h'),
                  _Dado('Em lentidão', _formatar(_tempoLento)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dado extends StatelessWidget {
  const _Dado(this.titulo, this.valor);

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.labelMedium),
        Text(valor, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}