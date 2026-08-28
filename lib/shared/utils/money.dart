/// Money helpers: integer minor units only.
class Money {
  Money._();

  static int parseMajorToMinor(String input, {int fractionDigits = 2}) {
    final normalized = input.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return 0;
    final parts = normalized.split('.');
    final whole = int.tryParse(parts[0].isEmpty ? '0' : parts[0]) ?? 0;
    var fraction = 0;
    if (parts.length > 1) {
      final fracRaw = parts[1].padRight(fractionDigits, '0').substring(0, fractionDigits);
      fraction = int.tryParse(fracRaw) ?? 0;
    }
    final sign = whole < 0 || normalized.startsWith('-') ? -1 : 1;
    final absWhole = whole.abs();
    return sign * (absWhole * pow10(fractionDigits) + fraction);
  }

  /// Dot-decimal major units without grouping — for export / interchange.
  /// Prefer [formatMoneyDisplay] for UI.
  static String formatMinor(int minor, {int fractionDigits = 2}) {
    final sign = minor < 0 ? '-' : '';
    final abs = minor.abs();
    final whole = abs ~/ pow10(fractionDigits);
    final frac = (abs % pow10(fractionDigits)).toString().padLeft(fractionDigits, '0');
    return '$sign$whole.$frac';
  }

  /// Converts [originalMinor] using [rate] (units of target per 1 unit of source).
  static int convertMinor({
    required int originalMinor,
    required double rate,
    int fractionDigits = 2,
  }) {
    final factor = pow10(fractionDigits);
    final major = originalMinor / factor;
    final convertedMajor = major * rate;
    return (convertedMajor * factor).round();
  }

  static int pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}
