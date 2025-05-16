import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';

class VerticalSlider extends StatefulWidget {
  const VerticalSlider({
    super.key,
    required this.bandIndex,
    required this.value,
    required this.min,
    required this.max,
    required this.freq,
    required this.onChanged,
  });

  final int bandIndex;
  final double value;
  final double min;
  final double max;
  final int freq;
  final Function(double) onChanged;

  @override
  State<VerticalSlider> createState() => _VerticalSliderState();
}

class _VerticalSliderState extends State<VerticalSlider> {
  late double _dragValue;

  @override
  void initState() {
    super.initState();
    _dragValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant VerticalSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        _dragValue = widget.value;
      });
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragValue -= details.primaryDelta! / 10; // Sensitivity tuned
      _dragValue = _dragValue.clamp(widget.min, widget.max);
    });

    widget.onChanged(_dragValue);
  }

  void _onTapDown(TapDownDetails details) {
    final newValue =
        widget.max -
        ((details.localPosition.dy / 200) * (widget.max - widget.min));
    setState(() {
      _dragValue = newValue.clamp(widget.min, widget.max);
    });
    widget.onChanged(_dragValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onTapDown: _onTapDown,
          child: Stack(
            children: [
              SizedBox(
                height: 209,
                width: 30,
                child: Column(
                  children: [
                    Expanded(
                      flex:
                          ((1 -
                                      ((_dragValue - widget.min) /
                                          (widget.max - widget.min))) *
                                  100)
                              .toInt(),
                      child: Container(
                        width: 15,
                        decoration: BoxDecoration(
                          color: context.onBgColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Expanded(
                      flex:
                          (((_dragValue - widget.min) /
                                      (widget.max - widget.min)) *
                                  100)
                              .toInt(),
                      child: Container(
                        width: 15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              context.primary,
                              context.primary,
                              context.scheme.error,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom:
                    (((_dragValue - widget.min) / (widget.max - widget.min)) *
                        (200 - 20)),
                left: 0,
                right: 0,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: context.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap(5),
        Text(
          '${formatFollowersCount(widget.freq ~/ 1000)} Hz',
          style: TextStyle(fontSize: 8, color: context.onBgColor),
        ),
      ],
    );
  }
}
