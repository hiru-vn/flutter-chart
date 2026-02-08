import 'package:intl/intl.dart' show DateFormat;

/// Granularity for X-axis labels.
enum XAxisGranularity {
  /// Default behavior.
  auto,

  /// Monthly labels (e.g., Jan, Feb).
  monthly,

  /// Quarterly labels (e.g., Q1, Q2).
  quarterly,

  /// Yearly labels (e.g., 2023).
  yearly,
}

/// Builder to override X-axis label display.
typedef XAxisLabelBuilder = String Function(DateTime dateTime);

/// Current granularity setting.
XAxisGranularity xAxisGranularity = XAxisGranularity.auto;

/// Optional builder to override label text.
XAxisLabelBuilder? xAxisLabelBuilder;

/// Returns the time label for the given [time].
String timeLabel(DateTime time) {
  // 1. If builder is provided, use it.
  if (xAxisLabelBuilder != null) {
    return xAxisLabelBuilder!(time);
  }

  // 2. Handle specific granularities.
  switch (xAxisGranularity) {
    case XAxisGranularity.monthly:
      return DateFormat('MMM').format(time);
    case XAxisGranularity.quarterly:
      final int quarter = ((time.month - 1) / 3).floor() + 1;
      return 'Q$quarter';
    case XAxisGranularity.yearly:
      return DateFormat('yyyy').format(time);
    case XAxisGranularity.auto:
      // Fallthrough to default logic
      break;
  }

  // 3. Default auto logic.
  final bool is0h0m0s = time.hour == 0 && time.minute == 0 && time.second == 0;
  if (time.month == 1 && time.day == 1 && is0h0m0s) {
    return DateFormat('y').format(time);
  }
  if (time.day == 1 && is0h0m0s) {
    return DateFormat('MMMM').format(time);
  }
  if (is0h0m0s) {
    return DateFormat('d MMM').format(time);
  }
  return DateFormat('Hms').format(time);
}
