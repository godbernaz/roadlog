import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:roadlog/database.dart';
import 'package:roadlog/sectors.dart';

// ---------- Gerador de voltas inventadas -----------------------------
// Uma estrada reta de 10 km para leste, no Porto, com 3 "rotundas"
// (aos 2 000, 4 500 e 7 000 m) onde se abranda para 5 km/h.

const _lat0 = 41.15;
const _lon0 = -8.61;
const _rotundas = [2000.0, 4500.0, 7000.0];

double _velocidadeBase(double d) {
  for (final r in _rotundas) {
    if ((d - r).abs() < 40) return 5; // a passar a rotunda
    if ((d - r).abs() < 200) return 25; // a travar ou a acelerar
  }
  return 50;
}

List<Ponto> gerarVolta({
  double comprimento = 10000,
  double rapidez = 1.0, // 1.1 = 10% mais rápido
  double ruido = 0, // metros de erro lateral do GPS
  double desvioNorte = 0, // metros: desloca a estrada toda
  double paradoNoInicio = 0, // segundos parado antes de arrancar
  (double, double)? desvioEntre, // troço (metros) feito por outra rua
  int semente = 42,
}) {
  final aleatorio = math.Random(semente);
  const metrosPorGrauLat = 111320.0;
  final metrosPorGrauLon = metrosPorGrauLat * math.cos(_lat0 * math.pi / 180);
  final pontos = <Ponto>[];
  var hora = DateTime(2026, 11, 27, 8, 0);
  var id = 0;

  void juntar(double d, double kmh) {
    var norte = desvioNorte + (aleatorio.nextDouble() * 2 - 1) * ruido;
    if (desvioEntre != null && d > desvioEntre.$1 && d < desvioEntre.$2) {
      norte += 300; // por outra rua, 300 m ao lado
    }
    pontos.add(Ponto(
      id: id++,
      viagemId: 1,
      hora: hora,
      latitude: _lat0 + norte / metrosPorGrauLat,
      longitude: _lon0 + d / metrosPorGrauLon,
      velocidade: kmh / 3.6,
      precisao: 5,
    ));
  }

  juntar(0, 0); // carregaste em Iniciar aqui
  hora = hora.add(Duration(milliseconds: (paradoNoInicio * 1000).round()));
  for (var d = 10.0; d <= comprimento; d += 10) {
    final kmh = _velocidadeBase(d) * rapidez;
    hora = hora.add(Duration(milliseconds: (10 / (kmh / 3.6) * 1000).round()));
    juntar(d, kmh);
  }
  return pontos;
}

// ---------- Os testes ------------------------------------------------

void main() {
  group('Quantos setores', () {
    test('cresce com a distância, entre 3 e 20', () {
      expect(numeroDeSetores(2000), 4);
      expect(numeroDeSetores(18000), 11);
      expect(numeroDeSetores(120000), 20);
    });
    test('nunca setores com menos de 500 m', () {
      expect(numeroDeSetores(1000), 2);
    });
  });

  group('Fronteiras', () {
    test('cortam nas rotundas', () {
      final fronteiras = calcularFronteiras(gerarVolta());
      for (final r in _rotundas) {
        expect(fronteiras.any((f) => (f - r).abs() < 100), isTrue,
            reason: 'falta um corte perto dos $r m');
      }
    });
    test('nenhum setor com menos de 500 m', () {
      final cortes = [0.0, ...calcularFronteiras(gerarVolta()), 10000.0];
      for (var k = 1; k < cortes.length; k++) {
        expect(cortes[k] - cortes[k - 1], greaterThanOrEqualTo(500));
      }
    });
  });

  group('Tempos dos setores', () {
    final referencia = gerarVolta();
    final fronteiras = calcularFronteiras(referencia);
    final tempoRef = temposDosSetores(referencia, referencia, fronteiras)!;

    test('volta 10% mais rápida, com ruído de 10 m', () {
      final volta = gerarVolta(rapidez: 1.1, ruido: 10, semente: 7);
      final tempos = temposDosSetores(volta, referencia, fronteiras)!;
      for (var k = 0; k < tempos.length; k++) {
        expect(tempos[k], closeTo(tempoRef[k]! / 1.1, tempoRef[k]! * 0.05));
      }
    });

    test('o tempo parado antes de arrancar não conta', () {
      final volta = gerarVolta(paradoNoInicio: 120);
      final tempos = temposDosSetores(volta, referencia, fronteiras)!;
      expect(tempos.first, closeTo(tempoRef.first!, 2));
    });

    test('outra estrada, 300 m ao lado, não conta', () {
      final volta = gerarVolta(desvioNorte: 300);
      expect(temposDosSetores(volta, referencia, fronteiras), isNull);
    });

    test('um desvio só anula o setor onde aconteceu', () {
      final volta = gerarVolta(desvioEntre: (5000, 5600));
      final tempos = temposDosSetores(volta, referencia, fronteiras)!;
      final setorDoDesvio = fronteiras.where((f) => f <= 5300).length;
      expect(tempos[setorDoDesvio], isNull);
      expect(tempos.where((t) => t != null).length, tempos.length - 1);
    });
  });

  group('Cores', () {
    final tempos = <int, List<double?>>{
      1: [60, 60],
      2: [50, 70],
      3: [55, 65],
      4: [null, 59],
    };

    test('primeira volta fica cinzenta', () {
      expect(coresDaVolta(1, tempos), [CorSetor.cinzento, CorSetor.cinzento]);
    });
    test('roxo, verde, amarelo e sem tempo', () {
      expect(coresDaVolta(2, tempos), [CorSetor.roxo, CorSetor.amarelo]);
      expect(coresDaVolta(3, tempos), [CorSetor.amarelo, CorSetor.verde]);
      expect(coresDaVolta(4, tempos), [CorSetor.semTempo, CorSetor.roxo]);
    });
  });
}