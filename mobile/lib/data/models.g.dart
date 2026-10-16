// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetChildEntityCollection on Isar {
  IsarCollection<ChildEntity> get childEntitys => this.collection();
}

const ChildEntitySchema = CollectionSchema(
  name: r'ChildEntity',
  id: 5117725166865141993,
  properties: {
    r'allergies': PropertySchema(id: 0, name: r'allergies', type: IsarType.string),
    r'className': PropertySchema(id: 1, name: r'className', type: IsarType.string),
    r'dateOfBirth': PropertySchema(id: 2, name: r'dateOfBirth', type: IsarType.string),
    r'fullName': PropertySchema(id: 3, name: r'fullName', type: IsarType.string),
    r'gender': PropertySchema(id: 4, name: r'gender', type: IsarType.string),
    r'id': PropertySchema(id: 5, name: r'id', type: IsarType.string),
    r'medicalNotes': PropertySchema(id: 6, name: r'medicalNotes', type: IsarType.string),
    r'nickname': PropertySchema(id: 7, name: r'nickname', type: IsarType.string),
  },

  estimateSize: _childEntityEstimateSize,
  serialize: _childEntitySerialize,
  deserialize: _childEntityDeserialize,
  deserializeProp: _childEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [IndexPropertySchema(name: r'id', type: IndexType.hash, caseSensitive: true)],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _childEntityGetId,
  getLinks: _childEntityGetLinks,
  attach: _childEntityAttach,
  version: '3.4.1',
);

int _childEntityEstimateSize(ChildEntity object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  {
    final value = object.allergies;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.className.length * 3;
  bytesCount += 3 + object.dateOfBirth.length * 3;
  bytesCount += 3 + object.fullName.length * 3;
  {
    final value = object.gender;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.medicalNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.nickname;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _childEntitySerialize(ChildEntity object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {
  writer.writeString(offsets[0], object.allergies);
  writer.writeString(offsets[1], object.className);
  writer.writeString(offsets[2], object.dateOfBirth);
  writer.writeString(offsets[3], object.fullName);
  writer.writeString(offsets[4], object.gender);
  writer.writeString(offsets[5], object.id);
  writer.writeString(offsets[6], object.medicalNotes);
  writer.writeString(offsets[7], object.nickname);
}

ChildEntity _childEntityDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = ChildEntity();
  object.allergies = reader.readStringOrNull(offsets[0]);
  object.className = reader.readString(offsets[1]);
  object.dateOfBirth = reader.readString(offsets[2]);
  object.fullName = reader.readString(offsets[3]);
  object.gender = reader.readStringOrNull(offsets[4]);
  object.id = reader.readString(offsets[5]);
  object.isarId = id;
  object.medicalNotes = reader.readStringOrNull(offsets[6]);
  object.nickname = reader.readStringOrNull(offsets[7]);
  return object;
}

P _childEntityDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _childEntityGetId(ChildEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _childEntityGetLinks(ChildEntity object) {
  return [];
}

void _childEntityAttach(IsarCollection<dynamic> col, Id id, ChildEntity object) {
  object.isarId = id;
}

extension ChildEntityByIndex on IsarCollection<ChildEntity> {
  Future<ChildEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  ChildEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<ChildEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<ChildEntity?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(ChildEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(ChildEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<ChildEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<ChildEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension ChildEntityQueryWhereSort on QueryBuilder<ChildEntity, ChildEntity, QWhere> {
  QueryBuilder<ChildEntity, ChildEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChildEntityQueryWhere on QueryBuilder<ChildEntity, ChildEntity, QWhereClause> {
  QueryBuilder<ChildEntity, ChildEntity, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: isarId, upper: isarId));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IdWhereClause.lessThan(upper: isarId, includeUpper: false))
            .addWhereClause(IdWhereClause.greaterThan(lower: isarId, includeLower: false));
      } else {
        return query
            .addWhereClause(IdWhereClause.greaterThan(lower: isarId, includeLower: false))
            .addWhereClause(IdWhereClause.lessThan(upper: isarId, includeUpper: false));
      }
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(lower: isarId, includeLower: include));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(upper: isarId, includeUpper: include));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'id', value: [id]));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterWhereClause> idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(indexName: r'id', lower: [], upper: [id], includeUpper: false))
            .addWhereClause(IndexWhereClause.between(indexName: r'id', lower: [id], includeLower: false, upper: []));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(indexName: r'id', lower: [id], includeLower: false, upper: []))
            .addWhereClause(IndexWhereClause.between(indexName: r'id', lower: [], upper: [id], includeUpper: false));
      }
    });
  }
}

