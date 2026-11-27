import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../database.dart';
import '../live_sectors.dart';
import '../route_recognition.dart';
import '../sectors.dart' show CorSetor;
import '../widgets/route_dialog.dart';

class ViagemScreen extends StatefulWidget {
  const ViagemScreen({super.key});

  @override
  State<ViagemScreen> createState() => _ViagemScreenState();
}

class _ViagemScreenState extends State<ViagemScreen> {
  // Gravação
  final _cronometro = Stopwatch();
  Timer? _relogio;
  StreamSubscription<Position>? _gps;
  final List<Position> _pontos = [];
  double _distanciaMetros = 0;
  double _velocidadeAtualKmh = 0;
  DateTime? _inicio;
  bool _aGuardar = false;

  // Mapa
  mb.MapboxMap? _mapa;
  bool _estiloPronto = false;
  bool _rastoCriado = false;
  bool _referenciaDesenhada = false;
  bool _portasDesenhadas = false;
  bool _seguir = true;

  // Rota escolhida antes de sair (null = modo livre)
  Rota? _rota;
  List<Ponto> _referencia = [];
  List<double> _fronteiras = [];
  List<PontoMapa> _portas = [];

  // Setores ao vivo (só durante uma volta com rota)
  CronometroSetores? _setores;
  ResultadoSetor? _ultimoSetor;

  bool get _aGravar => _gps != null;

  @override
  void dispose() {
    _relogio?.cancel();
    _gps?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  // --- Mapa ------------------------------------------------------------------

  Future<void> _mapaCriado(mb.MapboxMap mapa) async {
    _mapa = mapa;
    await mapa.location.updateSettings(mb.LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
      puckBearingEnabled: true,
      puckBearing: mb.PuckBearing.COURSE,
    ));
    final ultima = await Geolocator.getLastKnownPosition();
    if (ultima != null) _centrar(ultima, animar: false);
  }

  Future<void> _estiloCarregado(mb.StyleLoadedEventData data) async {
    _estiloPronto = true;
    await _desenharReferencia();
    await _atualizarRasto();
  }

  void _centrar(Position p, {bool animar = true}) {
    final mapa = _mapa;
    if (mapa == null) return;
    final camera = mb.CameraOptions(
      center: mb.Point(coordinates: mb.Position(p.longitude, p.latitude)),
      zoom: 16.5,
      pitch: 45,
      bearing: p.speed > 2 ? p.heading : null,
    );
    if (animar) {
      mapa.easeTo(camera, mb.MapAnimationOptions(duration: 800));
    } else {
      mapa.setCamera(camera);
    }
  }

  Future<void> _voltarASeguir() async {
    setState(() => _seguir = true);
    final ultima = _pontos.isNotEmpty
        ? _pontos.last
        : await Geolocator.getLastKnownPosition();
    if (ultima != null) _centrar(ultima);
  }

  Map<String, dynamic> _linha(List<List<double>> coords) => {
        'type': 'Feature',
        'id': 1,
        'properties': <String, dynamic>{},
        'geometry': {'type': 'LineString', 'coordinates': coords},
      };

  mb.LineLayer _camadaRasto() => mb.LineLayer(
        id: 'rasto-linha',
        sourceId: 'rasto',
        lineColor: 0xFF1E88E5,
        lineWidth: 6.0,
        lineCap: mb.LineCap.ROUND,
        lineJoin: mb.LineJoin.ROUND,
        lineEmissiveStrength: 1.0,
      );

  mb.CircleLayer _camadaPortas() => mb.CircleLayer(
        id: 'portas-circulos',
        sourceId: 'portas',
        circleRadius: 6.0,
        circleColor: 0xFFFFFFFF,
        circleStrokeColor: 0xFF000000,
        circleStrokeWidth: 2.0,
        circleEmissiveStrength: 1.0,
      );

