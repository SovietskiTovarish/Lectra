// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, name, code, colorValue, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(Insertable<Subject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final String name;
  final String code;
  final int? colorValue;
  final DateTime createdAt;
  const Subject(
      {required this.id,
      required this.name,
      required this.code,
      this.colorValue,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      createdAt: Value(createdAt),
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'colorValue': serializer.toJson<int?>(colorValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Subject copyWith(
          {int? id,
          String? name,
          String? code,
          Value<int?> colorValue = const Value.absent(),
          DateTime? createdAt}) =>
      Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        colorValue: colorValue.present ? colorValue.value : this.colorValue,
        createdAt: createdAt ?? this.createdAt,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('colorValue: $colorValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, code, colorValue, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.colorValue == this.colorValue &&
          other.createdAt == this.createdAt);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> code;
  final Value<int?> colorValue;
  final Value<DateTime> createdAt;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.code = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<int>? colorValue,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (colorValue != null) 'color_value': colorValue,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SubjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? code,
      Value<int?>? colorValue,
      Value<DateTime>? createdAt}) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('colorValue: $colorValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TimetableEntriesTable extends TimetableEntries
    with TableInfo<$TimetableEntriesTable, TimetableEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetableEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subjects (id) ON DELETE CASCADE'));
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startMinutesMeta =
      const VerificationMeta('startMinutes');
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
      'start_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endMinutesMeta =
      const VerificationMeta('endMinutes');
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
      'end_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
      'room', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns =>
      [id, subjectId, dayOfWeek, startMinutes, endMinutes, room];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetable_entries';
  @override
  VerificationContext validateIntegrity(Insertable<TimetableEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
          _startMinutesMeta,
          startMinutes.isAcceptableOrUnknown(
              data['start_minutes']!, _startMinutesMeta));
    } else if (isInserting) {
      context.missing(_startMinutesMeta);
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
          _endMinutesMeta,
          endMinutes.isAcceptableOrUnknown(
              data['end_minutes']!, _endMinutesMeta));
    } else if (isInserting) {
      context.missing(_endMinutesMeta);
    }
    if (data.containsKey('room')) {
      context.handle(
          _roomMeta, room.isAcceptableOrUnknown(data['room']!, _roomMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimetableEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimetableEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subject_id'])!,
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      startMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_minutes'])!,
      endMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_minutes'])!,
      room: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room'])!,
    );
  }

  @override
  $TimetableEntriesTable createAlias(String alias) {
    return $TimetableEntriesTable(attachedDatabase, alias);
  }
}

