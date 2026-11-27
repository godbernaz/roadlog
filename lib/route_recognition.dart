import 'dart:math';

import 'database.dart';

// --- Regras do reconhecimento ----------------------------------------------

/// A partida e a chegada têm de ficar a menos disto das da rota (metros).
/// É largo de propósito: o carro pode estar estacionado noutro lugar.
const raioDasPontas = 300.0;

/// O comprimento pode ser até 15 % diferente do da rota.
const diferencaDeComprimento = 0.15;

/// Um ponto "está na rota" se estiver a menos disto da linha (metros).
const desvioNaRota = 50.0;

/// Pelo menos 80 % dos pontos analisados têm de estar na rota,
/// nos dois sentidos: a viagem em cima da rota e a rota em cima da viagem.
const coberturaMinima = 0.8;

const _metrosPorGrau = 111320.0;

/// Um ponto simples: só latitude e longitude.
typedef _P = ({double lat, double lon});

_P _p(Ponto p) => (lat: p.latitude, lon: p.longitude);

/// Diz quanto uma viagem se parece com a volta de referência de uma rota.
/// Devolve um número entre 0,8 e 1 (1 = igual), ou null se não for a mesma rota.
double? semelhancaComRota(List<Ponto> viagem, List<Ponto> referencia) {
  if (viagem.length < 2 || referencia.length < 2) return null;
  final linhaViagem = [for (final p in viagem) _p(p)];
  final linhaRef = [for (final p in referencia) _p(p)];

  // 1. Partida e chegada no mesmo sítio
  if (_metros(linhaViagem.first, linhaRef.first) > raioDasPontas) return null;
  if (_metros(linhaViagem.last, linhaRef.last) > raioDasPontas) return null;

  // 2. Comprimento parecido
  final cv = _comprimento(linhaViagem);
  final cr = _comprimento(linhaRef);
  if (cr == 0 || (cv - cr).abs() / cr > diferencaDeComprimento) return null;

  // 3. A viagem em cima da rota (um ponto de 50 em 50 m)...
  final viagemNaRota =
      _cobertura(_amostrar(linhaViagem, 50), _amostrar(linhaRef, 25));

  // 4. ...e sempre para a frente, nunca ao contrário
  if (viagemNaRota.descidas > viagemNaRota.subidas) return null;

  // 5. A rota em cima da viagem (apanha atalhos que saltam partes da rota)
  final rotaNaViagem =
      _cobertura(_amostrar(linhaRef, 50), _amostrar(linhaViagem, 25));

  final nota = min(viagemNaRota.fracao, rotaNaViagem.fracao);
  return nota >= coberturaMinima ? nota : null;
}

/// Procura, entre as tuas rotas, a que mais se parece com esta viagem.
/// Devolve null se nenhuma passar nos testes.
Future<Rota?> reconhecerRota(List<Ponto> viagem) async {
  Rota? melhor;
  var melhorNota = 0.0;
  for (var rota in await db.verRotas().first) {
    // Rotas antigas podem ainda não ter volta de referência
    if (rota.viagemReferenciaId == null) {
      await db.recalcularSetoresDaRota(rota.id);
      rota = await db.rotaPorId(rota.id);
    }
    final referenciaId = rota.viagemReferenciaId;
    if (referenciaId == null) continue;
    final referencia = await db.pontosDaViagem(referenciaId);
    final nota = semelhancaComRota(viagem, referencia);
    if (nota != null && nota > melhorNota) {
      melhor = rota;
      melhorNota = nota;
    }
  }
  return melhor;
}

// --- Contas ------------------------------------------------------------------

/// Que fração das amostras está perto da linha, e quantas vezes
/// a amostra seguinte ficou mais à frente (subidas) ou mais atrás (descidas).
({double fracao, int subidas, int descidas}) _cobertura(
  List<_P> amostras,
  List<_P> linha,
) {
  var naRota = 0, subidas = 0, descidas = 0;
  int? anterior;
  for (final a in amostras) {
    final m = _maisProximo(a, linha);
    if (m.distancia > desvioNaRota) continue;
    naRota++;
    if (anterior != null) {
      if (m.indice > anterior) subidas++;
      if (m.indice < anterior) descidas++;
    }
    anterior = m.indice;
  }
  return (
    fracao: naRota / amostras.length,
    subidas: subidas,
    descidas: descidas,
  );
}

/// O troço da linha mais perto do ponto: a distância (m) e o número do troço.
({double distancia, int indice}) _maisProximo(_P p, List<_P> linha) {
  var melhor = double.infinity;
  var indice = 0;
  final kx = cos(p.lat * pi / 180) * _metrosPorGrau;
  for (var i = 1; i < linha.length; i++) {
    final a = linha[i - 1];
    final b = linha[i];
    // Atalho: troço inteiro a mais de ~220 m para norte ou para sul
    final da = a.lat - p.lat;
    final db2 = b.lat - p.lat;
    if (da.abs() > 0.002 && db2.abs() > 0.002 && (da > 0) == (db2 > 0)) {
      continue;
    }
    // Coordenadas em metros, com o ponto na origem
    final ax = (a.lon - p.lon) * kx, ay = da * _metrosPorGrau;
    final bx = (b.lon - p.lon) * kx, by = db2 * _metrosPorGrau;
    final dx = bx - ax, dy = by - ay;
    final l2 = dx * dx + dy * dy;
    var t = l2 == 0 ? 0.0 : -(ax * dx + ay * dy) / l2;
    if (t < 0) t = 0;
    if (t > 1) t = 1;
    final x = ax + t * dx, y = ay + t * dy;
    final d = sqrt(x * x + y * y);
    if (d < melhor) {
      melhor = d;
      indice = i;
    }
  }
  return (distancia: melhor, indice: indice);
}

/// Pontos espaçados de `passo` em `passo` metros ao longo da linha.
/// Assim, parar num semáforo (muitos pontos no mesmo sítio) não pesa mais.
List<_P> _amostrar(List<_P> linha, double passo) {
  final r = <_P>[linha.first];
  var falta = passo;
  for (var i = 1; i < linha.length; i++) {
    var a = linha[i - 1];
    final b = linha[i];
    var d = _metros(a, b);
    while (d >= falta) {
      final t = falta / d;
      a = (lat: a.lat + (b.lat - a.lat) * t, lon: a.lon + (b.lon - a.lon) * t);
      r.add(a);
      d -= falta;
      falta = passo;
    }
    falta -= d;
  }
  r.add(linha.last);
  return r;
}

double _comprimento(List<_P> linha) {
  var total = 0.0;
  for (var i = 1; i < linha.length; i++) {
    total += _metros(linha[i - 1], linha[i]);
  }
  return total;
}

/// Distância entre dois pontos (fórmula de Haversine), em metros.
double _metros(_P a, _P b) {
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