  // O rasto azul da viagem que estás a fazer
  Future<void> _atualizarRasto() async {
    final mapa = _mapa;
    if (mapa == null || !_estiloPronto || _pontos.length < 2) return;
    if (!_rastoCriado) {
      _rastoCriado = true;
      final dados = _linha([
        for (final p in _pontos) [p.longitude, p.latitude],
      ]);
      await mapa.addSource(
          mb.GeoJsonSource(id: 'rasto', data: jsonEncode(dados)));
      await mapa.addLayer(_camadaRasto());
      // As bolinhas das portas ficam sempre por cima do rasto
      if (_portasDesenhadas) {
        await mapa.removeStyleLayer('portas-circulos');
        await mapa.addLayer(_camadaPortas());
      }
    } else {
      await mapa.updateGeoJSONSourceFeatures('rasto', 'rasto-dados', [
        mb.Feature(
          id: 1,
          geometry: mb.LineString(coordinates: [
            for (final p in _pontos) mb.Position(p.longitude, p.latitude),
          ]),
        ),
      ]);
    }
  }

  Future<void> _limparRasto() async {
    final mapa = _mapa;
    if (mapa == null || !_rastoCriado) return;
    await mapa.removeStyleLayer('rasto-linha');
    await mapa.removeStyleSource('rasto');
    _rastoCriado = false;
  }

  // A volta de referência a cinzento e as portas dos setores
  // As camadas desenham-se pela ordem em que entram no mapa:
  // referência (em baixo), rasto azul, bolinhas das portas (em cima).
  Future<void> _desenharReferencia() async {
    final mapa = _mapa;
    if (mapa == null || !_estiloPronto) return;
    if (_portasDesenhadas) {
      await mapa.removeStyleLayer('portas-circulos');
      await mapa.removeStyleSource('portas');
      _portasDesenhadas = false;
    }
    if (_referenciaDesenhada) {
      await mapa.removeStyleLayer('referencia-linha');
      await mapa.removeStyleSource('referencia');
      _referenciaDesenhada = false;
    }
    if (_referencia.length < 2) return;

    final dados = _linha([
      for (final p in _referencia) [p.longitude, p.latitude],
    ]);
    await mapa.addSource(
        mb.GeoJsonSource(id: 'referencia', data: jsonEncode(dados)));
    await mapa.addLayer(mb.LineLayer(
      id: 'referencia-linha',
      sourceId: 'referencia',
      lineColor: 0xFF9E9E9E,
      lineWidth: 9.0,
      lineOpacity: 0.8,
      lineCap: mb.LineCap.ROUND,
      lineJoin: mb.LineJoin.ROUND,
      lineEmissiveStrength: 1.0,
    ));
    _referenciaDesenhada = true;

    // Se o rasto azul já existia, tira-se e volta a pôr-se, para ficar por cima
    if (_rastoCriado) {
      await mapa.removeStyleLayer('rasto-linha');
      await mapa.addLayer(_camadaRasto());
    }

    if (_portas.isNotEmpty) {
      final portas = {
        'type': 'FeatureCollection',
        'features': [
          for (final p in _portas)
            {
              'type': 'Feature',
              'properties': <String, dynamic>{},
              'geometry': {
                'type': 'Point',
                'coordinates': [p.lon, p.lat],
              },
            },
        ],
      };
      await mapa.addSource(
          mb.GeoJsonSource(id: 'portas', data: jsonEncode(portas)));
      await mapa.addLayer(_camadaPortas());
      _portasDesenhadas = true;
    }
  }

  // --- Escolher a rota antes de sair ------------------------------------------

