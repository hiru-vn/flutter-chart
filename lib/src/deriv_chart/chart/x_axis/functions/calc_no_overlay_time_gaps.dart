import 'package:deriv_chart/src/deriv_chart/chart/x_axis/grid/time_label.dart';

/// Calculate time labels' from [gridTimestamps] without any overlaps.

List<DateTime> calculateNoOverlapGridTimestamps(
  List<DateTime> gridTimestamps,
  double minDistanceBetweenTimeGridLines,

  /// Px distance between two epochs minus the time gaps.
  double Function(int leftEpoch, int rightEpoch) pxBetween,

  /// Does the given epoch fall into a time gap.
  bool Function(int) isInGap, {
  /// Returns the end epoch of the gap if the given epoch falls into one.
  int? Function(int)? getGapEnd,
}) {
  final List<DateTime> _noOverlapGridTimestamps = <DateTime>[];
  if (gridTimestamps.isEmpty) {
    return _noOverlapGridTimestamps;
  }
  // check if timestamp is not have overlap with Previous timestamp
  bool noOverlapWithPrevious(int timestamp) {
    // Skip overlap check if granularity is forced
    if (xAxisGranularity != XAxisGranularity.auto) {
      return true;
    }
    return _noOverlapGridTimestamps.isEmpty ||
        pxBetween(_noOverlapGridTimestamps.last.millisecondsSinceEpoch,
                timestamp) >=
            minDistanceBetweenTimeGridLines;
  }

  for (final DateTime timestamp in gridTimestamps) {
    DateTime correctedTimestamp = timestamp;

    // Apply gap correction if granularity is forced
    if (xAxisGranularity != XAxisGranularity.auto && getGapEnd != null) {
      final int? gapEnd = getGapEnd(timestamp.millisecondsSinceEpoch);
      if (gapEnd != null) {
        // Move to the end of the gap (which is the next valid open time)
        correctedTimestamp =
            DateTime.fromMillisecondsSinceEpoch(gapEnd, isUtc: true);
      }
    } else if (isInGap(timestamp.millisecondsSinceEpoch)) {
      // Normal behavior: skip if in gap
      continue;
    }

    if (noOverlapWithPrevious(correctedTimestamp.millisecondsSinceEpoch)) {
      _noOverlapGridTimestamps.add(correctedTimestamp);
    }
  }
  return _noOverlapGridTimestamps;
}
