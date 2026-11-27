import 'dart:math';

import 'database.dart';
import 'sectors.dart' show CorSetor;

// Iguais aos da Fase 5.1, para os tempos ao vivo baterem com os do Histórico
const _margemPortas = 50.0; // portas de partida e chegada (metros)
const _desvioMaximo = 50.0; // mais longe do que isto = fora da rota
const _foraDoSetorMaximo = 0.2; // 20 % dos pontos fora = setor sem tempo

/// Quantos troços da referência se procuram para a frente em cada ponto.
const _janela = 300;

/// Depois de tantos pontos seguidos fora da rota, procura na rota toda
/// (para a frente), para te reencontrar depois de um desvio grande.
const _foraSeguidosParaProcurarTudo = 10;

const _metrosPorGrau = 111320.0;

/// Um ponto simples do mapa.
typedef PontoMapa = ({double lat, double lon});

/// O resultado de um setor acabado de fazer.
class ResultadoSetor {
  const ResultadoSetor({
    required this.numero,
    required this.segundos,
    required this.vsAnterior,
    required this.vsMelhor,
    required this.cor,
  });

  final int numero; // 1, 2, 3...
  final double? segundos; // null = sem tempo (saíste da rota)
  final double? vsAnterior; // negativo = mais rápido
  final double? vsMelhor;
  final CorSetor cor;
}

/// Cronometra os setores de uma volta, ponto a ponto, enquanto conduzes.
class CronometroSetores {
  CronometroSetores({
    required List<Ponto> referencia,
    required List<double> fronteiras,
    Map<int, List<double?>> temposDaRota = const {},
  }) : _ref = [
          for (final p in referencia) (lat: p.latitude, lon: p.longitude),
        ] {
    for (var i = 1; i < _ref.length; i++) {
      _acum.add(_acum.last + _metros(_ref[i - 1], _ref[i]));
    }
    portas = [_margemPortas, ...fronteiras, _acum.last - _margemPortas];
    numeroSetores = portas.length - 1;
    _passagens = List<DateTime?>.filled(portas.length, null);
    _pontosNoSetor = List<int>.filled(numeroSetores, 0);
    _foraNoSetor = List<int>.filled(numeroSetores, 0);
    resultados = List<ResultadoSetor?>.filled(numeroSetores, null);

    // Para comparar: o tempo mais recente e o melhor de cada setor.
    // temposDaRota vem por ordem cronológica, por isso o último é o mais recente.
    _anterior = List<double?>.filled(numeroSetores, null);
    _melhor = List<double?>.filled(numeroSetores, null);
    for (final tempos in temposDaRota.values) {
      for (var k = 0; k < min(numeroSetores, tempos.length); k++) {
        final t = tempos[k];
        if (t == null) continue;
        _anterior[k] = t;
        final melhor = _melhor[k];
        _melhor[k] = melhor == null ? t : min(melhor, t);
      }
    }
  }

  final List<PontoMapa> _ref;
  final List<double> _acum = [0.0]; // distância desde a partida, em cada ponto

  /// Distâncias (m) das portas: partida, fronteiras e chegada.
  late final List<double> portas;
  late final int numeroSetores;

  /// O resultado de cada setor (null = ainda não acabado).
  late final List<ResultadoSetor?> resultados;

  late final List<DateTime?> _passagens; // hora a que passaste cada porta
  late final List<int> _pontosNoSetor;
  late final List<int> _foraNoSetor;
  late final List<double?> _anterior;
  late final List<double?> _melhor;

  int _indice = 1; // troço da referência onde estás
  double? _distancia; // metros desde a partida, ao longo da rota
  DateTime? _hora;
  int _foraSeguidos = 0;

  /// Passaste a porta de chegada.
  bool get terminou => _passagens.last != null;

  /// O último ponto estava a mais de 50 m da rota.
  bool get foraDaRota => _foraSeguidos > 0;

  /// Setor onde estás: 0 = o primeiro; -1 = ainda antes da partida.
  int get setorAtual => _passagens.lastIndexWhere((p) => p != null);

  /// Onde ficam as portas no mapa (para as bolinhas brancas).
  List<PontoMapa> get pontosDasPortas =>
      [for (final d in portas) _pontoNaDistancia(d)];

  /// Recebe um ponto do GPS. Se acabaste um setor, devolve o resultado.
  ResultadoSetor? novoPonto(double lat, double lon, DateTime hora) {
    if (terminou || _ref.length < 2) return null;
    final d = _projetar(lat, lon);

    // Conta os pontos (e os que estão fora) do setor onde estás
    final setor = setorAtual;
    if (setor >= 0 && setor < numeroSetores) {
      _pontosNoSetor[setor]++;
      if (d == null) _foraNoSetor[setor]++;
    }
    if (d == null) {
      _foraSeguidos++;
      return null;
    }
    _foraSeguidos = 0;

    final antes = _distancia;
    final horaAntes = _hora;
    _distancia = d;
    _hora = hora;
    if (antes == null || horaAntes == null) return null;

    // Passaste alguma porta entre o ponto anterior e este?
    ResultadoSetor? fechado;
    for (var j = 0; j < portas.length; j++) {
      if (_passagens[j] != null) continue;
      if (antes < portas[j] && d >= portas[j]) {
        // Hora exata da passagem, entre os dois pontos
        final f = (portas[j] - antes) / (d - antes);
        final micros = hora.difference(horaAntes).inMicroseconds;
        _passagens[j] =
            horaAntes.add(Duration(microseconds: (micros * f).round()));
        if (j > 0) fechado = _fecharSetor(j - 1);
      }
    }
    return fechado;
  }

