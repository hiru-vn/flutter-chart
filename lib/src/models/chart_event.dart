import 'package:flutter/material.dart';

/// Represents an event on the chart.
class ChartEvent {
  /// Initializes a chart event.
  const ChartEvent({
    required this.epoch,
    required this.builder,
    required this.contentBuilder,
    this.label,
  });

  /// Timestamp of the event.
  final int epoch;

  /// Builder for the icon displayed on the X-axis.
  final WidgetBuilder builder;

  /// Builder for the popup content when the icon is tapped.
  final WidgetBuilder contentBuilder;

  /// Optional label for the event.
  final String? label;
}