extension ChildEntityQueryFilter on QueryBuilder<ChildEntity, ChildEntity, QFilterCondition> {
  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'allergies'));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'allergies'));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'allergies', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'allergies',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'allergies', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'allergies',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'allergies', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'allergies', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'allergies', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'allergies', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'allergies', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> allergiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'allergies', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> classNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'className', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> classNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'className',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> classNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'className', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> classNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'className',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> classNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'className', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> classNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'className', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> classNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'className', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> classNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'className', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> classNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'className', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> classNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'className', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> dateOfBirthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dateOfBirth', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> dateOfBirthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dateOfBirth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> dateOfBirthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dateOfBirth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> dateOfBirthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dateOfBirth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> dateOfBirthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'dateOfBirth', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> dateOfBirthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'dateOfBirth', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> dateOfBirthContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'dateOfBirth', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> dateOfBirthMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'dateOfBirth', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> dateOfBirthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'dateOfBirth', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> dateOfBirthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'dateOfBirth', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fullName', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'fullName', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fullName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'fullName', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'fullName', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> fullNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'fullName', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> fullNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'fullName', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'fullName', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'fullName', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'gender'));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'gender'));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'gender', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'gender', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'gender', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'gender',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'gender', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'gender', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'gender', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'gender', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'gender', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'gender', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> idEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> idEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'id', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'id', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'id', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'isarId', value: value));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> isarIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'isarId', value: value));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> isarIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'isarId', value: value));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'medicalNotes'));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'medicalNotes'));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'medicalNotes', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'medicalNotes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'medicalNotes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'medicalNotes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'medicalNotes', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'medicalNotes', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'medicalNotes', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'medicalNotes', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'medicalNotes', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> medicalNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'medicalNotes', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'nickname'));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'nickname'));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nickname', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nickname',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'nickname', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nickname',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'nickname', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'nickname', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'nickname', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'nickname', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'nickname', value: ''));
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterFilterCondition> nicknameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'nickname', value: ''));
    });
  }
}

extension ChildEntityQueryObject on QueryBuilder<ChildEntity, ChildEntity, QFilterCondition> {}

extension ChildEntityQueryLinks on QueryBuilder<ChildEntity, ChildEntity, QFilterCondition> {}

extension ChildEntityQuerySortBy on QueryBuilder<ChildEntity, ChildEntity, QSortBy> {
  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByAllergies() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allergies', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByAllergiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allergies', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByMedicalNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalNotes', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByMedicalNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalNotes', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> sortByNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.desc);
    });
  }
}

extension ChildEntityQuerySortThenBy on QueryBuilder<ChildEntity, ChildEntity, QSortThenBy> {
  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByAllergies() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allergies', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByAllergiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allergies', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByMedicalNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalNotes', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByMedicalNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalNotes', Sort.desc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.asc);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QAfterSortBy> thenByNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.desc);
    });
  }
}

extension ChildEntityQueryWhereDistinct on QueryBuilder<ChildEntity, ChildEntity, QDistinct> {
  QueryBuilder<ChildEntity, ChildEntity, QDistinct> distinctByAllergies({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allergies', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QDistinct> distinctByClassName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'className', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QDistinct> distinctByDateOfBirth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateOfBirth', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QDistinct> distinctByFullName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QDistinct> distinctByGender({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QDistinct> distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QDistinct> distinctByMedicalNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'medicalNotes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChildEntity, ChildEntity, QDistinct> distinctByNickname({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nickname', caseSensitive: caseSensitive);
    });
  }
}

extension ChildEntityQueryProperty on QueryBuilder<ChildEntity, ChildEntity, QQueryProperty> {
  QueryBuilder<ChildEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ChildEntity, String?, QQueryOperations> allergiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allergies');
    });
  }

  QueryBuilder<ChildEntity, String, QQueryOperations> classNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'className');
    });
  }

  QueryBuilder<ChildEntity, String, QQueryOperations> dateOfBirthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateOfBirth');
    });
  }

  QueryBuilder<ChildEntity, String, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<ChildEntity, String?, QQueryOperations> genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<ChildEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChildEntity, String?, QQueryOperations> medicalNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicalNotes');
    });
  }

  QueryBuilder<ChildEntity, String?, QQueryOperations> nicknameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nickname');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetAttendanceEntityCollection on Isar {
  IsarCollection<AttendanceEntity> get attendanceEntitys => this.collection();
}

