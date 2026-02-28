import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';

/// Paints the volume histogram at the bottom of the chart.
class VolumePainter {
  /// Paints the volume data.
  static void paint(
    Canvas canvas,
    Size size,
    List<Tick> visibleEntries,
    double Function(int) epochToCanvasX,
    CandleStyle candleStyle,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
  ) {
    if (visibleEntries.isEmpty) {
      return;
    }

    // Find the max volume in the visible entries
    double maxVolume = 0;
    for (final Tick tick in visibleEntries) {
      if (tick.volume != null && tick.volume! > maxVolume) {
        maxVolume = tick.volume!;
      }
    }

    if (maxVolume == 0) {
      return;
    }

    // We want the volume chart to take up at most 20% of the chart height
    final double maxVolumeHeight = size.height * 0.20;

    // Width of each bar - Match candle width calculation exactly
    final double intervalWidth =
        epochToCanvasX(chartConfig.granularity) - epochToCanvasX(0);
    final double barWidth = intervalWidth * 0.6;
    final double halfBarWidth = barWidth / 2;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final Tick tick in visibleEntries) {
      if (tick.volume == null || tick.volume! <= 0) {
        continue;
      }

      final double volumeRatio = tick.volume! / maxVolume;
      // Animate height if needed, though for panning it's mostly static.
      final double barHeight = maxVolumeHeight * volumeRatio;

      final double x = epochToCanvasX(tick.epoch);
      final double top = size.height - barHeight;
      final double bottom = size.height;

      // Determine color based on candle open/close or previous tick
      Color barColor = candleStyle.neutralColor;

      if (tick is Candle) {
        if (tick.close > tick.open) {
          barColor = candleStyle.candleBullishBodyColor;
        } else if (tick.close < tick.open) {
          barColor = candleStyle.candleBearishBodyColor;
        }
      } else {
        // If it's a Tick, check if it's bullish or bearish compared to previous
        barColor = candleStyle.neutralColor;
      }

      // Make volume a bit transparent so it doesn't distract too much or obscure data directly
      paint.color = barColor.withValues(alpha: 0.6);

      final Rect barRect =
          Rect.fromLTRB(x - halfBarWidth, top, x + halfBarWidth, bottom);
      canvas.drawRect(barRect, paint);
    }
  }
}
