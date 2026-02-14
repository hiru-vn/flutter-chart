import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A class that paints a lable on the Y axis of grid.
class YGridLabelPainter extends CustomPainter {
  /// initializes a class that paints a lable on the Y axis of grid.
  YGridLabelPainter({
    required this.gridLineQuotes,
    required this.pipSize,
    required this.quoteToCanvasY,
    required this.style,
    required this.topBoundQuote,
    required this.bottomBoundQuote,
    required this.topPadding,
    required this.bottomPadding,
  });

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// The list of quotes.
  final List<double> gridLineQuotes;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// The style of chart's grid.

  final GridStyle style;

  /// The top bound quote used for repaint optimization.
  /// Note: This value is already captured by [quoteToCanvasY] closure
  /// and is tracked separately to detect when repainting is needed.
  final double topBoundQuote;

  /// The bottom bound quote used for repaint optimization.
  /// Note: This value is already captured by [quoteToCanvasY] closure
  /// and is tracked separately to detect when repainting is needed.
  final double bottomBoundQuote;

  /// The top padding used for repaint optimization.
  /// Note: This value is already captured by [quoteToCanvasY] closure
  /// and is tracked separately to detect when repainting is needed.
  final double topPadding;

  /// The bottom padding used for repaint optimization.
  /// Note: This value is already captured by [quoteToCanvasY] closure
  /// and is tracked separately to detect when repainting is needed.
  final double bottomPadding;

  @override
  void paint(Canvas canvas, Size size) {
    for (final double quote in gridLineQuotes) {
      final double y = quoteToCanvasY(quote);

      String text;

      if (topBoundQuote > 1000) {
        final double val = quote / 1000;
        if (val % 1 == 0) {
          text = val.toStringAsFixed(0);
        } else {
          // Show up to 2 decimals if needed, stripping trailing zeros
          text = val
              .toStringAsFixed(2)
              .replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
        }
      } else {
        text = quote.toStringAsFixed(pipSize);
      }

      paintText(
        canvas,
        text: text,
        style: style.yLabelStyle,
        anchor: Offset(size.width - style.labelHorizontalPadding, y),
        anchorAlignment: Alignment.centerRight,
      );
    }
  }

  @override
  bool shouldRepaint(YGridLabelPainter oldDelegate) =>
      !listEquals(gridLineQuotes, oldDelegate.gridLineQuotes) ||
      pipSize != oldDelegate.pipSize ||
      style != oldDelegate.style ||
      topBoundQuote != oldDelegate.topBoundQuote ||
      bottomBoundQuote != oldDelegate.bottomBoundQuote ||
      topPadding != oldDelegate.topPadding ||
      bottomPadding != oldDelegate.bottomPadding;

  @override
  bool shouldRebuildSemantics(YGridLabelPainter oldDelegate) => false;
}
