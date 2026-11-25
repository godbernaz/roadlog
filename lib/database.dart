import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'sectors.dart';

part 'database.g.dart'; // ficheiro gerado automaticamente

@DataClassName('Rota')
class Rotas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  IntColumn get viagemReferenciaId => integer().nullable()(); // novo (v2)
}

@DataClassName('Viagem')
class Viagens extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get inicio => dateTime()();
  DateTimeColumn get fim => dateTime()();
  RealColumn get distanciaMetros => real()();
  IntColumn get rotaId => integer().nullable().references(Rotas, #id)();
}

@DataClassName('Ponto')
class Pontos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get viagemId => integer().references(Viagens, #id)();
  DateTimeColumn get hora => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get velocidade => real()(); // metros por segundo
  RealColumn get precisao => real()(); // metros
}

// Novo (v2): os setores de cada rota, como distâncias ao longo da rota
@DataClassName('Setor')
class Setores extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rotaId => integer().references(Rotas, #id)();
  IntColumn get ordem => integer()(); // 1, 2, 3...
  RealColumn get inicioMetros => real()();
  RealColumn get fimMetros => real()();
}

// Novo (v2): o tempo de cada volta em cada setor
@DataClassName('TempoSetor')
class TemposSetor extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get viagemId => integer().references(Viagens, #id)();
  IntColumn get ordem => integer()();
  RealColumn get segundos => real()();
}

