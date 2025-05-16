import 'package:flutter/material.dart';
import 'package:new_tuneflow/src/equalizer/presentation/providers/equalizer_provider.dart';
import 'package:new_tuneflow/src/equalizer/presentation/widgets/vertical_slider.dart';
import 'package:provider/provider.dart';

class BandLevel extends StatelessWidget {
  const BandLevel({
    super.key,
    required this.bandId,
    required this.freq,
    required this.min,
    required this.max,
  });
  final int bandId;
  final int freq;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Consumer<EqualizerProvider>(
      builder: (context, value, child) {
        return VerticalSlider(
          bandIndex: bandId,
          freq: freq,
          max: max,
          min: min,
          value: value.bands[bandId].toDouble(),
          onChanged: (p0) {
            value.changeFreq(bandId, p0.toInt());
            value.changeMode('Custom');
          },
        );
      },
    );
  }
}