const AttendanceEntitySchema = CollectionSchema(
  name: r'AttendanceEntity',
  id: 5479936569571385882,
  properties: {
    r'checkInAt': PropertySchema(id: 0, name: r'checkInAt', type: IsarType.dateTime),
    r'checkOutAt': PropertySchema(id: 1, name: r'checkOutAt', type: IsarType.dateTime),
    r'childId': PropertySchema(id: 2, name: r'childId', type: IsarType.string),
    r'date': PropertySchema(id: 3, name: r'date', type: IsarType.string),
    r'key': PropertySchema(id: 4, name: r'key', type: IsarType.string),
    r'pending': PropertySchema(id: 5, name: r'pending', type: IsarType.bool),
    r'pickedUpBy': PropertySchema(id: 6, name: r'pickedUpBy', type: IsarType.string),
    r'serverId': PropertySchema(id: 7, name: r'serverId', type: IsarType.string),
  },

  estimateSize: _attendanceEntityEstimateSize,
  serialize: _attendanceEntitySerialize,
  deserialize: _attendanceEntityDeserialize,
  deserializeProp: _attendanceEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [IndexPropertySchema(name: r'key', type: IndexType.hash, caseSensitive: true)],
    ),
    r'childId': IndexSchema(
      id: -5533418659857701897,
      name: r'childId',
      unique: false,
      replace: false,
      properties: [IndexPropertySchema(name: r'childId', type: IndexType.hash, caseSensitive: true)],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _attendanceEntityGetId,
  getLinks: _attendanceEntityGetLinks,
  attach: _attendanceEntityAttach,
  version: '3.4.1',
);

int _attendanceEntityEstimateSize(AttendanceEntity object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.childId.length * 3;
  bytesCount += 3 + object.date.length * 3;
  bytesCount += 3 + object.key.length * 3;
  {
    final value = object.pickedUpBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.serverId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _attendanceEntitySerialize(
  AttendanceEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.checkInAt);
  writer.writeDateTime(offsets[1], object.checkOutAt);
  writer.writeString(offsets[2], object.childId);
  writer.writeString(offsets[3], object.date);
  writer.writeString(offsets[4], object.key);
  writer.writeBool(offsets[5], object.pending);
  writer.writeString(offsets[6], object.pickedUpBy);
  writer.writeString(offsets[7], object.serverId);
}

AttendanceEntity _attendanceEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AttendanceEntity();
  object.checkInAt = reader.readDateTime(offsets[0]);
  object.checkOutAt = reader.readDateTimeOrNull(offsets[1]);
  object.childId = reader.readString(offsets[2]);
  object.date = reader.readString(offsets[3]);
  object.isarId = id;
  object.key = reader.readString(offsets[4]);
  object.pending = reader.readBool(offsets[5]);
  object.pickedUpBy = reader.readStringOrNull(offsets[6]);
  object.serverId = reader.readStringOrNull(offsets[7]);
  return object;
}

P _attendanceEntityDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _attendanceEntityGetId(AttendanceEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _attendanceEntityGetLinks(AttendanceEntity object) {
  return [];
}

void _attendanceEntityAttach(IsarCollection<dynamic> col, Id id, AttendanceEntity object) {
  object.isarId = id;
}

extension AttendanceEntityByIndex on IsarCollection<AttendanceEntity> {
  Future<AttendanceEntity?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  AttendanceEntity? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<AttendanceEntity?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<AttendanceEntity?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(AttendanceEntity object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(AttendanceEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<AttendanceEntity> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<AttendanceEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension AttendanceEntityQueryWhereSort on QueryBuilder<AttendanceEntity, AttendanceEntity, QWhere> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AttendanceEntityQueryWhere on QueryBuilder<AttendanceEntity, AttendanceEntity, QWhereClause> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: isarId, upper: isarId));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IdWhereClause.lessThan(upper: isarId, includeUpper: false))
            .addWhereClause(IdWhereClause.greaterThan(lower: isarId, includeLower: false));
      } else {
        return query
            .addWhereClause(IdWhereClause.greaterThan(lower: isarId, includeLower: false))
            .addWhereClause(IdWhereClause.lessThan(upper: isarId, includeUpper: false));
      }
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause> isarIdGreaterThan(
    Id isarId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(lower: isarId, includeLower: include));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause> isarIdLessThan(
    Id isarId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(upper: isarId, includeUpper: include));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause> keyEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'key', value: [key]));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause> keyNotEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(indexName: r'key', lower: [], upper: [key], includeUpper: false))
            .addWhereClause(IndexWhereClause.between(indexName: r'key', lower: [key], includeLower: false, upper: []));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(indexName: r'key', lower: [key], includeLower: false, upper: []))
            .addWhereClause(IndexWhereClause.between(indexName: r'key', lower: [], upper: [key], includeUpper: false));
      }
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause> childIdEqualTo(String childId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'childId', value: [childId]));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause> childIdNotEqualTo(String childId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'childId', lower: [], upper: [childId], includeUpper: false),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'childId', lower: [childId], includeLower: false, upper: []),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'childId', lower: [childId], includeLower: false, upper: []),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'childId', lower: [], upper: [childId], includeUpper: false),
            );
      }
    });
  }
}

