class DesignValidationV2Result {
  final bool ok;
  final String? message;

  final double usedHeight;
  final double availableHeight;

  final int visibleCount;
  final int maxVisibleCount;

  final List<String> blockingFields;
  final List<String> warnings;

  const DesignValidationV2Result({
    required this.ok,
    this.message,
    required this.usedHeight,
    required this.availableHeight,
    required this.visibleCount,
    required this.maxVisibleCount,
    this.blockingFields = const [],
    this.warnings = const [],
  });

  factory DesignValidationV2Result.valid({
    required double usedHeight,
    required double availableHeight,
    required int visibleCount,
    required int maxVisibleCount,
    List<String> warnings = const [],
  }) {
    return DesignValidationV2Result(
      ok: true,
      usedHeight: usedHeight,
      availableHeight: availableHeight,
      visibleCount: visibleCount,
      maxVisibleCount: maxVisibleCount,
      warnings: warnings,
    );
  }

  factory DesignValidationV2Result.invalid({
    required String message,
    required double usedHeight,
    required double availableHeight,
    required int visibleCount,
    required int maxVisibleCount,
    List<String> blockingFields = const [],
    List<String> warnings = const [],
  }) {
    return DesignValidationV2Result(
      ok: false,
      message: message,
      usedHeight: usedHeight,
      availableHeight: availableHeight,
      visibleCount: visibleCount,
      maxVisibleCount: maxVisibleCount,
      blockingFields: blockingFields,
      warnings: warnings,
    );
  }

  bool get hasWarnings => warnings.isNotEmpty;

  double get remainingHeight {
    final value = availableHeight - usedHeight;
    return value < 0 ? 0 : value;
  }
}