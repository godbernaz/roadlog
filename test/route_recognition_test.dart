import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:roadlog/database.dart';
import 'package:roadlog/route_recognition.dart';

const _lat0 = 41.15;
const _lon0 = -8.61;
const _metrosPorGrau = 111320.0;

/// Um percurso que passa pelos vértices (x, y) em metros,
/// com um ponto a cada ~10 m e, se quiseres, ruído do GPS.
List<Ponto> percurso(
  List<(num, num)> vertices, {
  double ruido = 0,
  int semente = 1,
}) {
  final aleatorio = Random(semente);
  final pontos = <Ponto>[];
  for (var v = 1; v < vertices.length; v++) {
    final x0 = vertices[v - 1].$1.toDouble(), y0 = vertices[v - 1].$2.toDouble();
    final x1 = vertices[v].$1.toDouble(), y1 = vertices[v].$2.toDouble();
    final comprimento = sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));
    final n = max(1, (comprimento / 10).round());
    for (var k = v == 1 ? 0 : 1; k <= n; k++) {
      final t = k / n;
      final rx = (aleatorio.nextDouble() * 2 - 1) * ruido;
      final ry = (aleatorio.nextDouble() * 2 - 1) * ruido;
      final x = x0 + (x1 - x0) * t + rx;
      final y = y0 + (y1 - y0) * t + ry;
      pontos.add(Ponto(
        id: pontos.length,
        viagemId: 1,
        hora: DateTime(2026, 1, 1).add(Duration(seconds: pontos.length)),
        latitude: _lat0 + y / _metrosPorGrau,
        longitude: _lon0 + x / (_metrosPorGrau * cos(_lat0 * pi / 180)),
        velocidade: 10,
        precisao: 5,
      ));
    }
  }
  return pontos;
}

void main() {
  // A rota: 3 km para leste, depois 2 km para norte
  final rotaEmL = percurso([(0, 0), (3000, 0), (3000, 2000)]);

  test('a mesma rota, com ruído do GPS, é reconhecida', () {
    final viagem =
        percurso([(0, 0), (3000, 0), (3000, 2000)], ruido: 3, semente: 7);
    final nota = semelhancaComRota(viagem, rotaEmL);
    expect(nota, isNotNull);
    expect(nota!, greaterThan(0.95));
  });

  test('partir 150 m antes do sítio habitual ainda conta', () {
    final viagem = percurso([(-150, 0), (3000, 0), (3000, 2000)]);
    expect(semelhancaComRota(viagem, rotaEmL), isNotNull);
  });

  test('o sentido contrário não é a mesma rota', () {
    final viagem = percurso([(3000, 2000), (3000, 0), (0, 0)]);
    expect(semelhancaComRota(viagem, rotaEmL), isNull);
  });

  test('outro caminho entre os mesmos sítios não é a mesma rota', () {
    // Mesma partida, mesma chegada, mesmo comprimento, forma diferente
    final viagem = percurso([(0, 0), (0, 2000), (3000, 2000)]);
    expect(semelhancaComRota(viagem, rotaEmL), isNull);
  });

  test('meia viagem não é a mesma rota', () {
    final viagem = percurso([(0, 0), (1500, 0)]);
    expect(semelhancaComRota(viagem, rotaEmL), isNull);
  });

  test('um pequeno desvio não estraga o reconhecimento', () {
    // Sai 150 m da estrada durante 200 m (por exemplo, uma bomba de gasolina)
    final viagem = percurso([
      (0, 0),
      (1000, 0),
      (1000, 150),
      (1200, 150),
      (1200, 0),
      (3000, 0),
      (3000, 2000),
    ]);
    expect(semelhancaComRota(viagem, rotaEmL), isNotNull);
  });

  test('numa rota em círculo, dar a volta ao contrário não conta', () {
    final circuito =
        percurso([(0, 0), (1000, 0), (1000, 1000), (0, 1000), (0, 0)]);
    final igual = percurso(
      [(0, 0), (1000, 0), (1000, 1000), (0, 1000), (0, 0)],
      ruido: 3,
    );
    final aoContrario =
        percurso([(0, 0), (0, 1000), (1000, 1000), (1000, 0), (0, 0)]);
    expect(semelhancaComRota(igual, circuito), isNotNull);
    expect(semelhancaComRota(aoContrario, circuito), isNull);
  });
}