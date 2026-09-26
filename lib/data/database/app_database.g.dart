// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _loginIdMeta = const VerificationMeta(
    'loginId',
  );
  @override
  late final GeneratedColumn<String> loginId = GeneratedColumn<String>(
    'login_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _associatedIdMeta = const VerificationMeta(
    'associatedId',
  );
  @override
  late final GeneratedColumn<String> associatedId = GeneratedColumn<String>(
    'associated_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordSaltMeta = const VerificationMeta(
    'passwordSalt',
  );
  @override
  late final GeneratedColumn<String> passwordSalt = GeneratedColumn<String>(
    'password_salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uid,
    name,
    loginId,
    role,
    associatedId,
    passwordHash,
    passwordSalt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('login_id')) {
      context.handle(
        _loginIdMeta,
        loginId.isAcceptableOrUnknown(data['login_id']!, _loginIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loginIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('associated_id')) {
      context.handle(
        _associatedIdMeta,
        associatedId.isAcceptableOrUnknown(
          data['associated_id']!,
          _associatedIdMeta,
        ),
      );
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('password_salt')) {
      context.handle(
        _passwordSaltMeta,
        passwordSalt.isAcceptableOrUnknown(
          data['password_salt']!,
          _passwordSaltMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordSaltMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      loginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      associatedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}associated_id'],
      ),
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      passwordSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_salt'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String uid;
  final String name;
  final String loginId;
  final String role;
  final String? associatedId;
  final String passwordHash;
  final String passwordSalt;
  final DateTime createdAt;
  const UserRow({
    required this.uid,
    required this.name,
    required this.loginId,
    required this.role,
    this.associatedId,
    required this.passwordHash,
    required this.passwordSalt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['name'] = Variable<String>(name);
    map['login_id'] = Variable<String>(loginId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || associatedId != null) {
      map['associated_id'] = Variable<String>(associatedId);
    }
    map['password_hash'] = Variable<String>(passwordHash);
    map['password_salt'] = Variable<String>(passwordSalt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      uid: Value(uid),
      name: Value(name),
      loginId: Value(loginId),
      role: Value(role),
      associatedId: associatedId == null && nullToAbsent
          ? const Value.absent()
          : Value(associatedId),
      passwordHash: Value(passwordHash),
      passwordSalt: Value(passwordSalt),
      createdAt: Value(createdAt),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      uid: serializer.fromJson<String>(json['uid']),
      name: serializer.fromJson<String>(json['name']),
      loginId: serializer.fromJson<String>(json['loginId']),
      role: serializer.fromJson<String>(json['role']),
      associatedId: serializer.fromJson<String?>(json['associatedId']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      passwordSalt: serializer.fromJson<String>(json['passwordSalt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'name': serializer.toJson<String>(name),
      'loginId': serializer.toJson<String>(loginId),
      'role': serializer.toJson<String>(role),
      'associatedId': serializer.toJson<String?>(associatedId),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'passwordSalt': serializer.toJson<String>(passwordSalt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserRow copyWith({
    String? uid,
    String? name,
    String? loginId,
    String? role,
    Value<String?> associatedId = const Value.absent(),
    String? passwordHash,
    String? passwordSalt,
    DateTime? createdAt,
  }) => UserRow(
    uid: uid ?? this.uid,
    name: name ?? this.name,
    loginId: loginId ?? this.loginId,
    role: role ?? this.role,
    associatedId: associatedId.present ? associatedId.value : this.associatedId,
    passwordHash: passwordHash ?? this.passwordHash,
    passwordSalt: passwordSalt ?? this.passwordSalt,
    createdAt: createdAt ?? this.createdAt,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      uid: data.uid.present ? data.uid.value : this.uid,
      name: data.name.present ? data.name.value : this.name,
      loginId: data.loginId.present ? data.loginId.value : this.loginId,
      role: data.role.present ? data.role.value : this.role,
      associatedId: data.associatedId.present
          ? data.associatedId.value
          : this.associatedId,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      passwordSalt: data.passwordSalt.present
          ? data.passwordSalt.value
          : this.passwordSalt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('loginId: $loginId, ')
          ..write('role: $role, ')
          ..write('associatedId: $associatedId, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uid,
    name,
    loginId,
    role,
    associatedId,
    passwordHash,
    passwordSalt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.loginId == this.loginId &&
          other.role == this.role &&
          other.associatedId == this.associatedId &&
          other.passwordHash == this.passwordHash &&
          other.passwordSalt == this.passwordSalt &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> uid;
  final Value<String> name;
  final Value<String> loginId;
  final Value<String> role;
  final Value<String?> associatedId;
  final Value<String> passwordHash;
  final Value<String> passwordSalt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.loginId = const Value.absent(),
    this.role = const Value.absent(),
    this.associatedId = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.passwordSalt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String uid,
    required String name,
    required String loginId,
    required String role,
    this.associatedId = const Value.absent(),
    required String passwordHash,
    required String passwordSalt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : uid = Value(uid),
       name = Value(name),
       loginId = Value(loginId),
       role = Value(role),
       passwordHash = Value(passwordHash),
       passwordSalt = Value(passwordSalt),
       createdAt = Value(createdAt);
  static Insertable<UserRow> custom({
    Expression<String>? uid,
    Expression<String>? name,
    Expression<String>? loginId,
    Expression<String>? role,
    Expression<String>? associatedId,
    Expression<String>? passwordHash,
    Expression<String>? passwordSalt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (loginId != null) 'login_id': loginId,
      if (role != null) 'role': role,
      if (associatedId != null) 'associated_id': associatedId,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (passwordSalt != null) 'password_salt': passwordSalt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? uid,
    Value<String>? name,
    Value<String>? loginId,
    Value<String>? role,
    Value<String?>? associatedId,
    Value<String>? passwordHash,
    Value<String>? passwordSalt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      loginId: loginId ?? this.loginId,
      role: role ?? this.role,
      associatedId: associatedId ?? this.associatedId,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (loginId.present) {
      map['login_id'] = Variable<String>(loginId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (associatedId.present) {
      map['associated_id'] = Variable<String>(associatedId.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (passwordSalt.present) {
      map['password_salt'] = Variable<String>(passwordSalt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('loginId: $loginId, ')
          ..write('role: $role, ')
          ..write('associatedId: $associatedId, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoursesTable extends Courses with TableInfo<$CoursesTable, Course> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Course> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Course map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Course(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class CoursesCompanion extends UpdateCompanion<Course> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoursesCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Course> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoursesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CoursesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$CourseInsertable implements Insertable<Course> {
  Course _object;
  _$CourseInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(_object.id),
      name: Value(_object.name),
    ).toColumns(false);
  }
}

extension CourseToInsertable on Course {
  _$CourseInsertable toInsertable() {
    return _$CourseInsertable(this);
  }
}

class $BranchesTable extends Branches with TableInfo<$BranchesTable, Branch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, courseId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Branch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Branch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Branch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $BranchesTable createAlias(String alias) {
    return $BranchesTable(attachedDatabase, alias);
  }
}

class BranchesCompanion extends UpdateCompanion<Branch> {
  final Value<String> id;
  final Value<String> courseId;
  final Value<String> name;
  final Value<int> rowid;
  const BranchesCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BranchesCompanion.insert({
    required String id,
    required String courseId,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseId = Value(courseId),
       name = Value(name);
  static Insertable<Branch> custom({
    Expression<String>? id,
    Expression<String>? courseId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BranchesCompanion copyWith({
    Value<String>? id,
    Value<String>? courseId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return BranchesCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchesCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$BranchInsertable implements Insertable<Branch> {
  Branch _object;
  _$BranchInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return BranchesCompanion(
      id: Value(_object.id),
      courseId: Value(_object.courseId),
      name: Value(_object.name),
    ).toColumns(false);
  }
}

extension BranchToInsertable on Branch {
  _$BranchInsertable toInsertable() {
    return _$BranchInsertable(this);
  }
}

class $SemestersTable extends Semesters
    with TableInfo<$SemestersTable, Semester> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SemestersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _semesterNumberMeta = const VerificationMeta(
    'semesterNumber',
  );
  @override
  late final GeneratedColumn<int> semesterNumber = GeneratedColumn<int>(
    'semester_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, branchId, semesterNumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'semesters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Semester> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('semester_number')) {
      context.handle(
        _semesterNumberMeta,
        semesterNumber.isAcceptableOrUnknown(
          data['semester_number']!,
          _semesterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_semesterNumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Semester map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Semester(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      semesterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}semester_number'],
      )!,
    );
  }

  @override
  $SemestersTable createAlias(String alias) {
    return $SemestersTable(attachedDatabase, alias);
  }
}

class SemestersCompanion extends UpdateCompanion<Semester> {
  final Value<String> id;
  final Value<String> branchId;
  final Value<int> semesterNumber;
  final Value<int> rowid;
  const SemestersCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.semesterNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SemestersCompanion.insert({
    required String id,
    required String branchId,
    required int semesterNumber,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       branchId = Value(branchId),
       semesterNumber = Value(semesterNumber);
  static Insertable<Semester> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<int>? semesterNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (semesterNumber != null) 'semester_number': semesterNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SemestersCompanion copyWith({
    Value<String>? id,
    Value<String>? branchId,
    Value<int>? semesterNumber,
    Value<int>? rowid,
  }) {
    return SemestersCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (semesterNumber.present) {
      map['semester_number'] = Variable<int>(semesterNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SemestersCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('semesterNumber: $semesterNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$SemesterInsertable implements Insertable<Semester> {
  Semester _object;
  _$SemesterInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return SemestersCompanion(
      id: Value(_object.id),
      branchId: Value(_object.branchId),
      semesterNumber: Value(_object.semesterNumber),
    ).toColumns(false);
  }
}

extension SemesterToInsertable on Semester {
  _$SemesterInsertable toInsertable() {
    return _$SemesterInsertable(this);
  }
}

class $SectionsTable extends Sections with TableInfo<$SectionsTable, Section> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _semesterIdMeta = const VerificationMeta(
    'semesterId',
  );
  @override
  late final GeneratedColumn<String> semesterId = GeneratedColumn<String>(
    'semester_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, semesterId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Section> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('semester_id')) {
      context.handle(
        _semesterIdMeta,
        semesterId.isAcceptableOrUnknown(data['semester_id']!, _semesterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_semesterIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Section map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Section(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      semesterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}semester_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $SectionsTable createAlias(String alias) {
    return $SectionsTable(attachedDatabase, alias);
  }
}

class SectionsCompanion extends UpdateCompanion<Section> {
  final Value<String> id;
  final Value<String> semesterId;
  final Value<String> name;
  final Value<int> rowid;
  const SectionsCompanion({
    this.id = const Value.absent(),
    this.semesterId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SectionsCompanion.insert({
    required String id,
    required String semesterId,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       semesterId = Value(semesterId),
       name = Value(name);
  static Insertable<Section> custom({
    Expression<String>? id,
    Expression<String>? semesterId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (semesterId != null) 'semester_id': semesterId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? semesterId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return SectionsCompanion(
      id: id ?? this.id,
      semesterId: semesterId ?? this.semesterId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (semesterId.present) {
      map['semester_id'] = Variable<String>(semesterId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsCompanion(')
          ..write('id: $id, ')
          ..write('semesterId: $semesterId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$SectionInsertable implements Insertable<Section> {
  Section _object;
  _$SectionInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return SectionsCompanion(
      id: Value(_object.id),
      semesterId: Value(_object.semesterId),
      name: Value(_object.name),
    ).toColumns(false);
  }
}

extension SectionToInsertable on Section {
  _$SectionInsertable toInsertable() {
    return _$SectionInsertable(this);
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rollNumberMeta = const VerificationMeta(
    'rollNumber',
  );
  @override
  late final GeneratedColumn<String> rollNumber = GeneratedColumn<String>(
    'roll_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, rollNumber, name, sectionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('roll_number')) {
      context.handle(
        _rollNumberMeta,
        rollNumber.isAcceptableOrUnknown(data['roll_number']!, _rollNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_rollNumberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      rollNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}roll_number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<String> id;
  final Value<String> rollNumber;
  final Value<String> name;
  final Value<String> sectionId;
  final Value<int> rowid;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.rollNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    required String id,
    required String rollNumber,
    required String name,
    required String sectionId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       rollNumber = Value(rollNumber),
       name = Value(name),
       sectionId = Value(sectionId);
  static Insertable<Student> custom({
    Expression<String>? id,
    Expression<String>? rollNumber,
    Expression<String>? name,
    Expression<String>? sectionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rollNumber != null) 'roll_number': rollNumber,
      if (name != null) 'name': name,
      if (sectionId != null) 'section_id': sectionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith({
    Value<String>? id,
    Value<String>? rollNumber,
    Value<String>? name,
    Value<String>? sectionId,
    Value<int>? rowid,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      rollNumber: rollNumber ?? this.rollNumber,
      name: name ?? this.name,
      sectionId: sectionId ?? this.sectionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rollNumber.present) {
      map['roll_number'] = Variable<String>(rollNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('rollNumber: $rollNumber, ')
          ..write('name: $name, ')
          ..write('sectionId: $sectionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$StudentInsertable implements Insertable<Student> {
  Student _object;
  _$StudentInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(_object.id),
      rollNumber: Value(_object.rollNumber),
      name: Value(_object.name),
      sectionId: Value(_object.sectionId),
    ).toColumns(false);
  }
}

extension StudentToInsertable on Student {
  _$StudentInsertable toInsertable() {
    return _$StudentInsertable(this);
  }
}

class $FacultyMembersTable extends FacultyMembers
    with TableInfo<$FacultyMembersTable, Faculty> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacultyMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, employeeId, name, email];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'faculty';
  @override
  VerificationContext validateIntegrity(
    Insertable<Faculty> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Faculty map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Faculty(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
    );
  }

  @override
  $FacultyMembersTable createAlias(String alias) {
    return $FacultyMembersTable(attachedDatabase, alias);
  }
}

class FacultyMembersCompanion extends UpdateCompanion<Faculty> {
  final Value<String> id;
  final Value<String> employeeId;
  final Value<String> name;
  final Value<String> email;
  final Value<int> rowid;
  const FacultyMembersCompanion({
    this.id = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacultyMembersCompanion.insert({
    required String id,
    required String employeeId,
    required String name,
    required String email,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       employeeId = Value(employeeId),
       name = Value(name),
       email = Value(email);
  static Insertable<Faculty> custom({
    Expression<String>? id,
    Expression<String>? employeeId,
    Expression<String>? name,
    Expression<String>? email,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeId != null) 'employee_id': employeeId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacultyMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? employeeId,
    Value<String>? name,
    Value<String>? email,
    Value<int>? rowid,
  }) {
    return FacultyMembersCompanion(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FacultyMembersCompanion(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$FacultyInsertable implements Insertable<Faculty> {
  Faculty _object;
  _$FacultyInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return FacultyMembersCompanion(
      id: Value(_object.id),
      employeeId: Value(_object.employeeId),
      name: Value(_object.name),
      email: Value(_object.email),
    ).toColumns(false);
  }
}

extension FacultyToInsertable on Faculty {
  _$FacultyInsertable toInsertable() {
    return _$FacultyInsertable(this);
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, code, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    required String id,
    required String code,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name);
  static Insertable<Subject> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$SubjectInsertable implements Insertable<Subject> {
  Subject _object;
  _$SubjectInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(_object.id),
      code: Value(_object.code),
      name: Value(_object.name),
    ).toColumns(false);
  }
}

extension SubjectToInsertable on Subject {
  _$SubjectInsertable toInsertable() {
    return _$SubjectInsertable(this);
  }
}

class $SubjectMappingsTable extends SubjectMappings
    with TableInfo<$SubjectMappingsTable, SubjectMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sectionId, subjectId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subject_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubjectMapping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubjectMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubjectMapping(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
    );
  }

  @override
  $SubjectMappingsTable createAlias(String alias) {
    return $SubjectMappingsTable(attachedDatabase, alias);
  }
}

class SubjectMappingsCompanion extends UpdateCompanion<SubjectMapping> {
  final Value<String> id;
  final Value<String> sectionId;
  final Value<String> subjectId;
  final Value<int> rowid;
  const SubjectMappingsCompanion({
    this.id = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectMappingsCompanion.insert({
    required String id,
    required String sectionId,
    required String subjectId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sectionId = Value(sectionId),
       subjectId = Value(subjectId);
  static Insertable<SubjectMapping> custom({
    Expression<String>? id,
    Expression<String>? sectionId,
    Expression<String>? subjectId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionId != null) 'section_id': sectionId,
      if (subjectId != null) 'subject_id': subjectId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectMappingsCompanion copyWith({
    Value<String>? id,
    Value<String>? sectionId,
    Value<String>? subjectId,
    Value<int>? rowid,
  }) {
    return SubjectMappingsCompanion(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      subjectId: subjectId ?? this.subjectId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectMappingsCompanion(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('subjectId: $subjectId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$SubjectMappingInsertable implements Insertable<SubjectMapping> {
  SubjectMapping _object;
  _$SubjectMappingInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return SubjectMappingsCompanion(
      id: Value(_object.id),
      sectionId: Value(_object.sectionId),
      subjectId: Value(_object.subjectId),
    ).toColumns(false);
  }
}

extension SubjectMappingToInsertable on SubjectMapping {
  _$SubjectMappingInsertable toInsertable() {
    return _$SubjectMappingInsertable(this);
  }
}

class $FacultyAssignmentsTable extends FacultyAssignments
    with TableInfo<$FacultyAssignmentsTable, FacultyAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacultyAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facultyIdMeta = const VerificationMeta(
    'facultyId',
  );
  @override
  late final GeneratedColumn<String> facultyId = GeneratedColumn<String>(
    'faculty_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectMappingIdMeta = const VerificationMeta(
    'subjectMappingId',
  );
  @override
  late final GeneratedColumn<String> subjectMappingId = GeneratedColumn<String>(
    'subject_mapping_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, facultyId, subjectMappingId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'faculty_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<FacultyAssignment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('faculty_id')) {
      context.handle(
        _facultyIdMeta,
        facultyId.isAcceptableOrUnknown(data['faculty_id']!, _facultyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facultyIdMeta);
    }
    if (data.containsKey('subject_mapping_id')) {
      context.handle(
        _subjectMappingIdMeta,
        subjectMappingId.isAcceptableOrUnknown(
          data['subject_mapping_id']!,
          _subjectMappingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subjectMappingIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FacultyAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FacultyAssignment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      facultyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}faculty_id'],
      )!,
      subjectMappingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_mapping_id'],
      )!,
    );
  }

  @override
  $FacultyAssignmentsTable createAlias(String alias) {
    return $FacultyAssignmentsTable(attachedDatabase, alias);
  }
}

class FacultyAssignmentsCompanion extends UpdateCompanion<FacultyAssignment> {
  final Value<String> id;
  final Value<String> facultyId;
  final Value<String> subjectMappingId;
  final Value<int> rowid;
  const FacultyAssignmentsCompanion({
    this.id = const Value.absent(),
    this.facultyId = const Value.absent(),
    this.subjectMappingId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacultyAssignmentsCompanion.insert({
    required String id,
    required String facultyId,
    required String subjectMappingId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facultyId = Value(facultyId),
       subjectMappingId = Value(subjectMappingId);
  static Insertable<FacultyAssignment> custom({
    Expression<String>? id,
    Expression<String>? facultyId,
    Expression<String>? subjectMappingId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (facultyId != null) 'faculty_id': facultyId,
      if (subjectMappingId != null) 'subject_mapping_id': subjectMappingId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacultyAssignmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? facultyId,
    Value<String>? subjectMappingId,
    Value<int>? rowid,
  }) {
    return FacultyAssignmentsCompanion(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      subjectMappingId: subjectMappingId ?? this.subjectMappingId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (facultyId.present) {
      map['faculty_id'] = Variable<String>(facultyId.value);
    }
    if (subjectMappingId.present) {
      map['subject_mapping_id'] = Variable<String>(subjectMappingId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FacultyAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('facultyId: $facultyId, ')
          ..write('subjectMappingId: $subjectMappingId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$FacultyAssignmentInsertable implements Insertable<FacultyAssignment> {
  FacultyAssignment _object;
  _$FacultyAssignmentInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return FacultyAssignmentsCompanion(
      id: Value(_object.id),
      facultyId: Value(_object.facultyId),
      subjectMappingId: Value(_object.subjectMappingId),
    ).toColumns(false);
  }
}

extension FacultyAssignmentToInsertable on FacultyAssignment {
  _$FacultyAssignmentInsertable toInsertable() {
    return _$FacultyAssignmentInsertable(this);
  }
}

class $AttendanceSessionsTable extends AttendanceSessions
    with TableInfo<$AttendanceSessionsTable, AttendanceSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facultyIdMeta = const VerificationMeta(
    'facultyId',
  );
  @override
  late final GeneratedColumn<String> facultyId = GeneratedColumn<String>(
    'faculty_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    facultyId,
    subjectId,
    sectionId,
    date,
    startTime,
    endTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('faculty_id')) {
      context.handle(
        _facultyIdMeta,
        facultyId.isAcceptableOrUnknown(data['faculty_id']!, _facultyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facultyIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      facultyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}faculty_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
    );
  }

  @override
  $AttendanceSessionsTable createAlias(String alias) {
    return $AttendanceSessionsTable(attachedDatabase, alias);
  }
}

class AttendanceSessionsCompanion extends UpdateCompanion<AttendanceSession> {
  final Value<String> id;
  final Value<String> facultyId;
  final Value<String> subjectId;
  final Value<String> sectionId;
  final Value<DateTime> date;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<int> rowid;
  const AttendanceSessionsCompanion({
    this.id = const Value.absent(),
    this.facultyId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceSessionsCompanion.insert({
    required String id,
    required String facultyId,
    required String subjectId,
    required String sectionId,
    required DateTime date,
    required String startTime,
    required String endTime,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facultyId = Value(facultyId),
       subjectId = Value(subjectId),
       sectionId = Value(sectionId),
       date = Value(date),
       startTime = Value(startTime),
       endTime = Value(endTime);
  static Insertable<AttendanceSession> custom({
    Expression<String>? id,
    Expression<String>? facultyId,
    Expression<String>? subjectId,
    Expression<String>? sectionId,
    Expression<DateTime>? date,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (facultyId != null) 'faculty_id': facultyId,
      if (subjectId != null) 'subject_id': subjectId,
      if (sectionId != null) 'section_id': sectionId,
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? facultyId,
    Value<String>? subjectId,
    Value<String>? sectionId,
    Value<DateTime>? date,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<int>? rowid,
  }) {
    return AttendanceSessionsCompanion(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      subjectId: subjectId ?? this.subjectId,
      sectionId: sectionId ?? this.sectionId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (facultyId.present) {
      map['faculty_id'] = Variable<String>(facultyId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceSessionsCompanion(')
          ..write('id: $id, ')
          ..write('facultyId: $facultyId, ')
          ..write('subjectId: $subjectId, ')
          ..write('sectionId: $sectionId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$AttendanceSessionInsertable implements Insertable<AttendanceSession> {
  AttendanceSession _object;
  _$AttendanceSessionInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return AttendanceSessionsCompanion(
      id: Value(_object.id),
      facultyId: Value(_object.facultyId),
      subjectId: Value(_object.subjectId),
      sectionId: Value(_object.sectionId),
      date: Value(_object.date),
      startTime: Value(_object.startTime),
      endTime: Value(_object.endTime),
    ).toColumns(false);
  }
}

extension AttendanceSessionToInsertable on AttendanceSession {
  _$AttendanceSessionInsertable toInsertable() {
    return _$AttendanceSessionInsertable(this);
  }
}

class $AttendanceRecordsTable extends AttendanceRecords
    with TableInfo<$AttendanceRecordsTable, AttendanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attendance_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, studentId, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, studentId},
  ];
  @override
  AttendanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $AttendanceRecordsTable createAlias(String alias) {
    return $AttendanceRecordsTable(attachedDatabase, alias);
  }
}

class AttendanceRecordsCompanion extends UpdateCompanion<AttendanceRecord> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> studentId;
  final Value<String> status;
  final Value<int> rowid;
  const AttendanceRecordsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceRecordsCompanion.insert({
    required String id,
    required String sessionId,
    required String studentId,
    required String status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       studentId = Value(studentId),
       status = Value(status);
  static Insertable<AttendanceRecord> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? studentId,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (studentId != null) 'student_id': studentId,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? studentId,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return AttendanceRecordsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('studentId: $studentId, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$AttendanceRecordInsertable implements Insertable<AttendanceRecord> {
  AttendanceRecord _object;
  _$AttendanceRecordInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return AttendanceRecordsCompanion(
      id: Value(_object.id),
      sessionId: Value(_object.sessionId),
      studentId: Value(_object.studentId),
      status: Value(_object.status),
    ).toColumns(false);
  }
}

extension AttendanceRecordToInsertable on AttendanceRecord {
  _$AttendanceRecordInsertable toInsertable() {
    return _$AttendanceRecordInsertable(this);
  }
}

class $StudentEnrollmentsTable extends StudentEnrollments
    with TableInfo<$StudentEnrollmentsTable, StudentEnrollment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentEnrollmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _semesterNumberMeta = const VerificationMeta(
    'semesterNumber',
  );
  @override
  late final GeneratedColumn<int> semesterNumber = GeneratedColumn<int>(
    'semester_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _academicYearMeta = const VerificationMeta(
    'academicYear',
  );
  @override
  late final GeneratedColumn<String> academicYear = GeneratedColumn<String>(
    'academic_year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    sectionId,
    semesterNumber,
    academicYear,
    startedAt,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_enrollments';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentEnrollment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('semester_number')) {
      context.handle(
        _semesterNumberMeta,
        semesterNumber.isAcceptableOrUnknown(
          data['semester_number']!,
          _semesterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_semesterNumberMeta);
    }
    if (data.containsKey('academic_year')) {
      context.handle(
        _academicYearMeta,
        academicYear.isAcceptableOrUnknown(
          data['academic_year']!,
          _academicYearMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentEnrollment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentEnrollment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      semesterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}semester_number'],
      )!,
      academicYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}academic_year'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $StudentEnrollmentsTable createAlias(String alias) {
    return $StudentEnrollmentsTable(attachedDatabase, alias);
  }
}

class StudentEnrollmentsCompanion extends UpdateCompanion<StudentEnrollment> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> sectionId;
  final Value<int> semesterNumber;
  final Value<String?> academicYear;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> rowid;
  const StudentEnrollmentsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.semesterNumber = const Value.absent(),
    this.academicYear = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentEnrollmentsCompanion.insert({
    required String id,
    required String studentId,
    required String sectionId,
    required int semesterNumber,
    this.academicYear = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       sectionId = Value(sectionId),
       semesterNumber = Value(semesterNumber),
       startedAt = Value(startedAt);
  static Insertable<StudentEnrollment> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? sectionId,
    Expression<int>? semesterNumber,
    Expression<String>? academicYear,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (sectionId != null) 'section_id': sectionId,
      if (semesterNumber != null) 'semester_number': semesterNumber,
      if (academicYear != null) 'academic_year': academicYear,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentEnrollmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? sectionId,
    Value<int>? semesterNumber,
    Value<String?>? academicYear,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? rowid,
  }) {
    return StudentEnrollmentsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      sectionId: sectionId ?? this.sectionId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      academicYear: academicYear ?? this.academicYear,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (semesterNumber.present) {
      map['semester_number'] = Variable<int>(semesterNumber.value);
    }
    if (academicYear.present) {
      map['academic_year'] = Variable<String>(academicYear.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentEnrollmentsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sectionId: $sectionId, ')
          ..write('semesterNumber: $semesterNumber, ')
          ..write('academicYear: $academicYear, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$StudentEnrollmentInsertable implements Insertable<StudentEnrollment> {
  StudentEnrollment _object;
  _$StudentEnrollmentInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return StudentEnrollmentsCompanion(
      id: Value(_object.id),
      studentId: Value(_object.studentId),
      sectionId: Value(_object.sectionId),
      semesterNumber: Value(_object.semesterNumber),
      academicYear: Value(_object.academicYear),
      startedAt: Value(_object.startedAt),
      endedAt: Value(_object.endedAt),
    ).toColumns(false);
  }
}

extension StudentEnrollmentToInsertable on StudentEnrollment {
  _$StudentEnrollmentInsertable toInsertable() {
    return _$StudentEnrollmentInsertable(this);
  }
}

class $ImportBatchesTable extends ImportBatches
    with TableInfo<$ImportBatchesTable, ImportBatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedByMeta = const VerificationMeta(
    'importedBy',
  );
  @override
  late final GeneratedColumn<String> importedBy = GeneratedColumn<String>(
    'imported_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordCountMeta = const VerificationMeta(
    'recordCount',
  );
  @override
  late final GeneratedColumn<int> recordCount = GeneratedColumn<int>(
    'record_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fileName,
    importedAt,
    importedBy,
    recordCount,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportBatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('imported_by')) {
      context.handle(
        _importedByMeta,
        importedBy.isAcceptableOrUnknown(data['imported_by']!, _importedByMeta),
      );
    }
    if (data.containsKey('record_count')) {
      context.handle(
        _recordCountMeta,
        recordCount.isAcceptableOrUnknown(
          data['record_count']!,
          _recordCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordCountMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportBatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportBatch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      importedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imported_by'],
      ),
      recordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}record_count'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ImportBatchesTable createAlias(String alias) {
    return $ImportBatchesTable(attachedDatabase, alias);
  }
}

class ImportBatchesCompanion extends UpdateCompanion<ImportBatch> {
  final Value<String> id;
  final Value<String> fileName;
  final Value<DateTime> importedAt;
  final Value<String?> importedBy;
  final Value<int> recordCount;
  final Value<String?> notes;
  final Value<int> rowid;
  const ImportBatchesCompanion({
    this.id = const Value.absent(),
    this.fileName = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.importedBy = const Value.absent(),
    this.recordCount = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportBatchesCompanion.insert({
    required String id,
    required String fileName,
    required DateTime importedAt,
    this.importedBy = const Value.absent(),
    required int recordCount,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fileName = Value(fileName),
       importedAt = Value(importedAt),
       recordCount = Value(recordCount);
  static Insertable<ImportBatch> custom({
    Expression<String>? id,
    Expression<String>? fileName,
    Expression<DateTime>? importedAt,
    Expression<String>? importedBy,
    Expression<int>? recordCount,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileName != null) 'file_name': fileName,
      if (importedAt != null) 'imported_at': importedAt,
      if (importedBy != null) 'imported_by': importedBy,
      if (recordCount != null) 'record_count': recordCount,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportBatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? fileName,
    Value<DateTime>? importedAt,
    Value<String?>? importedBy,
    Value<int>? recordCount,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return ImportBatchesCompanion(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      importedAt: importedAt ?? this.importedAt,
      importedBy: importedBy ?? this.importedBy,
      recordCount: recordCount ?? this.recordCount,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (importedBy.present) {
      map['imported_by'] = Variable<String>(importedBy.value);
    }
    if (recordCount.present) {
      map['record_count'] = Variable<int>(recordCount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('importedAt: $importedAt, ')
          ..write('importedBy: $importedBy, ')
          ..write('recordCount: $recordCount, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$ImportBatchInsertable implements Insertable<ImportBatch> {
  ImportBatch _object;
  _$ImportBatchInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return ImportBatchesCompanion(
      id: Value(_object.id),
      fileName: Value(_object.fileName),
      importedAt: Value(_object.importedAt),
      importedBy: Value(_object.importedBy),
      recordCount: Value(_object.recordCount),
      notes: Value(_object.notes),
    ).toColumns(false);
  }
}

extension ImportBatchToInsertable on ImportBatch {
  _$ImportBatchInsertable toInsertable() {
    return _$ImportBatchInsertable(this);
  }
}

class $SchoolResultsTable extends SchoolResults
    with TableInfo<$SchoolResultsTable, SchoolResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boardMeta = const VerificationMeta('board');
  @override
  late final GeneratedColumn<String> board = GeneratedColumn<String>(
    'board',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _percentageMeta = const VerificationMeta(
    'percentage',
  );
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
    'percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passingYearMeta = const VerificationMeta(
    'passingYear',
  );
  @override
  late final GeneratedColumn<int> passingYear = GeneratedColumn<int>(
    'passing_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importBatchIdMeta = const VerificationMeta(
    'importBatchId',
  );
  @override
  late final GeneratedColumn<String> importBatchId = GeneratedColumn<String>(
    'import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    level,
    board,
    percentage,
    passingYear,
    importBatchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'school_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('board')) {
      context.handle(
        _boardMeta,
        board.isAcceptableOrUnknown(data['board']!, _boardMeta),
      );
    }
    if (data.containsKey('percentage')) {
      context.handle(
        _percentageMeta,
        percentage.isAcceptableOrUnknown(data['percentage']!, _percentageMeta),
      );
    } else if (isInserting) {
      context.missing(_percentageMeta);
    }
    if (data.containsKey('passing_year')) {
      context.handle(
        _passingYearMeta,
        passingYear.isAcceptableOrUnknown(
          data['passing_year']!,
          _passingYearMeta,
        ),
      );
    }
    if (data.containsKey('import_batch_id')) {
      context.handle(
        _importBatchIdMeta,
        importBatchId.isAcceptableOrUnknown(
          data['import_batch_id']!,
          _importBatchIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentId, level},
  ];
  @override
  SchoolResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      board: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board'],
      ),
      percentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percentage'],
      )!,
      passingYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passing_year'],
      ),
      importBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_batch_id'],
      ),
    );
  }

  @override
  $SchoolResultsTable createAlias(String alias) {
    return $SchoolResultsTable(attachedDatabase, alias);
  }
}

class SchoolResultsCompanion extends UpdateCompanion<SchoolResult> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> level;
  final Value<String?> board;
  final Value<double> percentage;
  final Value<int?> passingYear;
  final Value<String?> importBatchId;
  final Value<int> rowid;
  const SchoolResultsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.level = const Value.absent(),
    this.board = const Value.absent(),
    this.percentage = const Value.absent(),
    this.passingYear = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolResultsCompanion.insert({
    required String id,
    required String studentId,
    required String level,
    this.board = const Value.absent(),
    required double percentage,
    this.passingYear = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       level = Value(level),
       percentage = Value(percentage);
  static Insertable<SchoolResult> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? level,
    Expression<String>? board,
    Expression<double>? percentage,
    Expression<int>? passingYear,
    Expression<String>? importBatchId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (level != null) 'level': level,
      if (board != null) 'board': board,
      if (percentage != null) 'percentage': percentage,
      if (passingYear != null) 'passing_year': passingYear,
      if (importBatchId != null) 'import_batch_id': importBatchId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? level,
    Value<String?>? board,
    Value<double>? percentage,
    Value<int?>? passingYear,
    Value<String?>? importBatchId,
    Value<int>? rowid,
  }) {
    return SchoolResultsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      level: level ?? this.level,
      board: board ?? this.board,
      percentage: percentage ?? this.percentage,
      passingYear: passingYear ?? this.passingYear,
      importBatchId: importBatchId ?? this.importBatchId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (board.present) {
      map['board'] = Variable<String>(board.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    if (passingYear.present) {
      map['passing_year'] = Variable<int>(passingYear.value);
    }
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<String>(importBatchId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolResultsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('level: $level, ')
          ..write('board: $board, ')
          ..write('percentage: $percentage, ')
          ..write('passingYear: $passingYear, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$SchoolResultInsertable implements Insertable<SchoolResult> {
  SchoolResult _object;
  _$SchoolResultInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return SchoolResultsCompanion(
      id: Value(_object.id),
      studentId: Value(_object.studentId),
      level: Value(_object.level),
      board: Value(_object.board),
      percentage: Value(_object.percentage),
      passingYear: Value(_object.passingYear),
      importBatchId: Value(_object.importBatchId),
    ).toColumns(false);
  }
}

extension SchoolResultToInsertable on SchoolResult {
  _$SchoolResultInsertable toInsertable() {
    return _$SchoolResultInsertable(this);
  }
}

class $SemesterResultsTable extends SemesterResults
    with TableInfo<$SemesterResultsTable, SemesterResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SemesterResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _semesterNumberMeta = const VerificationMeta(
    'semesterNumber',
  );
  @override
  late final GeneratedColumn<int> semesterNumber = GeneratedColumn<int>(
    'semester_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _academicYearMeta = const VerificationMeta(
    'academicYear',
  );
  @override
  late final GeneratedColumn<String> academicYear = GeneratedColumn<String>(
    'academic_year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sgpaMeta = const VerificationMeta('sgpa');
  @override
  late final GeneratedColumn<double> sgpa = GeneratedColumn<double>(
    'sgpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _percentageMeta = const VerificationMeta(
    'percentage',
  );
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
    'percentage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cgpaMeta = const VerificationMeta('cgpa');
  @override
  late final GeneratedColumn<double> cgpa = GeneratedColumn<double>(
    'cgpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backlogsMeta = const VerificationMeta(
    'backlogs',
  );
  @override
  late final GeneratedColumn<int> backlogs = GeneratedColumn<int>(
    'backlogs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _importBatchIdMeta = const VerificationMeta(
    'importBatchId',
  );
  @override
  late final GeneratedColumn<String> importBatchId = GeneratedColumn<String>(
    'import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    semesterNumber,
    academicYear,
    sgpa,
    percentage,
    cgpa,
    backlogs,
    importBatchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'semester_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<SemesterResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('semester_number')) {
      context.handle(
        _semesterNumberMeta,
        semesterNumber.isAcceptableOrUnknown(
          data['semester_number']!,
          _semesterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_semesterNumberMeta);
    }
    if (data.containsKey('academic_year')) {
      context.handle(
        _academicYearMeta,
        academicYear.isAcceptableOrUnknown(
          data['academic_year']!,
          _academicYearMeta,
        ),
      );
    }
    if (data.containsKey('sgpa')) {
      context.handle(
        _sgpaMeta,
        sgpa.isAcceptableOrUnknown(data['sgpa']!, _sgpaMeta),
      );
    }
    if (data.containsKey('percentage')) {
      context.handle(
        _percentageMeta,
        percentage.isAcceptableOrUnknown(data['percentage']!, _percentageMeta),
      );
    }
    if (data.containsKey('cgpa')) {
      context.handle(
        _cgpaMeta,
        cgpa.isAcceptableOrUnknown(data['cgpa']!, _cgpaMeta),
      );
    }
    if (data.containsKey('backlogs')) {
      context.handle(
        _backlogsMeta,
        backlogs.isAcceptableOrUnknown(data['backlogs']!, _backlogsMeta),
      );
    }
    if (data.containsKey('import_batch_id')) {
      context.handle(
        _importBatchIdMeta,
        importBatchId.isAcceptableOrUnknown(
          data['import_batch_id']!,
          _importBatchIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentId, semesterNumber},
  ];
  @override
  SemesterResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SemesterResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      semesterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}semester_number'],
      )!,
      academicYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}academic_year'],
      ),
      sgpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sgpa'],
      ),
      percentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percentage'],
      ),
      cgpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cgpa'],
      ),
      backlogs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backlogs'],
      )!,
      importBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_batch_id'],
      ),
    );
  }

  @override
  $SemesterResultsTable createAlias(String alias) {
    return $SemesterResultsTable(attachedDatabase, alias);
  }
}

class SemesterResultsCompanion extends UpdateCompanion<SemesterResult> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<int> semesterNumber;
  final Value<String?> academicYear;
  final Value<double?> sgpa;
  final Value<double?> percentage;
  final Value<double?> cgpa;
  final Value<int> backlogs;
  final Value<String?> importBatchId;
  final Value<int> rowid;
  const SemesterResultsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.semesterNumber = const Value.absent(),
    this.academicYear = const Value.absent(),
    this.sgpa = const Value.absent(),
    this.percentage = const Value.absent(),
    this.cgpa = const Value.absent(),
    this.backlogs = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SemesterResultsCompanion.insert({
    required String id,
    required String studentId,
    required int semesterNumber,
    this.academicYear = const Value.absent(),
    this.sgpa = const Value.absent(),
    this.percentage = const Value.absent(),
    this.cgpa = const Value.absent(),
    this.backlogs = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       semesterNumber = Value(semesterNumber);
  static Insertable<SemesterResult> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<int>? semesterNumber,
    Expression<String>? academicYear,
    Expression<double>? sgpa,
    Expression<double>? percentage,
    Expression<double>? cgpa,
    Expression<int>? backlogs,
    Expression<String>? importBatchId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (semesterNumber != null) 'semester_number': semesterNumber,
      if (academicYear != null) 'academic_year': academicYear,
      if (sgpa != null) 'sgpa': sgpa,
      if (percentage != null) 'percentage': percentage,
      if (cgpa != null) 'cgpa': cgpa,
      if (backlogs != null) 'backlogs': backlogs,
      if (importBatchId != null) 'import_batch_id': importBatchId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SemesterResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<int>? semesterNumber,
    Value<String?>? academicYear,
    Value<double?>? sgpa,
    Value<double?>? percentage,
    Value<double?>? cgpa,
    Value<int>? backlogs,
    Value<String?>? importBatchId,
    Value<int>? rowid,
  }) {
    return SemesterResultsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      academicYear: academicYear ?? this.academicYear,
      sgpa: sgpa ?? this.sgpa,
      percentage: percentage ?? this.percentage,
      cgpa: cgpa ?? this.cgpa,
      backlogs: backlogs ?? this.backlogs,
      importBatchId: importBatchId ?? this.importBatchId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (semesterNumber.present) {
      map['semester_number'] = Variable<int>(semesterNumber.value);
    }
    if (academicYear.present) {
      map['academic_year'] = Variable<String>(academicYear.value);
    }
    if (sgpa.present) {
      map['sgpa'] = Variable<double>(sgpa.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    if (cgpa.present) {
      map['cgpa'] = Variable<double>(cgpa.value);
    }
    if (backlogs.present) {
      map['backlogs'] = Variable<int>(backlogs.value);
    }
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<String>(importBatchId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SemesterResultsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('semesterNumber: $semesterNumber, ')
          ..write('academicYear: $academicYear, ')
          ..write('sgpa: $sgpa, ')
          ..write('percentage: $percentage, ')
          ..write('cgpa: $cgpa, ')
          ..write('backlogs: $backlogs, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$SemesterResultInsertable implements Insertable<SemesterResult> {
  SemesterResult _object;
  _$SemesterResultInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return SemesterResultsCompanion(
      id: Value(_object.id),
      studentId: Value(_object.studentId),
      semesterNumber: Value(_object.semesterNumber),
      academicYear: Value(_object.academicYear),
      sgpa: Value(_object.sgpa),
      percentage: Value(_object.percentage),
      cgpa: Value(_object.cgpa),
      backlogs: Value(_object.backlogs),
      importBatchId: Value(_object.importBatchId),
    ).toColumns(false);
  }
}

extension SemesterResultToInsertable on SemesterResult {
  _$SemesterResultInsertable toInsertable() {
    return _$SemesterResultInsertable(this);
  }
}

class $SubjectResultsTable extends SubjectResults
    with TableInfo<$SubjectResultsTable, SubjectResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _semesterNumberMeta = const VerificationMeta(
    'semesterNumber',
  );
  @override
  late final GeneratedColumn<int> semesterNumber = GeneratedColumn<int>(
    'semester_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectNameMeta = const VerificationMeta(
    'subjectName',
  );
  @override
  late final GeneratedColumn<String> subjectName = GeneratedColumn<String>(
    'subject_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _internalMarksMeta = const VerificationMeta(
    'internalMarks',
  );
  @override
  late final GeneratedColumn<double> internalMarks = GeneratedColumn<double>(
    'internal_marks',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _practicalMarksMeta = const VerificationMeta(
    'practicalMarks',
  );
  @override
  late final GeneratedColumn<double> practicalMarks = GeneratedColumn<double>(
    'practical_marks',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalMarksMeta = const VerificationMeta(
    'externalMarks',
  );
  @override
  late final GeneratedColumn<double> externalMarks = GeneratedColumn<double>(
    'external_marks',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMarksMeta = const VerificationMeta(
    'totalMarks',
  );
  @override
  late final GeneratedColumn<double> totalMarks = GeneratedColumn<double>(
    'total_marks',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxMarksMeta = const VerificationMeta(
    'maxMarks',
  );
  @override
  late final GeneratedColumn<double> maxMarks = GeneratedColumn<double>(
    'max_marks',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passedMeta = const VerificationMeta('passed');
  @override
  late final GeneratedColumn<bool> passed = GeneratedColumn<bool>(
    'passed',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("passed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _importBatchIdMeta = const VerificationMeta(
    'importBatchId',
  );
  @override
  late final GeneratedColumn<String> importBatchId = GeneratedColumn<String>(
    'import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    semesterNumber,
    subjectId,
    subjectName,
    internalMarks,
    practicalMarks,
    externalMarks,
    totalMarks,
    maxMarks,
    grade,
    passed,
    attempt,
    importBatchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subject_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubjectResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('semester_number')) {
      context.handle(
        _semesterNumberMeta,
        semesterNumber.isAcceptableOrUnknown(
          data['semester_number']!,
          _semesterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_semesterNumberMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('subject_name')) {
      context.handle(
        _subjectNameMeta,
        subjectName.isAcceptableOrUnknown(
          data['subject_name']!,
          _subjectNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subjectNameMeta);
    }
    if (data.containsKey('internal_marks')) {
      context.handle(
        _internalMarksMeta,
        internalMarks.isAcceptableOrUnknown(
          data['internal_marks']!,
          _internalMarksMeta,
        ),
      );
    }
    if (data.containsKey('practical_marks')) {
      context.handle(
        _practicalMarksMeta,
        practicalMarks.isAcceptableOrUnknown(
          data['practical_marks']!,
          _practicalMarksMeta,
        ),
      );
    }
    if (data.containsKey('external_marks')) {
      context.handle(
        _externalMarksMeta,
        externalMarks.isAcceptableOrUnknown(
          data['external_marks']!,
          _externalMarksMeta,
        ),
      );
    }
    if (data.containsKey('total_marks')) {
      context.handle(
        _totalMarksMeta,
        totalMarks.isAcceptableOrUnknown(data['total_marks']!, _totalMarksMeta),
      );
    }
    if (data.containsKey('max_marks')) {
      context.handle(
        _maxMarksMeta,
        maxMarks.isAcceptableOrUnknown(data['max_marks']!, _maxMarksMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('passed')) {
      context.handle(
        _passedMeta,
        passed.isAcceptableOrUnknown(data['passed']!, _passedMeta),
      );
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('import_batch_id')) {
      context.handle(
        _importBatchIdMeta,
        importBatchId.isAcceptableOrUnknown(
          data['import_batch_id']!,
          _importBatchIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentId, semesterNumber, subjectName, attempt},
  ];
  @override
  SubjectResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubjectResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      semesterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}semester_number'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      subjectName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_name'],
      )!,
      internalMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}internal_marks'],
      ),
      practicalMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}practical_marks'],
      ),
      externalMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}external_marks'],
      ),
      totalMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_marks'],
      ),
      maxMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_marks'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      ),
      passed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}passed'],
      ),
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      importBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_batch_id'],
      ),
    );
  }

  @override
  $SubjectResultsTable createAlias(String alias) {
    return $SubjectResultsTable(attachedDatabase, alias);
  }
}

class SubjectResultsCompanion extends UpdateCompanion<SubjectResult> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<int> semesterNumber;
  final Value<String?> subjectId;
  final Value<String> subjectName;
  final Value<double?> internalMarks;
  final Value<double?> practicalMarks;
  final Value<double?> externalMarks;
  final Value<double?> totalMarks;
  final Value<double?> maxMarks;
  final Value<String?> grade;
  final Value<bool?> passed;
  final Value<int> attempt;
  final Value<String?> importBatchId;
  final Value<int> rowid;
  const SubjectResultsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.semesterNumber = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.subjectName = const Value.absent(),
    this.internalMarks = const Value.absent(),
    this.practicalMarks = const Value.absent(),
    this.externalMarks = const Value.absent(),
    this.totalMarks = const Value.absent(),
    this.maxMarks = const Value.absent(),
    this.grade = const Value.absent(),
    this.passed = const Value.absent(),
    this.attempt = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectResultsCompanion.insert({
    required String id,
    required String studentId,
    required int semesterNumber,
    this.subjectId = const Value.absent(),
    required String subjectName,
    this.internalMarks = const Value.absent(),
    this.practicalMarks = const Value.absent(),
    this.externalMarks = const Value.absent(),
    this.totalMarks = const Value.absent(),
    this.maxMarks = const Value.absent(),
    this.grade = const Value.absent(),
    this.passed = const Value.absent(),
    this.attempt = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       semesterNumber = Value(semesterNumber),
       subjectName = Value(subjectName);
  static Insertable<SubjectResult> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<int>? semesterNumber,
    Expression<String>? subjectId,
    Expression<String>? subjectName,
    Expression<double>? internalMarks,
    Expression<double>? practicalMarks,
    Expression<double>? externalMarks,
    Expression<double>? totalMarks,
    Expression<double>? maxMarks,
    Expression<String>? grade,
    Expression<bool>? passed,
    Expression<int>? attempt,
    Expression<String>? importBatchId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (semesterNumber != null) 'semester_number': semesterNumber,
      if (subjectId != null) 'subject_id': subjectId,
      if (subjectName != null) 'subject_name': subjectName,
      if (internalMarks != null) 'internal_marks': internalMarks,
      if (practicalMarks != null) 'practical_marks': practicalMarks,
      if (externalMarks != null) 'external_marks': externalMarks,
      if (totalMarks != null) 'total_marks': totalMarks,
      if (maxMarks != null) 'max_marks': maxMarks,
      if (grade != null) 'grade': grade,
      if (passed != null) 'passed': passed,
      if (attempt != null) 'attempt': attempt,
      if (importBatchId != null) 'import_batch_id': importBatchId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<int>? semesterNumber,
    Value<String?>? subjectId,
    Value<String>? subjectName,
    Value<double?>? internalMarks,
    Value<double?>? practicalMarks,
    Value<double?>? externalMarks,
    Value<double?>? totalMarks,
    Value<double?>? maxMarks,
    Value<String?>? grade,
    Value<bool?>? passed,
    Value<int>? attempt,
    Value<String?>? importBatchId,
    Value<int>? rowid,
  }) {
    return SubjectResultsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      internalMarks: internalMarks ?? this.internalMarks,
      practicalMarks: practicalMarks ?? this.practicalMarks,
      externalMarks: externalMarks ?? this.externalMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      maxMarks: maxMarks ?? this.maxMarks,
      grade: grade ?? this.grade,
      passed: passed ?? this.passed,
      attempt: attempt ?? this.attempt,
      importBatchId: importBatchId ?? this.importBatchId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (semesterNumber.present) {
      map['semester_number'] = Variable<int>(semesterNumber.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (subjectName.present) {
      map['subject_name'] = Variable<String>(subjectName.value);
    }
    if (internalMarks.present) {
      map['internal_marks'] = Variable<double>(internalMarks.value);
    }
    if (practicalMarks.present) {
      map['practical_marks'] = Variable<double>(practicalMarks.value);
    }
    if (externalMarks.present) {
      map['external_marks'] = Variable<double>(externalMarks.value);
    }
    if (totalMarks.present) {
      map['total_marks'] = Variable<double>(totalMarks.value);
    }
    if (maxMarks.present) {
      map['max_marks'] = Variable<double>(maxMarks.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (passed.present) {
      map['passed'] = Variable<bool>(passed.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<String>(importBatchId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectResultsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('semesterNumber: $semesterNumber, ')
          ..write('subjectId: $subjectId, ')
          ..write('subjectName: $subjectName, ')
          ..write('internalMarks: $internalMarks, ')
          ..write('practicalMarks: $practicalMarks, ')
          ..write('externalMarks: $externalMarks, ')
          ..write('totalMarks: $totalMarks, ')
          ..write('maxMarks: $maxMarks, ')
          ..write('grade: $grade, ')
          ..write('passed: $passed, ')
          ..write('attempt: $attempt, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$SubjectResultInsertable implements Insertable<SubjectResult> {
  SubjectResult _object;
  _$SubjectResultInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return SubjectResultsCompanion(
      id: Value(_object.id),
      studentId: Value(_object.studentId),
      semesterNumber: Value(_object.semesterNumber),
      subjectId: Value(_object.subjectId),
      subjectName: Value(_object.subjectName),
      internalMarks: Value(_object.internalMarks),
      practicalMarks: Value(_object.practicalMarks),
      externalMarks: Value(_object.externalMarks),
      totalMarks: Value(_object.totalMarks),
      maxMarks: Value(_object.maxMarks),
      grade: Value(_object.grade),
      passed: Value(_object.passed),
      attempt: Value(_object.attempt),
      importBatchId: Value(_object.importBatchId),
    ).toColumns(false);
  }
}

extension SubjectResultToInsertable on SubjectResult {
  _$SubjectResultInsertable toInsertable() {
    return _$SubjectResultInsertable(this);
  }
}

class $AttendanceSummariesTable extends AttendanceSummaries
    with TableInfo<$AttendanceSummariesTable, AttendanceSummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _semesterNumberMeta = const VerificationMeta(
    'semesterNumber',
  );
  @override
  late final GeneratedColumn<int> semesterNumber = GeneratedColumn<int>(
    'semester_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectNameMeta = const VerificationMeta(
    'subjectName',
  );
  @override
  late final GeneratedColumn<String> subjectName = GeneratedColumn<String>(
    'subject_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classesHeldMeta = const VerificationMeta(
    'classesHeld',
  );
  @override
  late final GeneratedColumn<int> classesHeld = GeneratedColumn<int>(
    'classes_held',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classesAttendedMeta = const VerificationMeta(
    'classesAttended',
  );
  @override
  late final GeneratedColumn<int> classesAttended = GeneratedColumn<int>(
    'classes_attended',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _percentageMeta = const VerificationMeta(
    'percentage',
  );
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
    'percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importBatchIdMeta = const VerificationMeta(
    'importBatchId',
  );
  @override
  late final GeneratedColumn<String> importBatchId = GeneratedColumn<String>(
    'import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    semesterNumber,
    subjectId,
    subjectName,
    classesHeld,
    classesAttended,
    percentage,
    importBatchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceSummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('semester_number')) {
      context.handle(
        _semesterNumberMeta,
        semesterNumber.isAcceptableOrUnknown(
          data['semester_number']!,
          _semesterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_semesterNumberMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('subject_name')) {
      context.handle(
        _subjectNameMeta,
        subjectName.isAcceptableOrUnknown(
          data['subject_name']!,
          _subjectNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subjectNameMeta);
    }
    if (data.containsKey('classes_held')) {
      context.handle(
        _classesHeldMeta,
        classesHeld.isAcceptableOrUnknown(
          data['classes_held']!,
          _classesHeldMeta,
        ),
      );
    }
    if (data.containsKey('classes_attended')) {
      context.handle(
        _classesAttendedMeta,
        classesAttended.isAcceptableOrUnknown(
          data['classes_attended']!,
          _classesAttendedMeta,
        ),
      );
    }
    if (data.containsKey('percentage')) {
      context.handle(
        _percentageMeta,
        percentage.isAcceptableOrUnknown(data['percentage']!, _percentageMeta),
      );
    } else if (isInserting) {
      context.missing(_percentageMeta);
    }
    if (data.containsKey('import_batch_id')) {
      context.handle(
        _importBatchIdMeta,
        importBatchId.isAcceptableOrUnknown(
          data['import_batch_id']!,
          _importBatchIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentId, semesterNumber, subjectName},
  ];
  @override
  AttendanceSummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceSummary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      semesterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}semester_number'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      subjectName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_name'],
      )!,
      classesHeld: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}classes_held'],
      ),
      classesAttended: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}classes_attended'],
      ),
      percentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percentage'],
      )!,
      importBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_batch_id'],
      ),
    );
  }

  @override
  $AttendanceSummariesTable createAlias(String alias) {
    return $AttendanceSummariesTable(attachedDatabase, alias);
  }
}

class AttendanceSummariesCompanion extends UpdateCompanion<AttendanceSummary> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<int> semesterNumber;
  final Value<String?> subjectId;
  final Value<String> subjectName;
  final Value<int?> classesHeld;
  final Value<int?> classesAttended;
  final Value<double> percentage;
  final Value<String?> importBatchId;
  final Value<int> rowid;
  const AttendanceSummariesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.semesterNumber = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.subjectName = const Value.absent(),
    this.classesHeld = const Value.absent(),
    this.classesAttended = const Value.absent(),
    this.percentage = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceSummariesCompanion.insert({
    required String id,
    required String studentId,
    required int semesterNumber,
    this.subjectId = const Value.absent(),
    required String subjectName,
    this.classesHeld = const Value.absent(),
    this.classesAttended = const Value.absent(),
    required double percentage,
    this.importBatchId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       semesterNumber = Value(semesterNumber),
       subjectName = Value(subjectName),
       percentage = Value(percentage);
  static Insertable<AttendanceSummary> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<int>? semesterNumber,
    Expression<String>? subjectId,
    Expression<String>? subjectName,
    Expression<int>? classesHeld,
    Expression<int>? classesAttended,
    Expression<double>? percentage,
    Expression<String>? importBatchId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (semesterNumber != null) 'semester_number': semesterNumber,
      if (subjectId != null) 'subject_id': subjectId,
      if (subjectName != null) 'subject_name': subjectName,
      if (classesHeld != null) 'classes_held': classesHeld,
      if (classesAttended != null) 'classes_attended': classesAttended,
      if (percentage != null) 'percentage': percentage,
      if (importBatchId != null) 'import_batch_id': importBatchId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceSummariesCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<int>? semesterNumber,
    Value<String?>? subjectId,
    Value<String>? subjectName,
    Value<int?>? classesHeld,
    Value<int?>? classesAttended,
    Value<double>? percentage,
    Value<String?>? importBatchId,
    Value<int>? rowid,
  }) {
    return AttendanceSummariesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      classesHeld: classesHeld ?? this.classesHeld,
      classesAttended: classesAttended ?? this.classesAttended,
      percentage: percentage ?? this.percentage,
      importBatchId: importBatchId ?? this.importBatchId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (semesterNumber.present) {
      map['semester_number'] = Variable<int>(semesterNumber.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (subjectName.present) {
      map['subject_name'] = Variable<String>(subjectName.value);
    }
    if (classesHeld.present) {
      map['classes_held'] = Variable<int>(classesHeld.value);
    }
    if (classesAttended.present) {
      map['classes_attended'] = Variable<int>(classesAttended.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<String>(importBatchId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceSummariesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('semesterNumber: $semesterNumber, ')
          ..write('subjectId: $subjectId, ')
          ..write('subjectName: $subjectName, ')
          ..write('classesHeld: $classesHeld, ')
          ..write('classesAttended: $classesAttended, ')
          ..write('percentage: $percentage, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$AttendanceSummaryInsertable implements Insertable<AttendanceSummary> {
  AttendanceSummary _object;
  _$AttendanceSummaryInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return AttendanceSummariesCompanion(
      id: Value(_object.id),
      studentId: Value(_object.studentId),
      semesterNumber: Value(_object.semesterNumber),
      subjectId: Value(_object.subjectId),
      subjectName: Value(_object.subjectName),
      classesHeld: Value(_object.classesHeld),
      classesAttended: Value(_object.classesAttended),
      percentage: Value(_object.percentage),
      importBatchId: Value(_object.importBatchId),
    ).toColumns(false);
  }
}

extension AttendanceSummaryToInsertable on AttendanceSummary {
  _$AttendanceSummaryInsertable toInsertable() {
    return _$AttendanceSummaryInsertable(this);
  }
}

class $AssessmentsTable extends Assessments
    with TableInfo<$AssessmentsTable, Assessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _semesterNumberMeta = const VerificationMeta(
    'semesterNumber',
  );
  @override
  late final GeneratedColumn<int> semesterNumber = GeneratedColumn<int>(
    'semester_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectNameMeta = const VerificationMeta(
    'subjectName',
  );
  @override
  late final GeneratedColumn<String> subjectName = GeneratedColumn<String>(
    'subject_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessmentTypeMeta = const VerificationMeta(
    'assessmentType',
  );
  @override
  late final GeneratedColumn<String> assessmentType = GeneratedColumn<String>(
    'assessment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxScoreMeta = const VerificationMeta(
    'maxScore',
  );
  @override
  late final GeneratedColumn<double> maxScore = GeneratedColumn<double>(
    'max_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessedOnMeta = const VerificationMeta(
    'assessedOn',
  );
  @override
  late final GeneratedColumn<DateTime> assessedOn = GeneratedColumn<DateTime>(
    'assessed_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importBatchIdMeta = const VerificationMeta(
    'importBatchId',
  );
  @override
  late final GeneratedColumn<String> importBatchId = GeneratedColumn<String>(
    'import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    semesterNumber,
    subjectId,
    subjectName,
    assessmentType,
    title,
    score,
    maxScore,
    assessedOn,
    importBatchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Assessment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('semester_number')) {
      context.handle(
        _semesterNumberMeta,
        semesterNumber.isAcceptableOrUnknown(
          data['semester_number']!,
          _semesterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_semesterNumberMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('subject_name')) {
      context.handle(
        _subjectNameMeta,
        subjectName.isAcceptableOrUnknown(
          data['subject_name']!,
          _subjectNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subjectNameMeta);
    }
    if (data.containsKey('assessment_type')) {
      context.handle(
        _assessmentTypeMeta,
        assessmentType.isAcceptableOrUnknown(
          data['assessment_type']!,
          _assessmentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('max_score')) {
      context.handle(
        _maxScoreMeta,
        maxScore.isAcceptableOrUnknown(data['max_score']!, _maxScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_maxScoreMeta);
    }
    if (data.containsKey('assessed_on')) {
      context.handle(
        _assessedOnMeta,
        assessedOn.isAcceptableOrUnknown(data['assessed_on']!, _assessedOnMeta),
      );
    }
    if (data.containsKey('import_batch_id')) {
      context.handle(
        _importBatchIdMeta,
        importBatchId.isAcceptableOrUnknown(
          data['import_batch_id']!,
          _importBatchIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assessment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assessment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      semesterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}semester_number'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      subjectName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_name'],
      )!,
      assessmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      maxScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_score'],
      )!,
      assessedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assessed_on'],
      ),
      importBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_batch_id'],
      ),
    );
  }

  @override
  $AssessmentsTable createAlias(String alias) {
    return $AssessmentsTable(attachedDatabase, alias);
  }
}

class AssessmentsCompanion extends UpdateCompanion<Assessment> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<int> semesterNumber;
  final Value<String?> subjectId;
  final Value<String> subjectName;
  final Value<String> assessmentType;
  final Value<String?> title;
  final Value<double> score;
  final Value<double> maxScore;
  final Value<DateTime?> assessedOn;
  final Value<String?> importBatchId;
  final Value<int> rowid;
  const AssessmentsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.semesterNumber = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.subjectName = const Value.absent(),
    this.assessmentType = const Value.absent(),
    this.title = const Value.absent(),
    this.score = const Value.absent(),
    this.maxScore = const Value.absent(),
    this.assessedOn = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessmentsCompanion.insert({
    required String id,
    required String studentId,
    required int semesterNumber,
    this.subjectId = const Value.absent(),
    required String subjectName,
    required String assessmentType,
    this.title = const Value.absent(),
    required double score,
    required double maxScore,
    this.assessedOn = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       semesterNumber = Value(semesterNumber),
       subjectName = Value(subjectName),
       assessmentType = Value(assessmentType),
       score = Value(score),
       maxScore = Value(maxScore);
  static Insertable<Assessment> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<int>? semesterNumber,
    Expression<String>? subjectId,
    Expression<String>? subjectName,
    Expression<String>? assessmentType,
    Expression<String>? title,
    Expression<double>? score,
    Expression<double>? maxScore,
    Expression<DateTime>? assessedOn,
    Expression<String>? importBatchId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (semesterNumber != null) 'semester_number': semesterNumber,
      if (subjectId != null) 'subject_id': subjectId,
      if (subjectName != null) 'subject_name': subjectName,
      if (assessmentType != null) 'assessment_type': assessmentType,
      if (title != null) 'title': title,
      if (score != null) 'score': score,
      if (maxScore != null) 'max_score': maxScore,
      if (assessedOn != null) 'assessed_on': assessedOn,
      if (importBatchId != null) 'import_batch_id': importBatchId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<int>? semesterNumber,
    Value<String?>? subjectId,
    Value<String>? subjectName,
    Value<String>? assessmentType,
    Value<String?>? title,
    Value<double>? score,
    Value<double>? maxScore,
    Value<DateTime?>? assessedOn,
    Value<String?>? importBatchId,
    Value<int>? rowid,
  }) {
    return AssessmentsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      assessmentType: assessmentType ?? this.assessmentType,
      title: title ?? this.title,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      assessedOn: assessedOn ?? this.assessedOn,
      importBatchId: importBatchId ?? this.importBatchId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (semesterNumber.present) {
      map['semester_number'] = Variable<int>(semesterNumber.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (subjectName.present) {
      map['subject_name'] = Variable<String>(subjectName.value);
    }
    if (assessmentType.present) {
      map['assessment_type'] = Variable<String>(assessmentType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (maxScore.present) {
      map['max_score'] = Variable<double>(maxScore.value);
    }
    if (assessedOn.present) {
      map['assessed_on'] = Variable<DateTime>(assessedOn.value);
    }
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<String>(importBatchId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('semesterNumber: $semesterNumber, ')
          ..write('subjectId: $subjectId, ')
          ..write('subjectName: $subjectName, ')
          ..write('assessmentType: $assessmentType, ')
          ..write('title: $title, ')
          ..write('score: $score, ')
          ..write('maxScore: $maxScore, ')
          ..write('assessedOn: $assessedOn, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$AssessmentInsertable implements Insertable<Assessment> {
  Assessment _object;
  _$AssessmentInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return AssessmentsCompanion(
      id: Value(_object.id),
      studentId: Value(_object.studentId),
      semesterNumber: Value(_object.semesterNumber),
      subjectId: Value(_object.subjectId),
      subjectName: Value(_object.subjectName),
      assessmentType: Value(_object.assessmentType),
      title: Value(_object.title),
      score: Value(_object.score),
      maxScore: Value(_object.maxScore),
      assessedOn: Value(_object.assessedOn),
      importBatchId: Value(_object.importBatchId),
    ).toColumns(false);
  }
}

extension AssessmentToInsertable on Assessment {
  _$AssessmentInsertable toInsertable() {
    return _$AssessmentInsertable(this);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $BranchesTable branches = $BranchesTable(this);
  late final $SemestersTable semesters = $SemestersTable(this);
  late final $SectionsTable sections = $SectionsTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $FacultyMembersTable facultyMembers = $FacultyMembersTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $SubjectMappingsTable subjectMappings = $SubjectMappingsTable(
    this,
  );
  late final $FacultyAssignmentsTable facultyAssignments =
      $FacultyAssignmentsTable(this);
  late final $AttendanceSessionsTable attendanceSessions =
      $AttendanceSessionsTable(this);
  late final $AttendanceRecordsTable attendanceRecords =
      $AttendanceRecordsTable(this);
  late final $StudentEnrollmentsTable studentEnrollments =
      $StudentEnrollmentsTable(this);
  late final $ImportBatchesTable importBatches = $ImportBatchesTable(this);
  late final $SchoolResultsTable schoolResults = $SchoolResultsTable(this);
  late final $SemesterResultsTable semesterResults = $SemesterResultsTable(
    this,
  );
  late final $SubjectResultsTable subjectResults = $SubjectResultsTable(this);
  late final $AttendanceSummariesTable attendanceSummaries =
      $AttendanceSummariesTable(this);
  late final $AssessmentsTable assessments = $AssessmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    courses,
    branches,
    semesters,
    sections,
    students,
    facultyMembers,
    subjects,
    subjectMappings,
    facultyAssignments,
    attendanceSessions,
    attendanceRecords,
    studentEnrollments,
    importBatches,
    schoolResults,
    semesterResults,
    subjectResults,
    attendanceSummaries,
    assessments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'attendance_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attendance_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attendance_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('student_enrollments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('school_results', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'import_batches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('school_results', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('semester_results', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'import_batches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('semester_results', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('subject_results', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'import_batches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('subject_results', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attendance_summaries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'import_batches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attendance_summaries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('assessments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'import_batches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('assessments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String uid,
      required String name,
      required String loginId,
      required String role,
      Value<String?> associatedId,
      required String passwordHash,
      required String passwordSalt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> uid,
      Value<String> name,
      Value<String> loginId,
      Value<String> role,
      Value<String?> associatedId,
      Value<String> passwordHash,
      Value<String> passwordSalt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loginId => $composableBuilder(
    column: $table.loginId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get associatedId => $composableBuilder(
    column: $table.associatedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loginId => $composableBuilder(
    column: $table.loginId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get associatedId => $composableBuilder(
    column: $table.associatedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get loginId =>
      $composableBuilder(column: $table.loginId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get associatedId => $composableBuilder(
    column: $table.associatedId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> loginId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> associatedId = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> passwordSalt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                uid: uid,
                name: name,
                loginId: loginId,
                role: role,
                associatedId: associatedId,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uid,
                required String name,
                required String loginId,
                required String role,
                Value<String?> associatedId = const Value.absent(),
                required String passwordHash,
                required String passwordSalt,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                uid: uid,
                name: name,
                loginId: loginId,
                role: role,
                associatedId: associatedId,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  BaseReferences<_$AppDatabase, $UsersTable, UserRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$CoursesTableCreateCompanionBuilder =
    CoursesCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$CoursesTableUpdateCompanionBuilder =
    CoursesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$CoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursesTable,
          Course,
          $$CoursesTableFilterComposer,
          $$CoursesTableOrderingComposer,
          $$CoursesTableAnnotationComposer,
          $$CoursesTableCreateCompanionBuilder,
          $$CoursesTableUpdateCompanionBuilder,
          (Course, BaseReferences<_$AppDatabase, $CoursesTable, Course>),
          Course,
          PrefetchHooks Function()
        > {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoursesTable, Course>(table),
                  BaseReferences<_$AppDatabase, $CoursesTable, Course>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursesTable,
      Course,
      $$CoursesTableFilterComposer,
      $$CoursesTableOrderingComposer,
      $$CoursesTableAnnotationComposer,
      $$CoursesTableCreateCompanionBuilder,
      $$CoursesTableUpdateCompanionBuilder,
      (Course, BaseReferences<_$AppDatabase, $CoursesTable, Course>),
      Course,
      PrefetchHooks Function()
    >;
typedef $$BranchesTableCreateCompanionBuilder =
    BranchesCompanion Function({
      required String id,
      required String courseId,
      required String name,
      Value<int> rowid,
    });
typedef $$BranchesTableUpdateCompanionBuilder =
    BranchesCompanion Function({
      Value<String> id,
      Value<String> courseId,
      Value<String> name,
      Value<int> rowid,
    });

class $$BranchesTableFilterComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BranchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BranchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$BranchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BranchesTable,
          Branch,
          $$BranchesTableFilterComposer,
          $$BranchesTableOrderingComposer,
          $$BranchesTableAnnotationComposer,
          $$BranchesTableCreateCompanionBuilder,
          $$BranchesTableUpdateCompanionBuilder,
          (Branch, BaseReferences<_$AppDatabase, $BranchesTable, Branch>),
          Branch,
          PrefetchHooks Function()
        > {
  $$BranchesTableTableManager(_$AppDatabase db, $BranchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BranchesCompanion(
                id: id,
                courseId: courseId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String courseId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => BranchesCompanion.insert(
                id: id,
                courseId: courseId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BranchesTable, Branch>(table),
                  BaseReferences<_$AppDatabase, $BranchesTable, Branch>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BranchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BranchesTable,
      Branch,
      $$BranchesTableFilterComposer,
      $$BranchesTableOrderingComposer,
      $$BranchesTableAnnotationComposer,
      $$BranchesTableCreateCompanionBuilder,
      $$BranchesTableUpdateCompanionBuilder,
      (Branch, BaseReferences<_$AppDatabase, $BranchesTable, Branch>),
      Branch,
      PrefetchHooks Function()
    >;
typedef $$SemestersTableCreateCompanionBuilder =
    SemestersCompanion Function({
      required String id,
      required String branchId,
      required int semesterNumber,
      Value<int> rowid,
    });
typedef $$SemestersTableUpdateCompanionBuilder =
    SemestersCompanion Function({
      Value<String> id,
      Value<String> branchId,
      Value<int> semesterNumber,
      Value<int> rowid,
    });

class $$SemestersTableFilterComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SemestersTableOrderingComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SemestersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => column,
  );
}

class $$SemestersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SemestersTable,
          Semester,
          $$SemestersTableFilterComposer,
          $$SemestersTableOrderingComposer,
          $$SemestersTableAnnotationComposer,
          $$SemestersTableCreateCompanionBuilder,
          $$SemestersTableUpdateCompanionBuilder,
          (Semester, BaseReferences<_$AppDatabase, $SemestersTable, Semester>),
          Semester,
          PrefetchHooks Function()
        > {
  $$SemestersTableTableManager(_$AppDatabase db, $SemestersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SemestersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SemestersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SemestersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<int> semesterNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SemestersCompanion(
                id: id,
                branchId: branchId,
                semesterNumber: semesterNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String branchId,
                required int semesterNumber,
                Value<int> rowid = const Value.absent(),
              }) => SemestersCompanion.insert(
                id: id,
                branchId: branchId,
                semesterNumber: semesterNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SemestersTable, Semester>(table),
                  BaseReferences<_$AppDatabase, $SemestersTable, Semester>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SemestersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SemestersTable,
      Semester,
      $$SemestersTableFilterComposer,
      $$SemestersTableOrderingComposer,
      $$SemestersTableAnnotationComposer,
      $$SemestersTableCreateCompanionBuilder,
      $$SemestersTableUpdateCompanionBuilder,
      (Semester, BaseReferences<_$AppDatabase, $SemestersTable, Semester>),
      Semester,
      PrefetchHooks Function()
    >;
typedef $$SectionsTableCreateCompanionBuilder =
    SectionsCompanion Function({
      required String id,
      required String semesterId,
      required String name,
      Value<int> rowid,
    });
typedef $$SectionsTableUpdateCompanionBuilder =
    SectionsCompanion Function({
      Value<String> id,
      Value<String> semesterId,
      Value<String> name,
      Value<int> rowid,
    });

class $$SectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get semesterId => $composableBuilder(
    column: $table.semesterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get semesterId => $composableBuilder(
    column: $table.semesterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get semesterId => $composableBuilder(
    column: $table.semesterId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$SectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionsTable,
          Section,
          $$SectionsTableFilterComposer,
          $$SectionsTableOrderingComposer,
          $$SectionsTableAnnotationComposer,
          $$SectionsTableCreateCompanionBuilder,
          $$SectionsTableUpdateCompanionBuilder,
          (Section, BaseReferences<_$AppDatabase, $SectionsTable, Section>),
          Section,
          PrefetchHooks Function()
        > {
  $$SectionsTableTableManager(_$AppDatabase db, $SectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> semesterId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SectionsCompanion(
                id: id,
                semesterId: semesterId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String semesterId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => SectionsCompanion.insert(
                id: id,
                semesterId: semesterId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SectionsTable, Section>(table),
                  BaseReferences<_$AppDatabase, $SectionsTable, Section>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionsTable,
      Section,
      $$SectionsTableFilterComposer,
      $$SectionsTableOrderingComposer,
      $$SectionsTableAnnotationComposer,
      $$SectionsTableCreateCompanionBuilder,
      $$SectionsTableUpdateCompanionBuilder,
      (Section, BaseReferences<_$AppDatabase, $SectionsTable, Section>),
      Section,
      PrefetchHooks Function()
    >;
typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      required String id,
      required String rollNumber,
      required String name,
      required String sectionId,
      Value<int> rowid,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<String> id,
      Value<String> rollNumber,
      Value<String> name,
      Value<String> sectionId,
      Value<int> rowid,
    });

final class $$StudentsTableReferences
    extends BaseReferences<_$AppDatabase, $StudentsTable, Student> {
  $$StudentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AttendanceRecordsTable, List<AttendanceRecord>>
  _attendanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceRecords,
        aliasName: 'students__id__attendance_records__student_id',
      );

  $$AttendanceRecordsTableProcessedTableManager get attendanceRecordsRefs {
    final manager = $$AttendanceRecordsTableTableManager(
      $_db,
      $_db.attendanceRecords,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudentEnrollmentsTable, List<StudentEnrollment>>
  _studentEnrollmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.studentEnrollments,
        aliasName: 'students__id__student_enrollments__student_id',
      );

  $$StudentEnrollmentsTableProcessedTableManager get studentEnrollmentsRefs {
    final manager = $$StudentEnrollmentsTableTableManager(
      $_db,
      $_db.studentEnrollments,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studentEnrollmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SchoolResultsTable, List<SchoolResult>>
  _schoolResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.schoolResults,
    aliasName: 'students__id__school_results__student_id',
  );

  $$SchoolResultsTableProcessedTableManager get schoolResultsRefs {
    final manager = $$SchoolResultsTableTableManager(
      $_db,
      $_db.schoolResults,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_schoolResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SemesterResultsTable, List<SemesterResult>>
  _semesterResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.semesterResults,
    aliasName: 'students__id__semester_results__student_id',
  );

  $$SemesterResultsTableProcessedTableManager get semesterResultsRefs {
    final manager = $$SemesterResultsTableTableManager(
      $_db,
      $_db.semesterResults,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _semesterResultsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SubjectResultsTable, List<SubjectResult>>
  _subjectResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subjectResults,
    aliasName: 'students__id__subject_results__student_id',
  );

  $$SubjectResultsTableProcessedTableManager get subjectResultsRefs {
    final manager = $$SubjectResultsTableTableManager(
      $_db,
      $_db.subjectResults,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subjectResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttendanceSummariesTable, List<AttendanceSummary>>
  _attendanceSummariesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceSummaries,
        aliasName: 'students__id__attendance_summaries__student_id',
      );

  $$AttendanceSummariesTableProcessedTableManager get attendanceSummariesRefs {
    final manager = $$AttendanceSummariesTableTableManager(
      $_db,
      $_db.attendanceSummaries,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceSummariesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssessmentsTable, List<Assessment>>
  _assessmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessments,
    aliasName: 'students__id__assessments__student_id',
  );

  $$AssessmentsTableProcessedTableManager get assessmentsRefs {
    final manager = $$AssessmentsTableTableManager(
      $_db,
      $_db.assessments,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_assessmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rollNumber => $composableBuilder(
    column: $table.rollNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> attendanceRecordsRefs(
    Expression<bool> Function($$AttendanceRecordsTableFilterComposer f) f,
  ) {
    final $$AttendanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceRecords,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studentEnrollmentsRefs(
    Expression<bool> Function($$StudentEnrollmentsTableFilterComposer f) f,
  ) {
    final $$StudentEnrollmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studentEnrollments,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentEnrollmentsTableFilterComposer(
            $db: $db,
            $table: $db.studentEnrollments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> schoolResultsRefs(
    Expression<bool> Function($$SchoolResultsTableFilterComposer f) f,
  ) {
    final $$SchoolResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schoolResults,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolResultsTableFilterComposer(
            $db: $db,
            $table: $db.schoolResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> semesterResultsRefs(
    Expression<bool> Function($$SemesterResultsTableFilterComposer f) f,
  ) {
    final $$SemesterResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.semesterResults,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SemesterResultsTableFilterComposer(
            $db: $db,
            $table: $db.semesterResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> subjectResultsRefs(
    Expression<bool> Function($$SubjectResultsTableFilterComposer f) f,
  ) {
    final $$SubjectResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subjectResults,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectResultsTableFilterComposer(
            $db: $db,
            $table: $db.subjectResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attendanceSummariesRefs(
    Expression<bool> Function($$AttendanceSummariesTableFilterComposer f) f,
  ) {
    final $$AttendanceSummariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceSummaries,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceSummariesTableFilterComposer(
            $db: $db,
            $table: $db.attendanceSummaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assessmentsRefs(
    Expression<bool> Function($$AssessmentsTableFilterComposer f) f,
  ) {
    final $$AssessmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessments,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentsTableFilterComposer(
            $db: $db,
            $table: $db.assessments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rollNumber => $composableBuilder(
    column: $table.rollNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rollNumber => $composableBuilder(
    column: $table.rollNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  Expression<T> attendanceRecordsRefs<T extends Object>(
    Expression<T> Function($$AttendanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceRecords,
          getReferencedColumn: (t) => t.studentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> studentEnrollmentsRefs<T extends Object>(
    Expression<T> Function($$StudentEnrollmentsTableAnnotationComposer a) f,
  ) {
    final $$StudentEnrollmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.studentEnrollments,
          getReferencedColumn: (t) => t.studentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StudentEnrollmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.studentEnrollments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> schoolResultsRefs<T extends Object>(
    Expression<T> Function($$SchoolResultsTableAnnotationComposer a) f,
  ) {
    final $$SchoolResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schoolResults,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.schoolResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> semesterResultsRefs<T extends Object>(
    Expression<T> Function($$SemesterResultsTableAnnotationComposer a) f,
  ) {
    final $$SemesterResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.semesterResults,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SemesterResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.semesterResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> subjectResultsRefs<T extends Object>(
    Expression<T> Function($$SubjectResultsTableAnnotationComposer a) f,
  ) {
    final $$SubjectResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subjectResults,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjectResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attendanceSummariesRefs<T extends Object>(
    Expression<T> Function($$AttendanceSummariesTableAnnotationComposer a) f,
  ) {
    final $$AttendanceSummariesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceSummaries,
          getReferencedColumn: (t) => t.studentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceSummariesTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceSummaries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> assessmentsRefs<T extends Object>(
    Expression<T> Function($$AssessmentsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessments,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, $$StudentsTableReferences),
          Student,
          PrefetchHooks Function({
            bool attendanceRecordsRefs,
            bool studentEnrollmentsRefs,
            bool schoolResultsRefs,
            bool semesterResultsRefs,
            bool subjectResultsRefs,
            bool attendanceSummariesRefs,
            bool assessmentsRefs,
          })
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> rollNumber = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                rollNumber: rollNumber,
                name: name,
                sectionId: sectionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String rollNumber,
                required String name,
                required String sectionId,
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                rollNumber: rollNumber,
                name: name,
                sectionId: sectionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudentsTable, Student>(table),
                  $$StudentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                attendanceRecordsRefs = false,
                studentEnrollmentsRefs = false,
                schoolResultsRefs = false,
                semesterResultsRefs = false,
                subjectResultsRefs = false,
                attendanceSummariesRefs = false,
                assessmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attendanceRecordsRefs) db.attendanceRecords,
                    if (studentEnrollmentsRefs) db.studentEnrollments,
                    if (schoolResultsRefs) db.schoolResults,
                    if (semesterResultsRefs) db.semesterResults,
                    if (subjectResultsRefs) db.subjectResults,
                    if (attendanceSummariesRefs) db.attendanceSummaries,
                    if (assessmentsRefs) db.assessments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attendanceRecordsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          AttendanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._attendanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (studentEnrollmentsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          StudentEnrollment
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._studentEnrollmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).studentEnrollmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (schoolResultsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          SchoolResult
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._schoolResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).schoolResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (semesterResultsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          SemesterResult
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._semesterResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).semesterResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (subjectResultsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          SubjectResult
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._subjectResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).subjectResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attendanceSummariesRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          AttendanceSummary
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._attendanceSummariesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceSummariesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (assessmentsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          Assessment
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._assessmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
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

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, $$StudentsTableReferences),
      Student,
      PrefetchHooks Function({
        bool attendanceRecordsRefs,
        bool studentEnrollmentsRefs,
        bool schoolResultsRefs,
        bool semesterResultsRefs,
        bool subjectResultsRefs,
        bool attendanceSummariesRefs,
        bool assessmentsRefs,
      })
    >;
typedef $$FacultyMembersTableCreateCompanionBuilder =
    FacultyMembersCompanion Function({
      required String id,
      required String employeeId,
      required String name,
      required String email,
      Value<int> rowid,
    });
typedef $$FacultyMembersTableUpdateCompanionBuilder =
    FacultyMembersCompanion Function({
      Value<String> id,
      Value<String> employeeId,
      Value<String> name,
      Value<String> email,
      Value<int> rowid,
    });

class $$FacultyMembersTableFilterComposer
    extends Composer<_$AppDatabase, $FacultyMembersTable> {
  $$FacultyMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FacultyMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $FacultyMembersTable> {
  $$FacultyMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FacultyMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FacultyMembersTable> {
  $$FacultyMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);
}

class $$FacultyMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FacultyMembersTable,
          Faculty,
          $$FacultyMembersTableFilterComposer,
          $$FacultyMembersTableOrderingComposer,
          $$FacultyMembersTableAnnotationComposer,
          $$FacultyMembersTableCreateCompanionBuilder,
          $$FacultyMembersTableUpdateCompanionBuilder,
          (
            Faculty,
            BaseReferences<_$AppDatabase, $FacultyMembersTable, Faculty>,
          ),
          Faculty,
          PrefetchHooks Function()
        > {
  $$FacultyMembersTableTableManager(
    _$AppDatabase db,
    $FacultyMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FacultyMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FacultyMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FacultyMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FacultyMembersCompanion(
                id: id,
                employeeId: employeeId,
                name: name,
                email: email,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String employeeId,
                required String name,
                required String email,
                Value<int> rowid = const Value.absent(),
              }) => FacultyMembersCompanion.insert(
                id: id,
                employeeId: employeeId,
                name: name,
                email: email,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FacultyMembersTable, Faculty>(table),
                  BaseReferences<_$AppDatabase, $FacultyMembersTable, Faculty>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FacultyMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FacultyMembersTable,
      Faculty,
      $$FacultyMembersTableFilterComposer,
      $$FacultyMembersTableOrderingComposer,
      $$FacultyMembersTableAnnotationComposer,
      $$FacultyMembersTableCreateCompanionBuilder,
      $$FacultyMembersTableUpdateCompanionBuilder,
      (Faculty, BaseReferences<_$AppDatabase, $FacultyMembersTable, Faculty>),
      Faculty,
      PrefetchHooks Function()
    >;
typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      required String id,
      required String code,
      required String name,
      Value<int> rowid,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> name,
      Value<int> rowid,
    });

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, BaseReferences<_$AppDatabase, $SubjectsTable, Subject>),
          Subject,
          PrefetchHooks Function()
        > {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                code: code,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion.insert(
                id: id,
                code: code,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubjectsTable, Subject>(table),
                  BaseReferences<_$AppDatabase, $SubjectsTable, Subject>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, BaseReferences<_$AppDatabase, $SubjectsTable, Subject>),
      Subject,
      PrefetchHooks Function()
    >;
typedef $$SubjectMappingsTableCreateCompanionBuilder =
    SubjectMappingsCompanion Function({
      required String id,
      required String sectionId,
      required String subjectId,
      Value<int> rowid,
    });
typedef $$SubjectMappingsTableUpdateCompanionBuilder =
    SubjectMappingsCompanion Function({
      Value<String> id,
      Value<String> sectionId,
      Value<String> subjectId,
      Value<int> rowid,
    });

class $$SubjectMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectMappingsTable> {
  $$SubjectMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubjectMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectMappingsTable> {
  $$SubjectMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectMappingsTable> {
  $$SubjectMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);
}

class $$SubjectMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectMappingsTable,
          SubjectMapping,
          $$SubjectMappingsTableFilterComposer,
          $$SubjectMappingsTableOrderingComposer,
          $$SubjectMappingsTableAnnotationComposer,
          $$SubjectMappingsTableCreateCompanionBuilder,
          $$SubjectMappingsTableUpdateCompanionBuilder,
          (
            SubjectMapping,
            BaseReferences<
              _$AppDatabase,
              $SubjectMappingsTable,
              SubjectMapping
            >,
          ),
          SubjectMapping,
          PrefetchHooks Function()
        > {
  $$SubjectMappingsTableTableManager(
    _$AppDatabase db,
    $SubjectMappingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectMappingsCompanion(
                id: id,
                sectionId: sectionId,
                subjectId: subjectId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sectionId,
                required String subjectId,
                Value<int> rowid = const Value.absent(),
              }) => SubjectMappingsCompanion.insert(
                id: id,
                sectionId: sectionId,
                subjectId: subjectId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubjectMappingsTable, SubjectMapping>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SubjectMappingsTable,
                    SubjectMapping
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubjectMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectMappingsTable,
      SubjectMapping,
      $$SubjectMappingsTableFilterComposer,
      $$SubjectMappingsTableOrderingComposer,
      $$SubjectMappingsTableAnnotationComposer,
      $$SubjectMappingsTableCreateCompanionBuilder,
      $$SubjectMappingsTableUpdateCompanionBuilder,
      (
        SubjectMapping,
        BaseReferences<_$AppDatabase, $SubjectMappingsTable, SubjectMapping>,
      ),
      SubjectMapping,
      PrefetchHooks Function()
    >;
typedef $$FacultyAssignmentsTableCreateCompanionBuilder =
    FacultyAssignmentsCompanion Function({
      required String id,
      required String facultyId,
      required String subjectMappingId,
      Value<int> rowid,
    });
typedef $$FacultyAssignmentsTableUpdateCompanionBuilder =
    FacultyAssignmentsCompanion Function({
      Value<String> id,
      Value<String> facultyId,
      Value<String> subjectMappingId,
      Value<int> rowid,
    });

class $$FacultyAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $FacultyAssignmentsTable> {
  $$FacultyAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facultyId => $composableBuilder(
    column: $table.facultyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectMappingId => $composableBuilder(
    column: $table.subjectMappingId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FacultyAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $FacultyAssignmentsTable> {
  $$FacultyAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facultyId => $composableBuilder(
    column: $table.facultyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectMappingId => $composableBuilder(
    column: $table.subjectMappingId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FacultyAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FacultyAssignmentsTable> {
  $$FacultyAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get facultyId =>
      $composableBuilder(column: $table.facultyId, builder: (column) => column);

  GeneratedColumn<String> get subjectMappingId => $composableBuilder(
    column: $table.subjectMappingId,
    builder: (column) => column,
  );
}

class $$FacultyAssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FacultyAssignmentsTable,
          FacultyAssignment,
          $$FacultyAssignmentsTableFilterComposer,
          $$FacultyAssignmentsTableOrderingComposer,
          $$FacultyAssignmentsTableAnnotationComposer,
          $$FacultyAssignmentsTableCreateCompanionBuilder,
          $$FacultyAssignmentsTableUpdateCompanionBuilder,
          (
            FacultyAssignment,
            BaseReferences<
              _$AppDatabase,
              $FacultyAssignmentsTable,
              FacultyAssignment
            >,
          ),
          FacultyAssignment,
          PrefetchHooks Function()
        > {
  $$FacultyAssignmentsTableTableManager(
    _$AppDatabase db,
    $FacultyAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FacultyAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FacultyAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FacultyAssignmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> facultyId = const Value.absent(),
                Value<String> subjectMappingId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FacultyAssignmentsCompanion(
                id: id,
                facultyId: facultyId,
                subjectMappingId: subjectMappingId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String facultyId,
                required String subjectMappingId,
                Value<int> rowid = const Value.absent(),
              }) => FacultyAssignmentsCompanion.insert(
                id: id,
                facultyId: facultyId,
                subjectMappingId: subjectMappingId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FacultyAssignmentsTable, FacultyAssignment>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $FacultyAssignmentsTable,
                    FacultyAssignment
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FacultyAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FacultyAssignmentsTable,
      FacultyAssignment,
      $$FacultyAssignmentsTableFilterComposer,
      $$FacultyAssignmentsTableOrderingComposer,
      $$FacultyAssignmentsTableAnnotationComposer,
      $$FacultyAssignmentsTableCreateCompanionBuilder,
      $$FacultyAssignmentsTableUpdateCompanionBuilder,
      (
        FacultyAssignment,
        BaseReferences<
          _$AppDatabase,
          $FacultyAssignmentsTable,
          FacultyAssignment
        >,
      ),
      FacultyAssignment,
      PrefetchHooks Function()
    >;
typedef $$AttendanceSessionsTableCreateCompanionBuilder =
    AttendanceSessionsCompanion Function({
      required String id,
      required String facultyId,
      required String subjectId,
      required String sectionId,
      required DateTime date,
      required String startTime,
      required String endTime,
      Value<int> rowid,
    });
typedef $$AttendanceSessionsTableUpdateCompanionBuilder =
    AttendanceSessionsCompanion Function({
      Value<String> id,
      Value<String> facultyId,
      Value<String> subjectId,
      Value<String> sectionId,
      Value<DateTime> date,
      Value<String> startTime,
      Value<String> endTime,
      Value<int> rowid,
    });

final class $$AttendanceSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttendanceSessionsTable,
          AttendanceSession
        > {
  $$AttendanceSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AttendanceRecordsTable, List<AttendanceRecord>>
  _attendanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceRecords,
        aliasName: 'attendance_sessions__id__attendance_records__session_id',
      );

  $$AttendanceRecordsTableProcessedTableManager get attendanceRecordsRefs {
    final manager = $$AttendanceRecordsTableTableManager(
      $_db,
      $_db.attendanceRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttendanceSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceSessionsTable> {
  $$AttendanceSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facultyId => $composableBuilder(
    column: $table.facultyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> attendanceRecordsRefs(
    Expression<bool> Function($$AttendanceRecordsTableFilterComposer f) f,
  ) {
    final $$AttendanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttendanceSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceSessionsTable> {
  $$AttendanceSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facultyId => $composableBuilder(
    column: $table.facultyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceSessionsTable> {
  $$AttendanceSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get facultyId =>
      $composableBuilder(column: $table.facultyId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  Expression<T> attendanceRecordsRefs<T extends Object>(
    Expression<T> Function($$AttendanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AttendanceSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceSessionsTable,
          AttendanceSession,
          $$AttendanceSessionsTableFilterComposer,
          $$AttendanceSessionsTableOrderingComposer,
          $$AttendanceSessionsTableAnnotationComposer,
          $$AttendanceSessionsTableCreateCompanionBuilder,
          $$AttendanceSessionsTableUpdateCompanionBuilder,
          (AttendanceSession, $$AttendanceSessionsTableReferences),
          AttendanceSession,
          PrefetchHooks Function({bool attendanceRecordsRefs})
        > {
  $$AttendanceSessionsTableTableManager(
    _$AppDatabase db,
    $AttendanceSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> facultyId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceSessionsCompanion(
                id: id,
                facultyId: facultyId,
                subjectId: subjectId,
                sectionId: sectionId,
                date: date,
                startTime: startTime,
                endTime: endTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String facultyId,
                required String subjectId,
                required String sectionId,
                required DateTime date,
                required String startTime,
                required String endTime,
                Value<int> rowid = const Value.absent(),
              }) => AttendanceSessionsCompanion.insert(
                id: id,
                facultyId: facultyId,
                subjectId: subjectId,
                sectionId: sectionId,
                date: date,
                startTime: startTime,
                endTime: endTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceSessionsTable, AttendanceSession>(
                    table,
                  ),
                  $$AttendanceSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attendanceRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (attendanceRecordsRefs) db.attendanceRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attendanceRecordsRefs)
                    await $_getPrefetchedData<
                      AttendanceSession,
                      $AttendanceSessionsTable,
                      AttendanceRecord
                    >(
                      currentTable: table,
                      referencedTable: $$AttendanceSessionsTableReferences
                          ._attendanceRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AttendanceSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).attendanceRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AttendanceSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceSessionsTable,
      AttendanceSession,
      $$AttendanceSessionsTableFilterComposer,
      $$AttendanceSessionsTableOrderingComposer,
      $$AttendanceSessionsTableAnnotationComposer,
      $$AttendanceSessionsTableCreateCompanionBuilder,
      $$AttendanceSessionsTableUpdateCompanionBuilder,
      (AttendanceSession, $$AttendanceSessionsTableReferences),
      AttendanceSession,
      PrefetchHooks Function({bool attendanceRecordsRefs})
    >;
typedef $$AttendanceRecordsTableCreateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      required String id,
      required String sessionId,
      required String studentId,
      required String status,
      Value<int> rowid,
    });
typedef $$AttendanceRecordsTableUpdateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> studentId,
      Value<String> status,
      Value<int> rowid,
    });

final class $$AttendanceRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord
        > {
  $$AttendanceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttendanceSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .attendanceSessions
      .createAlias('attendance_records__session_id__attendance_sessions__id');

  $$AttendanceSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$AttendanceSessionsTableTableManager(
      $_db,
      $_db.attendanceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('attendance_records__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$AttendanceSessionsTableFilterComposer get sessionId {
    final $$AttendanceSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.attendanceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceSessionsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttendanceSessionsTableOrderingComposer get sessionId {
    final $$AttendanceSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.attendanceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.attendanceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$AttendanceSessionsTableAnnotationComposer get sessionId {
    final $$AttendanceSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.attendanceSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord,
          $$AttendanceRecordsTableFilterComposer,
          $$AttendanceRecordsTableOrderingComposer,
          $$AttendanceRecordsTableAnnotationComposer,
          $$AttendanceRecordsTableCreateCompanionBuilder,
          $$AttendanceRecordsTableUpdateCompanionBuilder,
          (AttendanceRecord, $$AttendanceRecordsTableReferences),
          AttendanceRecord,
          PrefetchHooks Function({bool sessionId, bool studentId})
        > {
  $$AttendanceRecordsTableTableManager(
    _$AppDatabase db,
    $AttendanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceRecordsCompanion(
                id: id,
                sessionId: sessionId,
                studentId: studentId,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String studentId,
                required String status,
                Value<int> rowid = const Value.absent(),
              }) => AttendanceRecordsCompanion.insert(
                id: id,
                sessionId: sessionId,
                studentId: studentId,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceRecordsTable, AttendanceRecord>(table),
                  $$AttendanceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, studentId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$AttendanceRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$AttendanceRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable:
                                    $$AttendanceRecordsTableReferences
                                        ._studentIdTable(db),
                                referencedColumn:
                                    $$AttendanceRecordsTableReferences
                                        ._studentIdTable(db)
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

typedef $$AttendanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceRecordsTable,
      AttendanceRecord,
      $$AttendanceRecordsTableFilterComposer,
      $$AttendanceRecordsTableOrderingComposer,
      $$AttendanceRecordsTableAnnotationComposer,
      $$AttendanceRecordsTableCreateCompanionBuilder,
      $$AttendanceRecordsTableUpdateCompanionBuilder,
      (AttendanceRecord, $$AttendanceRecordsTableReferences),
      AttendanceRecord,
      PrefetchHooks Function({bool sessionId, bool studentId})
    >;
typedef $$StudentEnrollmentsTableCreateCompanionBuilder =
    StudentEnrollmentsCompanion Function({
      required String id,
      required String studentId,
      required String sectionId,
      required int semesterNumber,
      Value<String?> academicYear,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });
typedef $$StudentEnrollmentsTableUpdateCompanionBuilder =
    StudentEnrollmentsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String> sectionId,
      Value<int> semesterNumber,
      Value<String?> academicYear,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });

final class $$StudentEnrollmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StudentEnrollmentsTable,
          StudentEnrollment
        > {
  $$StudentEnrollmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('student_enrollments__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StudentEnrollmentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentEnrollmentsTable> {
  $$StudentEnrollmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentEnrollmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentEnrollmentsTable> {
  $$StudentEnrollmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentEnrollmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentEnrollmentsTable> {
  $$StudentEnrollmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentEnrollmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentEnrollmentsTable,
          StudentEnrollment,
          $$StudentEnrollmentsTableFilterComposer,
          $$StudentEnrollmentsTableOrderingComposer,
          $$StudentEnrollmentsTableAnnotationComposer,
          $$StudentEnrollmentsTableCreateCompanionBuilder,
          $$StudentEnrollmentsTableUpdateCompanionBuilder,
          (StudentEnrollment, $$StudentEnrollmentsTableReferences),
          StudentEnrollment,
          PrefetchHooks Function({bool studentId})
        > {
  $$StudentEnrollmentsTableTableManager(
    _$AppDatabase db,
    $StudentEnrollmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentEnrollmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentEnrollmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentEnrollmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<int> semesterNumber = const Value.absent(),
                Value<String?> academicYear = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentEnrollmentsCompanion(
                id: id,
                studentId: studentId,
                sectionId: sectionId,
                semesterNumber: semesterNumber,
                academicYear: academicYear,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String sectionId,
                required int semesterNumber,
                Value<String?> academicYear = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentEnrollmentsCompanion.insert(
                id: id,
                studentId: studentId,
                sectionId: sectionId,
                semesterNumber: semesterNumber,
                academicYear: academicYear,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudentEnrollmentsTable, StudentEnrollment>(
                    table,
                  ),
                  $$StudentEnrollmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable:
                                    $$StudentEnrollmentsTableReferences
                                        ._studentIdTable(db),
                                referencedColumn:
                                    $$StudentEnrollmentsTableReferences
                                        ._studentIdTable(db)
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

typedef $$StudentEnrollmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentEnrollmentsTable,
      StudentEnrollment,
      $$StudentEnrollmentsTableFilterComposer,
      $$StudentEnrollmentsTableOrderingComposer,
      $$StudentEnrollmentsTableAnnotationComposer,
      $$StudentEnrollmentsTableCreateCompanionBuilder,
      $$StudentEnrollmentsTableUpdateCompanionBuilder,
      (StudentEnrollment, $$StudentEnrollmentsTableReferences),
      StudentEnrollment,
      PrefetchHooks Function({bool studentId})
    >;
typedef $$ImportBatchesTableCreateCompanionBuilder =
    ImportBatchesCompanion Function({
      required String id,
      required String fileName,
      required DateTime importedAt,
      Value<String?> importedBy,
      required int recordCount,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$ImportBatchesTableUpdateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<String> id,
      Value<String> fileName,
      Value<DateTime> importedAt,
      Value<String?> importedBy,
      Value<int> recordCount,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$ImportBatchesTableReferences
    extends BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatch> {
  $$ImportBatchesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SchoolResultsTable, List<SchoolResult>>
  _schoolResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.schoolResults,
    aliasName: 'import_batches__id__school_results__import_batch_id',
  );

  $$SchoolResultsTableProcessedTableManager get schoolResultsRefs {
    final manager = $$SchoolResultsTableTableManager(
      $_db,
      $_db.schoolResults,
    ).filter((f) => f.importBatchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_schoolResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SemesterResultsTable, List<SemesterResult>>
  _semesterResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.semesterResults,
    aliasName: 'import_batches__id__semester_results__import_batch_id',
  );

  $$SemesterResultsTableProcessedTableManager get semesterResultsRefs {
    final manager = $$SemesterResultsTableTableManager(
      $_db,
      $_db.semesterResults,
    ).filter((f) => f.importBatchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _semesterResultsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SubjectResultsTable, List<SubjectResult>>
  _subjectResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subjectResults,
    aliasName: 'import_batches__id__subject_results__import_batch_id',
  );

  $$SubjectResultsTableProcessedTableManager get subjectResultsRefs {
    final manager = $$SubjectResultsTableTableManager(
      $_db,
      $_db.subjectResults,
    ).filter((f) => f.importBatchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subjectResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttendanceSummariesTable, List<AttendanceSummary>>
  _attendanceSummariesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceSummaries,
        aliasName: 'import_batches__id__attendance_summaries__import_batch_id',
      );

  $$AttendanceSummariesTableProcessedTableManager get attendanceSummariesRefs {
    final manager = $$AttendanceSummariesTableTableManager(
      $_db,
      $_db.attendanceSummaries,
    ).filter((f) => f.importBatchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceSummariesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssessmentsTable, List<Assessment>>
  _assessmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessments,
    aliasName: 'import_batches__id__assessments__import_batch_id',
  );

  $$AssessmentsTableProcessedTableManager get assessmentsRefs {
    final manager = $$AssessmentsTableTableManager(
      $_db,
      $_db.assessments,
    ).filter((f) => f.importBatchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_assessmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importedBy => $composableBuilder(
    column: $table.importedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> schoolResultsRefs(
    Expression<bool> Function($$SchoolResultsTableFilterComposer f) f,
  ) {
    final $$SchoolResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schoolResults,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolResultsTableFilterComposer(
            $db: $db,
            $table: $db.schoolResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> semesterResultsRefs(
    Expression<bool> Function($$SemesterResultsTableFilterComposer f) f,
  ) {
    final $$SemesterResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.semesterResults,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SemesterResultsTableFilterComposer(
            $db: $db,
            $table: $db.semesterResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> subjectResultsRefs(
    Expression<bool> Function($$SubjectResultsTableFilterComposer f) f,
  ) {
    final $$SubjectResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subjectResults,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectResultsTableFilterComposer(
            $db: $db,
            $table: $db.subjectResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attendanceSummariesRefs(
    Expression<bool> Function($$AttendanceSummariesTableFilterComposer f) f,
  ) {
    final $$AttendanceSummariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceSummaries,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceSummariesTableFilterComposer(
            $db: $db,
            $table: $db.attendanceSummaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assessmentsRefs(
    Expression<bool> Function($$AssessmentsTableFilterComposer f) f,
  ) {
    final $$AssessmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessments,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentsTableFilterComposer(
            $db: $db,
            $table: $db.assessments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importedBy => $composableBuilder(
    column: $table.importedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importedBy => $composableBuilder(
    column: $table.importedBy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> schoolResultsRefs<T extends Object>(
    Expression<T> Function($$SchoolResultsTableAnnotationComposer a) f,
  ) {
    final $$SchoolResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schoolResults,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchoolResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.schoolResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> semesterResultsRefs<T extends Object>(
    Expression<T> Function($$SemesterResultsTableAnnotationComposer a) f,
  ) {
    final $$SemesterResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.semesterResults,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SemesterResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.semesterResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> subjectResultsRefs<T extends Object>(
    Expression<T> Function($$SubjectResultsTableAnnotationComposer a) f,
  ) {
    final $$SubjectResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subjectResults,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjectResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attendanceSummariesRefs<T extends Object>(
    Expression<T> Function($$AttendanceSummariesTableAnnotationComposer a) f,
  ) {
    final $$AttendanceSummariesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceSummaries,
          getReferencedColumn: (t) => t.importBatchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceSummariesTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceSummaries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> assessmentsRefs<T extends Object>(
    Expression<T> Function($$AssessmentsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessments,
      getReferencedColumn: (t) => t.importBatchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportBatchesTable,
          ImportBatch,
          $$ImportBatchesTableFilterComposer,
          $$ImportBatchesTableOrderingComposer,
          $$ImportBatchesTableAnnotationComposer,
          $$ImportBatchesTableCreateCompanionBuilder,
          $$ImportBatchesTableUpdateCompanionBuilder,
          (ImportBatch, $$ImportBatchesTableReferences),
          ImportBatch,
          PrefetchHooks Function({
            bool schoolResultsRefs,
            bool semesterResultsRefs,
            bool subjectResultsRefs,
            bool attendanceSummariesRefs,
            bool assessmentsRefs,
          })
        > {
  $$ImportBatchesTableTableManager(_$AppDatabase db, $ImportBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<String?> importedBy = const Value.absent(),
                Value<int> recordCount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion(
                id: id,
                fileName: fileName,
                importedAt: importedAt,
                importedBy: importedBy,
                recordCount: recordCount,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fileName,
                required DateTime importedAt,
                Value<String?> importedBy = const Value.absent(),
                required int recordCount,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion.insert(
                id: id,
                fileName: fileName,
                importedAt: importedAt,
                importedBy: importedBy,
                recordCount: recordCount,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportBatchesTable, ImportBatch>(table),
                  $$ImportBatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                schoolResultsRefs = false,
                semesterResultsRefs = false,
                subjectResultsRefs = false,
                attendanceSummariesRefs = false,
                assessmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (schoolResultsRefs) db.schoolResults,
                    if (semesterResultsRefs) db.semesterResults,
                    if (subjectResultsRefs) db.subjectResults,
                    if (attendanceSummariesRefs) db.attendanceSummaries,
                    if (assessmentsRefs) db.assessments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (schoolResultsRefs)
                        await $_getPrefetchedData<
                          ImportBatch,
                          $ImportBatchesTable,
                          SchoolResult
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._schoolResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).schoolResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importBatchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (semesterResultsRefs)
                        await $_getPrefetchedData<
                          ImportBatch,
                          $ImportBatchesTable,
                          SemesterResult
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._semesterResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).semesterResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importBatchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (subjectResultsRefs)
                        await $_getPrefetchedData<
                          ImportBatch,
                          $ImportBatchesTable,
                          SubjectResult
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._subjectResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).subjectResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importBatchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attendanceSummariesRefs)
                        await $_getPrefetchedData<
                          ImportBatch,
                          $ImportBatchesTable,
                          AttendanceSummary
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._attendanceSummariesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceSummariesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importBatchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (assessmentsRefs)
                        await $_getPrefetchedData<
                          ImportBatch,
                          $ImportBatchesTable,
                          Assessment
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._assessmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importBatchId == item.id,
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

typedef $$ImportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportBatchesTable,
      ImportBatch,
      $$ImportBatchesTableFilterComposer,
      $$ImportBatchesTableOrderingComposer,
      $$ImportBatchesTableAnnotationComposer,
      $$ImportBatchesTableCreateCompanionBuilder,
      $$ImportBatchesTableUpdateCompanionBuilder,
      (ImportBatch, $$ImportBatchesTableReferences),
      ImportBatch,
      PrefetchHooks Function({
        bool schoolResultsRefs,
        bool semesterResultsRefs,
        bool subjectResultsRefs,
        bool attendanceSummariesRefs,
        bool assessmentsRefs,
      })
    >;
typedef $$SchoolResultsTableCreateCompanionBuilder =
    SchoolResultsCompanion Function({
      required String id,
      required String studentId,
      required String level,
      Value<String?> board,
      required double percentage,
      Value<int?> passingYear,
      Value<String?> importBatchId,
      Value<int> rowid,
    });
typedef $$SchoolResultsTableUpdateCompanionBuilder =
    SchoolResultsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String> level,
      Value<String?> board,
      Value<double> percentage,
      Value<int?> passingYear,
      Value<String?> importBatchId,
      Value<int> rowid,
    });

final class $$SchoolResultsTableReferences
    extends BaseReferences<_$AppDatabase, $SchoolResultsTable, SchoolResult> {
  $$SchoolResultsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('school_results__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportBatchesTable _importBatchIdTable(_$AppDatabase db) => db
      .importBatches
      .createAlias('school_results__import_batch_id__import_batches__id');

  $$ImportBatchesTableProcessedTableManager? get importBatchId {
    final $_column = $_itemColumn<String>('import_batch_id');
    if ($_column == null) return null;
    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importBatchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SchoolResultsTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolResultsTable> {
  $$SchoolResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get board => $composableBuilder(
    column: $table.board,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passingYear => $composableBuilder(
    column: $table.passingYear,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableFilterComposer get importBatchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchoolResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolResultsTable> {
  $$SchoolResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get board => $composableBuilder(
    column: $table.board,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passingYear => $composableBuilder(
    column: $table.passingYear,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableOrderingComposer get importBatchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchoolResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolResultsTable> {
  $$SchoolResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get board =>
      $composableBuilder(column: $table.board, builder: (column) => column);

  GeneratedColumn<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passingYear => $composableBuilder(
    column: $table.passingYear,
    builder: (column) => column,
  );

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableAnnotationComposer get importBatchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchoolResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchoolResultsTable,
          SchoolResult,
          $$SchoolResultsTableFilterComposer,
          $$SchoolResultsTableOrderingComposer,
          $$SchoolResultsTableAnnotationComposer,
          $$SchoolResultsTableCreateCompanionBuilder,
          $$SchoolResultsTableUpdateCompanionBuilder,
          (SchoolResult, $$SchoolResultsTableReferences),
          SchoolResult,
          PrefetchHooks Function({bool studentId, bool importBatchId})
        > {
  $$SchoolResultsTableTableManager(_$AppDatabase db, $SchoolResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchoolResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchoolResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String?> board = const Value.absent(),
                Value<double> percentage = const Value.absent(),
                Value<int?> passingYear = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolResultsCompanion(
                id: id,
                studentId: studentId,
                level: level,
                board: board,
                percentage: percentage,
                passingYear: passingYear,
                importBatchId: importBatchId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String level,
                Value<String?> board = const Value.absent(),
                required double percentage,
                Value<int?> passingYear = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolResultsCompanion.insert(
                id: id,
                studentId: studentId,
                level: level,
                board: board,
                percentage: percentage,
                passingYear: passingYear,
                importBatchId: importBatchId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchoolResultsTable, SchoolResult>(table),
                  $$SchoolResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false, importBatchId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$SchoolResultsTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$SchoolResultsTableReferences
                                    ._studentIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (importBatchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.importBatchId,
                                referencedTable: $$SchoolResultsTableReferences
                                    ._importBatchIdTable(db),
                                referencedColumn: $$SchoolResultsTableReferences
                                    ._importBatchIdTable(db)
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

typedef $$SchoolResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchoolResultsTable,
      SchoolResult,
      $$SchoolResultsTableFilterComposer,
      $$SchoolResultsTableOrderingComposer,
      $$SchoolResultsTableAnnotationComposer,
      $$SchoolResultsTableCreateCompanionBuilder,
      $$SchoolResultsTableUpdateCompanionBuilder,
      (SchoolResult, $$SchoolResultsTableReferences),
      SchoolResult,
      PrefetchHooks Function({bool studentId, bool importBatchId})
    >;
typedef $$SemesterResultsTableCreateCompanionBuilder =
    SemesterResultsCompanion Function({
      required String id,
      required String studentId,
      required int semesterNumber,
      Value<String?> academicYear,
      Value<double?> sgpa,
      Value<double?> percentage,
      Value<double?> cgpa,
      Value<int> backlogs,
      Value<String?> importBatchId,
      Value<int> rowid,
    });
typedef $$SemesterResultsTableUpdateCompanionBuilder =
    SemesterResultsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<int> semesterNumber,
      Value<String?> academicYear,
      Value<double?> sgpa,
      Value<double?> percentage,
      Value<double?> cgpa,
      Value<int> backlogs,
      Value<String?> importBatchId,
      Value<int> rowid,
    });

final class $$SemesterResultsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SemesterResultsTable, SemesterResult> {
  $$SemesterResultsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('semester_results__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportBatchesTable _importBatchIdTable(_$AppDatabase db) => db
      .importBatches
      .createAlias('semester_results__import_batch_id__import_batches__id');

  $$ImportBatchesTableProcessedTableManager? get importBatchId {
    final $_column = $_itemColumn<String>('import_batch_id');
    if ($_column == null) return null;
    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importBatchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SemesterResultsTableFilterComposer
    extends Composer<_$AppDatabase, $SemesterResultsTable> {
  $$SemesterResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgpa => $composableBuilder(
    column: $table.sgpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cgpa => $composableBuilder(
    column: $table.cgpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backlogs => $composableBuilder(
    column: $table.backlogs,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableFilterComposer get importBatchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SemesterResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $SemesterResultsTable> {
  $$SemesterResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgpa => $composableBuilder(
    column: $table.sgpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cgpa => $composableBuilder(
    column: $table.cgpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backlogs => $composableBuilder(
    column: $table.backlogs,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableOrderingComposer get importBatchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SemesterResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SemesterResultsTable> {
  $$SemesterResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sgpa =>
      $composableBuilder(column: $table.sgpa, builder: (column) => column);

  GeneratedColumn<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cgpa =>
      $composableBuilder(column: $table.cgpa, builder: (column) => column);

  GeneratedColumn<int> get backlogs =>
      $composableBuilder(column: $table.backlogs, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableAnnotationComposer get importBatchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SemesterResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SemesterResultsTable,
          SemesterResult,
          $$SemesterResultsTableFilterComposer,
          $$SemesterResultsTableOrderingComposer,
          $$SemesterResultsTableAnnotationComposer,
          $$SemesterResultsTableCreateCompanionBuilder,
          $$SemesterResultsTableUpdateCompanionBuilder,
          (SemesterResult, $$SemesterResultsTableReferences),
          SemesterResult,
          PrefetchHooks Function({bool studentId, bool importBatchId})
        > {
  $$SemesterResultsTableTableManager(
    _$AppDatabase db,
    $SemesterResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SemesterResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SemesterResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SemesterResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int> semesterNumber = const Value.absent(),
                Value<String?> academicYear = const Value.absent(),
                Value<double?> sgpa = const Value.absent(),
                Value<double?> percentage = const Value.absent(),
                Value<double?> cgpa = const Value.absent(),
                Value<int> backlogs = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SemesterResultsCompanion(
                id: id,
                studentId: studentId,
                semesterNumber: semesterNumber,
                academicYear: academicYear,
                sgpa: sgpa,
                percentage: percentage,
                cgpa: cgpa,
                backlogs: backlogs,
                importBatchId: importBatchId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required int semesterNumber,
                Value<String?> academicYear = const Value.absent(),
                Value<double?> sgpa = const Value.absent(),
                Value<double?> percentage = const Value.absent(),
                Value<double?> cgpa = const Value.absent(),
                Value<int> backlogs = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SemesterResultsCompanion.insert(
                id: id,
                studentId: studentId,
                semesterNumber: semesterNumber,
                academicYear: academicYear,
                sgpa: sgpa,
                percentage: percentage,
                cgpa: cgpa,
                backlogs: backlogs,
                importBatchId: importBatchId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SemesterResultsTable, SemesterResult>(table),
                  $$SemesterResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false, importBatchId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable:
                                    $$SemesterResultsTableReferences
                                        ._studentIdTable(db),
                                referencedColumn:
                                    $$SemesterResultsTableReferences
                                        ._studentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (importBatchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.importBatchId,
                                referencedTable:
                                    $$SemesterResultsTableReferences
                                        ._importBatchIdTable(db),
                                referencedColumn:
                                    $$SemesterResultsTableReferences
                                        ._importBatchIdTable(db)
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

typedef $$SemesterResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SemesterResultsTable,
      SemesterResult,
      $$SemesterResultsTableFilterComposer,
      $$SemesterResultsTableOrderingComposer,
      $$SemesterResultsTableAnnotationComposer,
      $$SemesterResultsTableCreateCompanionBuilder,
      $$SemesterResultsTableUpdateCompanionBuilder,
      (SemesterResult, $$SemesterResultsTableReferences),
      SemesterResult,
      PrefetchHooks Function({bool studentId, bool importBatchId})
    >;
typedef $$SubjectResultsTableCreateCompanionBuilder =
    SubjectResultsCompanion Function({
      required String id,
      required String studentId,
      required int semesterNumber,
      Value<String?> subjectId,
      required String subjectName,
      Value<double?> internalMarks,
      Value<double?> practicalMarks,
      Value<double?> externalMarks,
      Value<double?> totalMarks,
      Value<double?> maxMarks,
      Value<String?> grade,
      Value<bool?> passed,
      Value<int> attempt,
      Value<String?> importBatchId,
      Value<int> rowid,
    });
typedef $$SubjectResultsTableUpdateCompanionBuilder =
    SubjectResultsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<int> semesterNumber,
      Value<String?> subjectId,
      Value<String> subjectName,
      Value<double?> internalMarks,
      Value<double?> practicalMarks,
      Value<double?> externalMarks,
      Value<double?> totalMarks,
      Value<double?> maxMarks,
      Value<String?> grade,
      Value<bool?> passed,
      Value<int> attempt,
      Value<String?> importBatchId,
      Value<int> rowid,
    });

final class $$SubjectResultsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectResultsTable, SubjectResult> {
  $$SubjectResultsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('subject_results__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportBatchesTable _importBatchIdTable(_$AppDatabase db) => db
      .importBatches
      .createAlias('subject_results__import_batch_id__import_batches__id');

  $$ImportBatchesTableProcessedTableManager? get importBatchId {
    final $_column = $_itemColumn<String>('import_batch_id');
    if ($_column == null) return null;
    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importBatchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubjectResultsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectResultsTable> {
  $$SubjectResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get internalMarks => $composableBuilder(
    column: $table.internalMarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get practicalMarks => $composableBuilder(
    column: $table.practicalMarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get externalMarks => $composableBuilder(
    column: $table.externalMarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalMarks => $composableBuilder(
    column: $table.totalMarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxMarks => $composableBuilder(
    column: $table.maxMarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableFilterComposer get importBatchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubjectResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectResultsTable> {
  $$SubjectResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get internalMarks => $composableBuilder(
    column: $table.internalMarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get practicalMarks => $composableBuilder(
    column: $table.practicalMarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get externalMarks => $composableBuilder(
    column: $table.externalMarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalMarks => $composableBuilder(
    column: $table.totalMarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxMarks => $composableBuilder(
    column: $table.maxMarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableOrderingComposer get importBatchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubjectResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectResultsTable> {
  $$SubjectResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get internalMarks => $composableBuilder(
    column: $table.internalMarks,
    builder: (column) => column,
  );

  GeneratedColumn<double> get practicalMarks => $composableBuilder(
    column: $table.practicalMarks,
    builder: (column) => column,
  );

  GeneratedColumn<double> get externalMarks => $composableBuilder(
    column: $table.externalMarks,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalMarks => $composableBuilder(
    column: $table.totalMarks,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxMarks =>
      $composableBuilder(column: $table.maxMarks, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<bool> get passed =>
      $composableBuilder(column: $table.passed, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableAnnotationComposer get importBatchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubjectResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectResultsTable,
          SubjectResult,
          $$SubjectResultsTableFilterComposer,
          $$SubjectResultsTableOrderingComposer,
          $$SubjectResultsTableAnnotationComposer,
          $$SubjectResultsTableCreateCompanionBuilder,
          $$SubjectResultsTableUpdateCompanionBuilder,
          (SubjectResult, $$SubjectResultsTableReferences),
          SubjectResult,
          PrefetchHooks Function({bool studentId, bool importBatchId})
        > {
  $$SubjectResultsTableTableManager(
    _$AppDatabase db,
    $SubjectResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int> semesterNumber = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String> subjectName = const Value.absent(),
                Value<double?> internalMarks = const Value.absent(),
                Value<double?> practicalMarks = const Value.absent(),
                Value<double?> externalMarks = const Value.absent(),
                Value<double?> totalMarks = const Value.absent(),
                Value<double?> maxMarks = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                Value<bool?> passed = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectResultsCompanion(
                id: id,
                studentId: studentId,
                semesterNumber: semesterNumber,
                subjectId: subjectId,
                subjectName: subjectName,
                internalMarks: internalMarks,
                practicalMarks: practicalMarks,
                externalMarks: externalMarks,
                totalMarks: totalMarks,
                maxMarks: maxMarks,
                grade: grade,
                passed: passed,
                attempt: attempt,
                importBatchId: importBatchId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required int semesterNumber,
                Value<String?> subjectId = const Value.absent(),
                required String subjectName,
                Value<double?> internalMarks = const Value.absent(),
                Value<double?> practicalMarks = const Value.absent(),
                Value<double?> externalMarks = const Value.absent(),
                Value<double?> totalMarks = const Value.absent(),
                Value<double?> maxMarks = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                Value<bool?> passed = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectResultsCompanion.insert(
                id: id,
                studentId: studentId,
                semesterNumber: semesterNumber,
                subjectId: subjectId,
                subjectName: subjectName,
                internalMarks: internalMarks,
                practicalMarks: practicalMarks,
                externalMarks: externalMarks,
                totalMarks: totalMarks,
                maxMarks: maxMarks,
                grade: grade,
                passed: passed,
                attempt: attempt,
                importBatchId: importBatchId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubjectResultsTable, SubjectResult>(table),
                  $$SubjectResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false, importBatchId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$SubjectResultsTableReferences
                                    ._studentIdTable(db),
                                referencedColumn:
                                    $$SubjectResultsTableReferences
                                        ._studentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (importBatchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.importBatchId,
                                referencedTable: $$SubjectResultsTableReferences
                                    ._importBatchIdTable(db),
                                referencedColumn:
                                    $$SubjectResultsTableReferences
                                        ._importBatchIdTable(db)
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

typedef $$SubjectResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectResultsTable,
      SubjectResult,
      $$SubjectResultsTableFilterComposer,
      $$SubjectResultsTableOrderingComposer,
      $$SubjectResultsTableAnnotationComposer,
      $$SubjectResultsTableCreateCompanionBuilder,
      $$SubjectResultsTableUpdateCompanionBuilder,
      (SubjectResult, $$SubjectResultsTableReferences),
      SubjectResult,
      PrefetchHooks Function({bool studentId, bool importBatchId})
    >;
typedef $$AttendanceSummariesTableCreateCompanionBuilder =
    AttendanceSummariesCompanion Function({
      required String id,
      required String studentId,
      required int semesterNumber,
      Value<String?> subjectId,
      required String subjectName,
      Value<int?> classesHeld,
      Value<int?> classesAttended,
      required double percentage,
      Value<String?> importBatchId,
      Value<int> rowid,
    });
typedef $$AttendanceSummariesTableUpdateCompanionBuilder =
    AttendanceSummariesCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<int> semesterNumber,
      Value<String?> subjectId,
      Value<String> subjectName,
      Value<int?> classesHeld,
      Value<int?> classesAttended,
      Value<double> percentage,
      Value<String?> importBatchId,
      Value<int> rowid,
    });

final class $$AttendanceSummariesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttendanceSummariesTable,
          AttendanceSummary
        > {
  $$AttendanceSummariesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('attendance_summaries__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportBatchesTable _importBatchIdTable(_$AppDatabase db) => db
      .importBatches
      .createAlias('attendance_summaries__import_batch_id__import_batches__id');

  $$ImportBatchesTableProcessedTableManager? get importBatchId {
    final $_column = $_itemColumn<String>('import_batch_id');
    if ($_column == null) return null;
    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importBatchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceSummariesTable> {
  $$AttendanceSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get classesHeld => $composableBuilder(
    column: $table.classesHeld,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get classesAttended => $composableBuilder(
    column: $table.classesAttended,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableFilterComposer get importBatchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceSummariesTable> {
  $$AttendanceSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get classesHeld => $composableBuilder(
    column: $table.classesHeld,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get classesAttended => $composableBuilder(
    column: $table.classesAttended,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableOrderingComposer get importBatchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceSummariesTable> {
  $$AttendanceSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get classesHeld => $composableBuilder(
    column: $table.classesHeld,
    builder: (column) => column,
  );

  GeneratedColumn<int> get classesAttended => $composableBuilder(
    column: $table.classesAttended,
    builder: (column) => column,
  );

  GeneratedColumn<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => column,
  );

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableAnnotationComposer get importBatchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceSummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceSummariesTable,
          AttendanceSummary,
          $$AttendanceSummariesTableFilterComposer,
          $$AttendanceSummariesTableOrderingComposer,
          $$AttendanceSummariesTableAnnotationComposer,
          $$AttendanceSummariesTableCreateCompanionBuilder,
          $$AttendanceSummariesTableUpdateCompanionBuilder,
          (AttendanceSummary, $$AttendanceSummariesTableReferences),
          AttendanceSummary,
          PrefetchHooks Function({bool studentId, bool importBatchId})
        > {
  $$AttendanceSummariesTableTableManager(
    _$AppDatabase db,
    $AttendanceSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceSummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceSummariesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AttendanceSummariesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int> semesterNumber = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String> subjectName = const Value.absent(),
                Value<int?> classesHeld = const Value.absent(),
                Value<int?> classesAttended = const Value.absent(),
                Value<double> percentage = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceSummariesCompanion(
                id: id,
                studentId: studentId,
                semesterNumber: semesterNumber,
                subjectId: subjectId,
                subjectName: subjectName,
                classesHeld: classesHeld,
                classesAttended: classesAttended,
                percentage: percentage,
                importBatchId: importBatchId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required int semesterNumber,
                Value<String?> subjectId = const Value.absent(),
                required String subjectName,
                Value<int?> classesHeld = const Value.absent(),
                Value<int?> classesAttended = const Value.absent(),
                required double percentage,
                Value<String?> importBatchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceSummariesCompanion.insert(
                id: id,
                studentId: studentId,
                semesterNumber: semesterNumber,
                subjectId: subjectId,
                subjectName: subjectName,
                classesHeld: classesHeld,
                classesAttended: classesAttended,
                percentage: percentage,
                importBatchId: importBatchId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceSummariesTable, AttendanceSummary>(
                    table,
                  ),
                  $$AttendanceSummariesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false, importBatchId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable:
                                    $$AttendanceSummariesTableReferences
                                        ._studentIdTable(db),
                                referencedColumn:
                                    $$AttendanceSummariesTableReferences
                                        ._studentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (importBatchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.importBatchId,
                                referencedTable:
                                    $$AttendanceSummariesTableReferences
                                        ._importBatchIdTable(db),
                                referencedColumn:
                                    $$AttendanceSummariesTableReferences
                                        ._importBatchIdTable(db)
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

typedef $$AttendanceSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceSummariesTable,
      AttendanceSummary,
      $$AttendanceSummariesTableFilterComposer,
      $$AttendanceSummariesTableOrderingComposer,
      $$AttendanceSummariesTableAnnotationComposer,
      $$AttendanceSummariesTableCreateCompanionBuilder,
      $$AttendanceSummariesTableUpdateCompanionBuilder,
      (AttendanceSummary, $$AttendanceSummariesTableReferences),
      AttendanceSummary,
      PrefetchHooks Function({bool studentId, bool importBatchId})
    >;
typedef $$AssessmentsTableCreateCompanionBuilder =
    AssessmentsCompanion Function({
      required String id,
      required String studentId,
      required int semesterNumber,
      Value<String?> subjectId,
      required String subjectName,
      required String assessmentType,
      Value<String?> title,
      required double score,
      required double maxScore,
      Value<DateTime?> assessedOn,
      Value<String?> importBatchId,
      Value<int> rowid,
    });
typedef $$AssessmentsTableUpdateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<int> semesterNumber,
      Value<String?> subjectId,
      Value<String> subjectName,
      Value<String> assessmentType,
      Value<String?> title,
      Value<double> score,
      Value<double> maxScore,
      Value<DateTime?> assessedOn,
      Value<String?> importBatchId,
      Value<int> rowid,
    });

final class $$AssessmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AssessmentsTable, Assessment> {
  $$AssessmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('assessments__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportBatchesTable _importBatchIdTable(_$AppDatabase db) => db
      .importBatches
      .createAlias('assessments__import_batch_id__import_batches__id');

  $$ImportBatchesTableProcessedTableManager? get importBatchId {
    final $_column = $_itemColumn<String>('import_batch_id');
    if ($_column == null) return null;
    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importBatchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessmentType => $composableBuilder(
    column: $table.assessmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxScore => $composableBuilder(
    column: $table.maxScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assessedOn => $composableBuilder(
    column: $table.assessedOn,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableFilterComposer get importBatchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessmentType => $composableBuilder(
    column: $table.assessmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxScore => $composableBuilder(
    column: $table.maxScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assessedOn => $composableBuilder(
    column: $table.assessedOn,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableOrderingComposer get importBatchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get semesterNumber => $composableBuilder(
    column: $table.semesterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assessmentType => $composableBuilder(
    column: $table.assessmentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<double> get maxScore =>
      $composableBuilder(column: $table.maxScore, builder: (column) => column);

  GeneratedColumn<DateTime> get assessedOn => $composableBuilder(
    column: $table.assessedOn,
    builder: (column) => column,
  );

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableAnnotationComposer get importBatchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importBatchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssessmentsTable,
          Assessment,
          $$AssessmentsTableFilterComposer,
          $$AssessmentsTableOrderingComposer,
          $$AssessmentsTableAnnotationComposer,
          $$AssessmentsTableCreateCompanionBuilder,
          $$AssessmentsTableUpdateCompanionBuilder,
          (Assessment, $$AssessmentsTableReferences),
          Assessment,
          PrefetchHooks Function({bool studentId, bool importBatchId})
        > {
  $$AssessmentsTableTableManager(_$AppDatabase db, $AssessmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssessmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssessmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssessmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int> semesterNumber = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String> subjectName = const Value.absent(),
                Value<String> assessmentType = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<double> maxScore = const Value.absent(),
                Value<DateTime?> assessedOn = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessmentsCompanion(
                id: id,
                studentId: studentId,
                semesterNumber: semesterNumber,
                subjectId: subjectId,
                subjectName: subjectName,
                assessmentType: assessmentType,
                title: title,
                score: score,
                maxScore: maxScore,
                assessedOn: assessedOn,
                importBatchId: importBatchId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required int semesterNumber,
                Value<String?> subjectId = const Value.absent(),
                required String subjectName,
                required String assessmentType,
                Value<String?> title = const Value.absent(),
                required double score,
                required double maxScore,
                Value<DateTime?> assessedOn = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessmentsCompanion.insert(
                id: id,
                studentId: studentId,
                semesterNumber: semesterNumber,
                subjectId: subjectId,
                subjectName: subjectName,
                assessmentType: assessmentType,
                title: title,
                score: score,
                maxScore: maxScore,
                assessedOn: assessedOn,
                importBatchId: importBatchId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssessmentsTable, Assessment>(table),
                  $$AssessmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false, importBatchId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$AssessmentsTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$AssessmentsTableReferences
                                    ._studentIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (importBatchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.importBatchId,
                                referencedTable: $$AssessmentsTableReferences
                                    ._importBatchIdTable(db),
                                referencedColumn: $$AssessmentsTableReferences
                                    ._importBatchIdTable(db)
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

typedef $$AssessmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssessmentsTable,
      Assessment,
      $$AssessmentsTableFilterComposer,
      $$AssessmentsTableOrderingComposer,
      $$AssessmentsTableAnnotationComposer,
      $$AssessmentsTableCreateCompanionBuilder,
      $$AssessmentsTableUpdateCompanionBuilder,
      (Assessment, $$AssessmentsTableReferences),
      Assessment,
      PrefetchHooks Function({bool studentId, bool importBatchId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db, _db.branches);
  $$SemestersTableTableManager get semesters =>
      $$SemestersTableTableManager(_db, _db.semesters);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db, _db.sections);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$FacultyMembersTableTableManager get facultyMembers =>
      $$FacultyMembersTableTableManager(_db, _db.facultyMembers);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$SubjectMappingsTableTableManager get subjectMappings =>
      $$SubjectMappingsTableTableManager(_db, _db.subjectMappings);
  $$FacultyAssignmentsTableTableManager get facultyAssignments =>
      $$FacultyAssignmentsTableTableManager(_db, _db.facultyAssignments);
  $$AttendanceSessionsTableTableManager get attendanceSessions =>
      $$AttendanceSessionsTableTableManager(_db, _db.attendanceSessions);
  $$AttendanceRecordsTableTableManager get attendanceRecords =>
      $$AttendanceRecordsTableTableManager(_db, _db.attendanceRecords);
  $$StudentEnrollmentsTableTableManager get studentEnrollments =>
      $$StudentEnrollmentsTableTableManager(_db, _db.studentEnrollments);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db, _db.importBatches);
  $$SchoolResultsTableTableManager get schoolResults =>
      $$SchoolResultsTableTableManager(_db, _db.schoolResults);
  $$SemesterResultsTableTableManager get semesterResults =>
      $$SemesterResultsTableTableManager(_db, _db.semesterResults);
  $$SubjectResultsTableTableManager get subjectResults =>
      $$SubjectResultsTableTableManager(_db, _db.subjectResults);
  $$AttendanceSummariesTableTableManager get attendanceSummaries =>
      $$AttendanceSummariesTableTableManager(_db, _db.attendanceSummaries);
  $$AssessmentsTableTableManager get assessments =>
      $$AssessmentsTableTableManager(_db, _db.assessments);
}