extension AttendanceEntityQueryFilter on QueryBuilder<AttendanceEntity, AttendanceEntity, QFilterCondition> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> checkInAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'checkInAt', value: value));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> checkInAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'checkInAt', value: value),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> checkInAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'checkInAt', value: value));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> checkInAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'checkInAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> checkOutAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'checkOutAt'));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> checkOutAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'checkOutAt'));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> checkOutAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'checkOutAt', value: value));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> checkOutAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'checkOutAt', value: value),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> checkOutAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'checkOutAt', value: value),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> checkOutAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'checkOutAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> childIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> childIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> childIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> childIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'childId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> childIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> childIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> childIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> childIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'childId', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> childIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'childId', value: ''));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> childIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'childId', value: ''));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> dateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'date', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'date', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> dateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'date', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> dateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'date', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> dateContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'date', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> dateMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'date', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'date', value: ''));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'date', value: ''));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'isarId', value: value));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'isarId', value: value));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'isarId', value: value));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> keyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'key', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> keyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'key', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'key', value: ''));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'key', value: ''));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'pending', value: value));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'pickedUpBy'));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'pickedUpBy'));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pickedUpBy', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pickedUpBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'pickedUpBy', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pickedUpBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'pickedUpBy', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'pickedUpBy', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'pickedUpBy', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'pickedUpBy', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'pickedUpBy', value: ''));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> pickedUpByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'pickedUpBy', value: ''));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'serverId'));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'serverId'));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serverId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'serverId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'serverId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'serverId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'serverId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'serverId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'serverId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'serverId', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'serverId', value: ''));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'serverId', value: ''));
    });
  }
}

extension AttendanceEntityQueryObject on QueryBuilder<AttendanceEntity, AttendanceEntity, QFilterCondition> {}

extension AttendanceEntityQueryLinks on QueryBuilder<AttendanceEntity, AttendanceEntity, QFilterCondition> {}

extension AttendanceEntityQuerySortBy on QueryBuilder<AttendanceEntity, AttendanceEntity, QSortBy> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByCheckInAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByCheckInAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByCheckOutAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByCheckOutAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByChildId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByChildIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pending', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByPendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pending', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByPickedUpBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickedUpBy', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByPickedUpByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickedUpBy', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }
}

extension AttendanceEntityQuerySortThenBy on QueryBuilder<AttendanceEntity, AttendanceEntity, QSortThenBy> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByCheckInAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByCheckInAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByCheckOutAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByCheckOutAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByChildId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByChildIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pending', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByPendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pending', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByPickedUpBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickedUpBy', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByPickedUpByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickedUpBy', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }
}

extension AttendanceEntityQueryWhereDistinct on QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByCheckInAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkInAt');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByCheckOutAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkOutAt');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByChildId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'childId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pending');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByPickedUpBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pickedUpBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }
}

extension AttendanceEntityQueryProperty on QueryBuilder<AttendanceEntity, AttendanceEntity, QQueryProperty> {
  QueryBuilder<AttendanceEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<AttendanceEntity, DateTime, QQueryOperations> checkInAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkInAt');
    });
  }

  QueryBuilder<AttendanceEntity, DateTime?, QQueryOperations> checkOutAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkOutAt');
    });
  }

  QueryBuilder<AttendanceEntity, String, QQueryOperations> childIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'childId');
    });
  }

  QueryBuilder<AttendanceEntity, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<AttendanceEntity, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<AttendanceEntity, bool, QQueryOperations> pendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pending');
    });
  }

  QueryBuilder<AttendanceEntity, String?, QQueryOperations> pickedUpByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pickedUpBy');
    });
  }

  QueryBuilder<AttendanceEntity, String?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetActivityEntityCollection on Isar {
  IsarCollection<ActivityEntity> get activityEntitys => this.collection();
}

