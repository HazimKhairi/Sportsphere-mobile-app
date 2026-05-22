enum DrillMode {
  kneeLine,
  tap,
  lateral,
  sustainedContact;

  /// Map a Drill.category string to the analyzer mode.
  /// Per the web `feedback-daily-rotation-seed-pattern` + drill-analyzer
  /// shipped memory. Unknown categories fall back to kneeLine.
  static DrillMode forCategory(String category) {
    switch (category) {
      case 'juggle':
        return DrillMode.kneeLine;
      case 'toe_taps':
      case 'back_vee':
        return DrillMode.tap;
      case 'tic_toc':
      case 'inside_outside':
        return DrillMode.lateral;
      case 'sole_rolls':
        return DrillMode.sustainedContact;
      default:
        return DrillMode.kneeLine;
    }
  }
}
