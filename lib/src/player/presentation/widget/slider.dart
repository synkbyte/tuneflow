import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class MusicSlider extends StatefulWidget {
  const MusicSlider({
    super.key,
    required this.currentDuration,
    required this.bufferedDuration,
    required this.totalDuration,
    required this.onChanged,
  });
  final Duration currentDuration;
  final Duration bufferedDuration;
  final Duration totalDuration;
  final ValueChanged<Duration> onChanged;

  @override
  State<MusicSlider> createState() => _MusicSliderState();
}

class _MusicSliderState extends State<MusicSlider> {
  double dragPosition = 0.0;
  bool dragging = false;

  double getThumbPosition(Duration duration, double width) {
    if (widget.totalDuration == Duration.zero) return 0.0;
    return (duration.inMilliseconds / widget.totalDuration.inMilliseconds) *
        width;
  }

  void handleDragStart() {
    setState(() {
      dragging = true;
    });
  }

  void handleDragUpdate(DragUpdateDetails details, double width) {
    final dx = details.localPosition.dx.clamp(0.0, width);
    setState(() {
      dragPosition = dx;
    });
  }

  void handleDragEnd(DragEndDetails details, double width) {
    final newValue = dragPosition / width * widget.totalDuration.inMilliseconds;
    widget.onChanged(Duration(milliseconds: newValue.round()));
    setState(() {
      dragging = false;
    });
  }

  void handleTapUp(TapUpDetails details, double width) {
    final dx = details.localPosition.dx.clamp(0.0, width);
    final newValue = dx / width * widget.totalDuration.inMilliseconds;
    widget.onChanged(Duration(milliseconds: newValue.round()));
  }

  @override
  Widget build(BuildContext context) {
    const thumbSize = 14.0;
    final sliderWidth = MediaQuery.of(context).size.width - 2 * 20;
    final bufferPosition = (widget.bufferedDuration.inMilliseconds /
            (widget.totalDuration == Duration.zero
                ? 1
                : widget.totalDuration.inMilliseconds)) *
        sliderWidth;
    final currentPosition = widget.currentDuration == Duration.zero
        ? 0.0
        : getThumbPosition(widget.currentDuration, sliderWidth);
    final thumbPosition = dragging ? dragPosition : currentPosition;

    final draggingDuration = ((thumbPosition / sliderWidth) *
            (widget.totalDuration == Duration.zero
                ? 1
                : widget.totalDuration.inMilliseconds))
        .round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTapUp: (details) => handleTapUp(details, sliderWidth),
        onHorizontalDragStart: (details) => handleDragStart(),
        onHorizontalDragUpdate: (details) =>
            handleDragUpdate(details, sliderWidth),
        onHorizontalDragEnd: (details) => handleDragEnd(details, sliderWidth),
        child: Container(
          height: 15,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(thumbSize / 2),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 3.5,
                decoration: BoxDecoration(
                  color: context.scheme.onSurface.withValues(alpha: .24),
                  borderRadius: BorderRadius.circular(thumbSize / 2),
                ),
              ),
              Container(
                width: bufferPosition,
                height: 3.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.scheme.primary.withValues(alpha: 0.24),
                      context.scheme.secondary.withValues(alpha: 0.24),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(thumbSize / 2),
                ),
              ),
              Container(
                width: thumbPosition,
                height: 3.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.scheme.primary,
                      context.scheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(thumbSize / 2),
                ),
              ),
              if (dragging)
                Positioned(
                  left: (thumbPosition - (thumbSize / 2)) -
                      getSizeForSlider(
                          sliderWidth, (thumbPosition - (thumbSize / 2))),
                  top: -40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.scheme.primary,
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formatDurationToString(draggingDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: thumbPosition - (thumbSize / 2),
                top: -5,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        context.scheme.primary,
                        context.scheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getSizeForSlider(double width, double value) {
    if (width / 2 > value) {
      return 40.0;
    } else {
      return 60.0;
    }
  }

  String formatDurationToString(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes =
        twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
    String seconds =
        twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
    return "$minutes:$seconds";
  }
}
