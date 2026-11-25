// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RotasTable extends Rotas with TableInfo<$RotasTable, Rota> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RotasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viagemReferenciaIdMeta =
      const VerificationMeta('viagemReferenciaId');
  @override
  late final GeneratedColumn<int> viagemReferenciaId = GeneratedColumn<int>(
    'viagem_referencia_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nome, viagemReferenciaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rotas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Rota> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('viagem_referencia_id')) {
      context.handle(
        _viagemReferenciaIdMeta,
        viagemReferenciaId.isAcceptableOrUnknown(
          data['viagem_referencia_id']!,
          _viagemReferenciaIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rota map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rota(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      viagemReferenciaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}viagem_referencia_id'],
      ),
    );
  }

  @override
  $RotasTable createAlias(String alias) {
    return $RotasTable(attachedDatabase, alias);
  }
}

class Rota extends DataClass implements Insertable<Rota> {
  final int id;
  final String nome;
  final int? viagemReferenciaId;
  const Rota({required this.id, required this.nome, this.viagemReferenciaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || viagemReferenciaId != null) {
      map['viagem_referencia_id'] = Variable<int>(viagemReferenciaId);
    }
    return map;
  }

  RotasCompanion toCompanion(bool nullToAbsent) {
    return RotasCompanion(
      id: Value(id),
      nome: Value(nome),
      viagemReferenciaId: viagemReferenciaId == null && nullToAbsent
          ? const Value.absent()
          : Value(viagemReferenciaId),
    );
  }

  factory Rota.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rota(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      viagemReferenciaId: serializer.fromJson<int?>(json['viagemReferenciaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'viagemReferenciaId': serializer.toJson<int?>(viagemReferenciaId),
    };
  }

  Rota copyWith({
    int? id,
    String? nome,
    Value<int?> viagemReferenciaId = const Value.absent(),
  }) => Rota(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    viagemReferenciaId: viagemReferenciaId.present
        ? viagemReferenciaId.value
        : this.viagemReferenciaId,
  );
  Rota copyWithCompanion(RotasCompanion data) {
    return Rota(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      viagemReferenciaId: data.viagemReferenciaId.present
          ? data.viagemReferenciaId.value
          : this.viagemReferenciaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rota(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('viagemReferenciaId: $viagemReferenciaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, viagemReferenciaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rota &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.viagemReferenciaId == this.viagemReferenciaId);
}

class RotasCompanion extends UpdateCompanion<Rota> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int?> viagemReferenciaId;
  const RotasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.viagemReferenciaId = const Value.absent(),
  });
  RotasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    this.viagemReferenciaId = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<Rota> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? viagemReferenciaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (viagemReferenciaId != null)
        'viagem_referencia_id': viagemReferenciaId,
    });
  }

  RotasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<int?>? viagemReferenciaId,
  }) {
    return RotasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      viagemReferenciaId: viagemReferenciaId ?? this.viagemReferenciaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (viagemReferenciaId.present) {
      map['viagem_referencia_id'] = Variable<int>(viagemReferenciaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RotasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('viagemReferenciaId: $viagemReferenciaId')
          ..write(')'))
        .toString();
  }
}

class $ViagensTable extends Viagens with TableInfo<$ViagensTable, Viagem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ViagensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<DateTime> inicio = GeneratedColumn<DateTime>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fimMeta = const VerificationMeta('fim');
  @override
  late final GeneratedColumn<DateTime> fim = GeneratedColumn<DateTime>(
    'fim',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanciaMetrosMeta = const VerificationMeta(
    'distanciaMetros',
  );
  @override
  late final GeneratedColumn<double> distanciaMetros = GeneratedColumn<double>(
    'distancia_metros',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rotaIdMeta = const VerificationMeta('rotaId');
  @override
  late final GeneratedColumn<int> rotaId = GeneratedColumn<int>(
    'rota_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rotas (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    inicio,
    fim,
    distanciaMetros,
    rotaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'viagens';
  @override
  VerificationContext validateIntegrity(
    Insertable<Viagem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    } else if (isInserting) {
      context.missing(_inicioMeta);
    }
    if (data.containsKey('fim')) {
      context.handle(
        _fimMeta,
        fim.isAcceptableOrUnknown(data['fim']!, _fimMeta),
      );
    } else if (isInserting) {
      context.missing(_fimMeta);
    }
    if (data.containsKey('distancia_metros')) {
      context.handle(
        _distanciaMetrosMeta,
        distanciaMetros.isAcceptableOrUnknown(
          data['distancia_metros']!,
          _distanciaMetrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanciaMetrosMeta);
    }
    if (data.containsKey('rota_id')) {
      context.handle(
        _rotaIdMeta,
        rotaId.isAcceptableOrUnknown(data['rota_id']!, _rotaIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Viagem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Viagem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio'],
      )!,
      fim: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fim'],
      )!,
      distanciaMetros: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distancia_metros'],
      )!,
      rotaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rota_id'],
      ),
    );
  }

  @override
  $ViagensTable createAlias(String alias) {
    return $ViagensTable(attachedDatabase, alias);
  }
}