const ActivityEntitySchema = CollectionSchema(
  name: r'ActivityEntity',
  id: 2979934318015624436,
  properties: {
    r'caregiverName': PropertySchema(id: 0, name: r'caregiverName', type: IsarType.string),
    r'childId': PropertySchema(id: 1, name: r'childId', type: IsarType.string),
    r'detailsJson': PropertySchema(id: 2, name: r'detailsJson', type: IsarType.string),
    r'endedAt': PropertySchema(id: 3, name: r'endedAt', type: IsarType.dateTime),
    r'id': PropertySchema(id: 4, name: r'id', type: IsarType.string),
    r'notes': PropertySchema(id: 5, name: r'notes', type: IsarType.string),
    r'pending': PropertySchema(id: 6, name: r'pending', type: IsarType.bool),
    r'startedAt': PropertySchema(id: 7, name: r'startedAt', type: IsarType.dateTime),
    r'type': PropertySchema(id: 8, name: r'type', type: IsarType.string),
  },

  estimateSize: _activityEntityEstimateSize,
  serialize: _activityEntitySerialize,
  deserialize: _activityEntityDeserialize,
  deserializeProp: _activityEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [IndexPropertySchema(name: r'id', type: IndexType.hash, caseSensitive: true)],
    ),
    r'childId': IndexSchema(
      id: -5533418659857701897,
      name: r'childId',
      unique: false,
      replace: false,
      properties: [IndexPropertySchema(name: r'childId', type: IndexType.hash, caseSensitive: true)],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _activityEntityGetId,
  getLinks: _activityEntityGetLinks,
  attach: _activityEntityAttach,
  version: '3.4.1',
);

int _activityEntityEstimateSize(ActivityEntity object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  {
    final value = object.caregiverName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.childId.length * 3;
  bytesCount += 3 + object.detailsJson.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _activityEntitySerialize(
  ActivityEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.caregiverName);
  writer.writeString(offsets[1], object.childId);
  writer.writeString(offsets[2], object.detailsJson);
  writer.writeDateTime(offsets[3], object.endedAt);
  writer.writeString(offsets[4], object.id);
  writer.writeString(offsets[5], object.notes);
  writer.writeBool(offsets[6], object.pending);
  writer.writeDateTime(offsets[7], object.startedAt);
  writer.writeString(offsets[8], object.type);
}

ActivityEntity _activityEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ActivityEntity();
  object.caregiverName = reader.readStringOrNull(offsets[0]);
  object.childId = reader.readString(offsets[1]);
  object.detailsJson = reader.readString(offsets[2]);
  object.endedAt = reader.readDateTimeOrNull(offsets[3]);
  object.id = reader.readString(offsets[4]);
  object.isarId = id;
  object.notes = reader.readStringOrNull(offsets[5]);
  object.pending = reader.readBool(offsets[6]);
  object.startedAt = reader.readDateTime(offsets[7]);
  object.type = reader.readString(offsets[8]);
  return object;
}

P _activityEntityDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _activityEntityGetId(ActivityEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _activityEntityGetLinks(ActivityEntity object) {
  return [];
}

void _activityEntityAttach(IsarCollection<dynamic> col, Id id, ActivityEntity object) {
  object.isarId = id;
}

extension ActivityEntityByIndex on IsarCollection<ActivityEntity> {
  Future<ActivityEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  ActivityEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<ActivityEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<ActivityEntity?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(ActivityEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(ActivityEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<ActivityEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<ActivityEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension ActivityEntityQueryWhereSort on QueryBuilder<ActivityEntity, ActivityEntity, QWhere> {
  QueryBuilder<ActivityEntity, ActivityEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ActivityEntityQueryWhere on QueryBuilder<ActivityEntity, ActivityEntity, QWhereClause> {
  QueryBuilder<ActivityEntity, ActivityEntity, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: isarId, upper: isarId));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IdWhereClause.lessThan(upper: isarId, includeUpper: false))
            .addWhereClause(IdWhereClause.greaterThan(lower: isarId, includeLower: false));
      } else {
        return query
            .addWhereClause(IdWhereClause.greaterThan(lower: isarId, includeLower: false))
            .addWhereClause(IdWhereClause.lessThan(upper: isarId, includeUpper: false));
      }
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(lower: isarId, includeLower: include));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(upper: isarId, includeUpper: include));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'id', value: [id]));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterWhereClause> idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(indexName: r'id', lower: [], upper: [id], includeUpper: false))
            .addWhereClause(IndexWhereClause.between(indexName: r'id', lower: [id], includeLower: false, upper: []));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(indexName: r'id', lower: [id], includeLower: false, upper: []))
            .addWhereClause(IndexWhereClause.between(indexName: r'id', lower: [], upper: [id], includeUpper: false));
      }
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterWhereClause> childIdEqualTo(String childId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'childId', value: [childId]));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterWhereClause> childIdNotEqualTo(String childId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'childId', lower: [], upper: [childId], includeUpper: false),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'childId', lower: [childId], includeLower: false, upper: []),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(indexName: r'childId', lower: [childId], includeLower: false, upper: []),
            )
            .addWhereClause(
              IndexWhereClause.between(indexName: r'childId', lower: [], upper: [childId], includeUpper: false),
            );
      }
    });
  }
}

