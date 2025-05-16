import 'package:flutter/material.dart';
import 'package:new_tuneflow/src/equalizer/presentation/providers/equalizer_provider.dart';
import 'package:new_tuneflow/src/equalizer/presentation/widgets/band_level.dart';
import 'package:provider/provider.dart';

class BandFreq extends StatelessWidget {
  const BandFreq({super.key, required this.min, required this.max});
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Consumer<EqualizerProvider>(
      builder: (context, value, child) {
        int bandId = 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                value.centerBandFreqs
                    .map(
                      (e) => BandLevel(
                        bandId: bandId++,
                        freq: e,
                        max: max,
                        min: min,
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }
}
