import 'dart:math' as math;
import 'database.dart';

// =====================================================================
// Setores estilo F1: como nascem e como cada volta é medida.
// Tudo aqui é Dart puro: recebe pontos GPS, devolve números.
// =====================================================================

const double tamanhoMinimoSetor = 500; // metros
const double desvioMaximo = 50; // metros fora da linha que ainda contam
const double foraDoSetorMaximo = 0.2; // 20% dos pontos fora = setor sem tempo
const double foraDaRotaMaximo = 0.5; // 50% dos pontos fora = outra rota
const double margemPortas = 50; // portas a 50 m do início e do fim

// ---------- Geometria ------------------------------------------------

const double _raioTerra = 6371000; // metros

/// Distância em metros entre duas coordenadas (fórmula de Haversine).
double distanciaMetros(double lat1, double lon1, double lat2, double lon2) {
  final p1 = lat1 * math.pi / 180;
  final p2 = lat2 * math.pi / 180;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(p1) * math.cos(p2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  return 2 * _raioTerra * math.asin(math.sqrt(a));
}

/// Para cada ponto, a distância percorrida desde o primeiro (metros).
List<double> distanciasAcumuladas(List<Ponto> pontos) {
  final acumulada = <double>[0];
  for (var i = 1; i < pontos.length; i++) {
    final a = pontos[i - 1];
    final b = pontos[i];
    acumulada.add(acumulada.last +
        distanciaMetros(a.latitude, a.longitude, b.latitude, b.longitude));
  }
  return acumulada;
}

/// A coordenada do ponto da linha que está a [d] metros do início.
/// Serve para desenhar as fronteiras dos setores no mapa.
({double lat, double lon}) pontoNaDistancia(List<Ponto> linha, double d) {
  final dist = distanciasAcumuladas(linha);
  for (var i = 1; i < linha.length; i++) {
    if (dist[i] >= d) {
      final a = linha[i - 1];
      final b = linha[i];
      final troco = dist[i] - dist[i - 1];
      final f = troco <= 0 ? 0.0 : (d - dist[i - 1]) / troco;
      return (
        lat: a.latitude + (b.latitude - a.latitude) * f,
        lon: a.longitude + (b.longitude - a.longitude) * f,
      );
    }
  }
  return (lat: linha.last.latitude, lon: linha.last.longitude);
}

// ---------- 1. Quantos setores ---------------------------------------

/// 2,5 × √km, entre 3 e 20, e nunca setores com menos de 500 m.
int numeroDeSetores(double totalMetros) {
  final km = totalMetros / 1000;
  final pelaFormula = math.min(20, math.max(3, (2.5 * math.sqrt(km)).round()));
  final peloTamanho = (totalMetros / tamanhoMinimoSetor).floor();
  return math.max(1, math.min(pelaFormula, peloTamanho));
}

// ---------- 2. Velocidade suavizada ----------------------------------

/// Velocidade em km/h de cada ponto, como média com os 3 vizinhos de cada
/// lado. Tira os "saltos" do GPS sem esconder as travagens a sério.
List<double> velocidadesSuavizadas(List<Ponto> pontos) {
  final kmh = [for (final p in pontos) math.max(0.0, p.velocidade) * 3.6];
  const vizinhos = 3;
  return [
    for (var i = 0; i < kmh.length; i++)
      _media(kmh.sublist(
        math.max(0, i - vizinhos),
        math.min(kmh.length, i + vizinhos + 1),
      )),
  ];
}

double _media(List<double> valores) =>
    valores.reduce((a, b) => a + b) / valores.length;

// ---------- 3. Abrandamentos (os "fins de setor") -------------------

class _Abrandamento {
  _Abrandamento(this.distancia, this.queda);
  final double distancia; // onde (metros desde o início)
  final double queda; // quanto abrandaste (km/h)
}

/// Procura os sítios onde a velocidade cai pelo menos 15 km/h e fica abaixo
/// de 20 km/h: rotundas, semáforos, cruzamentos.
List<_Abrandamento> _abrandamentos(List<double> distancia, List<double> kmh) {
  final encontrados = <_Abrandamento>[];
  for (var i = 1; i < kmh.length - 1; i++) {
    final minimoLocal = kmh[i] <= kmh[i - 1] && kmh[i] <= kmh[i + 1];
    if (!minimoLocal || kmh[i] > 20) continue;

    // A velocidade mais alta nos 300 m antes deste ponto
    var antes = kmh[i];
    for (var j = i - 1; j >= 0 && distancia[i] - distancia[j] <= 300; j--) {
      antes = math.max(antes, kmh[j]);
    }
    final queda = antes - kmh[i];
    if (queda >= 15) encontrados.add(_Abrandamento(distancia[i], queda));
  }
  return encontrados;
}

// ---------- 4. Fronteiras dos setores --------------------------------

/// Onde acaba cada setor (metros desde o início), a partir da volta de
/// referência. Corta primeiro nos abrandamentos mais fortes; só parte
/// ao meio os troços que ficarem demasiado compridos.
List<double> calcularFronteiras(List<Ponto> referencia) {
  if (referencia.length < 2) return [];
  final distancia = distanciasAcumuladas(referencia);
  final total = distancia.last;
  final setores = numeroDeSetores(total);
  final fronteiras = <double>[];
  if (setores <= 1) return fronteiras;

  bool cabe(double d) =>
      d >= tamanhoMinimoSetor &&
      total - d >= tamanhoMinimoSetor &&
      fronteiras.every((f) => (f - d).abs() >= tamanhoMinimoSetor);

  // a) Os abrandamentos mais fortes primeiro
  final candidatos =
      _abrandamentos(distancia, velocidadesSuavizadas(referencia))
        ..sort((a, b) => b.queda.compareTo(a.queda));
  for (final c in candidatos) {
    if (fronteiras.length >= setores - 1) break;
    if (cabe(c.distancia)) fronteiras.add(c.distancia);
  }

  // b) Reserva: parte ao meio só os troços com mais do dobro do tamanho normal
  final alvo = total / setores; // tamanho "normal" de um setor
  while (fronteiras.length < setores - 1) {
    fronteiras.sort();
    final cortes = [0.0, ...fronteiras, total];
    var maior = 0;
    for (var i = 1; i < cortes.length - 1; i++) {
      if (cortes[i + 1] - cortes[i] > cortes[maior + 1] - cortes[maior]) {
        maior = i;
      }
    }
    final comprimento = cortes[maior + 1] - cortes[maior];
    if (comprimento < 2 * alvo) break; // já não há troços demasiado longos
    fronteiras.add(cortes[maior] + comprimento / 2);
  }

  fronteiras.sort();
  return fronteiras;
}

// ---------- 5. Pôr uma volta "em cima" da rota ---------------------

/// Um ponto de uma volta, visto ao longo da rota.
class PontoNaRota {
  PontoNaRota(this.hora, this.distancia, this.desvio);
  final DateTime hora;
  final double distancia; // metros desde o início da rota
  final double desvio; // metros de distância à linha da rota
}

/// Para cada ponto da volta, encontra o sítio mais próximo na linha da
/// volta de referência. Só procura para a frente (uma volta não anda para
/// trás), o que evita saltos quando a rota passa perto de si própria.
List<PontoNaRota> projetarNaRota(List<Ponto> volta, List<Ponto> referencia) {
  final distanciaRef = distanciasAcumuladas(referencia);
  final resultado = <PontoNaRota>[];
  var segmento = 0;
  for (final p in volta) {
    var melhorDesvio = double.infinity;
    var melhorDistancia = 0.0;
    var melhorSegmento = segmento;
    final ultimo = math.min(referencia.length - 1, segmento + 200);
    for (var s = segmento; s < ultimo; s++) {
      final r = _projetarNoSegmento(p, referencia[s], referencia[s + 1]);
      if (r.desvio < melhorDesvio) {
        melhorDesvio = r.desvio;
        melhorDistancia = distanciaRef[s] + r.aoLongo;
        melhorSegmento = s;
      }
    }
    segmento = melhorSegmento;
    resultado.add(PontoNaRota(p.hora, melhorDistancia, melhorDesvio));
  }
  return resultado;
}

/// Projeta o ponto p no segmento a→b, em metros num plano local
/// (suficiente para segmentos curtos como os do GPS).
({double desvio, double aoLongo}) _projetarNoSegmento(
  Ponto p,
  Ponto a,
  Ponto b,
) {
  const metrosPorGrau = _raioTerra * math.pi / 180;
  final escalaLon = metrosPorGrau * math.cos(a.latitude * math.pi / 180);
  final bx = (b.longitude - a.longitude) * escalaLon;
  final by = (b.latitude - a.latitude) * metrosPorGrau;
  final px = (p.longitude - a.longitude) * escalaLon;
  final py = (p.latitude - a.latitude) * metrosPorGrau;
  final comprimento2 = bx * bx + by * by;
  var t = comprimento2 == 0 ? 0.0 : (px * bx + py * by) / comprimento2;
  t = t.clamp(0.0, 1.0);
  final dx = px - t * bx;
  final dy = py - t * by;
  return (
    desvio: math.sqrt(dx * dx + dy * dy),
    aoLongo: t * math.sqrt(comprimento2),
  );
}

// ---------- 6. Tempo de cada setor (NOVO: portas e setores sem tempo) --

/// Tempo (segundos) de cada setor da volta. Um setor fica `null` (sem
/// tempo) se saíste da rota nele ou se não o completaste. A função
/// devolve `null` se a volta inteira foi por outro caminho.
///
/// O tempo é medido entre "portas": a partida fica a 50 m do início e a
/// chegada a 50 m do fim, para não contar o tempo parado no estacionamento
/// nem o momento em que carregas nos botões.
List<double?>? temposDosSetores(
  List<Ponto> volta,
  List<Ponto> referencia,
  List<double> fronteiras,
) {
  if (volta.length < 2 || referencia.length < 2) return null;
  final total = distanciasAcumuladas(referencia).last;
  final proj = projetarNaRota(volta, referencia);

  // Mais de metade dos pontos fora da linha: é outra rota
  final fora = proj.where((p) => p.desvio > desvioMaximo).length;
  if (fora > proj.length * foraDaRotaMaximo) return null;

  final portas = [margemPortas, ...fronteiras, total - margemPortas];
  final passagens = [for (final d in portas) _passagem(proj, d)];

  return [
    for (var k = 0; k < portas.length - 1; k++)
      _tempoDoSetor(proj, portas[k], portas[k + 1], passagens[k],
          passagens[k + 1]),
  ];
}

/// A hora em que a volta passou a distância [d], interpolada entre os
/// dois pontos GPS à volta dela. `null` se nunca lá passou.
DateTime? _passagem(List<PontoNaRota> proj, double d) {
  if (proj.first.distancia > d) return null; // começou depois desta porta
  for (var i = 0; i < proj.length - 1; i++) {
    final a = proj[i];
    final b = proj[i + 1];
    if (a.distancia <= d && b.distancia >= d) {
      final troco = b.distancia - a.distancia;
      final fracao = troco <= 0 ? 0.0 : (d - a.distancia) / troco;
      final ms = b.hora.difference(a.hora).inMilliseconds * fracao;
      return a.hora.add(Duration(milliseconds: ms.round()));
    }
  }
  return null; // não chegou a esta porta
}

/// O tempo de um setor, ou `null` se não conta (saíste da rota ou
/// faltou uma das passagens).
double? _tempoDoSetor(
  List<PontoNaRota> proj,
  double inicio,
  double fim,
  DateTime? entrada,
  DateTime? saida,
) {
  if (entrada == null || saida == null || !saida.isAfter(entrada)) return null;
  final noSetor =
      proj.where((p) => p.distancia >= inicio && p.distancia <= fim).toList();
  if (noSetor.isNotEmpty) {
    final fora = noSetor.where((p) => p.desvio > desvioMaximo).length;
    if (fora > noSetor.length * foraDoSetorMaximo) return null;
  }
  return saida.difference(entrada).inMilliseconds / 1000;
}

// ---------- 7. Comparações e cores (NOVO: ignora setores sem tempo) ---

enum CorSetor { roxo, verde, amarelo, cinzento, semTempo }

/// Com que tempos se compara o setor [k] desta volta: o da última volta
/// anterior que tem tempo nesse setor, e o melhor de todas as anteriores.
({double? anterior, double? melhor}) comparacaoDoSetor(
  int viagemId,
  int k,
  Map<int, List<double?>> temposDaRota,
) {
  final ids = temposDaRota.keys.toList();
  final posicao = ids.indexOf(viagemId);
  if (posicao <= 0) return (anterior: null, melhor: null);
  final validos = [
    for (final id in ids.take(posicao)) temposDaRota[id]![k],
  ].whereType<double>().toList();
  if (validos.isEmpty) return (anterior: null, melhor: null);
  return (
    anterior: validos.last,
    melhor: validos.reduce((a, b) => math.min(a, b)),
  );
}

/// A cor de cada setor desta volta. [temposDaRota] tem as voltas por
/// ordem cronológica.
List<CorSetor> coresDaVolta(
  int viagemId,
  Map<int, List<double?>> temposDaRota,
) {
  final minhas = temposDaRota[viagemId];
  if (minhas == null) return [];
  return [
    for (var k = 0; k < minhas.length; k++)
      _cor(minhas[k], comparacaoDoSetor(viagemId, k, temposDaRota)),
  ];
}

CorSetor _cor(double? meu, ({double? anterior, double? melhor}) c) {
  if (meu == null) return CorSetor.semTempo;
  if (c.anterior == null || c.melhor == null) return CorSetor.cinzento;
  if (meu < c.melhor!) return CorSetor.roxo; // melhor de sempre
  if (meu < c.anterior!) return CorSetor.verde; // melhor que a última
  return CorSetor.amarelo; // mais lento
}

/// Em que setor (0, 1, 2...) está cada ponto de uma volta. Serve para
/// pintar a linha do mapa com a cor de cada setor.
List<int> setorDeCadaPonto(
  List<Ponto> volta,
  List<Ponto> referencia,
  List<double> fronteiras,
) {
  return [
    for (final p in projetarNaRota(volta, referencia))
      fronteiras.where((f) => p.distancia >= f).length,
  ];
}