extension ActivityEntityQueryFilter on QueryBuilder<ActivityEntity, ActivityEntity, QFilterCondition> {
  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'caregiverName'));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'caregiverName'));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caregiverName', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caregiverName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caregiverName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caregiverName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'caregiverName', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'caregiverName', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'caregiverName', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'caregiverName', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'caregiverName', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> caregiverNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'caregiverName', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> childIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> childIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> childIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> childIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'childId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> childIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> childIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> childIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'childId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> childIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'childId', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> childIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'childId', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> childIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'childId', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> detailsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'detailsJson', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> detailsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> detailsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> detailsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'detailsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> detailsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'detailsJson', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> detailsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'detailsJson', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> detailsJsonContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'detailsJson', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> detailsJsonMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'detailsJson', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> detailsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'detailsJson', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> detailsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'detailsJson', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> endedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'endedAt'));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> endedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'endedAt'));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> endedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'endedAt', value: value));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> endedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'endedAt', value: value),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> endedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'endedAt', value: value));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> endedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> idContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'id', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> idMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'id', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'id', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'id', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'isarId', value: value));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'isarId', value: value));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> isarIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'isarId', value: value));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'notes'));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'notes'));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'notes', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'notes', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'notes', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'notes', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'notes', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'notes', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'notes', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'notes', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> pendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'pending', value: value));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'startedAt', value: value));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> startedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'startedAt', value: value));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'type', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'type', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'type', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'type', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> typeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'type', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> typeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'type', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'type', value: ''));
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'type', value: ''));
    });
  }
}

extension ActivityEntityQueryObject on QueryBuilder<ActivityEntity, ActivityEntity, QFilterCondition> {}

extension ActivityEntityQueryLinks on QueryBuilder<ActivityEntity, ActivityEntity, QFilterCondition> {}

extension ActivityEntityQuerySortBy on QueryBuilder<ActivityEntity, ActivityEntity, QSortBy> {
  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByCaregiverName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caregiverName', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByCaregiverNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caregiverName', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByChildId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childId', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByChildIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childId', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pending', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByPendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pending', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ActivityEntityQuerySortThenBy on QueryBuilder<ActivityEntity, ActivityEntity, QSortThenBy> {
  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByCaregiverName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caregiverName', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByCaregiverNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caregiverName', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByChildId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childId', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByChildIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childId', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pending', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByPendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pending', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ActivityEntityQueryWhereDistinct on QueryBuilder<ActivityEntity, ActivityEntity, QDistinct> {
  QueryBuilder<ActivityEntity, ActivityEntity, QDistinct> distinctByCaregiverName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caregiverName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QDistinct> distinctByChildId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'childId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QDistinct> distinctByDetailsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'detailsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QDistinct> distinctByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endedAt');
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QDistinct> distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QDistinct> distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QDistinct> distinctByPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pending');
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<ActivityEntity, ActivityEntity, QDistinct> distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension ActivityEntityQueryProperty on QueryBuilder<ActivityEntity, ActivityEntity, QQueryProperty> {
  QueryBuilder<ActivityEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ActivityEntity, String?, QQueryOperations> caregiverNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caregiverName');
    });
  }

  QueryBuilder<ActivityEntity, String, QQueryOperations> childIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'childId');
    });
  }

  QueryBuilder<ActivityEntity, String, QQueryOperations> detailsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detailsJson');
    });
  }

  QueryBuilder<ActivityEntity, DateTime?, QQueryOperations> endedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endedAt');
    });
  }

  QueryBuilder<ActivityEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ActivityEntity, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<ActivityEntity, bool, QQueryOperations> pendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pending');
    });
  }

  QueryBuilder<ActivityEntity, DateTime, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<ActivityEntity, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetOutboxEntryCollection on Isar {
  IsarCollection<OutboxEntry> get outboxEntrys => this.collection();
}

const OutboxEntrySchema = CollectionSchema(
  name: r'OutboxEntry',
  id: 147409428666453047,
  properties: {
    r'attempts': PropertySchema(id: 0, name: r'attempts', type: IsarType.long),
    r'createdAt': PropertySchema(id: 1, name: r'createdAt', type: IsarType.dateTime),
    r'failed': PropertySchema(id: 2, name: r'failed', type: IsarType.bool),
    r'kind': PropertySchema(id: 3, name: r'kind', type: IsarType.string),
    r'lastError': PropertySchema(id: 4, name: r'lastError', type: IsarType.string),
    r'payload': PropertySchema(id: 5, name: r'payload', type: IsarType.string),
  },

  estimateSize: _outboxEntryEstimateSize,
  serialize: _outboxEntrySerialize,
  deserialize: _outboxEntryDeserialize,
  deserializeProp: _outboxEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _outboxEntryGetId,
  getLinks: _outboxEntryGetLinks,
  attach: _outboxEntryAttach,
  version: '3.4.1',
);

