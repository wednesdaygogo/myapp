class IndicatorQuery {
  final int personId;
  final String indicatorType;

  const IndicatorQuery({
    required this.personId,
    required this.indicatorType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndicatorQuery &&
          personId == other.personId &&
          indicatorType == other.indicatorType;

  @override
  int get hashCode => Object.hash(personId, indicatorType);
}