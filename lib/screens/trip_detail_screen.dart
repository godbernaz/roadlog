import 'dart:convert';
import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import '../database.dart';
import '../sectors.dart';

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
  bool _aDesenhar = false;
  bool _marcasDesenhadas = false;
  bool _em3d = false;
  List<Ponto> _pontos = [];

  // Setores (só existem se a viagem pertencer a uma rota)
  bool _temSetores = false;
  bool _modoSetores = false;
  Map<int, List<double?>> _temposDaRota = {};
  List<double?>? _meusTempos;
  List<CorSetor> _cores = [];
  List<int> _setorDoPonto = [];
  List<({double lat, double lon})> _marcas = [];

  @override
  void initState() {
    super.initState();
    _carregarPontos();
  }

  Future<void> _carregarPontos() async {
    final pontos = await db.pontosDaViagem(widget.viagem.id);
    await _carregarSetores(pontos);
    if (!mounted) return;
    setState(() => _pontos = pontos);
    if (pontos.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Esta viagem não tem pontos GPS suficientes.'),
      ));
    }
    await _desenharPercurso();
  }

  // Se a viagem pertence a uma rota, prepara cores, tempos e marcas
  Future<void> _carregarSetores(List<Ponto> pontos) async {
    final rotaId = widget.viagem.rotaId;
    if (rotaId == null || pontos.length < 2) return;

    var setores = await db.setoresDaRota(rotaId);
    if (setores.isEmpty) {
      // Rotas criadas antes da Fase 5: calcula agora
      await db.recalcularSetoresDaRota(rotaId);
      setores = await db.setoresDaRota(rotaId);
    }
    final referenciaId = (await db.rotaPorId(rotaId)).viagemReferenciaId;
    if (setores.isEmpty || referenciaId == null) return;

    final tempos = await db.temposDaRota(rotaId);
    final meus = tempos[widget.viagem.id];
    if (meus == null) return; // esta volta não é desta rota

    final referencia = await db.pontosDaViagem(referenciaId);
    final fronteiras = [for (final s in setores.skip(1)) s.inicioMetros];

    _temposDaRota = tempos;
    _meusTempos = meus;
    _cores = coresDaVolta(widget.viagem.id, tempos);
    _setorDoPonto = setorDeCadaPonto(pontos, referencia, fronteiras);
    _marcas = [for (final f in fronteiras) pontoNaDistancia(referencia, f)];
    _temSetores = true;
    _modoSetores = true; // se há setores, mostra-os primeiro
  }

  void _mapaCriado(MapboxMap mapa) {
    _mapa = mapa;
  }

  Future<void> _estiloCarregado(StyleLoadedEventData data) async {
    _estiloPronto = true;
    await _desenharPercurso();
  }

  // --- Cores -------------------------------------------------------------

  // Velocidade: verde, roxo e amarelo ficam reservados para os setores
  String _corPara(double kmh) {
    if (kmh < 15) return '#E53935'; // vermelho: parado / trânsito
    if (kmh < 40) return '#FB8C00'; // laranja: lento
    return '#1E88E5'; // azul: a andar bem
  }

  String _corDoSetor(int indice) {
    if (indice >= _cores.length) return '#9E9E9E';
    return switch (_cores[indice]) {
      CorSetor.roxo => '#8E24AA',
      CorSetor.verde => '#43A047',
      CorSetor.amarelo => '#FDD835',
      CorSetor.cinzento => '#9E9E9E',
      CorSetor.semTempo => '#424242', // cinzento escuro
    };
  }

  Color _cor(String hex) => Color(int.parse('FF${hex.substring(1)}', radix: 16));

  Map<String, dynamic> _troco(List<List<double>> coords, String cor) {
    return {
      'type': 'Feature',
      'properties': {'cor': cor},
      'geometry': {'type': 'LineString', 'coordinates': coords},
    };
  }

  // Modo Velocidade: um troço novo sempre que a cor da velocidade muda
  Map<String, dynamic> _percursoColorido() {
    final trocos = <Map<String, dynamic>>[];
    var cor = '';
    var coords = <List<double>>[];
    for (var i = 1; i < _pontos.length; i++) {
      final a = _pontos[i - 1];
      final b = _pontos[i];
      final va = a.velocidade < 0 ? 0.0 : a.velocidade;
      final vb = b.velocidade < 0 ? 0.0 : b.velocidade;
      final c = _corPara((va + vb) / 2 * 3.6);
      if (c != cor) {
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

  // Modo Setores: um troço por setor, com a cor do setor
  Map<String, dynamic> _percursoPorSetores() {
    final trocos = <Map<String, dynamic>>[];
    var setor = -1;
    var coords = <List<double>>[];
    for (var i = 0; i < _pontos.length; i++) {
      final ponto = [_pontos[i].longitude, _pontos[i].latitude];
      final s = _setorDoPonto[i];
      if (s != setor) {
        if (coords.isNotEmpty) {
          coords.add(ponto); // fecha o setor anterior aqui, sem buracos
          trocos.add(_troco(coords, _corDoSetor(setor)));
        }
        coords = [ponto];
        setor = s;
      } else {
        coords.add(ponto);
      }
    }
    if (coords.length > 1) trocos.add(_troco(coords, _corDoSetor(setor)));
    return {'type': 'FeatureCollection', 'features': trocos};
  }

  // As fronteiras dos setores, como pontos
  Map<String, dynamic> _pontosFronteira() {
    return {
      'type': 'FeatureCollection',
      'features': [
        for (final m in _marcas)
          {
            'type': 'Feature',
            'properties': <String, dynamic>{},
            'geometry': {
              'type': 'Point',
              'coordinates': [m.lon, m.lat],
            },
          },
      ],
    };
  }

  // --- Desenhar ----------------------------------------------------------

  // Desenha (ou redesenha, ao trocar de modo) a linha e as marcas
  Future<void> _desenharPercurso() async {
    final mapa = _mapa;
    if (mapa == null || !_estiloPronto || _pontos.length < 2 || _aDesenhar) {
      return;
    }
    _aDesenhar = true;
    final primeiraVez = !_desenhado;
    if (_marcasDesenhadas) {
      await mapa.removeStyleLayer('fronteiras-circulos');
      await mapa.removeStyleSource('fronteiras');
      _marcasDesenhadas = false;
    }
    if (_desenhado) {
      await mapa.removeStyleLayer('percurso-linha');
      await mapa.removeStyleLayer('percurso-contorno');
      await mapa.removeStyleSource('percurso');
    }
    _desenhado = true;

    final dados = _modoSetores ? _percursoPorSetores() : _percursoColorido();
    await mapa.addSource(GeoJsonSource(id: 'percurso', data: jsonEncode(dados)));
    await mapa.addLayer(LineLayer(
      id: 'percurso-contorno',
      sourceId: 'percurso',
      lineWidth: 10.0,
      lineCap: LineCap.ROUND,
      lineJoin: LineJoin.ROUND,
      lineEmissiveStrength: 1.0,
      lineColor: Colors.white.toARGB32(),
    ));
    await mapa.addLayer(LineLayer(
      id: 'percurso-linha',
      sourceId: 'percurso',
      lineWidth: 6.0,
      lineCap: LineCap.ROUND,
      lineJoin: LineJoin.ROUND,
      lineEmissiveStrength: 1.0,
      lineColorExpression: ['get', 'cor'],
    ));

    // Bolinhas brancas nas fronteiras (só no modo Setores)
    if (_modoSetores && _marcas.isNotEmpty) {
      await mapa.addSource(GeoJsonSource(
        id: 'fronteiras',
        data: jsonEncode(_pontosFronteira()),
      ));
      await mapa.addLayer(CircleLayer(
        id: 'fronteiras-circulos',
        sourceId: 'fronteiras',
        circleRadius: 6.0,
        circleColor: Colors.white.toARGB32(),
        circleStrokeColor: Colors.black.toARGB32(),
        circleStrokeWidth: 2.0,
        circleEmissiveStrength: 1.0,
      ));
      _marcasDesenhadas = true;
    }

    _aDesenhar = false;
    if (primeiraVez) await _enquadrar();
  }

  void _mudarModo(bool setores) {
    setState(() => _modoSetores = setores);
    _desenharPercurso();
  }

  // --- Câmara ------------------------------------------------------------

  Future<void> _alternar3d() async {
    setState(() => _em3d = !_em3d);
    await _mapa?.flyTo(
      CameraOptions(pitch: _em3d ? 60 : 0),
      MapAnimationOptions(duration: 1000),
    );
  }

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

  // --- Números ------------------------------------------------------------

  double get _velocidadeMaxKmh {
    if (_pontos.isEmpty) return 0;
    final max =
        _pontos.map((p) => p.velocidade).reduce((a, b) => math.max(a, b));
    return max * 3.6;
  }

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

  String _segundos(double s) =>
      _formatar(Duration(milliseconds: (s * 1000).round()));

  String _diferenca(double segundos) {
    final sinal = segundos < 0 ? '−' : '+';
    return '$sinal${segundos.abs().toStringAsFixed(1)} s';
  }

  // --- Ecrã ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _tamanhoMapa = constraints.biggest;
                return Stack(
                  children: [
                    MapWidget(
                      key: const ValueKey('mapa-detalhe'),
                      styleUri: MapboxStyles.STANDARD,
                      viewport: CameraViewportState(
                        center: Point(coordinates: Position(-8.61, 41.15)),
                        zoom: 11,
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
                            icon: Icon(
                                _em3d ? Icons.map_outlined : Icons.view_in_ar),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_temSetores) ...[
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Velocidade'),
                          icon: Icon(Icons.speed),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Setores'),
                          icon: Icon(Icons.flag),
                        ),
                      ],
                      selected: {_modoSetores},
                      onSelectionChanged: (s) => _mudarModo(s.first),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_modoSetores) _tabelaSetores() else _numeros(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Os números gerais da viagem (modo Velocidade)
  Widget _numeros() {
    final v = widget.viagem;
    final duracao = v.fim.difference(v.inicio);
    final km = v.distanciaMetros / 1000;
    final horas = duracao.inSeconds / 3600;
    final media = horas == 0 ? 0.0 : km / horas;
    return Wrap(
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
    );
  }

  // A lista de setores com tempos e diferenças (modo Setores)
  Widget _tabelaSetores() {
    final meus = _meusTempos!;
    return SizedBox(
      height: 220,
      child: ListView.builder(
        itemCount: meus.length,
        itemBuilder: (context, k) {
          final meu = meus[k];
          final c = comparacaoDoSetor(widget.viagem.id, k, _temposDaRota);
          final String detalhe;
          if (meu == null) {
            detalhe = 'Sem tempo: saíste da rota neste setor';
          } else if (c.anterior == null || c.melhor == null) {
            detalhe = 'Primeiro tempo neste setor';
          } else {
            detalhe = 'vs anterior ${_diferenca(meu - c.anterior!)} · '
                'vs melhor ${_diferenca(meu - c.melhor!)}';
          }
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 8,
              backgroundColor: _cor(_corDoSetor(k)),
            ),
            title: Text(
              'Setor ${k + 1} · ${meu == null ? '—' : _segundos(meu)}',
            ),
            subtitle: Text(detalhe),
          );
        },
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