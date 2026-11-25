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
  Stream<List<Viagem>> verViagens() {
    return (select(viagens)
          ..orderBy([(v) => OrderingTerm.desc(v.inicio)]))
        .watch();
  }
}

// Uma única base de dados para toda a app
final db = AppDatabase();