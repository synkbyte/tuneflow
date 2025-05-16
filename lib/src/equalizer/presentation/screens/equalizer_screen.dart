import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/equalizer/presentation/providers/equalizer_provider.dart';
import 'package:new_tuneflow/src/equalizer/presentation/widgets/band_freq.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/premium.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  int bandId = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EqualizerProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Row(
            children: [
              const Gap(10),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.keyboard_backspace),
              ),
              Text(
                'Equalizer',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const Divider(),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              child: ListView(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Equalizer Settings',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: provider.isEqEnabled,
                    onChanged: (value) {
                      if (!(User.instance.user?.isPremium ?? false)) {
                        errorMessage(
                          context,
                          'Set custom EQ, boost bass & access exclusive presets. Upgrade now!',
                          title: 'Unlock Premium Equalizer!',
                        );
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const PremiumScreen(),
                            type: PageTransitionType.fade,
                          ),
                        );
                        return;
                      }
                      if (!playerProvider.isLoaded) {
                        errorMessage(context, 'Please play a song first!');
                        return;
                      }
                      provider.setEqEnabled(value);
                    },
                  ),
                  Gap(20),
                  if (provider.isEqEnabled)
                    if (provider.range.isNotEmpty)
                      BandFreq(
                        min: provider.range[0].toDouble(),
                        max: provider.range[1].toDouble(),
                      )
                    else
                      SizedBox(
                        height: 209,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  Gap(20),
                  if (provider.isEqEnabled)
                    SizedBox(
                      height: 55,
                      child: ListView.separated(
                        itemCount: provider.presets.length + 1,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            String preset = 'Custom';
                            return GestureDetector(
                              onTap: () async {
                                provider.changeMode(preset);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      provider.isThisPreset(preset)
                                          ? context.primary
                                          : context.primary.withValues(
                                            alpha: .1,
                                          ),
                                ),
                                child: Text(
                                  preset,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        provider.isThisPreset(preset)
                                            ? context.scheme.onPrimary
                                            : null,
                                  ),
                                ),
                              ),
                            );
                          }

                          String preset = provider.presets[index - 1];

                          return GestureDetector(
                            onTap: () async {
                              provider.changeMode(preset);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    provider.isThisPreset(preset)
                                        ? context.primary
                                        : context.primary.withValues(alpha: .1),
                              ),
                              child: Text(
                                preset,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      provider.isThisPreset(preset)
                                          ? context.scheme.onPrimary
                                          : null,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Gap(10);
                        },
                      ),
                    ),
                  Gap(30),
                  if (provider.isEqEnabled)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Bass Booster',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 0.0,
                            ),
                            inactiveTrackColor: context.onBgColor.withValues(
                              alpha: .3,
                            ),
                            trackHeight: 15,
                          ),
                          child: Slider(
                            min: 0,
                            max: 1000,
                            value: provider.bassBoost.toDouble(),
                            onChanged: (value) {
                              provider.bassBoost = value.round();
                              setState(() {});
                            },
                            onChangeEnd: (value) {
                              provider.setBassBoost();
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