int _outboxEntryEstimateSize(OutboxEntry object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.kind.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.payload.length * 3;
  return bytesCount;
}

void _outboxEntrySerialize(OutboxEntry object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {
  writer.writeLong(offsets[0], object.attempts);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeBool(offsets[2], object.failed);
  writer.writeString(offsets[3], object.kind);
  writer.writeString(offsets[4], object.lastError);
  writer.writeString(offsets[5], object.payload);
}

OutboxEntry _outboxEntryDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = OutboxEntry();
  object.attempts = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.failed = reader.readBool(offsets[2]);
  object.id = id;
  object.kind = reader.readString(offsets[3]);
  object.lastError = reader.readStringOrNull(offsets[4]);
  object.payload = reader.readString(offsets[5]);
  return object;
}

P _outboxEntryDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _outboxEntryGetId(OutboxEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _outboxEntryGetLinks(OutboxEntry object) {
  return [];
}

void _outboxEntryAttach(IsarCollection<dynamic> col, Id id, OutboxEntry object) {
  object.id = id;
}

extension OutboxEntryQueryWhereSort on QueryBuilder<OutboxEntry, OutboxEntry, QWhere> {
  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OutboxEntryQueryWhere on QueryBuilder<OutboxEntry, OutboxEntry, QWhereClause> {
  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false))
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false));
      } else {
        return query
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false))
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false));
      }
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: include));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: include));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: lowerId, includeLower: includeLower, upper: upperId, includeUpper: includeUpper),
      );
    });
  }
}

extension OutboxEntryQueryFilter on QueryBuilder<OutboxEntry, OutboxEntry, QFilterCondition> {
  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> attemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'attempts', value: value));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> attemptsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'attempts', value: value),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> attemptsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'attempts', value: value));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> attemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attempts',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'createdAt', value: value));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'createdAt', value: value));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> failedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'failed', value: value));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'id', value: value));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> kindEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> kindContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'kind', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> kindMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'kind', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'kind', value: ''));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'kind', value: ''));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'lastError'));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'lastError'));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastError', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'lastError', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'lastError', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'lastError', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'lastError', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'lastError', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'lastError', value: ''));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'lastError', value: ''));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> payloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payload', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> payloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'payload', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> payloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'payload', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> payloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payload',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> payloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'payload', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> payloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'payload', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> payloadContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'payload', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> payloadMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'payload', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'payload', value: ''));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'payload', value: ''));
    });
  }
}

extension OutboxEntryQueryObject on QueryBuilder<OutboxEntry, OutboxEntry, QFilterCondition> {}

extension OutboxEntryQueryLinks on QueryBuilder<OutboxEntry, OutboxEntry, QFilterCondition> {}

extension OutboxEntryQuerySortBy on QueryBuilder<OutboxEntry, OutboxEntry, QSortBy> {
  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }
}

extension OutboxEntryQuerySortThenBy on QueryBuilder<OutboxEntry, OutboxEntry, QSortThenBy> {
  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }
}

extension OutboxEntryQueryWhereDistinct on QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> {
  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attempts');
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failed');
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload', caseSensitive: caseSensitive);
    });
  }
}

extension OutboxEntryQueryProperty on QueryBuilder<OutboxEntry, OutboxEntry, QQueryProperty> {
  QueryBuilder<OutboxEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OutboxEntry, int, QQueryOperations> attemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attempts');
    });
  }

  QueryBuilder<OutboxEntry, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<OutboxEntry, bool, QQueryOperations> failedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failed');
    });
  }

  QueryBuilder<OutboxEntry, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<OutboxEntry, String?, QQueryOperations> lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<OutboxEntry, String, QQueryOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetSyncStateEntityCollection on Isar {
  IsarCollection<SyncStateEntity> get syncStateEntitys => this.collection();
}

const SyncStateEntitySchema = CollectionSchema(
  name: r'SyncStateEntity',
  id: 3262218820902267707,
  properties: {
    r'activitiesCursor': PropertySchema(id: 0, name: r'activitiesCursor', type: IsarType.string),
    r'attendanceCursor': PropertySchema(id: 1, name: r'attendanceCursor', type: IsarType.string),
    r'lastSyncAt': PropertySchema(id: 2, name: r'lastSyncAt', type: IsarType.dateTime),
  },

  estimateSize: _syncStateEntityEstimateSize,
  serialize: _syncStateEntitySerialize,
  deserialize: _syncStateEntityDeserialize,
  deserializeProp: _syncStateEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _syncStateEntityGetId,
  getLinks: _syncStateEntityGetLinks,
  attach: _syncStateEntityAttach,
  version: '3.4.1',
);

