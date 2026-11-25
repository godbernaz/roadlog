import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart'; // ficheiro gerado automaticamente

@DataClassName('Rota')
class Rotas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
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

@DriftDatabase(tables: [Rotas, Viagens, Pontos])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

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

  // Lista de viagens, a mais recente primeiro; atualiza-se sozinha
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

  Future<int> criarRota(String nome) {
    return into(rotas).insert(RotasCompanion.insert(nome: nome));
  }

  Future<void> associarRota(int viagemId, int rotaId) {
    return (update(viagens)..where((v) => v.id.equals(viagemId)))
        .write(ViagensCompanion(rotaId: Value(rotaId)));
  }

// Apaga primeiro os pontos e depois a viagem (tudo ou nada)
  Future<void> apagarViagem(int viagemId) {
    return transaction(() async {
      await (delete(pontos)..where((p) => p.viagemId.equals(viagemId))).go();
      await (delete(viagens)..where((v) => v.id.equals(viagemId))).go();
    });
  }

  // Todos os pontos GPS de uma viagem, pela ordem em que foram gravados
  Future<List<Ponto>> pontosDaViagem(int viagemId) {
    return (select(pontos)
          ..where((p) => p.viagemId.equals(viagemId))
          ..orderBy([(p) => OrderingTerm.asc(p.hora)]))
        .get();
  }
}   // ← fecha a classe AppDatabase

// Uma única base de dados para toda a app
final db = AppDatabase();