@DriftDatabase(tables: [Rotas, Viagens, Pontos, Setores, TemposSetor])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2; // era 1

  // Como passar de uma versão para a seguinte sem perder dados
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(rotas, rotas.viagemReferenciaId);
            await m.createTable(setores);
            await m.createTable(temposSetor);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'roadlog',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  // Guarda a viagem e todos os pontos de uma vez (ou tudo, ou nada)
  Future<int> guardarViagem(
    ViagensCompanion viagem,
    List<PontosCompanion> pontosDaViagem,
  ) {
    return transaction(() async {
      final viagemId = await into(viagens).insert(viagem);
      await batch((b) {
        b.insertAll(
          pontos,
          pontosDaViagem
              .map((p) => p.copyWith(viagemId: Value(viagemId)))
              .toList(),
        );
      });
      return viagemId;
    });
  }

  // Lista de viagens, a mais recente primeiro; atualiza-se sozinha.
  // rotaId = só essa rota; semRota = só as viagens sem nome.
  Stream<List<Viagem>> verViagens({int? rotaId, bool semRota = false}) {
    final query = select(viagens)
      ..orderBy([(v) => OrderingTerm.desc(v.inicio)]);
    if (semRota) {
      query.where((v) => v.rotaId.isNull());
    } else if (rotaId != null) {
      query.where((v) => v.rotaId.equals(rotaId));
    }
    return query.watch();
  }

  // Todas as rotas, por ordem alfabética
  Stream<List<Rota>> verRotas() {
    return (select(rotas)..orderBy([(r) => OrderingTerm.asc(r.nome)]))
        .watch();
  }

  Future<Rota> rotaPorId(int rotaId) {
    return (select(rotas)..where((r) => r.id.equals(rotaId))).getSingle();
  }

  Future<int> criarRota(String nome) {
    return into(rotas).insert(RotasCompanion.insert(nome: nome));
  }

  Future<void> associarRota(int viagemId, int rotaId) async {
    final antes = await (select(viagens)..where((v) => v.id.equals(viagemId)))
        .getSingle();
    await (update(viagens)..where((v) => v.id.equals(viagemId)))
        .write(ViagensCompanion(rotaId: Value(rotaId)));
    await recalcularSetoresDaRota(rotaId);
    // Se a viagem saiu de outra rota, essa também muda
    final rotaAntiga = antes.rotaId;
    if (rotaAntiga != null && rotaAntiga != rotaId) {
      await recalcularSetoresDaRota(rotaAntiga);
    }
  }

  // Apaga os tempos, os pontos e a viagem; depois recalcula a rota
  Future<void> apagarViagem(int viagemId) async {
    final viagem = await (select(viagens)..where((v) => v.id.equals(viagemId)))
        .getSingle();
    await transaction(() async {
      await (delete(temposSetor)..where((t) => t.viagemId.equals(viagemId)))
          .go();
      await (delete(pontos)..where((p) => p.viagemId.equals(viagemId))).go();
      await (delete(viagens)..where((v) => v.id.equals(viagemId))).go();
    });
    final rotaId = viagem.rotaId;
    if (rotaId != null) await recalcularSetoresDaRota(rotaId);
  }

  // Todos os pontos GPS de uma viagem, pela ordem em que foram gravados
  Future<List<Ponto>> pontosDaViagem(int viagemId) {
    return (select(pontos)
          ..where((p) => p.viagemId.equals(viagemId))
          ..orderBy([(p) => OrderingTerm.asc(p.hora)]))
        .get();
  }

  // Os setores de uma rota, por ordem
  Future<List<Setor>> setoresDaRota(int rotaId) {
    return (select(setores)
          ..where((s) => s.rotaId.equals(rotaId))
          ..orderBy([(s) => OrderingTerm.asc(s.ordem)]))
        .get();
  }

  // Refaz os setores e os tempos de todas as voltas de uma rota
  Future<void> recalcularSetoresDaRota(int rotaId) async {
    final voltas = await (select(viagens)
          ..where((v) => v.rotaId.equals(rotaId))
          ..orderBy([(v) => OrderingTerm.asc(v.inicio)]))
        .get();

    // Rota sem viagens: limpa tudo
    if (voltas.isEmpty) {
      await (delete(setores)..where((s) => s.rotaId.equals(rotaId))).go();
      await (update(rotas)..where((r) => r.id.equals(rotaId)))
          .write(const RotasCompanion(viagemReferenciaId: Value(null)));
      return;
    }

    // 1. Volta de referência: a da rota, ou a mais antiga
    final rota = await rotaPorId(rotaId);
    var referenciaId = rota.viagemReferenciaId;
    if (referenciaId == null || !voltas.any((v) => v.id == referenciaId)) {
      referenciaId = voltas.first.id;
      await (update(rotas)..where((r) => r.id.equals(rotaId)))
          .write(RotasCompanion(viagemReferenciaId: Value(referenciaId)));
    }
    final referencia = await pontosDaViagem(referenciaId);
    if (referencia.length < 2) return; // referência sem pontos suficientes

    // 2. Setores, a partir da referência
    final fronteiras = calcularFronteiras(referencia);
    final limites = [
      0.0,
      ...fronteiras,
      distanciasAcumuladas(referencia).last,
    ];

    // 3. Tempos de cada volta (calculados antes de escrever)
    final temposPorVolta = <int, List<double>>{};
    for (final v in voltas) {
      final tempos =
          temposDosSetores(await pontosDaViagem(v.id), referencia, fronteiras);
      if (tempos != null) temposPorVolta[v.id] = tempos;
    }

    // Escreve tudo de uma vez (ou tudo, ou nada)
    await transaction(() async {
      await (delete(setores)..where((s) => s.rotaId.equals(rotaId))).go();
      for (var k = 1; k < limites.length; k++) {
        await into(setores).insert(SetoresCompanion.insert(
          rotaId: rotaId,
          ordem: k,
          inicioMetros: limites[k - 1],
          fimMetros: limites[k],
        ));
      }
      await (delete(temposSetor)
            ..where((t) => t.viagemId.isIn(voltas.map((v) => v.id))))
          .go();
      for (final e in temposPorVolta.entries) {
        for (var k = 0; k < e.value.length; k++) {
          await into(temposSetor).insert(TemposSetorCompanion.insert(
            viagemId: e.key,
            ordem: k + 1,
            segundos: e.value[k],
          ));
        }
      }
    });
  }

  // Tempos de todas as voltas de uma rota, por ordem cronológica:
  // viagemId -> [segundos do setor 1, setor 2, ...]
  Future<Map<int, List<double>>> temposDaRota(int rotaId) async {
    final query = select(temposSetor).join([
      innerJoin(viagens, viagens.id.equalsExp(temposSetor.viagemId)),
    ])
      ..where(viagens.rotaId.equals(rotaId))
      ..orderBy([
        OrderingTerm.asc(viagens.inicio),
        OrderingTerm.asc(temposSetor.ordem),
      ]);
    final resultado = <int, List<double>>{};
    for (final linha in await query.get()) {
      final t = linha.readTable(temposSetor);
      resultado.putIfAbsent(t.viagemId, () => []).add(t.segundos);
    }
    return resultado;
  }
}

// Uma única base de dados para toda a app
final db = AppDatabase();