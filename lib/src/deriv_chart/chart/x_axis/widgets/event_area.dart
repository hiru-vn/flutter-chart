import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/chart_event.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A widget that renders event icons on the X-axis.
class EventArea extends StatelessWidget {
  /// Initializes an event area.
  const EventArea({
    required this.events,
    super.key,
  });

  /// The list of events to display.
  final List<ChartEvent> events;

  @override
  Widget build(BuildContext context) {
    final XAxisModel model = context.watch<XAxisModel>();
    final ChartTheme theme = context.watch<ChartTheme>();

    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: events.map((ChartEvent event) {
        final double x = model.xFromEpochSnapped(event.epoch);

        // Hide events outside the visible area (with some margin)
        if (x < -50 || x > (model.width ?? 0) + 50) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: x - theme.gridStyle.eventAreaHeight / 2,
          bottom: 0,
          width: theme.gridStyle.eventAreaHeight,
          height: theme.gridStyle.eventAreaHeight,
          child: GestureDetector(
            onTap: () => _showPopup(context, event, x),
            child: Center(
              child: event.builder(context),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPopup(BuildContext context, ChartEvent event, double x) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Position of the icon on screen
    final double iconCenterX = offset.dx + x;
    final double iconTopY = offset.dy;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Event Details',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return _EventPopup(
          event: event,
          centerX: iconCenterX,
          bottomY: iconTopY,
        );
      },
    );
  }
}

class _EventPopup extends StatelessWidget {
  const _EventPopup({
    required this.event,
    required this.centerX,
    required this.bottomY,
  });

  final ChartEvent event;
  final double centerX;
  final double bottomY;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: centerX - 100, // Center the popup (assuming 200 width)
          bottom: MediaQuery.of(context).size.height - bottomY + 8,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: event.contentBuilder(context),
            ),
          ),
        ),
      ],
    );
  }
}