  ResultadoSetor _fecharSetor(int k) {
    final entrada = _passagens[k];
    final saida = _passagens[k + 1];
    final fora =
        _pontosNoSetor[k] == 0 ? 0.0 : _foraNoSetor[k] / _pontosNoSetor[k];
    double? segundos;
    if (entrada != null && saida != null && fora <= _foraDoSetorMaximo) {
      segundos = saida.difference(entrada).inMilliseconds / 1000;
    }

    final anterior = _anterior[k];
    final melhor = _melhor[k];
    final CorSetor cor;
    if (segundos == null) {
      cor = CorSetor.semTempo;
    } else if (melhor == null) {
      cor = CorSetor.cinzento; // nada para comparar
    } else if (segundos < melhor) {
      cor = CorSetor.roxo;
    } else if (anterior != null && segundos < anterior) {
      cor = CorSetor.verde;
    } else {
      cor = CorSetor.amarelo;
    }

    final resultado = ResultadoSetor(
      numero: k + 1,
      segundos: segundos,
      vsAnterior:
          segundos == null || anterior == null ? null : segundos - anterior,
      vsMelhor: segundos == null || melhor == null ? null : segundos - melhor,
      cor: cor,
    );
    resultados[k] = resultado;
    return resultado;
  }

  /// Metros desde a partida, ao longo da rota, ou null se estiveres fora dela.
  /// Nunca anda para trás.
  double? _projetar(double lat, double lon) {
    final kx = cos(lat * pi / 180) * _metrosPorGrau;
    final n = _ref.length;
    int inicio, fim;
    if (_distancia == null) {
      // Primeiro ponto na rota: o troço mais cedo que esteja perto.
      // (Numa rota em círculo, a partida e a chegada estão no mesmo sítio.)
      var primeiro = -1;
      for (var i = 1; i < n; i++) {
        if (_troco(i, lat, lon, kx).distancia <= _desvioMaximo) {
          primeiro = i;
          break;
        }
      }
      if (primeiro < 0) return null;
      inicio = primeiro;
      fim = min(n, primeiro + _janela);
    } else {
      inicio = max(1, _indice - 2);
      fim = _foraSeguidos >= _foraSeguidosParaProcurarTudo
          ? n
          : min(n, _indice + _janela);
    }

    var melhorDistancia = double.infinity;
    var melhorIndice = -1;
    var melhorT = 0.0;
    for (var i = inicio; i < fim; i++) {
      final r = _troco(i, lat, lon, kx);
      if (r.distancia < melhorDistancia) {
        melhorDistancia = r.distancia;
        melhorIndice = i;
        melhorT = r.t;
      }
    }
    if (melhorDistancia > _desvioMaximo) return null;

    _indice = melhorIndice;
    final d = _acum[melhorIndice - 1] +
        melhorT * (_acum[melhorIndice] - _acum[melhorIndice - 1]);
    final anterior = _distancia;
    return anterior != null && d < anterior ? anterior : d;
  }

  /// Distância (m) do ponto ao troço i da referência, e onde cai nele (0 a 1).
  ({double distancia, double t}) _troco(
      int i, double lat, double lon, double kx) {
    final a = _ref[i - 1];
    final b = _ref[i];
    final ax = (a.lon - lon) * kx, ay = (a.lat - lat) * _metrosPorGrau;
    final bx = (b.lon - lon) * kx, by = (b.lat - lat) * _metrosPorGrau;
    final dx = bx - ax, dy = by - ay;
    final l2 = dx * dx + dy * dy;
    var t = l2 == 0 ? 0.0 : -(ax * dx + ay * dy) / l2;
    if (t < 0) t = 0;
    if (t > 1) t = 1;
    final x = ax + t * dx, y = ay + t * dy;
    return (distancia: sqrt(x * x + y * y), t: t);
  }

  PontoMapa _pontoNaDistancia(double d) {
    for (var i = 1; i < _ref.length; i++) {
      if (_acum[i] >= d) {
        final troco = _acum[i] - _acum[i - 1];
        final t = troco == 0 ? 0.0 : (d - _acum[i - 1]) / troco;
        final a = _ref[i - 1];
        final b = _ref[i];
        return (
          lat: a.lat + (b.lat - a.lat) * t,
          lon: a.lon + (b.lon - a.lon) * t,
        );
      }
    }
    return _ref.last;
  }
}

/// Distância entre dois pontos (fórmula de Haversine), em metros.
double _metros(PontoMapa a, PontoMapa b) {
  const r = 6371000.0;
  final dLat = (b.lat - a.lat) * pi / 180;
  final dLon = (b.lon - a.lon) * pi / 180;
  final h = sin(dLat / 2) * sin(dLat / 2) +
      cos(a.lat * pi / 180) *
          cos(b.lat * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  return 2 * r * asin(sqrt(h));
}