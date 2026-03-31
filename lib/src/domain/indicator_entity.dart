enum IndicatorStatus { ok, warning }

class IndicatorEntity {
  final int value;
  final int threshold;

  IndicatorEntity({required this.value, required this.threshold});

  IndicatorStatus get status {
    return value >= threshold ? IndicatorStatus.ok : IndicatorStatus.warning;
  }
}