  Future<void> _escolherRotaAntes() async {
    final rotas = await db.verRotas().first;
    if (!mounted) return;
    final escolha = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.explore),
              title: const Text('Modo livre'),
              subtitle: const Text('No fim, a app tenta reconhecer a rota'),
              selected: _rota == null,
              onTap: () => Navigator.pop(context, 0),
            ),
            const Divider(),
            for (final r in rotas)
              ListTile(
                leading: const Icon(Icons.route),
                title: Text(r.nome),
                selected: r.id == _rota?.id,
                onTap: () => Navigator.pop(context, r.id),
              ),
          ],
        ),
      ),
    );
    if (escolha == null) return; // fechou sem escolher
    await _usarRota(escolha == 0 ? null : escolha);
  }

  // Carrega a rota: referência, setores e portas. null = modo livre.
  Future<void> _usarRota(int? rotaId) async {
    if (rotaId == null) {
      setState(() {
        _rota = null;
        _referencia = [];
        _fronteiras = [];
        _portas = [];
      });
      await _desenharReferencia();
      return;
    }

    var rota = await db.rotaPorId(rotaId);
    // Rotas antigas podem ainda não ter volta de referência nem setores
    if (rota.viagemReferenciaId == null) {
      await db.recalcularSetoresDaRota(rota.id);
      rota = await db.rotaPorId(rota.id);
    }
    final referenciaId = rota.viagemReferenciaId;
    final referencia = referenciaId == null
        ? <Ponto>[]
        : await db.pontosDaViagem(referenciaId);
    var setores = await db.setoresDaRota(rota.id);
    if (setores.isEmpty && referencia.length >= 2) {
      await db.recalcularSetoresDaRota(rota.id);
      setores = await db.setoresDaRota(rota.id);
    }
    final fronteiras = [for (final s in setores.skip(1)) s.inicioMetros];
    final portas = referencia.length < 2
        ? <PontoMapa>[]
        : CronometroSetores(referencia: referencia, fronteiras: fronteiras)
            .pontosDasPortas;

    if (!mounted) return;
    setState(() {
      _rota = rota;
      _referencia = referencia;
      _fronteiras = fronteiras;
      _portas = portas;
    });
    await _desenharReferencia();
  }

  // --- Abrir no Waze ou no Google Maps -----------------------------------------

  Future<void> _escolherNavegacao() async {
    final app = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Carrega primeiro em Iniciar: o Roadlog continua a gravar '
                'por trás enquanto navegas.',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.navigation),
              title: const Text('Abrir no Waze'),
              onTap: () => Navigator.pop(context, 'waze'),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Abrir no Google Maps'),
              onTap: () => Navigator.pop(context, 'google'),
            ),
          ],
        ),
      ),
    );
    if (app == null || _referencia.isEmpty) return;

    // O destino é o fim da volta de referência
    final destino = _referencia.last;
    final lat = destino.latitude;
    final lon = destino.longitude;
    final url = app == 'waze'
        ? Uri.parse('https://waze.com/ul?ll=$lat,$lon&navigate=yes')
        : Uri.parse('https://www.google.com/maps/dir/?api=1'
            '&destination=$lat,$lon&travelmode=driving');
    final abriu = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!abriu) _aviso('Não consegui abrir a navegação.');
  }

  // --- Gravar ------------------------------------------------------------------

  void _aviso(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<bool> _temPermissao() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _aviso('Liga a localização (GPS) do telemóvel.');
      return false;
    }
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      _aviso('Sem permissão de localização não dá para gravar.');
      return false;
    }
    return true;
  }

  Future<void> _iniciar() async {
    if (!await _temPermissao()) return;

    // Com uma rota escolhida, prepara os setores ao vivo com os tempos de agora
    CronometroSetores? setores;
    final rota = _rota;
    if (rota != null && _referencia.length >= 2) {
      setores = CronometroSetores(
        referencia: _referencia,
        fronteiras: _fronteiras,
        temposDaRota: await db.temposDaRota(rota.id),
      );
    }

    await _limparRasto();
    _pontos.clear();
    setState(() {
      _distanciaMetros = 0;
      _velocidadeAtualKmh = 0;
      _inicio = DateTime.now();
      _seguir = true;
      _setores = setores;
      _ultimoSetor = null;
    });
    _cronometro
      ..reset()
      ..start();
    _relogio = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
    _gps = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        // O serviço com notificação que mantém o GPS ligado em segundo plano
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Roadlog a gravar',
          notificationText: 'A viagem continua a ser gravada em segundo plano.',
          enableWakeLock: true,
        ),
      ),
    ).listen(_novoPonto);
    await WakelockPlus.enable();
    setState(() {});
  }

  void _novoPonto(Position p) {
    if (_aGuardar) return; // já está a terminar
    if (p.accuracy > 30) return; // ponto pouco preciso: ignora
    if (_pontos.isNotEmpty) {
      final a = _pontos.last;
      _distanciaMetros += Geolocator.distanceBetween(
          a.latitude, a.longitude, p.latitude, p.longitude);
    }
    _pontos.add(p);

    final setores = _setores;
    final fechado = setores?.novoPonto(p.latitude, p.longitude, p.timestamp);
    setState(() {
      _velocidadeAtualKmh = p.speed < 0 ? 0 : p.speed * 3.6;
      if (fechado != null) _ultimoSetor = fechado;
    });
    if (_seguir) _centrar(p);
    _atualizarRasto();

    // Fim automático: passaste a porta de chegada
    if (setores != null && setores.terminou) _parar(automatico: true);
  }

  Future<void> _parar({bool automatico = false}) async {
    setState(() => _aGuardar = true);
    try {
      _cronometro.stop();
      _relogio?.cancel();
      _relogio = null;
      await _gps?.cancel();
      _gps = null;
      await WakelockPlus.disable();
      if (automatico) _aviso('Chegaste ao fim da rota!');

      // TODO: antes de publicar, voltar a ignorar viagens com menos de 2 pontos
      final viagemId = await db.guardarViagem(
        ViagensCompanion.insert(
          inicio: _inicio ?? DateTime.now(),
          fim: DateTime.now(),
          distanciaMetros: _distanciaMetros,
        ),
        [
          for (final p in _pontos)
            PontosCompanion(
              hora: Value(p.timestamp),
              latitude: Value(p.latitude),
              longitude: Value(p.longitude),
              velocidade: Value(p.speed),
              precisao: Value(p.accuracy),
            ),
        ],
      );
      if (!mounted) return;
      await _guardarNaRota(viagemId);

      // A primeira volta de uma rota passa a ser a referência: carrega-a
      final rota = _rota;
      if (rota != null && _referencia.length < 2) await _usarRota(rota.id);
    } finally {
      if (mounted) {
        setState(() {
          _aGuardar = false;
          _setores = null;
        });
      }
    }
  }

  // Decide em que rota fica a viagem que acabou de ser gravada
  Future<void> _guardarNaRota(int viagemId) async {
    final pontos = await db.pontosDaViagem(viagemId);
    if (!mounted) return;

    // 1. Escolheste a rota antes de sair: confirma que a fizeste mesmo
    final escolhida = _rota;
    if (escolhida != null) {
      final fizeste = _referencia.length < 2 ||
          semelhancaComRota(pontos, _referencia) != null;
      if (fizeste) {
        await db.associarRota(viagemId, escolhida.id);
        _aviso('Volta guardada em "${escolhida.nome}".');
        return;
      }
      final rotaId = await escolherRota(
        context,
        titulo: 'Isto não parece "${escolhida.nome}". Guardar onde?',
      );
      if (rotaId != null) await db.associarRota(viagemId, rotaId);
      return;
    }

    // 2. Modo livre: a app tenta reconhecer a rota
    final sugestao = await reconhecerRota(pontos);
    if (!mounted) return;
    if (sugestao != null) {
      final resposta = await _perguntarSugestao(sugestao);
      if (resposta == true) {
        await db.associarRota(viagemId, sugestao.id);
        _aviso('Volta guardada em "${sugestao.nome}".');
        return;
      }
      if (resposta == null) return; // "Agora não"
      // resposta == false: "Outra rota", segue para o diálogo de sempre
    }

    // 3. Nenhuma rota reconhecida (ou escolheste "Outra rota")
    if (!mounted) return;
    final rotaId = await escolherRota(context);
    if (rotaId != null) await db.associarRota(viagemId, rotaId);
  }

  // true = Sim, false = Outra rota, null = Agora não
  Future<bool?> _perguntarSugestao(Rota rota) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rota reconhecida'),
        content: Text('Isto foi "${rota.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agora não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Outra rota'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  // --- Ecrã ------------------------------------------------------------------

  String _formatar(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String _hora(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // 83,4 s -> "1:23.4"
  String _tempoSetor(double segundos) {
    final decimas = (segundos * 10).round();
    final m = decimas ~/ 600;
    final s = (decimas % 600) / 10;
    return '$m:${s.toStringAsFixed(1).padLeft(4, '0')}';
  }

  String _diferenca(double segundos) {
    final sinal = segundos < 0 ? '−' : '+';
    return '$sinal${segundos.abs().toStringAsFixed(1)} s';
  }

  Color _corDoSetor(CorSetor cor) => switch (cor) {
        CorSetor.roxo => const Color(0xFF8E24AA),
        CorSetor.verde => const Color(0xFF43A047),
        CorSetor.amarelo => const Color(0xFFFDD835),
        CorSetor.cinzento => const Color(0xFF9E9E9E),
        CorSetor.semTempo => const Color(0xFF424242),
      };

  String _textoSetor(ResultadoSetor r) {
    final segundos = r.segundos;
    if (segundos == null) return 'Setor ${r.numero}: sem tempo (saíste da rota)';
    final base = 'Setor ${r.numero}: ${_tempoSetor(segundos)}';
    final anterior = r.vsAnterior;
    return anterior == null
        ? '$base (primeiro tempo)'
        : '$base  ${_diferenca(anterior)} vs anterior';
  }

  Widget _seletorRota() {
    final nome = _rota?.nome ?? 'Modo livre';
    final icone = Icon(_rota == null ? Icons.explore : Icons.route);
    if (_aGravar || _aGuardar) {
      // Durante a viagem só mostra a rota, não deixa trocar
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icone, const SizedBox(width: 8), Text(nome)],
      );
    }
    return OutlinedButton.icon(
      onPressed: _escolherRotaAntes,
      icon: icone,
      label: Text('$nome  ▾'),
    );
  }

  // Uma bolinha por setor e o resultado do último setor acabado
  Widget _painelSetores() {
    final setores = _setores;
    if (setores == null) return const SizedBox.shrink();
    final tema = Theme.of(context);
    final atual = setores.setorAtual;
    final ultimo = _ultimoSetor;
    final estado = setores.foraDaRota
        ? 'Fora da rota'
        : atual < 0
            ? 'A caminho da partida'
            : 'Setor ${atual + 1} de ${setores.numeroSetores}';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var k = 0; k < setores.numeroSetores; k++)
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: setores.resultados[k] == null
                        ? tema.colorScheme.surfaceContainerHighest
                        : _corDoSetor(setores.resultados[k]!.cor),
                    border: k == atual
                        ? Border.all(color: tema.colorScheme.primary, width: 2)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(estado, style: tema.textTheme.labelMedium),
          if (ultimo != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 12, color: _corDoSetor(ultimo.cor)),
                const SizedBox(width: 6),
                Text(_textoSetor(ultimo), style: tema.textTheme.titleSmall),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final tempo = _cronometro.elapsed;
    final km = _distanciaMetros / 1000;
    final horas = tempo.inSeconds / 3600;
    final media = horas == 0 ? 0.0 : km / horas;
    final inicio = _inicio;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Listener(
                  // Arrastar o mapa com o dedo deixa de seguir a tua posição
                  onPointerMove: (_) {
                    if (_seguir) setState(() => _seguir = false);
                  },
                  child: mb.MapWidget(
                    key: const ValueKey('mapa-viagem'),
                    styleUri: mb.MapboxStyles.STANDARD,
                    viewport: mb.CameraViewportState(
                      center:
                          mb.Point(coordinates: mb.Position(-8.61, 41.15)),
                      zoom: 13,
                    ),
                    onMapCreated: _mapaCriado,
                    onStyleLoadedListener: _estiloCarregado,
                  ),
                ),
                if (_referencia.length >= 2)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 12,
                    right: 16,
                    child: FloatingActionButton.small(
                      heroTag: 'navegar',
                      tooltip: 'Abrir no Waze ou no Google Maps',
                      onPressed: _escolherNavegacao,
                      child: const Icon(Icons.navigation),
                    ),
                  ),
                if (!_seguir)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                      heroTag: 'seguir',
                      tooltip: 'Seguir a minha posição',
                      onPressed: _voltarASeguir,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _seletorRota(),
                  _painelSetores(),
                  const SizedBox(height: 8),
                  Text(_formatar(tempo), style: tema.textTheme.displayMedium),
                  Text(
                    inicio == null ? ' ' : 'Partida às ${_hora(inicio)}',
                    style: tema.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Indicador('Distância', '${km.toStringAsFixed(2)} km'),
                      _Indicador('Média', '${media.toStringAsFixed(0)} km/h'),
                      _Indicador('Agora',
                          '${_velocidadeAtualKmh.toStringAsFixed(0)} km/h'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${_pontos.length} pontos GPS',
                      style: tema.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _aGuardar ? null : (_aGravar ? _parar : _iniciar),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            _aGravar ? tema.colorScheme.error : null,
                      ),
                      icon: Icon(_aGravar ? Icons.stop : Icons.play_arrow),
                      label: Text(_aGuardar
                          ? 'A guardar...'
                          : (_aGravar ? 'Terminar' : 'Iniciar')),
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