class Viagem extends DataClass implements Insertable<Viagem> {
  final int id;
  final DateTime inicio;
  final DateTime fim;
  final double distanciaMetros;
  final int? rotaId;
  const Viagem({
    required this.id,
    required this.inicio,
    required this.fim,
    required this.distanciaMetros,
    this.rotaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['inicio'] = Variable<DateTime>(inicio);
    map['fim'] = Variable<DateTime>(fim);
    map['distancia_metros'] = Variable<double>(distanciaMetros);
    if (!nullToAbsent || rotaId != null) {
      map['rota_id'] = Variable<int>(rotaId);
    }
    return map;
  }

  ViagensCompanion toCompanion(bool nullToAbsent) {
    return ViagensCompanion(
      id: Value(id),
      inicio: Value(inicio),
      fim: Value(fim),
      distanciaMetros: Value(distanciaMetros),
      rotaId: rotaId == null && nullToAbsent
          ? const Value.absent()
          : Value(rotaId),
    );
  }

  factory Viagem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Viagem(
      id: serializer.fromJson<int>(json['id']),
      inicio: serializer.fromJson<DateTime>(json['inicio']),
      fim: serializer.fromJson<DateTime>(json['fim']),
      distanciaMetros: serializer.fromJson<double>(json['distanciaMetros']),
      rotaId: serializer.fromJson<int?>(json['rotaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'inicio': serializer.toJson<DateTime>(inicio),
      'fim': serializer.toJson<DateTime>(fim),
      'distanciaMetros': serializer.toJson<double>(distanciaMetros),
      'rotaId': serializer.toJson<int?>(rotaId),
    };
  }

  Viagem copyWith({
    int? id,
    DateTime? inicio,
    DateTime? fim,
    double? distanciaMetros,
    Value<int?> rotaId = const Value.absent(),
  }) => Viagem(
    id: id ?? this.id,
    inicio: inicio ?? this.inicio,
    fim: fim ?? this.fim,
    distanciaMetros: distanciaMetros ?? this.distanciaMetros,
    rotaId: rotaId.present ? rotaId.value : this.rotaId,
  );
  Viagem copyWithCompanion(ViagensCompanion data) {
    return Viagem(
      id: data.id.present ? data.id.value : this.id,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      fim: data.fim.present ? data.fim.value : this.fim,
      distanciaMetros: data.distanciaMetros.present
          ? data.distanciaMetros.value
          : this.distanciaMetros,
      rotaId: data.rotaId.present ? data.rotaId.value : this.rotaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Viagem(')
          ..write('id: $id, ')
          ..write('inicio: $inicio, ')
          ..write('fim: $fim, ')
          ..write('distanciaMetros: $distanciaMetros, ')
          ..write('rotaId: $rotaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, inicio, fim, distanciaMetros, rotaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Viagem &&
          other.id == this.id &&
          other.inicio == this.inicio &&
          other.fim == this.fim &&
          other.distanciaMetros == this.distanciaMetros &&
          other.rotaId == this.rotaId);
}

class ViagensCompanion extends UpdateCompanion<Viagem> {
  final Value<int> id;
  final Value<DateTime> inicio;
  final Value<DateTime> fim;
  final Value<double> distanciaMetros;
  final Value<int?> rotaId;
  const ViagensCompanion({
    this.id = const Value.absent(),
    this.inicio = const Value.absent(),
    this.fim = const Value.absent(),
    this.distanciaMetros = const Value.absent(),
    this.rotaId = const Value.absent(),
  });
  ViagensCompanion.insert({
    this.id = const Value.absent(),
    required DateTime inicio,
    required DateTime fim,
    required double distanciaMetros,
    this.rotaId = const Value.absent(),
  }) : inicio = Value(inicio),
       fim = Value(fim),
       distanciaMetros = Value(distanciaMetros);
  static Insertable<Viagem> custom({
    Expression<int>? id,
    Expression<DateTime>? inicio,
    Expression<DateTime>? fim,
    Expression<double>? distanciaMetros,
    Expression<int>? rotaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inicio != null) 'inicio': inicio,
      if (fim != null) 'fim': fim,
      if (distanciaMetros != null) 'distancia_metros': distanciaMetros,
      if (rotaId != null) 'rota_id': rotaId,
    });
  }

  ViagensCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? inicio,
    Value<DateTime>? fim,
    Value<double>? distanciaMetros,
    Value<int?>? rotaId,
  }) {
    return ViagensCompanion(
      id: id ?? this.id,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
      distanciaMetros: distanciaMetros ?? this.distanciaMetros,
      rotaId: rotaId ?? this.rotaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<DateTime>(inicio.value);
    }
    if (fim.present) {
      map['fim'] = Variable<DateTime>(fim.value);
    }
    if (distanciaMetros.present) {
      map['distancia_metros'] = Variable<double>(distanciaMetros.value);
    }
    if (rotaId.present) {
      map['rota_id'] = Variable<int>(rotaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ViagensCompanion(')
          ..write('id: $id, ')
          ..write('inicio: $inicio, ')
          ..write('fim: $fim, ')
          ..write('distanciaMetros: $distanciaMetros, ')
          ..write('rotaId: $rotaId')
          ..write(')'))
        .toString();
  }
}

class $PontosTable extends Pontos with TableInfo<$PontosTable, Ponto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PontosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _viagemIdMeta = const VerificationMeta(
    'viagemId',
  );
  @override
  late final GeneratedColumn<int> viagemId = GeneratedColumn<int>(
    'viagem_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES viagens (id)',
    ),
  );
  static const VerificationMeta _horaMeta = const VerificationMeta('hora');
  @override
  late final GeneratedColumn<DateTime> hora = GeneratedColumn<DateTime>(
    'hora',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _velocidadeMeta = const VerificationMeta(
    'velocidade',
  );
  @override
  late final GeneratedColumn<double> velocidade = GeneratedColumn<double>(
    'velocidade',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precisaoMeta = const VerificationMeta(
    'precisao',
  );
  @override
  late final GeneratedColumn<double> precisao = GeneratedColumn<double>(
    'precisao',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    viagemId,
    hora,
    latitude,
    longitude,
    velocidade,
    precisao,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pontos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ponto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('viagem_id')) {
      context.handle(
        _viagemIdMeta,
        viagemId.isAcceptableOrUnknown(data['viagem_id']!, _viagemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_viagemIdMeta);
    }
    if (data.containsKey('hora')) {
      context.handle(
        _horaMeta,
        hora.isAcceptableOrUnknown(data['hora']!, _horaMeta),
      );
    } else if (isInserting) {
      context.missing(_horaMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('velocidade')) {
      context.handle(
        _velocidadeMeta,
        velocidade.isAcceptableOrUnknown(data['velocidade']!, _velocidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_velocidadeMeta);
    }
    if (data.containsKey('precisao')) {
      context.handle(
        _precisaoMeta,
        precisao.isAcceptableOrUnknown(data['precisao']!, _precisaoMeta),
      );
    } else if (isInserting) {
      context.missing(_precisaoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ponto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ponto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      viagemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}viagem_id'],
      )!,
      hora: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}hora'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      velocidade: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}velocidade'],
      )!,
      precisao: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precisao'],
      )!,
    );
  }

  @override
  $PontosTable createAlias(String alias) {
    return $PontosTable(attachedDatabase, alias);
  }
}

