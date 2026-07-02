/// Small, dependency-free formatting helpers shared across the UI.
///
/// Kept intentionally simple (no `intl` package) since the demo is USD-only.
class Formatters {
  const Formatters._();

  /// Formats a USD amount, e.g. `1234.5` -> `$1,234.50`.
  static String price(double value) {
    final negative = value < 0;
    final cents = value.abs().toStringAsFixed(2);
    final parts = cents.split('.');
    final withThousands = _groupThousands(parts[0]);
    return '${negative ? '-' : ''}\$$withThousands.${parts[1]}';
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Formats a date as e.g. `12 Mar 2026`.
  static String date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// Compact count, e.g. `1284` -> `1.3k`, `5120` -> `5.1k`.
  static String compactCount(int value) {
    if (value < 1000) return '$value';
    final thousands = value / 1000;
    return '${thousands.toStringAsFixed(1)}k';
  }

  /// Inserts commas as thousands separators into a whole-number string.
  static String _groupThousands(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