int _syncStateEntityEstimateSize(SyncStateEntity object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  {
    final value = object.activitiesCursor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.attendanceCursor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _syncStateEntitySerialize(
  SyncStateEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activitiesCursor);
  writer.writeString(offsets[1], object.attendanceCursor);
  writer.writeDateTime(offsets[2], object.lastSyncAt);
}

SyncStateEntity _syncStateEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncStateEntity();
  object.activitiesCursor = reader.readStringOrNull(offsets[0]);
  object.attendanceCursor = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.lastSyncAt = reader.readDateTimeOrNull(offsets[2]);
  return object;
}

P _syncStateEntityDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncStateEntityGetId(SyncStateEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncStateEntityGetLinks(SyncStateEntity object) {
  return [];
}

void _syncStateEntityAttach(IsarCollection<dynamic> col, Id id, SyncStateEntity object) {
  object.id = id;
}

extension SyncStateEntityQueryWhereSort on QueryBuilder<SyncStateEntity, SyncStateEntity, QWhere> {
  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncStateEntityQueryWhere on QueryBuilder<SyncStateEntity, SyncStateEntity, QWhereClause> {
  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false))
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false));
      } else {
        return query
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false))
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false));
      }
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: include));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: include));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: lowerId, includeLower: includeLower, upper: upperId, includeUpper: includeUpper),
      );
    });
  }
}

extension SyncStateEntityQueryFilter on QueryBuilder<SyncStateEntity, SyncStateEntity, QFilterCondition> {
  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'activitiesCursor'));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'activitiesCursor'));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'activitiesCursor', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'activitiesCursor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'activitiesCursor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'activitiesCursor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'activitiesCursor', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'activitiesCursor', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'activitiesCursor', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'activitiesCursor', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'activitiesCursor', value: ''));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> activitiesCursorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'activitiesCursor', value: ''));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'attendanceCursor'));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'attendanceCursor'));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attendanceCursor', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attendanceCursor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attendanceCursor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attendanceCursor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'attendanceCursor', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'attendanceCursor', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'attendanceCursor', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(property: r'attendanceCursor', wildcard: pattern, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'attendanceCursor', value: ''));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> attendanceCursorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'attendanceCursor', value: ''));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'id', value: value));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(include: include, property: r'id', value: value));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> lastSyncAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'lastSyncAt'));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> lastSyncAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'lastSyncAt'));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> lastSyncAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'lastSyncAt', value: value));
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> lastSyncAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'lastSyncAt', value: value),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> lastSyncAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'lastSyncAt', value: value),
      );
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterFilterCondition> lastSyncAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSyncAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SyncStateEntityQueryObject on QueryBuilder<SyncStateEntity, SyncStateEntity, QFilterCondition> {}

extension SyncStateEntityQueryLinks on QueryBuilder<SyncStateEntity, SyncStateEntity, QFilterCondition> {}

extension SyncStateEntityQuerySortBy on QueryBuilder<SyncStateEntity, SyncStateEntity, QSortBy> {
  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> sortByActivitiesCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activitiesCursor', Sort.asc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> sortByActivitiesCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activitiesCursor', Sort.desc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> sortByAttendanceCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceCursor', Sort.asc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> sortByAttendanceCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceCursor', Sort.desc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }
}

extension SyncStateEntityQuerySortThenBy on QueryBuilder<SyncStateEntity, SyncStateEntity, QSortThenBy> {
  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> thenByActivitiesCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activitiesCursor', Sort.asc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> thenByActivitiesCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activitiesCursor', Sort.desc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> thenByAttendanceCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceCursor', Sort.asc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> thenByAttendanceCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceCursor', Sort.desc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QAfterSortBy> thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }
}

extension SyncStateEntityQueryWhereDistinct on QueryBuilder<SyncStateEntity, SyncStateEntity, QDistinct> {
  QueryBuilder<SyncStateEntity, SyncStateEntity, QDistinct> distinctByActivitiesCursor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activitiesCursor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QDistinct> distinctByAttendanceCursor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attendanceCursor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncStateEntity, SyncStateEntity, QDistinct> distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }
}

extension SyncStateEntityQueryProperty on QueryBuilder<SyncStateEntity, SyncStateEntity, QQueryProperty> {
  QueryBuilder<SyncStateEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncStateEntity, String?, QQueryOperations> activitiesCursorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activitiesCursor');
    });
  }

  QueryBuilder<SyncStateEntity, String?, QQueryOperations> attendanceCursorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attendanceCursor');
    });
  }

  QueryBuilder<SyncStateEntity, DateTime?, QQueryOperations> lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }
}
