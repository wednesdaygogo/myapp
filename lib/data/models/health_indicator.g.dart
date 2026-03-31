// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_indicator.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHealthIndicatorCollection on Isar {
  IsarCollection<HealthIndicator> get healthIndicators => this.collection();
}

const HealthIndicatorSchema = CollectionSchema(
  name: r'HealthIndicator',
  id: -326006915645616899,
  properties: {
    r'isAbnormal': PropertySchema(
      id: 0,
      name: r'isAbnormal',
      type: IsarType.bool,
    ),
    r'reportId': PropertySchema(
      id: 1,
      name: r'reportId',
      type: IsarType.long,
    ),
    r'secondValue': PropertySchema(
      id: 2,
      name: r'secondValue',
      type: IsarType.double,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.byte,
      enumMap: _HealthIndicatortypeEnumValueMap,
    ),
    r'unit': PropertySchema(
      id: 4,
      name: r'unit',
      type: IsarType.string,
    ),
    r'value': PropertySchema(
      id: 5,
      name: r'value',
      type: IsarType.double,
    )
  },
  estimateSize: _healthIndicatorEstimateSize,
  serialize: _healthIndicatorSerialize,
  deserialize: _healthIndicatorDeserialize,
  deserializeProp: _healthIndicatorDeserializeProp,
  idName: r'id',
  indexes: {
    r'reportId': IndexSchema(
      id: 1732854644896652467,
      name: r'reportId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'reportId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _healthIndicatorGetId,
  getLinks: _healthIndicatorGetLinks,
  attach: _healthIndicatorAttach,
  version: '3.1.0+1',
);

int _healthIndicatorEstimateSize(
  HealthIndicator object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.unit.length * 3;
  return bytesCount;
}

void _healthIndicatorSerialize(
  HealthIndicator object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isAbnormal);
  writer.writeLong(offsets[1], object.reportId);
  writer.writeDouble(offsets[2], object.secondValue);
  writer.writeByte(offsets[3], object.type.index);
  writer.writeString(offsets[4], object.unit);
  writer.writeDouble(offsets[5], object.value);
}

HealthIndicator _healthIndicatorDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HealthIndicator();
  object.id = id;
  object.isAbnormal = reader.readBool(offsets[0]);
  object.reportId = reader.readLong(offsets[1]);
  object.secondValue = reader.readDoubleOrNull(offsets[2]);
  object.type =
      _HealthIndicatortypeValueEnumMap[reader.readByteOrNull(offsets[3])] ??
          IndicatorType.bloodGlucose;
  object.unit = reader.readString(offsets[4]);
  object.value = reader.readDouble(offsets[5]);
  return object;
}

P _healthIndicatorDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (_HealthIndicatortypeValueEnumMap[reader.readByteOrNull(offset)] ??
          IndicatorType.bloodGlucose) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _HealthIndicatortypeEnumValueMap = {
  'bloodGlucose': 0,
  'bloodPressure': 1,
  'bloodLipidTC': 2,
  'bloodLipidTG': 3,
  'bloodLipidHDL': 4,
  'bloodLipidLDL': 5,
};
const _HealthIndicatortypeValueEnumMap = {
  0: IndicatorType.bloodGlucose,
  1: IndicatorType.bloodPressure,
  2: IndicatorType.bloodLipidTC,
  3: IndicatorType.bloodLipidTG,
  4: IndicatorType.bloodLipidHDL,
  5: IndicatorType.bloodLipidLDL,
};

Id _healthIndicatorGetId(HealthIndicator object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _healthIndicatorGetLinks(HealthIndicator object) {
  return [];
}

void _healthIndicatorAttach(
    IsarCollection<dynamic> col, Id id, HealthIndicator object) {
  object.id = id;
}

extension HealthIndicatorQueryWhereSort
    on QueryBuilder<HealthIndicator, HealthIndicator, QWhere> {
  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhere> anyReportId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'reportId'),
      );
    });
  }
}

