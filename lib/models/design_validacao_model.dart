class DesignValidationResult {
  final bool ok;
  final String? message;
  final double usedHeight;
  final double availableHeight;
  final int visibleCount;
  final List<String> blockingFields;

  const DesignValidationResult({
    required this.ok,
    this.message,
    required this.usedHeight,
    required this.availableHeight,
    required this.visibleCount,
    this.blockingFields = const [],
  });

  factory DesignValidationResult.valid({
    required double usedHeight,
    required double availableHeight,
    required int visibleCount,
  }) {
    return DesignValidationResult(
      ok: true,
      usedHeight: usedHeight,
      availableHeight: availableHeight,
      visibleCount: visibleCount,
    );
  }

  factory DesignValidationResult.invalid({
    required String message,
    required double usedHeight,
    required double availableHeight,
    required int visibleCount,
    List<String> blockingFields = const [],
  }) {
    return DesignValidationResult(
      ok: false,
      message: message,
      usedHeight: usedHeight,
      availableHeight: availableHeight,
      visibleCount: visibleCount,
      blockingFields: blockingFields,
    );
  }
}