class TimetableEntry extends DataClass implements Insertable<TimetableEntry> {
  final int id;
  final int subjectId;
  final int dayOfWeek;
  final int startMinutes;
  final int endMinutes;
  final String room;
  const TimetableEntry(
      {required this.id,
      required this.subjectId,
      required this.dayOfWeek,
      required this.startMinutes,
      required this.endMinutes,
      required this.room});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject_id'] = Variable<int>(subjectId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['start_minutes'] = Variable<int>(startMinutes);
    map['end_minutes'] = Variable<int>(endMinutes);
    map['room'] = Variable<String>(room);
    return map;
  }

  TimetableEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimetableEntriesCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      dayOfWeek: Value(dayOfWeek),
      startMinutes: Value(startMinutes),
      endMinutes: Value(endMinutes),
      room: Value(room),
    );
  }

  factory TimetableEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimetableEntry(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      startMinutes: serializer.fromJson<int>(json['startMinutes']),
      endMinutes: serializer.fromJson<int>(json['endMinutes']),
      room: serializer.fromJson<String>(json['room']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<int>(subjectId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'startMinutes': serializer.toJson<int>(startMinutes),
      'endMinutes': serializer.toJson<int>(endMinutes),
      'room': serializer.toJson<String>(room),
    };
  }

  TimetableEntry copyWith(
          {int? id,
          int? subjectId,
          int? dayOfWeek,
          int? startMinutes,
          int? endMinutes,
          String? room}) =>
      TimetableEntry(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startMinutes: startMinutes ?? this.startMinutes,
        endMinutes: endMinutes ?? this.endMinutes,
        room: room ?? this.room,
      );
  TimetableEntry copyWithCompanion(TimetableEntriesCompanion data) {
    return TimetableEntry(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes:
          data.endMinutes.present ? data.endMinutes.value : this.endMinutes,
      room: data.room.present ? data.room.value : this.room,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimetableEntry(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, subjectId, dayOfWeek, startMinutes, endMinutes, room);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetableEntry &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.room == this.room);
}

class TimetableEntriesCompanion extends UpdateCompanion<TimetableEntry> {
  final Value<int> id;
  final Value<int> subjectId;
  final Value<int> dayOfWeek;
  final Value<int> startMinutes;
  final Value<int> endMinutes;
  final Value<String> room;
  const TimetableEntriesCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.room = const Value.absent(),
  });
  TimetableEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int subjectId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
    this.room = const Value.absent(),
  })  : subjectId = Value(subjectId),
        dayOfWeek = Value(dayOfWeek),
        startMinutes = Value(startMinutes),
        endMinutes = Value(endMinutes);
  static Insertable<TimetableEntry> custom({
    Expression<int>? id,
    Expression<int>? subjectId,
    Expression<int>? dayOfWeek,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<String>? room,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (room != null) 'room': room,
    });
  }

  TimetableEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? subjectId,
      Value<int>? dayOfWeek,
      Value<int>? startMinutes,
      Value<int>? endMinutes,
      Value<String>? room}) {
    return TimetableEntriesCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      room: room ?? this.room,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetableEntriesCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventsTable extends CalendarEvents
    with TableInfo<$CalendarEventsTable, CalendarEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 150),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isHolidayMeta =
      const VerificationMeta('isHoliday');
  @override
  late final GeneratedColumn<bool> isHoliday = GeneratedColumn<bool>(
      'is_holiday', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_holiday" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, date, description, isHoliday];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_events';
  @override
  VerificationContext validateIntegrity(Insertable<CalendarEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_holiday')) {
      context.handle(_isHolidayMeta,
          isHoliday.isAcceptableOrUnknown(data['is_holiday']!, _isHolidayMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      isHoliday: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_holiday'])!,
    );
  }

  @override
  $CalendarEventsTable createAlias(String alias) {
    return $CalendarEventsTable(attachedDatabase, alias);
  }
}

class CalendarEvent extends DataClass implements Insertable<CalendarEvent> {
  final int id;
  final String title;
  final DateTime date;
  final String description;
  final bool isHoliday;
  const CalendarEvent(
      {required this.id,
      required this.title,
      required this.date,
      required this.description,
      required this.isHoliday});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['description'] = Variable<String>(description);
    map['is_holiday'] = Variable<bool>(isHoliday);
    return map;
  }

  CalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventsCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      description: Value(description),
      isHoliday: Value(isHoliday),
    );
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEvent(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String>(json['description']),
      isHoliday: serializer.fromJson<bool>(json['isHoliday']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String>(description),
      'isHoliday': serializer.toJson<bool>(isHoliday),
    };
  }

  CalendarEvent copyWith(
          {int? id,
          String? title,
          DateTime? date,
          String? description,
          bool? isHoliday}) =>
      CalendarEvent(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        description: description ?? this.description,
        isHoliday: isHoliday ?? this.isHoliday,
      );
  CalendarEvent copyWithCompanion(CalendarEventsCompanion data) {
    return CalendarEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      description:
          data.description.present ? data.description.value : this.description,
      isHoliday: data.isHoliday.present ? data.isHoliday.value : this.isHoliday,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('isHoliday: $isHoliday')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, date, description, isHoliday);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date &&
          other.description == this.description &&
          other.isHoliday == this.isHoliday);
}

