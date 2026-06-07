// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthUtcMeta = const VerificationMeta(
    'birthUtc',
  );
  @override
  late final GeneratedColumn<DateTime> birthUtc = GeneratedColumn<DateTime>(
    'birth_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthLocalIsoMeta = const VerificationMeta(
    'birthLocalIso',
  );
  @override
  late final GeneratedColumn<String> birthLocalIso = GeneratedColumn<String>(
    'birth_local_iso',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthTimeUnknownMeta = const VerificationMeta(
    'birthTimeUnknown',
  );
  @override
  late final GeneratedColumn<bool> birthTimeUnknown = GeneratedColumn<bool>(
    'birth_time_unknown',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("birth_time_unknown" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _birthPlaceNameMeta = const VerificationMeta(
    'birthPlaceName',
  );
  @override
  late final GeneratedColumn<String> birthPlaceName = GeneratedColumn<String>(
    'birth_place_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _longitudeEastMeta = const VerificationMeta(
    'longitudeEast',
  );
  @override
  late final GeneratedColumn<double> longitudeEast = GeneratedColumn<double>(
    'longitude_east',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneOffsetMinutesMeta =
      const VerificationMeta('timezoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timezoneOffsetMinutes = GeneratedColumn<int>(
    'timezone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    birthUtc,
    birthLocalIso,
    birthTimeUnknown,
    birthPlaceName,
    latitude,
    longitudeEast,
    timezoneOffsetMinutes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('birth_utc')) {
      context.handle(
        _birthUtcMeta,
        birthUtc.isAcceptableOrUnknown(data['birth_utc']!, _birthUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_birthUtcMeta);
    }
    if (data.containsKey('birth_local_iso')) {
      context.handle(
        _birthLocalIsoMeta,
        birthLocalIso.isAcceptableOrUnknown(
          data['birth_local_iso']!,
          _birthLocalIsoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birthLocalIsoMeta);
    }
    if (data.containsKey('birth_time_unknown')) {
      context.handle(
        _birthTimeUnknownMeta,
        birthTimeUnknown.isAcceptableOrUnknown(
          data['birth_time_unknown']!,
          _birthTimeUnknownMeta,
        ),
      );
    }
    if (data.containsKey('birth_place_name')) {
      context.handle(
        _birthPlaceNameMeta,
        birthPlaceName.isAcceptableOrUnknown(
          data['birth_place_name']!,
          _birthPlaceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birthPlaceNameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude_east')) {
      context.handle(
        _longitudeEastMeta,
        longitudeEast.isAcceptableOrUnknown(
          data['longitude_east']!,
          _longitudeEastMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_longitudeEastMeta);
    }
    if (data.containsKey('timezone_offset_minutes')) {
      context.handle(
        _timezoneOffsetMinutesMeta,
        timezoneOffsetMinutes.isAcceptableOrUnknown(
          data['timezone_offset_minutes']!,
          _timezoneOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timezoneOffsetMinutesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      birthUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_utc'],
      )!,
      birthLocalIso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_local_iso'],
      )!,
      birthTimeUnknown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}birth_time_unknown'],
      )!,
      birthPlaceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_place_name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitudeEast: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude_east'],
      )!,
      timezoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timezone_offset_minutes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String? displayName;

  /// 出生時刻（UTC、JD計算用）
  final DateTime birthUtc;

  /// 表示用：現地日時の文字列（"1990-05-15T09:30"）
  final String birthLocalIso;

  /// 出生時刻が不明か（true のとき内部で 12:00 を使用、ASC/ハウスは注意付き表示）
  final bool birthTimeUnknown;

  /// 表示用の出生地名（"東京都" など）
  final String birthPlaceName;
  final double latitude;
  final double longitudeEast;

  /// UTCからの分単位オフセット（JST=+540）
  final int timezoneOffsetMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile({
    required this.id,
    this.displayName,
    required this.birthUtc,
    required this.birthLocalIso,
    required this.birthTimeUnknown,
    required this.birthPlaceName,
    required this.latitude,
    required this.longitudeEast,
    required this.timezoneOffsetMinutes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['birth_utc'] = Variable<DateTime>(birthUtc);
    map['birth_local_iso'] = Variable<String>(birthLocalIso);
    map['birth_time_unknown'] = Variable<bool>(birthTimeUnknown);
    map['birth_place_name'] = Variable<String>(birthPlaceName);
    map['latitude'] = Variable<double>(latitude);
    map['longitude_east'] = Variable<double>(longitudeEast);
    map['timezone_offset_minutes'] = Variable<int>(timezoneOffsetMinutes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      birthUtc: Value(birthUtc),
      birthLocalIso: Value(birthLocalIso),
      birthTimeUnknown: Value(birthTimeUnknown),
      birthPlaceName: Value(birthPlaceName),
      latitude: Value(latitude),
      longitudeEast: Value(longitudeEast),
      timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      birthUtc: serializer.fromJson<DateTime>(json['birthUtc']),
      birthLocalIso: serializer.fromJson<String>(json['birthLocalIso']),
      birthTimeUnknown: serializer.fromJson<bool>(json['birthTimeUnknown']),
      birthPlaceName: serializer.fromJson<String>(json['birthPlaceName']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitudeEast: serializer.fromJson<double>(json['longitudeEast']),
      timezoneOffsetMinutes: serializer.fromJson<int>(
        json['timezoneOffsetMinutes'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String?>(displayName),
      'birthUtc': serializer.toJson<DateTime>(birthUtc),
      'birthLocalIso': serializer.toJson<String>(birthLocalIso),
      'birthTimeUnknown': serializer.toJson<bool>(birthTimeUnknown),
      'birthPlaceName': serializer.toJson<String>(birthPlaceName),
      'latitude': serializer.toJson<double>(latitude),
      'longitudeEast': serializer.toJson<double>(longitudeEast),
      'timezoneOffsetMinutes': serializer.toJson<int>(timezoneOffsetMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    int? id,
    Value<String?> displayName = const Value.absent(),
    DateTime? birthUtc,
    String? birthLocalIso,
    bool? birthTimeUnknown,
    String? birthPlaceName,
    double? latitude,
    double? longitudeEast,
    int? timezoneOffsetMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    displayName: displayName.present ? displayName.value : this.displayName,
    birthUtc: birthUtc ?? this.birthUtc,
    birthLocalIso: birthLocalIso ?? this.birthLocalIso,
    birthTimeUnknown: birthTimeUnknown ?? this.birthTimeUnknown,
    birthPlaceName: birthPlaceName ?? this.birthPlaceName,
    latitude: latitude ?? this.latitude,
    longitudeEast: longitudeEast ?? this.longitudeEast,
    timezoneOffsetMinutes: timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      birthUtc: data.birthUtc.present ? data.birthUtc.value : this.birthUtc,
      birthLocalIso: data.birthLocalIso.present
          ? data.birthLocalIso.value
          : this.birthLocalIso,
      birthTimeUnknown: data.birthTimeUnknown.present
          ? data.birthTimeUnknown.value
          : this.birthTimeUnknown,
      birthPlaceName: data.birthPlaceName.present
          ? data.birthPlaceName.value
          : this.birthPlaceName,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitudeEast: data.longitudeEast.present
          ? data.longitudeEast.value
          : this.longitudeEast,
      timezoneOffsetMinutes: data.timezoneOffsetMinutes.present
          ? data.timezoneOffsetMinutes.value
          : this.timezoneOffsetMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('birthUtc: $birthUtc, ')
          ..write('birthLocalIso: $birthLocalIso, ')
          ..write('birthTimeUnknown: $birthTimeUnknown, ')
          ..write('birthPlaceName: $birthPlaceName, ')
          ..write('latitude: $latitude, ')
          ..write('longitudeEast: $longitudeEast, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    birthUtc,
    birthLocalIso,
    birthTimeUnknown,
    birthPlaceName,
    latitude,
    longitudeEast,
    timezoneOffsetMinutes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.birthUtc == this.birthUtc &&
          other.birthLocalIso == this.birthLocalIso &&
          other.birthTimeUnknown == this.birthTimeUnknown &&
          other.birthPlaceName == this.birthPlaceName &&
          other.latitude == this.latitude &&
          other.longitudeEast == this.longitudeEast &&
          other.timezoneOffsetMinutes == this.timezoneOffsetMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String?> displayName;
  final Value<DateTime> birthUtc;
  final Value<String> birthLocalIso;
  final Value<bool> birthTimeUnknown;
  final Value<String> birthPlaceName;
  final Value<double> latitude;
  final Value<double> longitudeEast;
  final Value<int> timezoneOffsetMinutes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.birthUtc = const Value.absent(),
    this.birthLocalIso = const Value.absent(),
    this.birthTimeUnknown = const Value.absent(),
    this.birthPlaceName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitudeEast = const Value.absent(),
    this.timezoneOffsetMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    required DateTime birthUtc,
    required String birthLocalIso,
    this.birthTimeUnknown = const Value.absent(),
    required String birthPlaceName,
    required double latitude,
    required double longitudeEast,
    required int timezoneOffsetMinutes,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : birthUtc = Value(birthUtc),
       birthLocalIso = Value(birthLocalIso),
       birthPlaceName = Value(birthPlaceName),
       latitude = Value(latitude),
       longitudeEast = Value(longitudeEast),
       timezoneOffsetMinutes = Value(timezoneOffsetMinutes);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<DateTime>? birthUtc,
    Expression<String>? birthLocalIso,
    Expression<bool>? birthTimeUnknown,
    Expression<String>? birthPlaceName,
    Expression<double>? latitude,
    Expression<double>? longitudeEast,
    Expression<int>? timezoneOffsetMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (birthUtc != null) 'birth_utc': birthUtc,
      if (birthLocalIso != null) 'birth_local_iso': birthLocalIso,
      if (birthTimeUnknown != null) 'birth_time_unknown': birthTimeUnknown,
      if (birthPlaceName != null) 'birth_place_name': birthPlaceName,
      if (latitude != null) 'latitude': latitude,
      if (longitudeEast != null) 'longitude_east': longitudeEast,
      if (timezoneOffsetMinutes != null)
        'timezone_offset_minutes': timezoneOffsetMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String?>? displayName,
    Value<DateTime>? birthUtc,
    Value<String>? birthLocalIso,
    Value<bool>? birthTimeUnknown,
    Value<String>? birthPlaceName,
    Value<double>? latitude,
    Value<double>? longitudeEast,
    Value<int>? timezoneOffsetMinutes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      birthUtc: birthUtc ?? this.birthUtc,
      birthLocalIso: birthLocalIso ?? this.birthLocalIso,
      birthTimeUnknown: birthTimeUnknown ?? this.birthTimeUnknown,
      birthPlaceName: birthPlaceName ?? this.birthPlaceName,
      latitude: latitude ?? this.latitude,
      longitudeEast: longitudeEast ?? this.longitudeEast,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (birthUtc.present) {
      map['birth_utc'] = Variable<DateTime>(birthUtc.value);
    }
    if (birthLocalIso.present) {
      map['birth_local_iso'] = Variable<String>(birthLocalIso.value);
    }
    if (birthTimeUnknown.present) {
      map['birth_time_unknown'] = Variable<bool>(birthTimeUnknown.value);
    }
    if (birthPlaceName.present) {
      map['birth_place_name'] = Variable<String>(birthPlaceName.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitudeEast.present) {
      map['longitude_east'] = Variable<double>(longitudeEast.value);
    }
    if (timezoneOffsetMinutes.present) {
      map['timezone_offset_minutes'] = Variable<int>(
        timezoneOffsetMinutes.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('birthUtc: $birthUtc, ')
          ..write('birthLocalIso: $birthLocalIso, ')
          ..write('birthTimeUnknown: $birthTimeUnknown, ')
          ..write('birthPlaceName: $birthPlaceName, ')
          ..write('latitude: $latitude, ')
          ..write('longitudeEast: $longitudeEast, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NatalChartCachesTable extends NatalChartCaches
    with TableInfo<$NatalChartCachesTable, NatalChartCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NatalChartCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userProfileIdMeta = const VerificationMeta(
    'userProfileId',
  );
  @override
  late final GeneratedColumn<int> userProfileId = GeneratedColumn<int>(
    'user_profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _jdMeta = const VerificationMeta('jd');
  @override
  late final GeneratedColumn<double> jd = GeneratedColumn<double>(
    'jd',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<Body, double>, String>
  positions =
      GeneratedColumn<String>(
        'positions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<Body, double>>(
        $NatalChartCachesTable.$converterpositions,
      );
  static const VerificationMeta _ascendantMeta = const VerificationMeta(
    'ascendant',
  );
  @override
  late final GeneratedColumn<double> ascendant = GeneratedColumn<double>(
    'ascendant',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _midheavenMeta = const VerificationMeta(
    'midheaven',
  );
  @override
  late final GeneratedColumn<double> midheaven = GeneratedColumn<double>(
    'midheaven',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<double>, String> cusps =
      GeneratedColumn<String>(
        'cusps',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<double>>($NatalChartCachesTable.$convertercusps);
  @override
  late final GeneratedColumnWithTypeConverter<List<Aspect>, String> aspects =
      GeneratedColumn<String>(
        'aspects',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<Aspect>>($NatalChartCachesTable.$converteraspects);
  static const VerificationMeta _houseSystemMeta = const VerificationMeta(
    'houseSystem',
  );
  @override
  late final GeneratedColumn<String> houseSystem = GeneratedColumn<String>(
    'house_system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ephemerisVersionMeta = const VerificationMeta(
    'ephemerisVersion',
  );
  @override
  late final GeneratedColumn<String> ephemerisVersion = GeneratedColumn<String>(
    'ephemeris_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userProfileId,
    jd,
    positions,
    ascendant,
    midheaven,
    cusps,
    aspects,
    houseSystem,
    ephemerisVersion,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'natal_chart_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<NatalChartCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_profile_id')) {
      context.handle(
        _userProfileIdMeta,
        userProfileId.isAcceptableOrUnknown(
          data['user_profile_id']!,
          _userProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('jd')) {
      context.handle(_jdMeta, jd.isAcceptableOrUnknown(data['jd']!, _jdMeta));
    } else if (isInserting) {
      context.missing(_jdMeta);
    }
    if (data.containsKey('ascendant')) {
      context.handle(
        _ascendantMeta,
        ascendant.isAcceptableOrUnknown(data['ascendant']!, _ascendantMeta),
      );
    } else if (isInserting) {
      context.missing(_ascendantMeta);
    }
    if (data.containsKey('midheaven')) {
      context.handle(
        _midheavenMeta,
        midheaven.isAcceptableOrUnknown(data['midheaven']!, _midheavenMeta),
      );
    } else if (isInserting) {
      context.missing(_midheavenMeta);
    }
    if (data.containsKey('house_system')) {
      context.handle(
        _houseSystemMeta,
        houseSystem.isAcceptableOrUnknown(
          data['house_system']!,
          _houseSystemMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_houseSystemMeta);
    }
    if (data.containsKey('ephemeris_version')) {
      context.handle(
        _ephemerisVersionMeta,
        ephemerisVersion.isAcceptableOrUnknown(
          data['ephemeris_version']!,
          _ephemerisVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ephemerisVersionMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userProfileId};
  @override
  NatalChartCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NatalChartCache(
      userProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_profile_id'],
      )!,
      jd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}jd'],
      )!,
      positions: $NatalChartCachesTable.$converterpositions.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}positions'],
        )!,
      ),
      ascendant: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ascendant'],
      )!,
      midheaven: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}midheaven'],
      )!,
      cusps: $NatalChartCachesTable.$convertercusps.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cusps'],
        )!,
      ),
      aspects: $NatalChartCachesTable.$converteraspects.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}aspects'],
        )!,
      ),
      houseSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_system'],
      )!,
      ephemerisVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ephemeris_version'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $NatalChartCachesTable createAlias(String alias) {
    return $NatalChartCachesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<Body, double>, String> $converterpositions =
      const BodyMapConverter();
  static TypeConverter<List<double>, String> $convertercusps =
      const DoubleListConverter();
  static TypeConverter<List<Aspect>, String> $converteraspects =
      const AspectListConverter();
}

class NatalChartCache extends DataClass implements Insertable<NatalChartCache> {
  final int userProfileId;
  final double jd;
  final Map<Body, double> positions;
  final double ascendant;
  final double midheaven;
  final List<double> cusps;
  final List<Aspect> aspects;

  /// 'wholeSign' / 'equal'
  final String houseSystem;

  /// 計算したエンジンのバージョン（差分があれば再計算）
  final String ephemerisVersion;
  final DateTime generatedAt;
  const NatalChartCache({
    required this.userProfileId,
    required this.jd,
    required this.positions,
    required this.ascendant,
    required this.midheaven,
    required this.cusps,
    required this.aspects,
    required this.houseSystem,
    required this.ephemerisVersion,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_profile_id'] = Variable<int>(userProfileId);
    map['jd'] = Variable<double>(jd);
    {
      map['positions'] = Variable<String>(
        $NatalChartCachesTable.$converterpositions.toSql(positions),
      );
    }
    map['ascendant'] = Variable<double>(ascendant);
    map['midheaven'] = Variable<double>(midheaven);
    {
      map['cusps'] = Variable<String>(
        $NatalChartCachesTable.$convertercusps.toSql(cusps),
      );
    }
    {
      map['aspects'] = Variable<String>(
        $NatalChartCachesTable.$converteraspects.toSql(aspects),
      );
    }
    map['house_system'] = Variable<String>(houseSystem);
    map['ephemeris_version'] = Variable<String>(ephemerisVersion);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  NatalChartCachesCompanion toCompanion(bool nullToAbsent) {
    return NatalChartCachesCompanion(
      userProfileId: Value(userProfileId),
      jd: Value(jd),
      positions: Value(positions),
      ascendant: Value(ascendant),
      midheaven: Value(midheaven),
      cusps: Value(cusps),
      aspects: Value(aspects),
      houseSystem: Value(houseSystem),
      ephemerisVersion: Value(ephemerisVersion),
      generatedAt: Value(generatedAt),
    );
  }

  factory NatalChartCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NatalChartCache(
      userProfileId: serializer.fromJson<int>(json['userProfileId']),
      jd: serializer.fromJson<double>(json['jd']),
      positions: serializer.fromJson<Map<Body, double>>(json['positions']),
      ascendant: serializer.fromJson<double>(json['ascendant']),
      midheaven: serializer.fromJson<double>(json['midheaven']),
      cusps: serializer.fromJson<List<double>>(json['cusps']),
      aspects: serializer.fromJson<List<Aspect>>(json['aspects']),
      houseSystem: serializer.fromJson<String>(json['houseSystem']),
      ephemerisVersion: serializer.fromJson<String>(json['ephemerisVersion']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userProfileId': serializer.toJson<int>(userProfileId),
      'jd': serializer.toJson<double>(jd),
      'positions': serializer.toJson<Map<Body, double>>(positions),
      'ascendant': serializer.toJson<double>(ascendant),
      'midheaven': serializer.toJson<double>(midheaven),
      'cusps': serializer.toJson<List<double>>(cusps),
      'aspects': serializer.toJson<List<Aspect>>(aspects),
      'houseSystem': serializer.toJson<String>(houseSystem),
      'ephemerisVersion': serializer.toJson<String>(ephemerisVersion),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  NatalChartCache copyWith({
    int? userProfileId,
    double? jd,
    Map<Body, double>? positions,
    double? ascendant,
    double? midheaven,
    List<double>? cusps,
    List<Aspect>? aspects,
    String? houseSystem,
    String? ephemerisVersion,
    DateTime? generatedAt,
  }) => NatalChartCache(
    userProfileId: userProfileId ?? this.userProfileId,
    jd: jd ?? this.jd,
    positions: positions ?? this.positions,
    ascendant: ascendant ?? this.ascendant,
    midheaven: midheaven ?? this.midheaven,
    cusps: cusps ?? this.cusps,
    aspects: aspects ?? this.aspects,
    houseSystem: houseSystem ?? this.houseSystem,
    ephemerisVersion: ephemerisVersion ?? this.ephemerisVersion,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  NatalChartCache copyWithCompanion(NatalChartCachesCompanion data) {
    return NatalChartCache(
      userProfileId: data.userProfileId.present
          ? data.userProfileId.value
          : this.userProfileId,
      jd: data.jd.present ? data.jd.value : this.jd,
      positions: data.positions.present ? data.positions.value : this.positions,
      ascendant: data.ascendant.present ? data.ascendant.value : this.ascendant,
      midheaven: data.midheaven.present ? data.midheaven.value : this.midheaven,
      cusps: data.cusps.present ? data.cusps.value : this.cusps,
      aspects: data.aspects.present ? data.aspects.value : this.aspects,
      houseSystem: data.houseSystem.present
          ? data.houseSystem.value
          : this.houseSystem,
      ephemerisVersion: data.ephemerisVersion.present
          ? data.ephemerisVersion.value
          : this.ephemerisVersion,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NatalChartCache(')
          ..write('userProfileId: $userProfileId, ')
          ..write('jd: $jd, ')
          ..write('positions: $positions, ')
          ..write('ascendant: $ascendant, ')
          ..write('midheaven: $midheaven, ')
          ..write('cusps: $cusps, ')
          ..write('aspects: $aspects, ')
          ..write('houseSystem: $houseSystem, ')
          ..write('ephemerisVersion: $ephemerisVersion, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userProfileId,
    jd,
    positions,
    ascendant,
    midheaven,
    cusps,
    aspects,
    houseSystem,
    ephemerisVersion,
    generatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NatalChartCache &&
          other.userProfileId == this.userProfileId &&
          other.jd == this.jd &&
          other.positions == this.positions &&
          other.ascendant == this.ascendant &&
          other.midheaven == this.midheaven &&
          other.cusps == this.cusps &&
          other.aspects == this.aspects &&
          other.houseSystem == this.houseSystem &&
          other.ephemerisVersion == this.ephemerisVersion &&
          other.generatedAt == this.generatedAt);
}

class NatalChartCachesCompanion extends UpdateCompanion<NatalChartCache> {
  final Value<int> userProfileId;
  final Value<double> jd;
  final Value<Map<Body, double>> positions;
  final Value<double> ascendant;
  final Value<double> midheaven;
  final Value<List<double>> cusps;
  final Value<List<Aspect>> aspects;
  final Value<String> houseSystem;
  final Value<String> ephemerisVersion;
  final Value<DateTime> generatedAt;
  const NatalChartCachesCompanion({
    this.userProfileId = const Value.absent(),
    this.jd = const Value.absent(),
    this.positions = const Value.absent(),
    this.ascendant = const Value.absent(),
    this.midheaven = const Value.absent(),
    this.cusps = const Value.absent(),
    this.aspects = const Value.absent(),
    this.houseSystem = const Value.absent(),
    this.ephemerisVersion = const Value.absent(),
    this.generatedAt = const Value.absent(),
  });
  NatalChartCachesCompanion.insert({
    this.userProfileId = const Value.absent(),
    required double jd,
    required Map<Body, double> positions,
    required double ascendant,
    required double midheaven,
    required List<double> cusps,
    required List<Aspect> aspects,
    required String houseSystem,
    required String ephemerisVersion,
    this.generatedAt = const Value.absent(),
  }) : jd = Value(jd),
       positions = Value(positions),
       ascendant = Value(ascendant),
       midheaven = Value(midheaven),
       cusps = Value(cusps),
       aspects = Value(aspects),
       houseSystem = Value(houseSystem),
       ephemerisVersion = Value(ephemerisVersion);
  static Insertable<NatalChartCache> custom({
    Expression<int>? userProfileId,
    Expression<double>? jd,
    Expression<String>? positions,
    Expression<double>? ascendant,
    Expression<double>? midheaven,
    Expression<String>? cusps,
    Expression<String>? aspects,
    Expression<String>? houseSystem,
    Expression<String>? ephemerisVersion,
    Expression<DateTime>? generatedAt,
  }) {
    return RawValuesInsertable({
      if (userProfileId != null) 'user_profile_id': userProfileId,
      if (jd != null) 'jd': jd,
      if (positions != null) 'positions': positions,
      if (ascendant != null) 'ascendant': ascendant,
      if (midheaven != null) 'midheaven': midheaven,
      if (cusps != null) 'cusps': cusps,
      if (aspects != null) 'aspects': aspects,
      if (houseSystem != null) 'house_system': houseSystem,
      if (ephemerisVersion != null) 'ephemeris_version': ephemerisVersion,
      if (generatedAt != null) 'generated_at': generatedAt,
    });
  }

  NatalChartCachesCompanion copyWith({
    Value<int>? userProfileId,
    Value<double>? jd,
    Value<Map<Body, double>>? positions,
    Value<double>? ascendant,
    Value<double>? midheaven,
    Value<List<double>>? cusps,
    Value<List<Aspect>>? aspects,
    Value<String>? houseSystem,
    Value<String>? ephemerisVersion,
    Value<DateTime>? generatedAt,
  }) {
    return NatalChartCachesCompanion(
      userProfileId: userProfileId ?? this.userProfileId,
      jd: jd ?? this.jd,
      positions: positions ?? this.positions,
      ascendant: ascendant ?? this.ascendant,
      midheaven: midheaven ?? this.midheaven,
      cusps: cusps ?? this.cusps,
      aspects: aspects ?? this.aspects,
      houseSystem: houseSystem ?? this.houseSystem,
      ephemerisVersion: ephemerisVersion ?? this.ephemerisVersion,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userProfileId.present) {
      map['user_profile_id'] = Variable<int>(userProfileId.value);
    }
    if (jd.present) {
      map['jd'] = Variable<double>(jd.value);
    }
    if (positions.present) {
      map['positions'] = Variable<String>(
        $NatalChartCachesTable.$converterpositions.toSql(positions.value),
      );
    }
    if (ascendant.present) {
      map['ascendant'] = Variable<double>(ascendant.value);
    }
    if (midheaven.present) {
      map['midheaven'] = Variable<double>(midheaven.value);
    }
    if (cusps.present) {
      map['cusps'] = Variable<String>(
        $NatalChartCachesTable.$convertercusps.toSql(cusps.value),
      );
    }
    if (aspects.present) {
      map['aspects'] = Variable<String>(
        $NatalChartCachesTable.$converteraspects.toSql(aspects.value),
      );
    }
    if (houseSystem.present) {
      map['house_system'] = Variable<String>(houseSystem.value);
    }
    if (ephemerisVersion.present) {
      map['ephemeris_version'] = Variable<String>(ephemerisVersion.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NatalChartCachesCompanion(')
          ..write('userProfileId: $userProfileId, ')
          ..write('jd: $jd, ')
          ..write('positions: $positions, ')
          ..write('ascendant: $ascendant, ')
          ..write('midheaven: $midheaven, ')
          ..write('cusps: $cusps, ')
          ..write('aspects: $aspects, ')
          ..write('houseSystem: $houseSystem, ')
          ..write('ephemerisVersion: $ephemerisVersion, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }
}

class $PartnersTable extends Partners with TableInfo<$PartnersTable, Partner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartnersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userProfileIdMeta = const VerificationMeta(
    'userProfileId',
  );
  @override
  late final GeneratedColumn<int> userProfileId = GeneratedColumn<int>(
    'user_profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthUtcMeta = const VerificationMeta(
    'birthUtc',
  );
  @override
  late final GeneratedColumn<DateTime> birthUtc = GeneratedColumn<DateTime>(
    'birth_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthLocalIsoMeta = const VerificationMeta(
    'birthLocalIso',
  );
  @override
  late final GeneratedColumn<String> birthLocalIso = GeneratedColumn<String>(
    'birth_local_iso',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthTimeUnknownMeta = const VerificationMeta(
    'birthTimeUnknown',
  );
  @override
  late final GeneratedColumn<bool> birthTimeUnknown = GeneratedColumn<bool>(
    'birth_time_unknown',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("birth_time_unknown" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _birthPlaceNameMeta = const VerificationMeta(
    'birthPlaceName',
  );
  @override
  late final GeneratedColumn<String> birthPlaceName = GeneratedColumn<String>(
    'birth_place_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _longitudeEastMeta = const VerificationMeta(
    'longitudeEast',
  );
  @override
  late final GeneratedColumn<double> longitudeEast = GeneratedColumn<double>(
    'longitude_east',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneOffsetMinutesMeta =
      const VerificationMeta('timezoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timezoneOffsetMinutes = GeneratedColumn<int>(
    'timezone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationshipMeta = const VerificationMeta(
    'relationship',
  );
  @override
  late final GeneratedColumn<String> relationship = GeneratedColumn<String>(
    'relationship',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userProfileId,
    name,
    birthUtc,
    birthLocalIso,
    birthTimeUnknown,
    birthPlaceName,
    latitude,
    longitudeEast,
    timezoneOffsetMinutes,
    relationship,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'partners';
  @override
  VerificationContext validateIntegrity(
    Insertable<Partner> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_profile_id')) {
      context.handle(
        _userProfileIdMeta,
        userProfileId.isAcceptableOrUnknown(
          data['user_profile_id']!,
          _userProfileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userProfileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birth_utc')) {
      context.handle(
        _birthUtcMeta,
        birthUtc.isAcceptableOrUnknown(data['birth_utc']!, _birthUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_birthUtcMeta);
    }
    if (data.containsKey('birth_local_iso')) {
      context.handle(
        _birthLocalIsoMeta,
        birthLocalIso.isAcceptableOrUnknown(
          data['birth_local_iso']!,
          _birthLocalIsoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birthLocalIsoMeta);
    }
    if (data.containsKey('birth_time_unknown')) {
      context.handle(
        _birthTimeUnknownMeta,
        birthTimeUnknown.isAcceptableOrUnknown(
          data['birth_time_unknown']!,
          _birthTimeUnknownMeta,
        ),
      );
    }
    if (data.containsKey('birth_place_name')) {
      context.handle(
        _birthPlaceNameMeta,
        birthPlaceName.isAcceptableOrUnknown(
          data['birth_place_name']!,
          _birthPlaceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birthPlaceNameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude_east')) {
      context.handle(
        _longitudeEastMeta,
        longitudeEast.isAcceptableOrUnknown(
          data['longitude_east']!,
          _longitudeEastMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_longitudeEastMeta);
    }
    if (data.containsKey('timezone_offset_minutes')) {
      context.handle(
        _timezoneOffsetMinutesMeta,
        timezoneOffsetMinutes.isAcceptableOrUnknown(
          data['timezone_offset_minutes']!,
          _timezoneOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timezoneOffsetMinutesMeta);
    }
    if (data.containsKey('relationship')) {
      context.handle(
        _relationshipMeta,
        relationship.isAcceptableOrUnknown(
          data['relationship']!,
          _relationshipMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Partner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Partner(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birthUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_utc'],
      )!,
      birthLocalIso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_local_iso'],
      )!,
      birthTimeUnknown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}birth_time_unknown'],
      )!,
      birthPlaceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_place_name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitudeEast: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude_east'],
      )!,
      timezoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timezone_offset_minutes'],
      )!,
      relationship: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PartnersTable createAlias(String alias) {
    return $PartnersTable(attachedDatabase, alias);
  }
}

class Partner extends DataClass implements Insertable<Partner> {
  final int id;
  final int userProfileId;
  final String name;
  final DateTime birthUtc;
  final String birthLocalIso;
  final bool birthTimeUnknown;
  final String birthPlaceName;
  final double latitude;
  final double longitudeEast;
  final int timezoneOffsetMinutes;

  /// 'lover' / 'friend' / 'family' / 'work' / 'other'
  final String relationship;
  final DateTime createdAt;
  const Partner({
    required this.id,
    required this.userProfileId,
    required this.name,
    required this.birthUtc,
    required this.birthLocalIso,
    required this.birthTimeUnknown,
    required this.birthPlaceName,
    required this.latitude,
    required this.longitudeEast,
    required this.timezoneOffsetMinutes,
    required this.relationship,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_profile_id'] = Variable<int>(userProfileId);
    map['name'] = Variable<String>(name);
    map['birth_utc'] = Variable<DateTime>(birthUtc);
    map['birth_local_iso'] = Variable<String>(birthLocalIso);
    map['birth_time_unknown'] = Variable<bool>(birthTimeUnknown);
    map['birth_place_name'] = Variable<String>(birthPlaceName);
    map['latitude'] = Variable<double>(latitude);
    map['longitude_east'] = Variable<double>(longitudeEast);
    map['timezone_offset_minutes'] = Variable<int>(timezoneOffsetMinutes);
    map['relationship'] = Variable<String>(relationship);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PartnersCompanion toCompanion(bool nullToAbsent) {
    return PartnersCompanion(
      id: Value(id),
      userProfileId: Value(userProfileId),
      name: Value(name),
      birthUtc: Value(birthUtc),
      birthLocalIso: Value(birthLocalIso),
      birthTimeUnknown: Value(birthTimeUnknown),
      birthPlaceName: Value(birthPlaceName),
      latitude: Value(latitude),
      longitudeEast: Value(longitudeEast),
      timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
      relationship: Value(relationship),
      createdAt: Value(createdAt),
    );
  }

  factory Partner.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Partner(
      id: serializer.fromJson<int>(json['id']),
      userProfileId: serializer.fromJson<int>(json['userProfileId']),
      name: serializer.fromJson<String>(json['name']),
      birthUtc: serializer.fromJson<DateTime>(json['birthUtc']),
      birthLocalIso: serializer.fromJson<String>(json['birthLocalIso']),
      birthTimeUnknown: serializer.fromJson<bool>(json['birthTimeUnknown']),
      birthPlaceName: serializer.fromJson<String>(json['birthPlaceName']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitudeEast: serializer.fromJson<double>(json['longitudeEast']),
      timezoneOffsetMinutes: serializer.fromJson<int>(
        json['timezoneOffsetMinutes'],
      ),
      relationship: serializer.fromJson<String>(json['relationship']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userProfileId': serializer.toJson<int>(userProfileId),
      'name': serializer.toJson<String>(name),
      'birthUtc': serializer.toJson<DateTime>(birthUtc),
      'birthLocalIso': serializer.toJson<String>(birthLocalIso),
      'birthTimeUnknown': serializer.toJson<bool>(birthTimeUnknown),
      'birthPlaceName': serializer.toJson<String>(birthPlaceName),
      'latitude': serializer.toJson<double>(latitude),
      'longitudeEast': serializer.toJson<double>(longitudeEast),
      'timezoneOffsetMinutes': serializer.toJson<int>(timezoneOffsetMinutes),
      'relationship': serializer.toJson<String>(relationship),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Partner copyWith({
    int? id,
    int? userProfileId,
    String? name,
    DateTime? birthUtc,
    String? birthLocalIso,
    bool? birthTimeUnknown,
    String? birthPlaceName,
    double? latitude,
    double? longitudeEast,
    int? timezoneOffsetMinutes,
    String? relationship,
    DateTime? createdAt,
  }) => Partner(
    id: id ?? this.id,
    userProfileId: userProfileId ?? this.userProfileId,
    name: name ?? this.name,
    birthUtc: birthUtc ?? this.birthUtc,
    birthLocalIso: birthLocalIso ?? this.birthLocalIso,
    birthTimeUnknown: birthTimeUnknown ?? this.birthTimeUnknown,
    birthPlaceName: birthPlaceName ?? this.birthPlaceName,
    latitude: latitude ?? this.latitude,
    longitudeEast: longitudeEast ?? this.longitudeEast,
    timezoneOffsetMinutes: timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    relationship: relationship ?? this.relationship,
    createdAt: createdAt ?? this.createdAt,
  );
  Partner copyWithCompanion(PartnersCompanion data) {
    return Partner(
      id: data.id.present ? data.id.value : this.id,
      userProfileId: data.userProfileId.present
          ? data.userProfileId.value
          : this.userProfileId,
      name: data.name.present ? data.name.value : this.name,
      birthUtc: data.birthUtc.present ? data.birthUtc.value : this.birthUtc,
      birthLocalIso: data.birthLocalIso.present
          ? data.birthLocalIso.value
          : this.birthLocalIso,
      birthTimeUnknown: data.birthTimeUnknown.present
          ? data.birthTimeUnknown.value
          : this.birthTimeUnknown,
      birthPlaceName: data.birthPlaceName.present
          ? data.birthPlaceName.value
          : this.birthPlaceName,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitudeEast: data.longitudeEast.present
          ? data.longitudeEast.value
          : this.longitudeEast,
      timezoneOffsetMinutes: data.timezoneOffsetMinutes.present
          ? data.timezoneOffsetMinutes.value
          : this.timezoneOffsetMinutes,
      relationship: data.relationship.present
          ? data.relationship.value
          : this.relationship,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Partner(')
          ..write('id: $id, ')
          ..write('userProfileId: $userProfileId, ')
          ..write('name: $name, ')
          ..write('birthUtc: $birthUtc, ')
          ..write('birthLocalIso: $birthLocalIso, ')
          ..write('birthTimeUnknown: $birthTimeUnknown, ')
          ..write('birthPlaceName: $birthPlaceName, ')
          ..write('latitude: $latitude, ')
          ..write('longitudeEast: $longitudeEast, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('relationship: $relationship, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userProfileId,
    name,
    birthUtc,
    birthLocalIso,
    birthTimeUnknown,
    birthPlaceName,
    latitude,
    longitudeEast,
    timezoneOffsetMinutes,
    relationship,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Partner &&
          other.id == this.id &&
          other.userProfileId == this.userProfileId &&
          other.name == this.name &&
          other.birthUtc == this.birthUtc &&
          other.birthLocalIso == this.birthLocalIso &&
          other.birthTimeUnknown == this.birthTimeUnknown &&
          other.birthPlaceName == this.birthPlaceName &&
          other.latitude == this.latitude &&
          other.longitudeEast == this.longitudeEast &&
          other.timezoneOffsetMinutes == this.timezoneOffsetMinutes &&
          other.relationship == this.relationship &&
          other.createdAt == this.createdAt);
}

class PartnersCompanion extends UpdateCompanion<Partner> {
  final Value<int> id;
  final Value<int> userProfileId;
  final Value<String> name;
  final Value<DateTime> birthUtc;
  final Value<String> birthLocalIso;
  final Value<bool> birthTimeUnknown;
  final Value<String> birthPlaceName;
  final Value<double> latitude;
  final Value<double> longitudeEast;
  final Value<int> timezoneOffsetMinutes;
  final Value<String> relationship;
  final Value<DateTime> createdAt;
  const PartnersCompanion({
    this.id = const Value.absent(),
    this.userProfileId = const Value.absent(),
    this.name = const Value.absent(),
    this.birthUtc = const Value.absent(),
    this.birthLocalIso = const Value.absent(),
    this.birthTimeUnknown = const Value.absent(),
    this.birthPlaceName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitudeEast = const Value.absent(),
    this.timezoneOffsetMinutes = const Value.absent(),
    this.relationship = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PartnersCompanion.insert({
    this.id = const Value.absent(),
    required int userProfileId,
    required String name,
    required DateTime birthUtc,
    required String birthLocalIso,
    this.birthTimeUnknown = const Value.absent(),
    required String birthPlaceName,
    required double latitude,
    required double longitudeEast,
    required int timezoneOffsetMinutes,
    this.relationship = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : userProfileId = Value(userProfileId),
       name = Value(name),
       birthUtc = Value(birthUtc),
       birthLocalIso = Value(birthLocalIso),
       birthPlaceName = Value(birthPlaceName),
       latitude = Value(latitude),
       longitudeEast = Value(longitudeEast),
       timezoneOffsetMinutes = Value(timezoneOffsetMinutes);
  static Insertable<Partner> custom({
    Expression<int>? id,
    Expression<int>? userProfileId,
    Expression<String>? name,
    Expression<DateTime>? birthUtc,
    Expression<String>? birthLocalIso,
    Expression<bool>? birthTimeUnknown,
    Expression<String>? birthPlaceName,
    Expression<double>? latitude,
    Expression<double>? longitudeEast,
    Expression<int>? timezoneOffsetMinutes,
    Expression<String>? relationship,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userProfileId != null) 'user_profile_id': userProfileId,
      if (name != null) 'name': name,
      if (birthUtc != null) 'birth_utc': birthUtc,
      if (birthLocalIso != null) 'birth_local_iso': birthLocalIso,
      if (birthTimeUnknown != null) 'birth_time_unknown': birthTimeUnknown,
      if (birthPlaceName != null) 'birth_place_name': birthPlaceName,
      if (latitude != null) 'latitude': latitude,
      if (longitudeEast != null) 'longitude_east': longitudeEast,
      if (timezoneOffsetMinutes != null)
        'timezone_offset_minutes': timezoneOffsetMinutes,
      if (relationship != null) 'relationship': relationship,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PartnersCompanion copyWith({
    Value<int>? id,
    Value<int>? userProfileId,
    Value<String>? name,
    Value<DateTime>? birthUtc,
    Value<String>? birthLocalIso,
    Value<bool>? birthTimeUnknown,
    Value<String>? birthPlaceName,
    Value<double>? latitude,
    Value<double>? longitudeEast,
    Value<int>? timezoneOffsetMinutes,
    Value<String>? relationship,
    Value<DateTime>? createdAt,
  }) {
    return PartnersCompanion(
      id: id ?? this.id,
      userProfileId: userProfileId ?? this.userProfileId,
      name: name ?? this.name,
      birthUtc: birthUtc ?? this.birthUtc,
      birthLocalIso: birthLocalIso ?? this.birthLocalIso,
      birthTimeUnknown: birthTimeUnknown ?? this.birthTimeUnknown,
      birthPlaceName: birthPlaceName ?? this.birthPlaceName,
      latitude: latitude ?? this.latitude,
      longitudeEast: longitudeEast ?? this.longitudeEast,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      relationship: relationship ?? this.relationship,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userProfileId.present) {
      map['user_profile_id'] = Variable<int>(userProfileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthUtc.present) {
      map['birth_utc'] = Variable<DateTime>(birthUtc.value);
    }
    if (birthLocalIso.present) {
      map['birth_local_iso'] = Variable<String>(birthLocalIso.value);
    }
    if (birthTimeUnknown.present) {
      map['birth_time_unknown'] = Variable<bool>(birthTimeUnknown.value);
    }
    if (birthPlaceName.present) {
      map['birth_place_name'] = Variable<String>(birthPlaceName.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitudeEast.present) {
      map['longitude_east'] = Variable<double>(longitudeEast.value);
    }
    if (timezoneOffsetMinutes.present) {
      map['timezone_offset_minutes'] = Variable<int>(
        timezoneOffsetMinutes.value,
      );
    }
    if (relationship.present) {
      map['relationship'] = Variable<String>(relationship.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartnersCompanion(')
          ..write('id: $id, ')
          ..write('userProfileId: $userProfileId, ')
          ..write('name: $name, ')
          ..write('birthUtc: $birthUtc, ')
          ..write('birthLocalIso: $birthLocalIso, ')
          ..write('birthTimeUnknown: $birthTimeUnknown, ')
          ..write('birthPlaceName: $birthPlaceName, ')
          ..write('latitude: $latitude, ')
          ..write('longitudeEast: $longitudeEast, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('relationship: $relationship, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyReadingCachesTable extends DailyReadingCaches
    with TableInfo<$DailyReadingCachesTable, DailyReadingCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyReadingCachesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userProfileIdMeta = const VerificationMeta(
    'userProfileId',
  );
  @override
  late final GeneratedColumn<int> userProfileId = GeneratedColumn<int>(
    'user_profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overallHeadlineMeta = const VerificationMeta(
    'overallHeadline',
  );
  @override
  late final GeneratedColumn<String> overallHeadline = GeneratedColumn<String>(
    'overall_headline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overallScoreMeta = const VerificationMeta(
    'overallScore',
  );
  @override
  late final GeneratedColumn<double> overallScore = GeneratedColumn<double>(
    'overall_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  categoryTexts =
      GeneratedColumn<String>(
        'category_texts',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, String>>(
        $DailyReadingCachesTable.$convertercategoryTexts,
      );
  static const VerificationMeta _dictionaryVersionMeta = const VerificationMeta(
    'dictionaryVersion',
  );
  @override
  late final GeneratedColumn<String> dictionaryVersion =
      GeneratedColumn<String>(
        'dictionary_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ephemerisVersionMeta = const VerificationMeta(
    'ephemerisVersion',
  );
  @override
  late final GeneratedColumn<String> ephemerisVersion = GeneratedColumn<String>(
    'ephemeris_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userProfileId,
    localDate,
    overallHeadline,
    overallScore,
    categoryTexts,
    dictionaryVersion,
    ephemerisVersion,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_reading_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyReadingCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_profile_id')) {
      context.handle(
        _userProfileIdMeta,
        userProfileId.isAcceptableOrUnknown(
          data['user_profile_id']!,
          _userProfileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userProfileIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('overall_headline')) {
      context.handle(
        _overallHeadlineMeta,
        overallHeadline.isAcceptableOrUnknown(
          data['overall_headline']!,
          _overallHeadlineMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overallHeadlineMeta);
    }
    if (data.containsKey('overall_score')) {
      context.handle(
        _overallScoreMeta,
        overallScore.isAcceptableOrUnknown(
          data['overall_score']!,
          _overallScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overallScoreMeta);
    }
    if (data.containsKey('dictionary_version')) {
      context.handle(
        _dictionaryVersionMeta,
        dictionaryVersion.isAcceptableOrUnknown(
          data['dictionary_version']!,
          _dictionaryVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dictionaryVersionMeta);
    }
    if (data.containsKey('ephemeris_version')) {
      context.handle(
        _ephemerisVersionMeta,
        ephemerisVersion.isAcceptableOrUnknown(
          data['ephemeris_version']!,
          _ephemerisVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ephemerisVersionMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userProfileId, localDate},
  ];
  @override
  DailyReadingCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyReadingCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_profile_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      overallHeadline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overall_headline'],
      )!,
      overallScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_score'],
      )!,
      categoryTexts: $DailyReadingCachesTable.$convertercategoryTexts.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category_texts'],
        )!,
      ),
      dictionaryVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dictionary_version'],
      )!,
      ephemerisVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ephemeris_version'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $DailyReadingCachesTable createAlias(String alias) {
    return $DailyReadingCachesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, String>, String> $convertercategoryTexts =
      const StringMapConverter();
}

class DailyReadingCache extends DataClass
    implements Insertable<DailyReadingCache> {
  final int id;
  final int userProfileId;

  /// その日のローカル暦日（"2026-06-02"）
  final String localDate;
  final String overallHeadline;
  final double overallScore;

  /// カテゴリ → 文章
  final Map<String, String> categoryTexts;

  /// 生成時の辞書バージョン（差分があれば再生成）
  final String dictionaryVersion;

  /// 生成時のエンジンバージョン
  final String ephemerisVersion;
  final DateTime generatedAt;
  const DailyReadingCache({
    required this.id,
    required this.userProfileId,
    required this.localDate,
    required this.overallHeadline,
    required this.overallScore,
    required this.categoryTexts,
    required this.dictionaryVersion,
    required this.ephemerisVersion,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_profile_id'] = Variable<int>(userProfileId);
    map['local_date'] = Variable<String>(localDate);
    map['overall_headline'] = Variable<String>(overallHeadline);
    map['overall_score'] = Variable<double>(overallScore);
    {
      map['category_texts'] = Variable<String>(
        $DailyReadingCachesTable.$convertercategoryTexts.toSql(categoryTexts),
      );
    }
    map['dictionary_version'] = Variable<String>(dictionaryVersion);
    map['ephemeris_version'] = Variable<String>(ephemerisVersion);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  DailyReadingCachesCompanion toCompanion(bool nullToAbsent) {
    return DailyReadingCachesCompanion(
      id: Value(id),
      userProfileId: Value(userProfileId),
      localDate: Value(localDate),
      overallHeadline: Value(overallHeadline),
      overallScore: Value(overallScore),
      categoryTexts: Value(categoryTexts),
      dictionaryVersion: Value(dictionaryVersion),
      ephemerisVersion: Value(ephemerisVersion),
      generatedAt: Value(generatedAt),
    );
  }

  factory DailyReadingCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyReadingCache(
      id: serializer.fromJson<int>(json['id']),
      userProfileId: serializer.fromJson<int>(json['userProfileId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      overallHeadline: serializer.fromJson<String>(json['overallHeadline']),
      overallScore: serializer.fromJson<double>(json['overallScore']),
      categoryTexts: serializer.fromJson<Map<String, String>>(
        json['categoryTexts'],
      ),
      dictionaryVersion: serializer.fromJson<String>(json['dictionaryVersion']),
      ephemerisVersion: serializer.fromJson<String>(json['ephemerisVersion']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userProfileId': serializer.toJson<int>(userProfileId),
      'localDate': serializer.toJson<String>(localDate),
      'overallHeadline': serializer.toJson<String>(overallHeadline),
      'overallScore': serializer.toJson<double>(overallScore),
      'categoryTexts': serializer.toJson<Map<String, String>>(categoryTexts),
      'dictionaryVersion': serializer.toJson<String>(dictionaryVersion),
      'ephemerisVersion': serializer.toJson<String>(ephemerisVersion),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  DailyReadingCache copyWith({
    int? id,
    int? userProfileId,
    String? localDate,
    String? overallHeadline,
    double? overallScore,
    Map<String, String>? categoryTexts,
    String? dictionaryVersion,
    String? ephemerisVersion,
    DateTime? generatedAt,
  }) => DailyReadingCache(
    id: id ?? this.id,
    userProfileId: userProfileId ?? this.userProfileId,
    localDate: localDate ?? this.localDate,
    overallHeadline: overallHeadline ?? this.overallHeadline,
    overallScore: overallScore ?? this.overallScore,
    categoryTexts: categoryTexts ?? this.categoryTexts,
    dictionaryVersion: dictionaryVersion ?? this.dictionaryVersion,
    ephemerisVersion: ephemerisVersion ?? this.ephemerisVersion,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  DailyReadingCache copyWithCompanion(DailyReadingCachesCompanion data) {
    return DailyReadingCache(
      id: data.id.present ? data.id.value : this.id,
      userProfileId: data.userProfileId.present
          ? data.userProfileId.value
          : this.userProfileId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      overallHeadline: data.overallHeadline.present
          ? data.overallHeadline.value
          : this.overallHeadline,
      overallScore: data.overallScore.present
          ? data.overallScore.value
          : this.overallScore,
      categoryTexts: data.categoryTexts.present
          ? data.categoryTexts.value
          : this.categoryTexts,
      dictionaryVersion: data.dictionaryVersion.present
          ? data.dictionaryVersion.value
          : this.dictionaryVersion,
      ephemerisVersion: data.ephemerisVersion.present
          ? data.ephemerisVersion.value
          : this.ephemerisVersion,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyReadingCache(')
          ..write('id: $id, ')
          ..write('userProfileId: $userProfileId, ')
          ..write('localDate: $localDate, ')
          ..write('overallHeadline: $overallHeadline, ')
          ..write('overallScore: $overallScore, ')
          ..write('categoryTexts: $categoryTexts, ')
          ..write('dictionaryVersion: $dictionaryVersion, ')
          ..write('ephemerisVersion: $ephemerisVersion, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userProfileId,
    localDate,
    overallHeadline,
    overallScore,
    categoryTexts,
    dictionaryVersion,
    ephemerisVersion,
    generatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyReadingCache &&
          other.id == this.id &&
          other.userProfileId == this.userProfileId &&
          other.localDate == this.localDate &&
          other.overallHeadline == this.overallHeadline &&
          other.overallScore == this.overallScore &&
          other.categoryTexts == this.categoryTexts &&
          other.dictionaryVersion == this.dictionaryVersion &&
          other.ephemerisVersion == this.ephemerisVersion &&
          other.generatedAt == this.generatedAt);
}

class DailyReadingCachesCompanion extends UpdateCompanion<DailyReadingCache> {
  final Value<int> id;
  final Value<int> userProfileId;
  final Value<String> localDate;
  final Value<String> overallHeadline;
  final Value<double> overallScore;
  final Value<Map<String, String>> categoryTexts;
  final Value<String> dictionaryVersion;
  final Value<String> ephemerisVersion;
  final Value<DateTime> generatedAt;
  const DailyReadingCachesCompanion({
    this.id = const Value.absent(),
    this.userProfileId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.overallHeadline = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.categoryTexts = const Value.absent(),
    this.dictionaryVersion = const Value.absent(),
    this.ephemerisVersion = const Value.absent(),
    this.generatedAt = const Value.absent(),
  });
  DailyReadingCachesCompanion.insert({
    this.id = const Value.absent(),
    required int userProfileId,
    required String localDate,
    required String overallHeadline,
    required double overallScore,
    required Map<String, String> categoryTexts,
    required String dictionaryVersion,
    required String ephemerisVersion,
    this.generatedAt = const Value.absent(),
  }) : userProfileId = Value(userProfileId),
       localDate = Value(localDate),
       overallHeadline = Value(overallHeadline),
       overallScore = Value(overallScore),
       categoryTexts = Value(categoryTexts),
       dictionaryVersion = Value(dictionaryVersion),
       ephemerisVersion = Value(ephemerisVersion);
  static Insertable<DailyReadingCache> custom({
    Expression<int>? id,
    Expression<int>? userProfileId,
    Expression<String>? localDate,
    Expression<String>? overallHeadline,
    Expression<double>? overallScore,
    Expression<String>? categoryTexts,
    Expression<String>? dictionaryVersion,
    Expression<String>? ephemerisVersion,
    Expression<DateTime>? generatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userProfileId != null) 'user_profile_id': userProfileId,
      if (localDate != null) 'local_date': localDate,
      if (overallHeadline != null) 'overall_headline': overallHeadline,
      if (overallScore != null) 'overall_score': overallScore,
      if (categoryTexts != null) 'category_texts': categoryTexts,
      if (dictionaryVersion != null) 'dictionary_version': dictionaryVersion,
      if (ephemerisVersion != null) 'ephemeris_version': ephemerisVersion,
      if (generatedAt != null) 'generated_at': generatedAt,
    });
  }

  DailyReadingCachesCompanion copyWith({
    Value<int>? id,
    Value<int>? userProfileId,
    Value<String>? localDate,
    Value<String>? overallHeadline,
    Value<double>? overallScore,
    Value<Map<String, String>>? categoryTexts,
    Value<String>? dictionaryVersion,
    Value<String>? ephemerisVersion,
    Value<DateTime>? generatedAt,
  }) {
    return DailyReadingCachesCompanion(
      id: id ?? this.id,
      userProfileId: userProfileId ?? this.userProfileId,
      localDate: localDate ?? this.localDate,
      overallHeadline: overallHeadline ?? this.overallHeadline,
      overallScore: overallScore ?? this.overallScore,
      categoryTexts: categoryTexts ?? this.categoryTexts,
      dictionaryVersion: dictionaryVersion ?? this.dictionaryVersion,
      ephemerisVersion: ephemerisVersion ?? this.ephemerisVersion,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userProfileId.present) {
      map['user_profile_id'] = Variable<int>(userProfileId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (overallHeadline.present) {
      map['overall_headline'] = Variable<String>(overallHeadline.value);
    }
    if (overallScore.present) {
      map['overall_score'] = Variable<double>(overallScore.value);
    }
    if (categoryTexts.present) {
      map['category_texts'] = Variable<String>(
        $DailyReadingCachesTable.$convertercategoryTexts.toSql(
          categoryTexts.value,
        ),
      );
    }
    if (dictionaryVersion.present) {
      map['dictionary_version'] = Variable<String>(dictionaryVersion.value);
    }
    if (ephemerisVersion.present) {
      map['ephemeris_version'] = Variable<String>(ephemerisVersion.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyReadingCachesCompanion(')
          ..write('id: $id, ')
          ..write('userProfileId: $userProfileId, ')
          ..write('localDate: $localDate, ')
          ..write('overallHeadline: $overallHeadline, ')
          ..write('overallScore: $overallScore, ')
          ..write('categoryTexts: $categoryTexts, ')
          ..write('dictionaryVersion: $dictionaryVersion, ')
          ..write('ephemerisVersion: $ephemerisVersion, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dailyNotificationTimeLocalMeta =
      const VerificationMeta('dailyNotificationTimeLocal');
  @override
  late final GeneratedColumn<String> dailyNotificationTimeLocal =
      GeneratedColumn<String>(
        'daily_notification_time_local',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('08:00'),
      );
  static const VerificationMeta _themePreferenceMeta = const VerificationMeta(
    'themePreference',
  );
  @override
  late final GeneratedColumn<String> themePreference = GeneratedColumn<String>(
    'theme_preference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _roastLevelMeta = const VerificationMeta(
    'roastLevel',
  );
  @override
  late final GeneratedColumn<String> roastLevel = GeneratedColumn<String>(
    'roast_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mild'),
  );
  static const VerificationMeta _subscriptionStateMeta = const VerificationMeta(
    'subscriptionState',
  );
  @override
  late final GeneratedColumn<String> subscriptionState =
      GeneratedColumn<String>(
        'subscription_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('none'),
      );
  static const VerificationMeta _adsDisabledByPurchaseMeta =
      const VerificationMeta('adsDisabledByPurchase');
  @override
  late final GeneratedColumn<bool> adsDisabledByPurchase =
      GeneratedColumn<bool>(
        'ads_disabled_by_purchase',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("ads_disabled_by_purchase" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _lastSeenLocalDateMeta = const VerificationMeta(
    'lastSeenLocalDate',
  );
  @override
  late final GeneratedColumn<String> lastSeenLocalDate =
      GeneratedColumn<String>(
        'last_seen_local_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    notificationsEnabled,
    dailyNotificationTimeLocal,
    themePreference,
    roastLevel,
    subscriptionState,
    adsDisabledByPurchase,
    lastSeenLocalDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('daily_notification_time_local')) {
      context.handle(
        _dailyNotificationTimeLocalMeta,
        dailyNotificationTimeLocal.isAcceptableOrUnknown(
          data['daily_notification_time_local']!,
          _dailyNotificationTimeLocalMeta,
        ),
      );
    }
    if (data.containsKey('theme_preference')) {
      context.handle(
        _themePreferenceMeta,
        themePreference.isAcceptableOrUnknown(
          data['theme_preference']!,
          _themePreferenceMeta,
        ),
      );
    }
    if (data.containsKey('roast_level')) {
      context.handle(
        _roastLevelMeta,
        roastLevel.isAcceptableOrUnknown(
          data['roast_level']!,
          _roastLevelMeta,
        ),
      );
    }
    if (data.containsKey('subscription_state')) {
      context.handle(
        _subscriptionStateMeta,
        subscriptionState.isAcceptableOrUnknown(
          data['subscription_state']!,
          _subscriptionStateMeta,
        ),
      );
    }
    if (data.containsKey('ads_disabled_by_purchase')) {
      context.handle(
        _adsDisabledByPurchaseMeta,
        adsDisabledByPurchase.isAcceptableOrUnknown(
          data['ads_disabled_by_purchase']!,
          _adsDisabledByPurchaseMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_local_date')) {
      context.handle(
        _lastSeenLocalDateMeta,
        lastSeenLocalDate.isAcceptableOrUnknown(
          data['last_seen_local_date']!,
          _lastSeenLocalDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      dailyNotificationTimeLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_notification_time_local'],
      )!,
      themePreference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_preference'],
      )!,
      roastLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}roast_level'],
      )!,
      subscriptionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscription_state'],
      )!,
      adsDisabledByPurchase: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ads_disabled_by_purchase'],
      )!,
      lastSeenLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_seen_local_date'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final bool notificationsEnabled;

  /// 通知時刻（"08:00"）
  final String dailyNotificationTimeLocal;

  /// 'system' / 'light' / 'dark'
  final String themePreference;

  /// 'mild' / 'sharp' / 'extraHot'
  final String roastLevel;

  /// 'none' / 'active' / 'expired' / 'trial'
  /// 起動時に RevenueCat から同期
  final String subscriptionState;
  final bool adsDisabledByPurchase;

  /// 最後にアプリを開いたローカル暦日（"日次運勢が更新されたか"の判定用）
  final String? lastSeenLocalDate;
  const AppSetting({
    required this.id,
    required this.notificationsEnabled,
    required this.dailyNotificationTimeLocal,
    required this.themePreference,
    required this.roastLevel,
    required this.subscriptionState,
    required this.adsDisabledByPurchase,
    this.lastSeenLocalDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['daily_notification_time_local'] = Variable<String>(
      dailyNotificationTimeLocal,
    );
    map['theme_preference'] = Variable<String>(themePreference);
    map['roast_level'] = Variable<String>(roastLevel);
    map['subscription_state'] = Variable<String>(subscriptionState);
    map['ads_disabled_by_purchase'] = Variable<bool>(adsDisabledByPurchase);
    if (!nullToAbsent || lastSeenLocalDate != null) {
      map['last_seen_local_date'] = Variable<String>(lastSeenLocalDate);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      notificationsEnabled: Value(notificationsEnabled),
      dailyNotificationTimeLocal: Value(dailyNotificationTimeLocal),
      themePreference: Value(themePreference),
      roastLevel: Value(roastLevel),
      subscriptionState: Value(subscriptionState),
      adsDisabledByPurchase: Value(adsDisabledByPurchase),
      lastSeenLocalDate: lastSeenLocalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenLocalDate),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      dailyNotificationTimeLocal: serializer.fromJson<String>(
        json['dailyNotificationTimeLocal'],
      ),
      themePreference: serializer.fromJson<String>(json['themePreference']),
      roastLevel: serializer.fromJson<String>(json['roastLevel']),
      subscriptionState: serializer.fromJson<String>(json['subscriptionState']),
      adsDisabledByPurchase: serializer.fromJson<bool>(
        json['adsDisabledByPurchase'],
      ),
      lastSeenLocalDate: serializer.fromJson<String?>(
        json['lastSeenLocalDate'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'dailyNotificationTimeLocal': serializer.toJson<String>(
        dailyNotificationTimeLocal,
      ),
      'themePreference': serializer.toJson<String>(themePreference),
      'roastLevel': serializer.toJson<String>(roastLevel),
      'subscriptionState': serializer.toJson<String>(subscriptionState),
      'adsDisabledByPurchase': serializer.toJson<bool>(adsDisabledByPurchase),
      'lastSeenLocalDate': serializer.toJson<String?>(lastSeenLocalDate),
    };
  }

  AppSetting copyWith({
    int? id,
    bool? notificationsEnabled,
    String? dailyNotificationTimeLocal,
    String? themePreference,
    String? roastLevel,
    String? subscriptionState,
    bool? adsDisabledByPurchase,
    Value<String?> lastSeenLocalDate = const Value.absent(),
  }) => AppSetting(
    id: id ?? this.id,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    dailyNotificationTimeLocal:
        dailyNotificationTimeLocal ?? this.dailyNotificationTimeLocal,
    themePreference: themePreference ?? this.themePreference,
    roastLevel: roastLevel ?? this.roastLevel,
    subscriptionState: subscriptionState ?? this.subscriptionState,
    adsDisabledByPurchase: adsDisabledByPurchase ?? this.adsDisabledByPurchase,
    lastSeenLocalDate: lastSeenLocalDate.present
        ? lastSeenLocalDate.value
        : this.lastSeenLocalDate,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      dailyNotificationTimeLocal: data.dailyNotificationTimeLocal.present
          ? data.dailyNotificationTimeLocal.value
          : this.dailyNotificationTimeLocal,
      themePreference: data.themePreference.present
          ? data.themePreference.value
          : this.themePreference,
      roastLevel: data.roastLevel.present
          ? data.roastLevel.value
          : this.roastLevel,
      subscriptionState: data.subscriptionState.present
          ? data.subscriptionState.value
          : this.subscriptionState,
      adsDisabledByPurchase: data.adsDisabledByPurchase.present
          ? data.adsDisabledByPurchase.value
          : this.adsDisabledByPurchase,
      lastSeenLocalDate: data.lastSeenLocalDate.present
          ? data.lastSeenLocalDate.value
          : this.lastSeenLocalDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('dailyNotificationTimeLocal: $dailyNotificationTimeLocal, ')
          ..write('themePreference: $themePreference, ')
          ..write('roastLevel: $roastLevel, ')
          ..write('subscriptionState: $subscriptionState, ')
          ..write('adsDisabledByPurchase: $adsDisabledByPurchase, ')
          ..write('lastSeenLocalDate: $lastSeenLocalDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    notificationsEnabled,
    dailyNotificationTimeLocal,
    themePreference,
    roastLevel,
    subscriptionState,
    adsDisabledByPurchase,
    lastSeenLocalDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.dailyNotificationTimeLocal == this.dailyNotificationTimeLocal &&
          other.themePreference == this.themePreference &&
          other.roastLevel == this.roastLevel &&
          other.subscriptionState == this.subscriptionState &&
          other.adsDisabledByPurchase == this.adsDisabledByPurchase &&
          other.lastSeenLocalDate == this.lastSeenLocalDate);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<bool> notificationsEnabled;
  final Value<String> dailyNotificationTimeLocal;
  final Value<String> themePreference;
  final Value<String> roastLevel;
  final Value<String> subscriptionState;
  final Value<bool> adsDisabledByPurchase;
  final Value<String?> lastSeenLocalDate;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.dailyNotificationTimeLocal = const Value.absent(),
    this.themePreference = const Value.absent(),
    this.roastLevel = const Value.absent(),
    this.subscriptionState = const Value.absent(),
    this.adsDisabledByPurchase = const Value.absent(),
    this.lastSeenLocalDate = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.dailyNotificationTimeLocal = const Value.absent(),
    this.themePreference = const Value.absent(),
    this.roastLevel = const Value.absent(),
    this.subscriptionState = const Value.absent(),
    this.adsDisabledByPurchase = const Value.absent(),
    this.lastSeenLocalDate = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<bool>? notificationsEnabled,
    Expression<String>? dailyNotificationTimeLocal,
    Expression<String>? themePreference,
    Expression<String>? roastLevel,
    Expression<String>? subscriptionState,
    Expression<bool>? adsDisabledByPurchase,
    Expression<String>? lastSeenLocalDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (dailyNotificationTimeLocal != null)
        'daily_notification_time_local': dailyNotificationTimeLocal,
      if (themePreference != null) 'theme_preference': themePreference,
      if (roastLevel != null) 'roast_level': roastLevel,
      if (subscriptionState != null) 'subscription_state': subscriptionState,
      if (adsDisabledByPurchase != null)
        'ads_disabled_by_purchase': adsDisabledByPurchase,
      if (lastSeenLocalDate != null) 'last_seen_local_date': lastSeenLocalDate,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? notificationsEnabled,
    Value<String>? dailyNotificationTimeLocal,
    Value<String>? themePreference,
    Value<String>? roastLevel,
    Value<String>? subscriptionState,
    Value<bool>? adsDisabledByPurchase,
    Value<String?>? lastSeenLocalDate,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyNotificationTimeLocal:
          dailyNotificationTimeLocal ?? this.dailyNotificationTimeLocal,
      themePreference: themePreference ?? this.themePreference,
      roastLevel: roastLevel ?? this.roastLevel,
      subscriptionState: subscriptionState ?? this.subscriptionState,
      adsDisabledByPurchase:
          adsDisabledByPurchase ?? this.adsDisabledByPurchase,
      lastSeenLocalDate: lastSeenLocalDate ?? this.lastSeenLocalDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (dailyNotificationTimeLocal.present) {
      map['daily_notification_time_local'] = Variable<String>(
        dailyNotificationTimeLocal.value,
      );
    }
    if (themePreference.present) {
      map['theme_preference'] = Variable<String>(themePreference.value);
    }
    if (roastLevel.present) {
      map['roast_level'] = Variable<String>(roastLevel.value);
    }
    if (subscriptionState.present) {
      map['subscription_state'] = Variable<String>(subscriptionState.value);
    }
    if (adsDisabledByPurchase.present) {
      map['ads_disabled_by_purchase'] = Variable<bool>(
        adsDisabledByPurchase.value,
      );
    }
    if (lastSeenLocalDate.present) {
      map['last_seen_local_date'] = Variable<String>(lastSeenLocalDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('dailyNotificationTimeLocal: $dailyNotificationTimeLocal, ')
          ..write('themePreference: $themePreference, ')
          ..write('roastLevel: $roastLevel, ')
          ..write('subscriptionState: $subscriptionState, ')
          ..write('adsDisabledByPurchase: $adsDisabledByPurchase, ')
          ..write('lastSeenLocalDate: $lastSeenLocalDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $NatalChartCachesTable natalChartCaches = $NatalChartCachesTable(
    this,
  );
  late final $PartnersTable partners = $PartnersTable(this);
  late final $DailyReadingCachesTable dailyReadingCaches =
      $DailyReadingCachesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    natalChartCaches,
    partners,
    dailyReadingCaches,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('natal_chart_caches', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('partners', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('daily_reading_caches', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String?> displayName,
      required DateTime birthUtc,
      required String birthLocalIso,
      Value<bool> birthTimeUnknown,
      required String birthPlaceName,
      required double latitude,
      required double longitudeEast,
      required int timezoneOffsetMinutes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String?> displayName,
      Value<DateTime> birthUtc,
      Value<String> birthLocalIso,
      Value<bool> birthTimeUnknown,
      Value<String> birthPlaceName,
      Value<double> latitude,
      Value<double> longitudeEast,
      Value<int> timezoneOffsetMinutes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$UserProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile> {
  $$UserProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NatalChartCachesTable, List<NatalChartCache>>
  _natalChartCachesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.natalChartCaches,
    aliasName: $_aliasNameGenerator(
      db.userProfiles.id,
      db.natalChartCaches.userProfileId,
    ),
  );

  $$NatalChartCachesTableProcessedTableManager get natalChartCachesRefs {
    final manager = $$NatalChartCachesTableTableManager(
      $_db,
      $_db.natalChartCaches,
    ).filter((f) => f.userProfileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _natalChartCachesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PartnersTable, List<Partner>> _partnersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.partners,
    aliasName: $_aliasNameGenerator(
      db.userProfiles.id,
      db.partners.userProfileId,
    ),
  );

  $$PartnersTableProcessedTableManager get partnersRefs {
    final manager = $$PartnersTableTableManager(
      $_db,
      $_db.partners,
    ).filter((f) => f.userProfileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partnersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DailyReadingCachesTable, List<DailyReadingCache>>
  _dailyReadingCachesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dailyReadingCaches,
        aliasName: $_aliasNameGenerator(
          db.userProfiles.id,
          db.dailyReadingCaches.userProfileId,
        ),
      );

  $$DailyReadingCachesTableProcessedTableManager get dailyReadingCachesRefs {
    final manager = $$DailyReadingCachesTableTableManager(
      $_db,
      $_db.dailyReadingCaches,
    ).filter((f) => f.userProfileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dailyReadingCachesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthUtc => $composableBuilder(
    column: $table.birthUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthLocalIso => $composableBuilder(
    column: $table.birthLocalIso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get birthTimeUnknown => $composableBuilder(
    column: $table.birthTimeUnknown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthPlaceName => $composableBuilder(
    column: $table.birthPlaceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitudeEast => $composableBuilder(
    column: $table.longitudeEast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> natalChartCachesRefs(
    Expression<bool> Function($$NatalChartCachesTableFilterComposer f) f,
  ) {
    final $$NatalChartCachesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.natalChartCaches,
      getReferencedColumn: (t) => t.userProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NatalChartCachesTableFilterComposer(
            $db: $db,
            $table: $db.natalChartCaches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> partnersRefs(
    Expression<bool> Function($$PartnersTableFilterComposer f) f,
  ) {
    final $$PartnersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partners,
      getReferencedColumn: (t) => t.userProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartnersTableFilterComposer(
            $db: $db,
            $table: $db.partners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyReadingCachesRefs(
    Expression<bool> Function($$DailyReadingCachesTableFilterComposer f) f,
  ) {
    final $$DailyReadingCachesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyReadingCaches,
      getReferencedColumn: (t) => t.userProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyReadingCachesTableFilterComposer(
            $db: $db,
            $table: $db.dailyReadingCaches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthUtc => $composableBuilder(
    column: $table.birthUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthLocalIso => $composableBuilder(
    column: $table.birthLocalIso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get birthTimeUnknown => $composableBuilder(
    column: $table.birthTimeUnknown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthPlaceName => $composableBuilder(
    column: $table.birthPlaceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitudeEast => $composableBuilder(
    column: $table.longitudeEast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get birthUtc =>
      $composableBuilder(column: $table.birthUtc, builder: (column) => column);

  GeneratedColumn<String> get birthLocalIso => $composableBuilder(
    column: $table.birthLocalIso,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get birthTimeUnknown => $composableBuilder(
    column: $table.birthTimeUnknown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthPlaceName => $composableBuilder(
    column: $table.birthPlaceName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitudeEast => $composableBuilder(
    column: $table.longitudeEast,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> natalChartCachesRefs<T extends Object>(
    Expression<T> Function($$NatalChartCachesTableAnnotationComposer a) f,
  ) {
    final $$NatalChartCachesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.natalChartCaches,
      getReferencedColumn: (t) => t.userProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NatalChartCachesTableAnnotationComposer(
            $db: $db,
            $table: $db.natalChartCaches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> partnersRefs<T extends Object>(
    Expression<T> Function($$PartnersTableAnnotationComposer a) f,
  ) {
    final $$PartnersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partners,
      getReferencedColumn: (t) => t.userProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartnersTableAnnotationComposer(
            $db: $db,
            $table: $db.partners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailyReadingCachesRefs<T extends Object>(
    Expression<T> Function($$DailyReadingCachesTableAnnotationComposer a) f,
  ) {
    final $$DailyReadingCachesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dailyReadingCaches,
          getReferencedColumn: (t) => t.userProfileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DailyReadingCachesTableAnnotationComposer(
                $db: $db,
                $table: $db.dailyReadingCaches,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (UserProfile, $$UserProfilesTableReferences),
          UserProfile,
          PrefetchHooks Function({
            bool natalChartCachesRefs,
            bool partnersRefs,
            bool dailyReadingCachesRefs,
          })
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<DateTime> birthUtc = const Value.absent(),
                Value<String> birthLocalIso = const Value.absent(),
                Value<bool> birthTimeUnknown = const Value.absent(),
                Value<String> birthPlaceName = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitudeEast = const Value.absent(),
                Value<int> timezoneOffsetMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                displayName: displayName,
                birthUtc: birthUtc,
                birthLocalIso: birthLocalIso,
                birthTimeUnknown: birthTimeUnknown,
                birthPlaceName: birthPlaceName,
                latitude: latitude,
                longitudeEast: longitudeEast,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                required DateTime birthUtc,
                required String birthLocalIso,
                Value<bool> birthTimeUnknown = const Value.absent(),
                required String birthPlaceName,
                required double latitude,
                required double longitudeEast,
                required int timezoneOffsetMinutes,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                birthUtc: birthUtc,
                birthLocalIso: birthLocalIso,
                birthTimeUnknown: birthTimeUnknown,
                birthPlaceName: birthPlaceName,
                latitude: latitude,
                longitudeEast: longitudeEast,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                natalChartCachesRefs = false,
                partnersRefs = false,
                dailyReadingCachesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (natalChartCachesRefs) db.natalChartCaches,
                    if (partnersRefs) db.partners,
                    if (dailyReadingCachesRefs) db.dailyReadingCaches,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (natalChartCachesRefs)
                        await $_getPrefetchedData<
                          UserProfile,
                          $UserProfilesTable,
                          NatalChartCache
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._natalChartCachesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).natalChartCachesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (partnersRefs)
                        await $_getPrefetchedData<
                          UserProfile,
                          $UserProfilesTable,
                          Partner
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._partnersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).partnersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailyReadingCachesRefs)
                        await $_getPrefetchedData<
                          UserProfile,
                          $UserProfilesTable,
                          DailyReadingCache
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._dailyReadingCachesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyReadingCachesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (UserProfile, $$UserProfilesTableReferences),
      UserProfile,
      PrefetchHooks Function({
        bool natalChartCachesRefs,
        bool partnersRefs,
        bool dailyReadingCachesRefs,
      })
    >;
typedef $$NatalChartCachesTableCreateCompanionBuilder =
    NatalChartCachesCompanion Function({
      Value<int> userProfileId,
      required double jd,
      required Map<Body, double> positions,
      required double ascendant,
      required double midheaven,
      required List<double> cusps,
      required List<Aspect> aspects,
      required String houseSystem,
      required String ephemerisVersion,
      Value<DateTime> generatedAt,
    });
typedef $$NatalChartCachesTableUpdateCompanionBuilder =
    NatalChartCachesCompanion Function({
      Value<int> userProfileId,
      Value<double> jd,
      Value<Map<Body, double>> positions,
      Value<double> ascendant,
      Value<double> midheaven,
      Value<List<double>> cusps,
      Value<List<Aspect>> aspects,
      Value<String> houseSystem,
      Value<String> ephemerisVersion,
      Value<DateTime> generatedAt,
    });

final class $$NatalChartCachesTableReferences
    extends
        BaseReferences<_$AppDatabase, $NatalChartCachesTable, NatalChartCache> {
  $$NatalChartCachesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProfilesTable _userProfileIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(
          db.natalChartCaches.userProfileId,
          db.userProfiles.id,
        ),
      );

  $$UserProfilesTableProcessedTableManager get userProfileId {
    final $_column = $_itemColumn<int>('user_profile_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NatalChartCachesTableFilterComposer
    extends Composer<_$AppDatabase, $NatalChartCachesTable> {
  $$NatalChartCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get jd => $composableBuilder(
    column: $table.jd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Map<Body, double>, Map<Body, double>, String>
  get positions => $composableBuilder(
    column: $table.positions,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get ascendant => $composableBuilder(
    column: $table.ascendant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get midheaven => $composableBuilder(
    column: $table.midheaven,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<double>, List<double>, String>
  get cusps => $composableBuilder(
    column: $table.cusps,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<Aspect>, List<Aspect>, String>
  get aspects => $composableBuilder(
    column: $table.aspects,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get houseSystem => $composableBuilder(
    column: $table.houseSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ephemerisVersion => $composableBuilder(
    column: $table.ephemerisVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get userProfileId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProfileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NatalChartCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $NatalChartCachesTable> {
  $$NatalChartCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get jd => $composableBuilder(
    column: $table.jd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positions => $composableBuilder(
    column: $table.positions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ascendant => $composableBuilder(
    column: $table.ascendant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get midheaven => $composableBuilder(
    column: $table.midheaven,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cusps => $composableBuilder(
    column: $table.cusps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aspects => $composableBuilder(
    column: $table.aspects,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseSystem => $composableBuilder(
    column: $table.houseSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ephemerisVersion => $composableBuilder(
    column: $table.ephemerisVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get userProfileId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProfileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NatalChartCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NatalChartCachesTable> {
  $$NatalChartCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get jd =>
      $composableBuilder(column: $table.jd, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<Body, double>, String> get positions =>
      $composableBuilder(column: $table.positions, builder: (column) => column);

  GeneratedColumn<double> get ascendant =>
      $composableBuilder(column: $table.ascendant, builder: (column) => column);

  GeneratedColumn<double> get midheaven =>
      $composableBuilder(column: $table.midheaven, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<double>, String> get cusps =>
      $composableBuilder(column: $table.cusps, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Aspect>, String> get aspects =>
      $composableBuilder(column: $table.aspects, builder: (column) => column);

  GeneratedColumn<String> get houseSystem => $composableBuilder(
    column: $table.houseSystem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ephemerisVersion => $composableBuilder(
    column: $table.ephemerisVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  $$UserProfilesTableAnnotationComposer get userProfileId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProfileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NatalChartCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NatalChartCachesTable,
          NatalChartCache,
          $$NatalChartCachesTableFilterComposer,
          $$NatalChartCachesTableOrderingComposer,
          $$NatalChartCachesTableAnnotationComposer,
          $$NatalChartCachesTableCreateCompanionBuilder,
          $$NatalChartCachesTableUpdateCompanionBuilder,
          (NatalChartCache, $$NatalChartCachesTableReferences),
          NatalChartCache,
          PrefetchHooks Function({bool userProfileId})
        > {
  $$NatalChartCachesTableTableManager(
    _$AppDatabase db,
    $NatalChartCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NatalChartCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NatalChartCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NatalChartCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userProfileId = const Value.absent(),
                Value<double> jd = const Value.absent(),
                Value<Map<Body, double>> positions = const Value.absent(),
                Value<double> ascendant = const Value.absent(),
                Value<double> midheaven = const Value.absent(),
                Value<List<double>> cusps = const Value.absent(),
                Value<List<Aspect>> aspects = const Value.absent(),
                Value<String> houseSystem = const Value.absent(),
                Value<String> ephemerisVersion = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
              }) => NatalChartCachesCompanion(
                userProfileId: userProfileId,
                jd: jd,
                positions: positions,
                ascendant: ascendant,
                midheaven: midheaven,
                cusps: cusps,
                aspects: aspects,
                houseSystem: houseSystem,
                ephemerisVersion: ephemerisVersion,
                generatedAt: generatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> userProfileId = const Value.absent(),
                required double jd,
                required Map<Body, double> positions,
                required double ascendant,
                required double midheaven,
                required List<double> cusps,
                required List<Aspect> aspects,
                required String houseSystem,
                required String ephemerisVersion,
                Value<DateTime> generatedAt = const Value.absent(),
              }) => NatalChartCachesCompanion.insert(
                userProfileId: userProfileId,
                jd: jd,
                positions: positions,
                ascendant: ascendant,
                midheaven: midheaven,
                cusps: cusps,
                aspects: aspects,
                houseSystem: houseSystem,
                ephemerisVersion: ephemerisVersion,
                generatedAt: generatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NatalChartCachesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userProfileId = false}) {
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
                    if (userProfileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userProfileId,
                                referencedTable:
                                    $$NatalChartCachesTableReferences
                                        ._userProfileIdTable(db),
                                referencedColumn:
                                    $$NatalChartCachesTableReferences
                                        ._userProfileIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$NatalChartCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NatalChartCachesTable,
      NatalChartCache,
      $$NatalChartCachesTableFilterComposer,
      $$NatalChartCachesTableOrderingComposer,
      $$NatalChartCachesTableAnnotationComposer,
      $$NatalChartCachesTableCreateCompanionBuilder,
      $$NatalChartCachesTableUpdateCompanionBuilder,
      (NatalChartCache, $$NatalChartCachesTableReferences),
      NatalChartCache,
      PrefetchHooks Function({bool userProfileId})
    >;
typedef $$PartnersTableCreateCompanionBuilder =
    PartnersCompanion Function({
      Value<int> id,
      required int userProfileId,
      required String name,
      required DateTime birthUtc,
      required String birthLocalIso,
      Value<bool> birthTimeUnknown,
      required String birthPlaceName,
      required double latitude,
      required double longitudeEast,
      required int timezoneOffsetMinutes,
      Value<String> relationship,
      Value<DateTime> createdAt,
    });
typedef $$PartnersTableUpdateCompanionBuilder =
    PartnersCompanion Function({
      Value<int> id,
      Value<int> userProfileId,
      Value<String> name,
      Value<DateTime> birthUtc,
      Value<String> birthLocalIso,
      Value<bool> birthTimeUnknown,
      Value<String> birthPlaceName,
      Value<double> latitude,
      Value<double> longitudeEast,
      Value<int> timezoneOffsetMinutes,
      Value<String> relationship,
      Value<DateTime> createdAt,
    });

final class $$PartnersTableReferences
    extends BaseReferences<_$AppDatabase, $PartnersTable, Partner> {
  $$PartnersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTable _userProfileIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(db.partners.userProfileId, db.userProfiles.id),
      );

  $$UserProfilesTableProcessedTableManager get userProfileId {
    final $_column = $_itemColumn<int>('user_profile_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PartnersTableFilterComposer
    extends Composer<_$AppDatabase, $PartnersTable> {
  $$PartnersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthUtc => $composableBuilder(
    column: $table.birthUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthLocalIso => $composableBuilder(
    column: $table.birthLocalIso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get birthTimeUnknown => $composableBuilder(
    column: $table.birthTimeUnknown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthPlaceName => $composableBuilder(
    column: $table.birthPlaceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitudeEast => $composableBuilder(
    column: $table.longitudeEast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get userProfileId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProfileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartnersTableOrderingComposer
    extends Composer<_$AppDatabase, $PartnersTable> {
  $$PartnersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthUtc => $composableBuilder(
    column: $table.birthUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthLocalIso => $composableBuilder(
    column: $table.birthLocalIso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get birthTimeUnknown => $composableBuilder(
    column: $table.birthTimeUnknown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthPlaceName => $composableBuilder(
    column: $table.birthPlaceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitudeEast => $composableBuilder(
    column: $table.longitudeEast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get userProfileId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProfileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartnersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartnersTable> {
  $$PartnersTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get birthUtc =>
      $composableBuilder(column: $table.birthUtc, builder: (column) => column);

  GeneratedColumn<String> get birthLocalIso => $composableBuilder(
    column: $table.birthLocalIso,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get birthTimeUnknown => $composableBuilder(
    column: $table.birthTimeUnknown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthPlaceName => $composableBuilder(
    column: $table.birthPlaceName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitudeEast => $composableBuilder(
    column: $table.longitudeEast,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UserProfilesTableAnnotationComposer get userProfileId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProfileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartnersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartnersTable,
          Partner,
          $$PartnersTableFilterComposer,
          $$PartnersTableOrderingComposer,
          $$PartnersTableAnnotationComposer,
          $$PartnersTableCreateCompanionBuilder,
          $$PartnersTableUpdateCompanionBuilder,
          (Partner, $$PartnersTableReferences),
          Partner,
          PrefetchHooks Function({bool userProfileId})
        > {
  $$PartnersTableTableManager(_$AppDatabase db, $PartnersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartnersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartnersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartnersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userProfileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> birthUtc = const Value.absent(),
                Value<String> birthLocalIso = const Value.absent(),
                Value<bool> birthTimeUnknown = const Value.absent(),
                Value<String> birthPlaceName = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitudeEast = const Value.absent(),
                Value<int> timezoneOffsetMinutes = const Value.absent(),
                Value<String> relationship = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PartnersCompanion(
                id: id,
                userProfileId: userProfileId,
                name: name,
                birthUtc: birthUtc,
                birthLocalIso: birthLocalIso,
                birthTimeUnknown: birthTimeUnknown,
                birthPlaceName: birthPlaceName,
                latitude: latitude,
                longitudeEast: longitudeEast,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                relationship: relationship,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userProfileId,
                required String name,
                required DateTime birthUtc,
                required String birthLocalIso,
                Value<bool> birthTimeUnknown = const Value.absent(),
                required String birthPlaceName,
                required double latitude,
                required double longitudeEast,
                required int timezoneOffsetMinutes,
                Value<String> relationship = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PartnersCompanion.insert(
                id: id,
                userProfileId: userProfileId,
                name: name,
                birthUtc: birthUtc,
                birthLocalIso: birthLocalIso,
                birthTimeUnknown: birthTimeUnknown,
                birthPlaceName: birthPlaceName,
                latitude: latitude,
                longitudeEast: longitudeEast,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                relationship: relationship,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartnersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userProfileId = false}) {
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
                    if (userProfileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userProfileId,
                                referencedTable: $$PartnersTableReferences
                                    ._userProfileIdTable(db),
                                referencedColumn: $$PartnersTableReferences
                                    ._userProfileIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$PartnersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartnersTable,
      Partner,
      $$PartnersTableFilterComposer,
      $$PartnersTableOrderingComposer,
      $$PartnersTableAnnotationComposer,
      $$PartnersTableCreateCompanionBuilder,
      $$PartnersTableUpdateCompanionBuilder,
      (Partner, $$PartnersTableReferences),
      Partner,
      PrefetchHooks Function({bool userProfileId})
    >;
typedef $$DailyReadingCachesTableCreateCompanionBuilder =
    DailyReadingCachesCompanion Function({
      Value<int> id,
      required int userProfileId,
      required String localDate,
      required String overallHeadline,
      required double overallScore,
      required Map<String, String> categoryTexts,
      required String dictionaryVersion,
      required String ephemerisVersion,
      Value<DateTime> generatedAt,
    });
typedef $$DailyReadingCachesTableUpdateCompanionBuilder =
    DailyReadingCachesCompanion Function({
      Value<int> id,
      Value<int> userProfileId,
      Value<String> localDate,
      Value<String> overallHeadline,
      Value<double> overallScore,
      Value<Map<String, String>> categoryTexts,
      Value<String> dictionaryVersion,
      Value<String> ephemerisVersion,
      Value<DateTime> generatedAt,
    });

final class $$DailyReadingCachesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DailyReadingCachesTable,
          DailyReadingCache
        > {
  $$DailyReadingCachesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProfilesTable _userProfileIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(
          db.dailyReadingCaches.userProfileId,
          db.userProfiles.id,
        ),
      );

  $$UserProfilesTableProcessedTableManager get userProfileId {
    final $_column = $_itemColumn<int>('user_profile_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyReadingCachesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyReadingCachesTable> {
  $$DailyReadingCachesTableFilterComposer({
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

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overallHeadline => $composableBuilder(
    column: $table.overallHeadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get categoryTexts => $composableBuilder(
    column: $table.categoryTexts,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get dictionaryVersion => $composableBuilder(
    column: $table.dictionaryVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ephemerisVersion => $composableBuilder(
    column: $table.ephemerisVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get userProfileId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProfileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyReadingCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyReadingCachesTable> {
  $$DailyReadingCachesTableOrderingComposer({
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

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overallHeadline => $composableBuilder(
    column: $table.overallHeadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryTexts => $composableBuilder(
    column: $table.categoryTexts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dictionaryVersion => $composableBuilder(
    column: $table.dictionaryVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ephemerisVersion => $composableBuilder(
    column: $table.ephemerisVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get userProfileId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProfileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyReadingCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyReadingCachesTable> {
  $$DailyReadingCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get overallHeadline => $composableBuilder(
    column: $table.overallHeadline,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
  get categoryTexts => $composableBuilder(
    column: $table.categoryTexts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dictionaryVersion => $composableBuilder(
    column: $table.dictionaryVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ephemerisVersion => $composableBuilder(
    column: $table.ephemerisVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  $$UserProfilesTableAnnotationComposer get userProfileId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userProfileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyReadingCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyReadingCachesTable,
          DailyReadingCache,
          $$DailyReadingCachesTableFilterComposer,
          $$DailyReadingCachesTableOrderingComposer,
          $$DailyReadingCachesTableAnnotationComposer,
          $$DailyReadingCachesTableCreateCompanionBuilder,
          $$DailyReadingCachesTableUpdateCompanionBuilder,
          (DailyReadingCache, $$DailyReadingCachesTableReferences),
          DailyReadingCache,
          PrefetchHooks Function({bool userProfileId})
        > {
  $$DailyReadingCachesTableTableManager(
    _$AppDatabase db,
    $DailyReadingCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyReadingCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyReadingCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyReadingCachesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userProfileId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> overallHeadline = const Value.absent(),
                Value<double> overallScore = const Value.absent(),
                Value<Map<String, String>> categoryTexts = const Value.absent(),
                Value<String> dictionaryVersion = const Value.absent(),
                Value<String> ephemerisVersion = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
              }) => DailyReadingCachesCompanion(
                id: id,
                userProfileId: userProfileId,
                localDate: localDate,
                overallHeadline: overallHeadline,
                overallScore: overallScore,
                categoryTexts: categoryTexts,
                dictionaryVersion: dictionaryVersion,
                ephemerisVersion: ephemerisVersion,
                generatedAt: generatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userProfileId,
                required String localDate,
                required String overallHeadline,
                required double overallScore,
                required Map<String, String> categoryTexts,
                required String dictionaryVersion,
                required String ephemerisVersion,
                Value<DateTime> generatedAt = const Value.absent(),
              }) => DailyReadingCachesCompanion.insert(
                id: id,
                userProfileId: userProfileId,
                localDate: localDate,
                overallHeadline: overallHeadline,
                overallScore: overallScore,
                categoryTexts: categoryTexts,
                dictionaryVersion: dictionaryVersion,
                ephemerisVersion: ephemerisVersion,
                generatedAt: generatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyReadingCachesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userProfileId = false}) {
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
                    if (userProfileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userProfileId,
                                referencedTable:
                                    $$DailyReadingCachesTableReferences
                                        ._userProfileIdTable(db),
                                referencedColumn:
                                    $$DailyReadingCachesTableReferences
                                        ._userProfileIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$DailyReadingCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyReadingCachesTable,
      DailyReadingCache,
      $$DailyReadingCachesTableFilterComposer,
      $$DailyReadingCachesTableOrderingComposer,
      $$DailyReadingCachesTableAnnotationComposer,
      $$DailyReadingCachesTableCreateCompanionBuilder,
      $$DailyReadingCachesTableUpdateCompanionBuilder,
      (DailyReadingCache, $$DailyReadingCachesTableReferences),
      DailyReadingCache,
      PrefetchHooks Function({bool userProfileId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> notificationsEnabled,
      Value<String> dailyNotificationTimeLocal,
      Value<String> themePreference,
      Value<String> roastLevel,
      Value<String> subscriptionState,
      Value<bool> adsDisabledByPurchase,
      Value<String?> lastSeenLocalDate,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> notificationsEnabled,
      Value<String> dailyNotificationTimeLocal,
      Value<String> themePreference,
      Value<String> roastLevel,
      Value<String> subscriptionState,
      Value<bool> adsDisabledByPurchase,
      Value<String?> lastSeenLocalDate,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyNotificationTimeLocal => $composableBuilder(
    column: $table.dailyNotificationTimeLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roastLevel => $composableBuilder(
    column: $table.roastLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscriptionState => $composableBuilder(
    column: $table.subscriptionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get adsDisabledByPurchase => $composableBuilder(
    column: $table.adsDisabledByPurchase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSeenLocalDate => $composableBuilder(
    column: $table.lastSeenLocalDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyNotificationTimeLocal => $composableBuilder(
    column: $table.dailyNotificationTimeLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roastLevel => $composableBuilder(
    column: $table.roastLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionState => $composableBuilder(
    column: $table.subscriptionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get adsDisabledByPurchase => $composableBuilder(
    column: $table.adsDisabledByPurchase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSeenLocalDate => $composableBuilder(
    column: $table.lastSeenLocalDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyNotificationTimeLocal => $composableBuilder(
    column: $table.dailyNotificationTimeLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roastLevel => $composableBuilder(
    column: $table.roastLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subscriptionState => $composableBuilder(
    column: $table.subscriptionState,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get adsDisabledByPurchase => $composableBuilder(
    column: $table.adsDisabledByPurchase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSeenLocalDate => $composableBuilder(
    column: $table.lastSeenLocalDate,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String> dailyNotificationTimeLocal = const Value.absent(),
                Value<String> themePreference = const Value.absent(),
                Value<String> roastLevel = const Value.absent(),
                Value<String> subscriptionState = const Value.absent(),
                Value<bool> adsDisabledByPurchase = const Value.absent(),
                Value<String?> lastSeenLocalDate = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                notificationsEnabled: notificationsEnabled,
                dailyNotificationTimeLocal: dailyNotificationTimeLocal,
                themePreference: themePreference,
                roastLevel: roastLevel,
                subscriptionState: subscriptionState,
                adsDisabledByPurchase: adsDisabledByPurchase,
                lastSeenLocalDate: lastSeenLocalDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String> dailyNotificationTimeLocal = const Value.absent(),
                Value<String> themePreference = const Value.absent(),
                Value<String> roastLevel = const Value.absent(),
                Value<String> subscriptionState = const Value.absent(),
                Value<bool> adsDisabledByPurchase = const Value.absent(),
                Value<String?> lastSeenLocalDate = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                notificationsEnabled: notificationsEnabled,
                dailyNotificationTimeLocal: dailyNotificationTimeLocal,
                themePreference: themePreference,
                roastLevel: roastLevel,
                subscriptionState: subscriptionState,
                adsDisabledByPurchase: adsDisabledByPurchase,
                lastSeenLocalDate: lastSeenLocalDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$NatalChartCachesTableTableManager get natalChartCaches =>
      $$NatalChartCachesTableTableManager(_db, _db.natalChartCaches);
  $$PartnersTableTableManager get partners =>
      $$PartnersTableTableManager(_db, _db.partners);
  $$DailyReadingCachesTableTableManager get dailyReadingCaches =>
      $$DailyReadingCachesTableTableManager(_db, _db.dailyReadingCaches);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