extension HealthIndicatorQueryWhere
    on QueryBuilder<HealthIndicator, HealthIndicator, QWhereClause> {
  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhereClause>
      reportIdEqualTo(int reportId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'reportId',
        value: [reportId],
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhereClause>
      reportIdNotEqualTo(int reportId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reportId',
              lower: [],
              upper: [reportId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reportId',
              lower: [reportId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reportId',
              lower: [reportId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reportId',
              lower: [],
              upper: [reportId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhereClause>
      reportIdGreaterThan(
    int reportId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'reportId',
        lower: [reportId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhereClause>
      reportIdLessThan(
    int reportId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'reportId',
        lower: [],
        upper: [reportId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterWhereClause>
      reportIdBetween(
    int lowerReportId,
    int upperReportId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'reportId',
        lower: [lowerReportId],
        includeLower: includeLower,
        upper: [upperReportId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension HealthIndicatorQueryFilter
    on QueryBuilder<HealthIndicator, HealthIndicator, QFilterCondition> {
  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      isAbnormalEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAbnormal',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      reportIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reportId',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      reportIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reportId',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      reportIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reportId',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      reportIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reportId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      secondValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'secondValue',
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      secondValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'secondValue',
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      secondValueEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      secondValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'secondValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      secondValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'secondValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      secondValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'secondValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      typeEqualTo(IndicatorType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      typeGreaterThan(
    IndicatorType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      typeLessThan(
    IndicatorType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      typeBetween(
    IndicatorType lower,
    IndicatorType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      unitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      unitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      unitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      unitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      valueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      valueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      valueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterFilterCondition>
      valueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension HealthIndicatorQueryObject
    on QueryBuilder<HealthIndicator, HealthIndicator, QFilterCondition> {}

extension HealthIndicatorQueryLinks
    on QueryBuilder<HealthIndicator, HealthIndicator, QFilterCondition> {}

extension HealthIndicatorQuerySortBy
    on QueryBuilder<HealthIndicator, HealthIndicator, QSortBy> {
  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      sortByIsAbnormal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbnormal', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      sortByIsAbnormalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbnormal', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      sortByReportId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportId', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      sortByReportIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportId', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      sortBySecondValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondValue', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      sortBySecondValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondValue', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy> sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension HealthIndicatorQuerySortThenBy
    on QueryBuilder<HealthIndicator, HealthIndicator, QSortThenBy> {
  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      thenByIsAbnormal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbnormal', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      thenByIsAbnormalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbnormal', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      thenByReportId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportId', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      thenByReportIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportId', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      thenBySecondValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondValue', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      thenBySecondValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondValue', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy> thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QAfterSortBy>
      thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension HealthIndicatorQueryWhereDistinct
    on QueryBuilder<HealthIndicator, HealthIndicator, QDistinct> {
  QueryBuilder<HealthIndicator, HealthIndicator, QDistinct>
      distinctByIsAbnormal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAbnormal');
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QDistinct>
      distinctByReportId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reportId');
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QDistinct>
      distinctBySecondValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'secondValue');
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QDistinct> distinctByUnit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HealthIndicator, HealthIndicator, QDistinct> distinctByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value');
    });
  }
}

extension HealthIndicatorQueryProperty
    on QueryBuilder<HealthIndicator, HealthIndicator, QQueryProperty> {
  QueryBuilder<HealthIndicator, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HealthIndicator, bool, QQueryOperations> isAbnormalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAbnormal');
    });
  }

  QueryBuilder<HealthIndicator, int, QQueryOperations> reportIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reportId');
    });
  }

  QueryBuilder<HealthIndicator, double?, QQueryOperations>
      secondValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'secondValue');
    });
  }

  QueryBuilder<HealthIndicator, IndicatorType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<HealthIndicator, String, QQueryOperations> unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }

  QueryBuilder<HealthIndicator, double, QQueryOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}