class Ponto extends DataClass implements Insertable<Ponto> {
  final int id;
  final int viagemId;
  final DateTime hora;
  final double latitude;
  final double longitude;
  final double velocidade;
  final double precisao;
  const Ponto({
    required this.id,
    required this.viagemId,
    required this.hora,
    required this.latitude,
    required this.longitude,
    required this.velocidade,
    required this.precisao,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['viagem_id'] = Variable<int>(viagemId);
    map['hora'] = Variable<DateTime>(hora);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['velocidade'] = Variable<double>(velocidade);
    map['precisao'] = Variable<double>(precisao);
    return map;
  }

  PontosCompanion toCompanion(bool nullToAbsent) {
    return PontosCompanion(
      id: Value(id),
      viagemId: Value(viagemId),
      hora: Value(hora),
      latitude: Value(latitude),
      longitude: Value(longitude),
      velocidade: Value(velocidade),
      precisao: Value(precisao),
    );
  }

  factory Ponto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ponto(
      id: serializer.fromJson<int>(json['id']),
      viagemId: serializer.fromJson<int>(json['viagemId']),
      hora: serializer.fromJson<DateTime>(json['hora']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      velocidade: serializer.fromJson<double>(json['velocidade']),
      precisao: serializer.fromJson<double>(json['precisao']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'viagemId': serializer.toJson<int>(viagemId),
      'hora': serializer.toJson<DateTime>(hora),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'velocidade': serializer.toJson<double>(velocidade),
      'precisao': serializer.toJson<double>(precisao),
    };
  }

  Ponto copyWith({
    int? id,
    int? viagemId,
    DateTime? hora,
    double? latitude,
    double? longitude,
    double? velocidade,
    double? precisao,
  }) => Ponto(
    id: id ?? this.id,
    viagemId: viagemId ?? this.viagemId,
    hora: hora ?? this.hora,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    velocidade: velocidade ?? this.velocidade,
    precisao: precisao ?? this.precisao,
  );
  Ponto copyWithCompanion(PontosCompanion data) {
    return Ponto(
      id: data.id.present ? data.id.value : this.id,
      viagemId: data.viagemId.present ? data.viagemId.value : this.viagemId,
      hora: data.hora.present ? data.hora.value : this.hora,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      velocidade: data.velocidade.present
          ? data.velocidade.value
          : this.velocidade,
      precisao: data.precisao.present ? data.precisao.value : this.precisao,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ponto(')
          ..write('id: $id, ')
          ..write('viagemId: $viagemId, ')
          ..write('hora: $hora, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('velocidade: $velocidade, ')
          ..write('precisao: $precisao')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    viagemId,
    hora,
    latitude,
    longitude,
    velocidade,
    precisao,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ponto &&
          other.id == this.id &&
          other.viagemId == this.viagemId &&
          other.hora == this.hora &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.velocidade == this.velocidade &&
          other.precisao == this.precisao);
}

class PontosCompanion extends UpdateCompanion<Ponto> {
  final Value<int> id;
  final Value<int> viagemId;
  final Value<DateTime> hora;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> velocidade;
  final Value<double> precisao;
  const PontosCompanion({
    this.id = const Value.absent(),
    this.viagemId = const Value.absent(),
    this.hora = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.velocidade = const Value.absent(),
    this.precisao = const Value.absent(),
  });
  PontosCompanion.insert({
    this.id = const Value.absent(),
    required int viagemId,
    required DateTime hora,
    required double latitude,
    required double longitude,
    required double velocidade,
    required double precisao,
  }) : viagemId = Value(viagemId),
       hora = Value(hora),
       latitude = Value(latitude),
       longitude = Value(longitude),
       velocidade = Value(velocidade),
       precisao = Value(precisao);
  static Insertable<Ponto> custom({
    Expression<int>? id,
    Expression<int>? viagemId,
    Expression<DateTime>? hora,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? velocidade,
    Expression<double>? precisao,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (viagemId != null) 'viagem_id': viagemId,
      if (hora != null) 'hora': hora,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (velocidade != null) 'velocidade': velocidade,
      if (precisao != null) 'precisao': precisao,
    });
  }

  PontosCompanion copyWith({
    Value<int>? id,
    Value<int>? viagemId,
    Value<DateTime>? hora,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? velocidade,
    Value<double>? precisao,
  }) {
    return PontosCompanion(
      id: id ?? this.id,
      viagemId: viagemId ?? this.viagemId,
      hora: hora ?? this.hora,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      velocidade: velocidade ?? this.velocidade,
      precisao: precisao ?? this.precisao,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (viagemId.present) {
      map['viagem_id'] = Variable<int>(viagemId.value);
    }
    if (hora.present) {
      map['hora'] = Variable<DateTime>(hora.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (velocidade.present) {
      map['velocidade'] = Variable<double>(velocidade.value);
    }
    if (precisao.present) {
      map['precisao'] = Variable<double>(precisao.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PontosCompanion(')
          ..write('id: $id, ')
          ..write('viagemId: $viagemId, ')
          ..write('hora: $hora, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('velocidade: $velocidade, ')
          ..write('precisao: $precisao')
          ..write(')'))
        .toString();
  }
}

class $SetoresTable extends Setores with TableInfo<$SetoresTable, Setor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rotaIdMeta = const VerificationMeta('rotaId');
  @override
  late final GeneratedColumn<int> rotaId = GeneratedColumn<int>(
    'rota_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rotas (id)',
    ),
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inicioMetrosMeta = const VerificationMeta(
    'inicioMetros',
  );
  @override
  late final GeneratedColumn<double> inicioMetros = GeneratedColumn<double>(
    'inicio_metros',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fimMetrosMeta = const VerificationMeta(
    'fimMetros',
  );
  @override
  late final GeneratedColumn<double> fimMetros = GeneratedColumn<double>(
    'fim_metros',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rotaId,
    ordem,
    inicioMetros,
    fimMetros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rota_id')) {
      context.handle(
        _rotaIdMeta,
        rotaId.isAcceptableOrUnknown(data['rota_id']!, _rotaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rotaIdMeta);
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    } else if (isInserting) {
      context.missing(_ordemMeta);
    }
    if (data.containsKey('inicio_metros')) {
      context.handle(
        _inicioMetrosMeta,
        inicioMetros.isAcceptableOrUnknown(
          data['inicio_metros']!,
          _inicioMetrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inicioMetrosMeta);
    }
    if (data.containsKey('fim_metros')) {
      context.handle(
        _fimMetrosMeta,
        fimMetros.isAcceptableOrUnknown(data['fim_metros']!, _fimMetrosMeta),
      );
    } else if (isInserting) {
      context.missing(_fimMetrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rotaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rota_id'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
      inicioMetros: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}inicio_metros'],
      )!,
      fimMetros: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fim_metros'],
      )!,
    );
  }

  @override
  $SetoresTable createAlias(String alias) {
    return $SetoresTable(attachedDatabase, alias);
  }
}

class Setor extends DataClass implements Insertable<Setor> {
  final int id;
  final int rotaId;
  final int ordem;
  final double inicioMetros;
  final double fimMetros;
  const Setor({
    required this.id,
    required this.rotaId,
    required this.ordem,
    required this.inicioMetros,
    required this.fimMetros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rota_id'] = Variable<int>(rotaId);
    map['ordem'] = Variable<int>(ordem);
    map['inicio_metros'] = Variable<double>(inicioMetros);
    map['fim_metros'] = Variable<double>(fimMetros);
    return map;
  }

  SetoresCompanion toCompanion(bool nullToAbsent) {
    return SetoresCompanion(
      id: Value(id),
      rotaId: Value(rotaId),
      ordem: Value(ordem),
      inicioMetros: Value(inicioMetros),
      fimMetros: Value(fimMetros),
    );
  }

  factory Setor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setor(
      id: serializer.fromJson<int>(json['id']),
      rotaId: serializer.fromJson<int>(json['rotaId']),
      ordem: serializer.fromJson<int>(json['ordem']),
      inicioMetros: serializer.fromJson<double>(json['inicioMetros']),
      fimMetros: serializer.fromJson<double>(json['fimMetros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rotaId': serializer.toJson<int>(rotaId),
      'ordem': serializer.toJson<int>(ordem),
      'inicioMetros': serializer.toJson<double>(inicioMetros),
      'fimMetros': serializer.toJson<double>(fimMetros),
    };
  }

  Setor copyWith({
    int? id,
    int? rotaId,
    int? ordem,
    double? inicioMetros,
    double? fimMetros,
  }) => Setor(
    id: id ?? this.id,
    rotaId: rotaId ?? this.rotaId,
    ordem: ordem ?? this.ordem,
    inicioMetros: inicioMetros ?? this.inicioMetros,
    fimMetros: fimMetros ?? this.fimMetros,
  );
  Setor copyWithCompanion(SetoresCompanion data) {
    return Setor(
      id: data.id.present ? data.id.value : this.id,
      rotaId: data.rotaId.present ? data.rotaId.value : this.rotaId,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
      inicioMetros: data.inicioMetros.present
          ? data.inicioMetros.value
          : this.inicioMetros,
      fimMetros: data.fimMetros.present ? data.fimMetros.value : this.fimMetros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setor(')
          ..write('id: $id, ')
          ..write('rotaId: $rotaId, ')
          ..write('ordem: $ordem, ')
          ..write('inicioMetros: $inicioMetros, ')
          ..write('fimMetros: $fimMetros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rotaId, ordem, inicioMetros, fimMetros);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setor &&
          other.id == this.id &&
          other.rotaId == this.rotaId &&
          other.ordem == this.ordem &&
          other.inicioMetros == this.inicioMetros &&
          other.fimMetros == this.fimMetros);
}

class SetoresCompanion extends UpdateCompanion<Setor> {
  final Value<int> id;
  final Value<int> rotaId;
  final Value<int> ordem;
  final Value<double> inicioMetros;
  final Value<double> fimMetros;
  const SetoresCompanion({
    this.id = const Value.absent(),
    this.rotaId = const Value.absent(),
    this.ordem = const Value.absent(),
    this.inicioMetros = const Value.absent(),
    this.fimMetros = const Value.absent(),
  });
  SetoresCompanion.insert({
    this.id = const Value.absent(),
    required int rotaId,
    required int ordem,
    required double inicioMetros,
    required double fimMetros,
  }) : rotaId = Value(rotaId),
       ordem = Value(ordem),
       inicioMetros = Value(inicioMetros),
       fimMetros = Value(fimMetros);
  static Insertable<Setor> custom({
    Expression<int>? id,
    Expression<int>? rotaId,
    Expression<int>? ordem,
    Expression<double>? inicioMetros,
    Expression<double>? fimMetros,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rotaId != null) 'rota_id': rotaId,
      if (ordem != null) 'ordem': ordem,
      if (inicioMetros != null) 'inicio_metros': inicioMetros,
      if (fimMetros != null) 'fim_metros': fimMetros,
    });
  }

  SetoresCompanion copyWith({
    Value<int>? id,
    Value<int>? rotaId,
    Value<int>? ordem,
    Value<double>? inicioMetros,
    Value<double>? fimMetros,
  }) {
    return SetoresCompanion(
      id: id ?? this.id,
      rotaId: rotaId ?? this.rotaId,
      ordem: ordem ?? this.ordem,
      inicioMetros: inicioMetros ?? this.inicioMetros,
      fimMetros: fimMetros ?? this.fimMetros,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rotaId.present) {
      map['rota_id'] = Variable<int>(rotaId.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (inicioMetros.present) {
      map['inicio_metros'] = Variable<double>(inicioMetros.value);
    }
    if (fimMetros.present) {
      map['fim_metros'] = Variable<double>(fimMetros.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetoresCompanion(')
          ..write('id: $id, ')
          ..write('rotaId: $rotaId, ')
          ..write('ordem: $ordem, ')
          ..write('inicioMetros: $inicioMetros, ')
          ..write('fimMetros: $fimMetros')
          ..write(')'))
        .toString();
  }
}

class $TemposSetorTable extends TemposSetor
    with TableInfo<$TemposSetorTable, TempoSetor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemposSetorTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _viagemIdMeta = const VerificationMeta(
    'viagemId',
  );
  @override
  late final GeneratedColumn<int> viagemId = GeneratedColumn<int>(
    'viagem_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES viagens (id)',
    ),
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segundosMeta = const VerificationMeta(
    'segundos',
  );
  @override
  late final GeneratedColumn<double> segundos = GeneratedColumn<double>(
    'segundos',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, viagemId, ordem, segundos];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tempos_setor';
  @override
  VerificationContext validateIntegrity(
    Insertable<TempoSetor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('viagem_id')) {
      context.handle(
        _viagemIdMeta,
        viagemId.isAcceptableOrUnknown(data['viagem_id']!, _viagemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_viagemIdMeta);
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    } else if (isInserting) {
      context.missing(_ordemMeta);
    }
    if (data.containsKey('segundos')) {
      context.handle(
        _segundosMeta,
        segundos.isAcceptableOrUnknown(data['segundos']!, _segundosMeta),
      );
    } else if (isInserting) {
      context.missing(_segundosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TempoSetor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TempoSetor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      viagemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}viagem_id'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
      segundos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}segundos'],
      )!,
    );
  }

  @override
  $TemposSetorTable createAlias(String alias) {
    return $TemposSetorTable(attachedDatabase, alias);
  }
}

class TempoSetor extends DataClass implements Insertable<TempoSetor> {
  final int id;
  final int viagemId;
  final int ordem;
  final double segundos;
  const TempoSetor({
    required this.id,
    required this.viagemId,
    required this.ordem,
    required this.segundos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['viagem_id'] = Variable<int>(viagemId);
    map['ordem'] = Variable<int>(ordem);
    map['segundos'] = Variable<double>(segundos);
    return map;
  }

  TemposSetorCompanion toCompanion(bool nullToAbsent) {
    return TemposSetorCompanion(
      id: Value(id),
      viagemId: Value(viagemId),
      ordem: Value(ordem),
      segundos: Value(segundos),
    );
  }

  factory TempoSetor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TempoSetor(
      id: serializer.fromJson<int>(json['id']),
      viagemId: serializer.fromJson<int>(json['viagemId']),
      ordem: serializer.fromJson<int>(json['ordem']),
      segundos: serializer.fromJson<double>(json['segundos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'viagemId': serializer.toJson<int>(viagemId),
      'ordem': serializer.toJson<int>(ordem),
      'segundos': serializer.toJson<double>(segundos),
    };
  }

  TempoSetor copyWith({int? id, int? viagemId, int? ordem, double? segundos}) =>
      TempoSetor(
        id: id ?? this.id,
        viagemId: viagemId ?? this.viagemId,
        ordem: ordem ?? this.ordem,
        segundos: segundos ?? this.segundos,
      );
  TempoSetor copyWithCompanion(TemposSetorCompanion data) {
    return TempoSetor(
      id: data.id.present ? data.id.value : this.id,
      viagemId: data.viagemId.present ? data.viagemId.value : this.viagemId,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
      segundos: data.segundos.present ? data.segundos.value : this.segundos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TempoSetor(')
          ..write('id: $id, ')
          ..write('viagemId: $viagemId, ')
          ..write('ordem: $ordem, ')
          ..write('segundos: $segundos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, viagemId, ordem, segundos);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TempoSetor &&
          other.id == this.id &&
          other.viagemId == this.viagemId &&
          other.ordem == this.ordem &&
          other.segundos == this.segundos);
}

class TemposSetorCompanion extends UpdateCompanion<TempoSetor> {
  final Value<int> id;
  final Value<int> viagemId;
  final Value<int> ordem;
  final Value<double> segundos;
  const TemposSetorCompanion({
    this.id = const Value.absent(),
    this.viagemId = const Value.absent(),
    this.ordem = const Value.absent(),
    this.segundos = const Value.absent(),
  });
  TemposSetorCompanion.insert({
    this.id = const Value.absent(),
    required int viagemId,
    required int ordem,
    required double segundos,
  }) : viagemId = Value(viagemId),
       ordem = Value(ordem),
       segundos = Value(segundos);
  static Insertable<TempoSetor> custom({
    Expression<int>? id,
    Expression<int>? viagemId,
    Expression<int>? ordem,
    Expression<double>? segundos,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (viagemId != null) 'viagem_id': viagemId,
      if (ordem != null) 'ordem': ordem,
      if (segundos != null) 'segundos': segundos,
    });
  }

  TemposSetorCompanion copyWith({
    Value<int>? id,
    Value<int>? viagemId,
    Value<int>? ordem,
    Value<double>? segundos,
  }) {
    return TemposSetorCompanion(
      id: id ?? this.id,
      viagemId: viagemId ?? this.viagemId,
      ordem: ordem ?? this.ordem,
      segundos: segundos ?? this.segundos,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (viagemId.present) {
      map['viagem_id'] = Variable<int>(viagemId.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (segundos.present) {
      map['segundos'] = Variable<double>(segundos.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemposSetorCompanion(')
          ..write('id: $id, ')
          ..write('viagemId: $viagemId, ')
          ..write('ordem: $ordem, ')
          ..write('segundos: $segundos')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RotasTable rotas = $RotasTable(this);
  late final $ViagensTable viagens = $ViagensTable(this);
  late final $PontosTable pontos = $PontosTable(this);
  late final $SetoresTable setores = $SetoresTable(this);
  late final $TemposSetorTable temposSetor = $TemposSetorTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    rotas,
    viagens,
    pontos,
    setores,
    temposSetor,
  ];
}

typedef $$RotasTableCreateCompanionBuilder = RotasCompanion Function({
  Value<int> id,
  required String nome,
  Value<int?> viagemReferenciaId,
});
typedef $$RotasTableUpdateCompanionBuilder = RotasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int?> viagemReferenciaId,
});

final class $$RotasTableReferences
    extends BaseReferences<_$AppDatabase, $RotasTable, Rota> {
  $$RotasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ViagensTable, List<Viagem>> _viagensRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.viagens,
    aliasName: 'rotas__id__viagens__rota_id',
  );

  $$ViagensTableProcessedTableManager get viagensRefs {
    final manager = $$ViagensTableTableManager(
      $_db,
      $_db.viagens,
    ).filter((f) => f.rotaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_viagensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SetoresTable, List<Setor>> _setoresRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.setores,
    aliasName: 'rotas__id__setores__rota_id',
  );

  $$SetoresTableProcessedTableManager get setoresRefs {
    final manager = $$SetoresTableTableManager(
      $_db,
      $_db.setores,
    ).filter((f) => f.rotaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setoresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RotasTableFilterComposer extends Composer<_$AppDatabase, $RotasTable> {
  $$RotasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get viagemReferenciaId => $composableBuilder(
    column: $table.viagemReferenciaId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> viagensRefs(
    Expression<bool> Function($$ViagensTableFilterComposer f) f,
  ) {
    final $$ViagensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.viagens,
      getReferencedColumn: (t) => t.rotaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ViagensTableFilterComposer(
            $db: $db,
            $table: $db.viagens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> setoresRefs(
    Expression<bool> Function($$SetoresTableFilterComposer f) f,
  ) {
    final $$SetoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setores,
      getReferencedColumn: (t) => t.rotaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetoresTableFilterComposer(
            $db: $db,
            $table: $db.setores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RotasTableOrderingComposer
    extends Composer<_$AppDatabase, $RotasTable> {
  $$RotasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get viagemReferenciaId => $composableBuilder(
    column: $table.viagemReferenciaId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RotasTableAnnotationComposer
    extends Composer<_$AppDatabase, $RotasTable> {
  $$RotasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get viagemReferenciaId => $composableBuilder(
    column: $table.viagemReferenciaId,
    builder: (column) => column,
  );

  Expression<T> viagensRefs<T extends Object>(
    Expression<T> Function($$ViagensTableAnnotationComposer a) f,
  ) {
    final $$ViagensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.viagens,
      getReferencedColumn: (t) => t.rotaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ViagensTableAnnotationComposer(
            $db: $db,
            $table: $db.viagens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> setoresRefs<T extends Object>(
    Expression<T> Function($$SetoresTableAnnotationComposer a) f,
  ) {
    final $$SetoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setores,
      getReferencedColumn: (t) => t.rotaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetoresTableAnnotationComposer(
            $db: $db,
            $table: $db.setores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RotasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RotasTable,
          Rota,
          $$RotasTableFilterComposer,
          $$RotasTableOrderingComposer,
          $$RotasTableAnnotationComposer,
          $$RotasTableCreateCompanionBuilder,
          $$RotasTableUpdateCompanionBuilder,
          (Rota, $$RotasTableReferences),
          Rota,
          PrefetchHooks Function({bool viagensRefs, bool setoresRefs})
        > {
  $$RotasTableTableManager(_$AppDatabase db, $RotasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int?> viagemReferenciaId = const Value.absent(),
              }) => RotasCompanion(
                id: id,
                nome: nome,
                viagemReferenciaId: viagemReferenciaId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                Value<int?> viagemReferenciaId = const Value.absent(),
              }) => RotasCompanion.insert(
                id: id,
                nome: nome,
                viagemReferenciaId: viagemReferenciaId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RotasTable, Rota>(table),
                  $$RotasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({viagensRefs = false, setoresRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (viagensRefs) db.viagens,
                if (setoresRefs) db.setores,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (viagensRefs)
                    await $_getPrefetchedDataByColumns<
                      Rota,
                      $RotasTable,
                      Viagem,
                      $ViagensTable
                    >(
                      currentTable: table,
                      referencedTable: $$RotasTableReferences._viagensRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$RotasTableReferences(db, table, p0).viagensRefs,
                      currentColumn: 'id',
                      referencedColumn: 'rota_id',
                      typedResults: items,
                    ),
                  if (setoresRefs)
                    await $_getPrefetchedDataByColumns<
                      Rota,
                      $RotasTable,
                      Setor,
                      $SetoresTable
                    >(
                      currentTable: table,
                      referencedTable: $$RotasTableReferences._setoresRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$RotasTableReferences(db, table, p0).setoresRefs,
                      currentColumn: 'id',
                      referencedColumn: 'rota_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RotasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RotasTable,
      Rota,
      $$RotasTableFilterComposer,
      $$RotasTableOrderingComposer,
      $$RotasTableAnnotationComposer,
      $$RotasTableCreateCompanionBuilder,
      $$RotasTableUpdateCompanionBuilder,
      (Rota, $$RotasTableReferences),
      Rota,
      PrefetchHooks Function({bool viagensRefs, bool setoresRefs})
    >;
typedef $$ViagensTableCreateCompanionBuilder = ViagensCompanion Function({
  Value<int> id,
  required DateTime inicio,
  required DateTime fim,
  required double distanciaMetros,
  Value<int?> rotaId,
});
typedef $$ViagensTableUpdateCompanionBuilder = ViagensCompanion Function({
  Value<int> id,
  Value<DateTime> inicio,
  Value<DateTime> fim,
  Value<double> distanciaMetros,
  Value<int?> rotaId,
});

final class $$ViagensTableReferences
    extends BaseReferences<_$AppDatabase, $ViagensTable, Viagem> {
  $$ViagensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RotasTable _rotaIdTable(_$AppDatabase db) =>
      db.rotas.createAlias('viagens__rota_id__rotas__id');

  $$RotasTableProcessedTableManager? get rotaId {
    final $_column = $_itemColumn<int>('rota_id');
    if ($_column == null) return null;
    final manager = $$RotasTableTableManager(
      $_db,
      $_db.rotas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rotaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PontosTable, List<Ponto>> _pontosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pontos,
    aliasName: 'viagens__id__pontos__viagem_id',
  );

  $$PontosTableProcessedTableManager get pontosRefs {
    final manager = $$PontosTableTableManager(
      $_db,
      $_db.pontos,
    ).filter((f) => f.viagemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pontosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TemposSetorTable, List<TempoSetor>>
  _temposSetorRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.temposSetor,
    aliasName: 'viagens__id__tempos_setor__viagem_id',
  );

  $$TemposSetorTableProcessedTableManager get temposSetorRefs {
    final manager = $$TemposSetorTableTableManager(
      $_db,
      $_db.temposSetor,
    ).filter((f) => f.viagemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_temposSetorRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ViagensTableFilterComposer
    extends Composer<_$AppDatabase, $ViagensTable> {
  $$ViagensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fim => $composableBuilder(
    column: $table.fim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanciaMetros => $composableBuilder(
    column: $table.distanciaMetros,
    builder: (column) => ColumnFilters(column),
  );

  $$RotasTableFilterComposer get rotaId {
    final $$RotasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rotaId,
      referencedTable: $db.rotas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RotasTableFilterComposer(
            $db: $db,
            $table: $db.rotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> pontosRefs(
    Expression<bool> Function($$PontosTableFilterComposer f) f,
  ) {
    final $$PontosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pontos,
      getReferencedColumn: (t) => t.viagemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PontosTableFilterComposer(
            $db: $db,
            $table: $db.pontos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> temposSetorRefs(
    Expression<bool> Function($$TemposSetorTableFilterComposer f) f,
  ) {
    final $$TemposSetorTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.temposSetor,
      getReferencedColumn: (t) => t.viagemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemposSetorTableFilterComposer(
            $db: $db,
            $table: $db.temposSetor,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ViagensTableOrderingComposer
    extends Composer<_$AppDatabase, $ViagensTable> {
  $$ViagensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fim => $composableBuilder(
    column: $table.fim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanciaMetros => $composableBuilder(
    column: $table.distanciaMetros,
    builder: (column) => ColumnOrderings(column),
  );

  $$RotasTableOrderingComposer get rotaId {
    final $$RotasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rotaId,
      referencedTable: $db.rotas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RotasTableOrderingComposer(
            $db: $db,
            $table: $db.rotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ViagensTableAnnotationComposer
    extends Composer<_$AppDatabase, $ViagensTable> {
  $$ViagensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<DateTime> get fim =>
      $composableBuilder(column: $table.fim, builder: (column) => column);

  GeneratedColumn<double> get distanciaMetros => $composableBuilder(
    column: $table.distanciaMetros,
    builder: (column) => column,
  );

  $$RotasTableAnnotationComposer get rotaId {
    final $$RotasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rotaId,
      referencedTable: $db.rotas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RotasTableAnnotationComposer(
            $db: $db,
            $table: $db.rotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> pontosRefs<T extends Object>(
    Expression<T> Function($$PontosTableAnnotationComposer a) f,
  ) {
    final $$PontosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pontos,
      getReferencedColumn: (t) => t.viagemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PontosTableAnnotationComposer(
            $db: $db,
            $table: $db.pontos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> temposSetorRefs<T extends Object>(
    Expression<T> Function($$TemposSetorTableAnnotationComposer a) f,
  ) {
    final $$TemposSetorTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.temposSetor,
      getReferencedColumn: (t) => t.viagemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemposSetorTableAnnotationComposer(
            $db: $db,
            $table: $db.temposSetor,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ViagensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ViagensTable,
          Viagem,
          $$ViagensTableFilterComposer,
          $$ViagensTableOrderingComposer,
          $$ViagensTableAnnotationComposer,
          $$ViagensTableCreateCompanionBuilder,
          $$ViagensTableUpdateCompanionBuilder,
          (Viagem, $$ViagensTableReferences),
          Viagem,
          PrefetchHooks Function({
            bool rotaId,
            bool pontosRefs,
            bool temposSetorRefs,
          })
        > {
  $$ViagensTableTableManager(_$AppDatabase db, $ViagensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ViagensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ViagensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ViagensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> inicio = const Value.absent(),
                Value<DateTime> fim = const Value.absent(),
                Value<double> distanciaMetros = const Value.absent(),
                Value<int?> rotaId = const Value.absent(),
              }) => ViagensCompanion(
                id: id,
                inicio: inicio,
                fim: fim,
                distanciaMetros: distanciaMetros,
                rotaId: rotaId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime inicio,
                required DateTime fim,
                required double distanciaMetros,
                Value<int?> rotaId = const Value.absent(),
              }) => ViagensCompanion.insert(
                id: id,
                inicio: inicio,
                fim: fim,
                distanciaMetros: distanciaMetros,
                rotaId: rotaId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ViagensTable, Viagem>(table),
                  $$ViagensTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({rotaId = false, pontosRefs = false, temposSetorRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pontosRefs) db.pontos,
                    if (temposSetorRefs) db.temposSetor,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (rotaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.rotaId,
                            referencedTable: $$ViagensTableReferences
                                ._rotaIdTable(db),
                            referencedColumn: $$ViagensTableReferences
                                ._rotaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pontosRefs)
                        await $_getPrefetchedDataByColumns<
                          Viagem,
                          $ViagensTable,
                          Ponto,
                          $PontosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ViagensTableReferences
                              ._pontosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ViagensTableReferences(
                                db,
                                table,
                                p0,
                              ).pontosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'viagem_id',
                          typedResults: items,
                        ),
                      if (temposSetorRefs)
                        await $_getPrefetchedDataByColumns<
                          Viagem,
                          $ViagensTable,
                          TempoSetor,
                          $TemposSetorTable
                        >(
                          currentTable: table,
                          referencedTable: $$ViagensTableReferences
                              ._temposSetorRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ViagensTableReferences(
                                db,
                                table,
                                p0,
                              ).temposSetorRefs,
                          currentColumn: 'id',
                          referencedColumn: 'viagem_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ViagensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ViagensTable,
      Viagem,
      $$ViagensTableFilterComposer,
      $$ViagensTableOrderingComposer,
      $$ViagensTableAnnotationComposer,
      $$ViagensTableCreateCompanionBuilder,
      $$ViagensTableUpdateCompanionBuilder,
      (Viagem, $$ViagensTableReferences),
      Viagem,
      PrefetchHooks Function({
        bool rotaId,
        bool pontosRefs,
        bool temposSetorRefs,
      })
    >;
typedef $$PontosTableCreateCompanionBuilder = PontosCompanion Function({
  Value<int> id,
  required int viagemId,
  required DateTime hora,
  required double latitude,
  required double longitude,
  required double velocidade,
  required double precisao,
});
typedef $$PontosTableUpdateCompanionBuilder = PontosCompanion Function({
  Value<int> id,
  Value<int> viagemId,
  Value<DateTime> hora,
  Value<double> latitude,
  Value<double> longitude,
  Value<double> velocidade,
  Value<double> precisao,
});

final class $$PontosTableReferences
    extends BaseReferences<_$AppDatabase, $PontosTable, Ponto> {
  $$PontosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ViagensTable _viagemIdTable(_$AppDatabase db) =>
      db.viagens.createAlias('pontos__viagem_id__viagens__id');

  $$ViagensTableProcessedTableManager get viagemId {
    final $_column = $_itemColumn<int>('viagem_id')!;

    final manager = $$ViagensTableTableManager(
      $_db,
      $_db.viagens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_viagemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PontosTableFilterComposer
    extends Composer<_$AppDatabase, $PontosTable> {
  $$PontosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get velocidade => $composableBuilder(
    column: $table.velocidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precisao => $composableBuilder(
    column: $table.precisao,
    builder: (column) => ColumnFilters(column),
  );

  $$ViagensTableFilterComposer get viagemId {
    final $$ViagensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.viagemId,
      referencedTable: $db.viagens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ViagensTableFilterComposer(
            $db: $db,
            $table: $db.viagens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PontosTableOrderingComposer
    extends Composer<_$AppDatabase, $PontosTable> {
  $$PontosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get velocidade => $composableBuilder(
    column: $table.velocidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precisao => $composableBuilder(
    column: $table.precisao,
    builder: (column) => ColumnOrderings(column),
  );

  $$ViagensTableOrderingComposer get viagemId {
    final $$ViagensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.viagemId,
      referencedTable: $db.viagens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ViagensTableOrderingComposer(
            $db: $db,
            $table: $db.viagens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PontosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PontosTable> {
  $$PontosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get hora =>
      $composableBuilder(column: $table.hora, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get velocidade => $composableBuilder(
    column: $table.velocidade,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precisao =>
      $composableBuilder(column: $table.precisao, builder: (column) => column);

  $$ViagensTableAnnotationComposer get viagemId {
    final $$ViagensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.viagemId,
      referencedTable: $db.viagens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ViagensTableAnnotationComposer(
            $db: $db,
            $table: $db.viagens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PontosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PontosTable,
          Ponto,
          $$PontosTableFilterComposer,
          $$PontosTableOrderingComposer,
          $$PontosTableAnnotationComposer,
          $$PontosTableCreateCompanionBuilder,
          $$PontosTableUpdateCompanionBuilder,
          (Ponto, $$PontosTableReferences),
          Ponto,
          PrefetchHooks Function({bool viagemId})
        > {
  $$PontosTableTableManager(_$AppDatabase db, $PontosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PontosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PontosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PontosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> viagemId = const Value.absent(),
                Value<DateTime> hora = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> velocidade = const Value.absent(),
                Value<double> precisao = const Value.absent(),
              }) => PontosCompanion(
                id: id,
                viagemId: viagemId,
                hora: hora,
                latitude: latitude,
                longitude: longitude,
                velocidade: velocidade,
                precisao: precisao,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int viagemId,
                required DateTime hora,
                required double latitude,
                required double longitude,
                required double velocidade,
                required double precisao,
              }) => PontosCompanion.insert(
                id: id,
                viagemId: viagemId,
                hora: hora,
                latitude: latitude,
                longitude: longitude,
                velocidade: velocidade,
                precisao: precisao,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PontosTable, Ponto>(table),
                  $$PontosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({viagemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (viagemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.viagemId,
                        referencedTable: $$PontosTableReferences._viagemIdTable(
                          db,
                        ),
                        referencedColumn: $$PontosTableReferences
                            ._viagemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PontosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PontosTable,
      Ponto,
      $$PontosTableFilterComposer,
      $$PontosTableOrderingComposer,
      $$PontosTableAnnotationComposer,
      $$PontosTableCreateCompanionBuilder,
      $$PontosTableUpdateCompanionBuilder,
      (Ponto, $$PontosTableReferences),
      Ponto,
      PrefetchHooks Function({bool viagemId})
    >;
typedef $$SetoresTableCreateCompanionBuilder = SetoresCompanion Function({
  Value<int> id,
  required int rotaId,
  required int ordem,
  required double inicioMetros,
  required double fimMetros,
});
typedef $$SetoresTableUpdateCompanionBuilder = SetoresCompanion Function({
  Value<int> id,
  Value<int> rotaId,
  Value<int> ordem,
  Value<double> inicioMetros,
  Value<double> fimMetros,
});

final class $$SetoresTableReferences
    extends BaseReferences<_$AppDatabase, $SetoresTable, Setor> {
  $$SetoresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RotasTable _rotaIdTable(_$AppDatabase db) =>
      db.rotas.createAlias('setores__rota_id__rotas__id');

  $$RotasTableProcessedTableManager get rotaId {
    final $_column = $_itemColumn<int>('rota_id')!;

    final manager = $$RotasTableTableManager(
      $_db,
      $_db.rotas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rotaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetoresTableFilterComposer
    extends Composer<_$AppDatabase, $SetoresTable> {
  $$SetoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get inicioMetros => $composableBuilder(
    column: $table.inicioMetros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fimMetros => $composableBuilder(
    column: $table.fimMetros,
    builder: (column) => ColumnFilters(column),
  );

  $$RotasTableFilterComposer get rotaId {
    final $$RotasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rotaId,
      referencedTable: $db.rotas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RotasTableFilterComposer(
            $db: $db,
            $table: $db.rotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetoresTableOrderingComposer
    extends Composer<_$AppDatabase, $SetoresTable> {
  $$SetoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get inicioMetros => $composableBuilder(
    column: $table.inicioMetros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fimMetros => $composableBuilder(
    column: $table.fimMetros,
    builder: (column) => ColumnOrderings(column),
  );

  $$RotasTableOrderingComposer get rotaId {
    final $$RotasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rotaId,
      referencedTable: $db.rotas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RotasTableOrderingComposer(
            $db: $db,
            $table: $db.rotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetoresTable> {
  $$SetoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  GeneratedColumn<double> get inicioMetros => $composableBuilder(
    column: $table.inicioMetros,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fimMetros =>
      $composableBuilder(column: $table.fimMetros, builder: (column) => column);

  $$RotasTableAnnotationComposer get rotaId {
    final $$RotasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rotaId,
      referencedTable: $db.rotas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RotasTableAnnotationComposer(
            $db: $db,
            $table: $db.rotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetoresTable,
          Setor,
          $$SetoresTableFilterComposer,
          $$SetoresTableOrderingComposer,
          $$SetoresTableAnnotationComposer,
          $$SetoresTableCreateCompanionBuilder,
          $$SetoresTableUpdateCompanionBuilder,
          (Setor, $$SetoresTableReferences),
          Setor,
          PrefetchHooks Function({bool rotaId})
        > {
  $$SetoresTableTableManager(_$AppDatabase db, $SetoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rotaId = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<double> inicioMetros = const Value.absent(),
                Value<double> fimMetros = const Value.absent(),
              }) => SetoresCompanion(
                id: id,
                rotaId: rotaId,
                ordem: ordem,
                inicioMetros: inicioMetros,
                fimMetros: fimMetros,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rotaId,
                required int ordem,
                required double inicioMetros,
                required double fimMetros,
              }) => SetoresCompanion.insert(
                id: id,
                rotaId: rotaId,
                ordem: ordem,
                inicioMetros: inicioMetros,
                fimMetros: fimMetros,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SetoresTable, Setor>(table),
                  $$SetoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rotaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rotaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.rotaId,
                        referencedTable: $$SetoresTableReferences._rotaIdTable(
                          db,
                        ),
                        referencedColumn: $$SetoresTableReferences
                            ._rotaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SetoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetoresTable,
      Setor,
      $$SetoresTableFilterComposer,
      $$SetoresTableOrderingComposer,
      $$SetoresTableAnnotationComposer,
      $$SetoresTableCreateCompanionBuilder,
      $$SetoresTableUpdateCompanionBuilder,
      (Setor, $$SetoresTableReferences),
      Setor,
      PrefetchHooks Function({bool rotaId})
    >;
typedef $$TemposSetorTableCreateCompanionBuilder =
    TemposSetorCompanion Function({
      Value<int> id,
      required int viagemId,
      required int ordem,
      required double segundos,
    });
typedef $$TemposSetorTableUpdateCompanionBuilder =
    TemposSetorCompanion Function({
      Value<int> id,
      Value<int> viagemId,
      Value<int> ordem,
      Value<double> segundos,
    });

final class $$TemposSetorTableReferences
    extends BaseReferences<_$AppDatabase, $TemposSetorTable, TempoSetor> {
  $$TemposSetorTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ViagensTable _viagemIdTable(_$AppDatabase db) =>
      db.viagens.createAlias('tempos_setor__viagem_id__viagens__id');

  $$ViagensTableProcessedTableManager get viagemId {
    final $_column = $_itemColumn<int>('viagem_id')!;

    final manager = $$ViagensTableTableManager(
      $_db,
      $_db.viagens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_viagemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TemposSetorTableFilterComposer
    extends Composer<_$AppDatabase, $TemposSetorTable> {
  $$TemposSetorTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get segundos => $composableBuilder(
    column: $table.segundos,
    builder: (column) => ColumnFilters(column),
  );

  $$ViagensTableFilterComposer get viagemId {
    final $$ViagensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.viagemId,
      referencedTable: $db.viagens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ViagensTableFilterComposer(
            $db: $db,
            $table: $db.viagens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemposSetorTableOrderingComposer
    extends Composer<_$AppDatabase, $TemposSetorTable> {
  $$TemposSetorTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get segundos => $composableBuilder(
    column: $table.segundos,
    builder: (column) => ColumnOrderings(column),
  );

  $$ViagensTableOrderingComposer get viagemId {
    final $$ViagensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.viagemId,
      referencedTable: $db.viagens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ViagensTableOrderingComposer(
            $db: $db,
            $table: $db.viagens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemposSetorTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemposSetorTable> {
  $$TemposSetorTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  GeneratedColumn<double> get segundos =>
      $composableBuilder(column: $table.segundos, builder: (column) => column);

  $$ViagensTableAnnotationComposer get viagemId {
    final $$ViagensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.viagemId,
      referencedTable: $db.viagens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ViagensTableAnnotationComposer(
            $db: $db,
            $table: $db.viagens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemposSetorTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemposSetorTable,
          TempoSetor,
          $$TemposSetorTableFilterComposer,
          $$TemposSetorTableOrderingComposer,
          $$TemposSetorTableAnnotationComposer,
          $$TemposSetorTableCreateCompanionBuilder,
          $$TemposSetorTableUpdateCompanionBuilder,
          (TempoSetor, $$TemposSetorTableReferences),
          TempoSetor,
          PrefetchHooks Function({bool viagemId})
        > {
  $$TemposSetorTableTableManager(_$AppDatabase db, $TemposSetorTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemposSetorTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemposSetorTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemposSetorTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> viagemId = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<double> segundos = const Value.absent(),
              }) => TemposSetorCompanion(
                id: id,
                viagemId: viagemId,
                ordem: ordem,
                segundos: segundos,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int viagemId,
                required int ordem,
                required double segundos,
              }) => TemposSetorCompanion.insert(
                id: id,
                viagemId: viagemId,
                ordem: ordem,
                segundos: segundos,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TemposSetorTable, TempoSetor>(table),
                  $$TemposSetorTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({viagemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (viagemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.viagemId,
                        referencedTable: $$TemposSetorTableReferences
                            ._viagemIdTable(db),
                        referencedColumn: $$TemposSetorTableReferences
                            ._viagemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TemposSetorTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemposSetorTable,
      TempoSetor,
      $$TemposSetorTableFilterComposer,
      $$TemposSetorTableOrderingComposer,
      $$TemposSetorTableAnnotationComposer,
      $$TemposSetorTableCreateCompanionBuilder,
      $$TemposSetorTableUpdateCompanionBuilder,
      (TempoSetor, $$TemposSetorTableReferences),
      TempoSetor,
      PrefetchHooks Function({bool viagemId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RotasTableTableManager get rotas =>
      $$RotasTableTableManager(_db, _db.rotas);
  $$ViagensTableTableManager get viagens =>
      $$ViagensTableTableManager(_db, _db.viagens);
  $$PontosTableTableManager get pontos =>
      $$PontosTableTableManager(_db, _db.pontos);
  $$SetoresTableTableManager get setores =>
      $$SetoresTableTableManager(_db, _db.setores);
  $$TemposSetorTableTableManager get temposSetor =>
      $$TemposSetorTableTableManager(_db, _db.temposSetor);
}