class CalendarEventsCompanion extends UpdateCompanion<CalendarEvent> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<String> description;
  final Value<bool> isHoliday;
  const CalendarEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.isHoliday = const Value.absent(),
  });
  CalendarEventsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime date,
    this.description = const Value.absent(),
    this.isHoliday = const Value.absent(),
  })  : title = Value(title),
        date = Value(date);
  static Insertable<CalendarEvent> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<bool>? isHoliday,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (isHoliday != null) 'is_holiday': isHoliday,
    });
  }

  CalendarEventsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<DateTime>? date,
      Value<String>? description,
      Value<bool>? isHoliday}) {
    return CalendarEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      description: description ?? this.description,
      isHoliday: isHoliday ?? this.isHoliday,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isHoliday.present) {
      map['is_holiday'] = Variable<bool>(isHoliday.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('isHoliday: $isHoliday')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $TimetableEntriesTable timetableEntries =
      $TimetableEntriesTable(this);
  late final $CalendarEventsTable calendarEvents = $CalendarEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [subjects, timetableEntries, calendarEvents];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('subjects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('timetable_entries', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> code,
  Value<int?> colorValue,
  Value<DateTime> createdAt,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> code,
  Value<int?> colorValue,
  Value<DateTime> createdAt,
});

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimetableEntriesTable, List<TimetableEntry>>
      _timetableEntriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.timetableEntries,
              aliasName: $_aliasNameGenerator(
                  db.subjects.id, db.timetableEntries.subjectId));

  $$TimetableEntriesTableProcessedTableManager get timetableEntriesRefs {
    final manager =
        $$TimetableEntriesTableTableManager($_db, $_db.timetableEntries)
            .filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_timetableEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> timetableEntriesRefs(
      Expression<bool> Function($$TimetableEntriesTableFilterComposer f) f) {
    final $$TimetableEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.timetableEntries,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimetableEntriesTableFilterComposer(
              $db: $db,
              $table: $db.timetableEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> timetableEntriesRefs<T extends Object>(
      Expression<T> Function($$TimetableEntriesTableAnnotationComposer a) f) {
    final $$TimetableEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.timetableEntries,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimetableEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.timetableEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, $$SubjectsTableReferences),
    Subject,
    PrefetchHooks Function({bool timetableEntriesRefs})> {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<int?> colorValue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SubjectsCompanion(
            id: id,
            name: name,
            code: code,
            colorValue: colorValue,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> code = const Value.absent(),
            Value<int?> colorValue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SubjectsCompanion.insert(
            id: id,
            name: name,
            code: code,
            colorValue: colorValue,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SubjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({timetableEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (timetableEntriesRefs) db.timetableEntries
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timetableEntriesRefs)
                    await $_getPrefetchedData<Subject, $SubjectsTable,
                            TimetableEntry>(
                        currentTable: table,
                        referencedTable: $$SubjectsTableReferences
                            ._timetableEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubjectsTableReferences(db, table, p0)
                                .timetableEntriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subjectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, $$SubjectsTableReferences),
    Subject,
    PrefetchHooks Function({bool timetableEntriesRefs})>;
typedef $$TimetableEntriesTableCreateCompanionBuilder
    = TimetableEntriesCompanion Function({
  Value<int> id,
  required int subjectId,
  required int dayOfWeek,
  required int startMinutes,
  required int endMinutes,
  Value<String> room,
});
typedef $$TimetableEntriesTableUpdateCompanionBuilder
    = TimetableEntriesCompanion Function({
  Value<int> id,
  Value<int> subjectId,
  Value<int> dayOfWeek,
  Value<int> startMinutes,
  Value<int> endMinutes,
  Value<String> room,
});

final class $$TimetableEntriesTableReferences extends BaseReferences<
    _$AppDatabase, $TimetableEntriesTable, TimetableEntry> {
  $$TimetableEntriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias(
          $_aliasNameGenerator(db.timetableEntries.subjectId, db.subjects.id));

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<int>('subject_id')!;

    final manager = $$SubjectsTableTableManager($_db, $_db.subjects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TimetableEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TimetableEntriesTable> {
  $$TimetableEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startMinutes => $composableBuilder(
      column: $table.startMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endMinutes => $composableBuilder(
      column: $table.endMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnFilters(column));

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableFilterComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimetableEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetableEntriesTable> {
  $$TimetableEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startMinutes => $composableBuilder(
      column: $table.startMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endMinutes => $composableBuilder(
      column: $table.endMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnOrderings(column));

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableOrderingComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimetableEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetableEntriesTable> {
  $$TimetableEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
      column: $table.startMinutes, builder: (column) => column);

  GeneratedColumn<int> get endMinutes => $composableBuilder(
      column: $table.endMinutes, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimetableEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TimetableEntriesTable,
    TimetableEntry,
    $$TimetableEntriesTableFilterComposer,
    $$TimetableEntriesTableOrderingComposer,
    $$TimetableEntriesTableAnnotationComposer,
    $$TimetableEntriesTableCreateCompanionBuilder,
    $$TimetableEntriesTableUpdateCompanionBuilder,
    (TimetableEntry, $$TimetableEntriesTableReferences),
    TimetableEntry,
    PrefetchHooks Function({bool subjectId})> {
  $$TimetableEntriesTableTableManager(
      _$AppDatabase db, $TimetableEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetableEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetableEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetableEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> subjectId = const Value.absent(),
            Value<int> dayOfWeek = const Value.absent(),
            Value<int> startMinutes = const Value.absent(),
            Value<int> endMinutes = const Value.absent(),
            Value<String> room = const Value.absent(),
          }) =>
              TimetableEntriesCompanion(
            id: id,
            subjectId: subjectId,
            dayOfWeek: dayOfWeek,
            startMinutes: startMinutes,
            endMinutes: endMinutes,
            room: room,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int subjectId,
            required int dayOfWeek,
            required int startMinutes,
            required int endMinutes,
            Value<String> room = const Value.absent(),
          }) =>
              TimetableEntriesCompanion.insert(
            id: id,
            subjectId: subjectId,
            dayOfWeek: dayOfWeek,
            startMinutes: startMinutes,
            endMinutes: endMinutes,
            room: room,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TimetableEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({subjectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (subjectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subjectId,
                    referencedTable:
                        $$TimetableEntriesTableReferences._subjectIdTable(db),
                    referencedColumn: $$TimetableEntriesTableReferences
                        ._subjectIdTable(db)
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
        ));
}

typedef $$TimetableEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TimetableEntriesTable,
    TimetableEntry,
    $$TimetableEntriesTableFilterComposer,
    $$TimetableEntriesTableOrderingComposer,
    $$TimetableEntriesTableAnnotationComposer,
    $$TimetableEntriesTableCreateCompanionBuilder,
    $$TimetableEntriesTableUpdateCompanionBuilder,
    (TimetableEntry, $$TimetableEntriesTableReferences),
    TimetableEntry,
    PrefetchHooks Function({bool subjectId})>;
typedef $$CalendarEventsTableCreateCompanionBuilder = CalendarEventsCompanion
    Function({
  Value<int> id,
  required String title,
  required DateTime date,
  Value<String> description,
  Value<bool> isHoliday,
});
typedef $$CalendarEventsTableUpdateCompanionBuilder = CalendarEventsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<DateTime> date,
  Value<String> description,
  Value<bool> isHoliday,
});

class $$CalendarEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isHoliday => $composableBuilder(
      column: $table.isHoliday, builder: (column) => ColumnFilters(column));
}

class $$CalendarEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isHoliday => $composableBuilder(
      column: $table.isHoliday, builder: (column) => ColumnOrderings(column));
}

class $$CalendarEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isHoliday =>
      $composableBuilder(column: $table.isHoliday, builder: (column) => column);
}

class $$CalendarEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CalendarEventsTable,
    CalendarEvent,
    $$CalendarEventsTableFilterComposer,
    $$CalendarEventsTableOrderingComposer,
    $$CalendarEventsTableAnnotationComposer,
    $$CalendarEventsTableCreateCompanionBuilder,
    $$CalendarEventsTableUpdateCompanionBuilder,
    (
      CalendarEvent,
      BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEvent>
    ),
    CalendarEvent,
    PrefetchHooks Function()> {
  $$CalendarEventsTableTableManager(
      _$AppDatabase db, $CalendarEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isHoliday = const Value.absent(),
          }) =>
              CalendarEventsCompanion(
            id: id,
            title: title,
            date: date,
            description: description,
            isHoliday: isHoliday,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required DateTime date,
            Value<String> description = const Value.absent(),
            Value<bool> isHoliday = const Value.absent(),
          }) =>
              CalendarEventsCompanion.insert(
            id: id,
            title: title,
            date: date,
            description: description,
            isHoliday: isHoliday,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CalendarEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CalendarEventsTable,
    CalendarEvent,
    $$CalendarEventsTableFilterComposer,
    $$CalendarEventsTableOrderingComposer,
    $$CalendarEventsTableAnnotationComposer,
    $$CalendarEventsTableCreateCompanionBuilder,
    $$CalendarEventsTableUpdateCompanionBuilder,
    (
      CalendarEvent,
      BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEvent>
    ),
    CalendarEvent,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$TimetableEntriesTableTableManager get timetableEntries =>
      $$TimetableEntriesTableTableManager(_db, _db.timetableEntries);
  $$CalendarEventsTableTableManager get calendarEvents =>
      $$CalendarEventsTableTableManager(_db, _db.calendarEvents);
}
