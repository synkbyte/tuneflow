import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:new_tuneflow/core/common/providers/dash_provider.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/src/settings/screens/privacy_policy.dart';
import 'package:new_tuneflow/src/settings/screens/term_and_condition.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {},
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {},
    );
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List features = [
    'Equalizer.',
    'Premium Badge.',
    'Advance Room Settings.',
    'Unlock Unlimited Room Creation.',
    'Download Entire Albums & Playlists.',
    'Early Access to Exclusive New Features.',
  ];

  int selectedPlan = 0;

  @override
  Widget build(BuildContext context) {
    final dashProvider = Provider.of<DashProvider>(context);

    if (User.instance.user?.isPremium ?? false) {
      return EdgeToEdge(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Premium Unlocked',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    const Gap(20),
                    Text(
                      User.instance.user!.planName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Till: ${User.instance.user!.planExpireDate}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    Column(
                      children: List.generate(features.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.done, size: 16),
                              const Gap(5),
                              Expanded(
                                child: Text(
                                  features[index],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const Gap(40),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return EdgeToEdge(
      child: Scaffold(
        body: Stack(
          children: [
            if (!dashProvider.isLoading && !dashProvider.gotError)
              ListView(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Gap(10),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        const Gap(10),
                        Column(
                          children: List.generate(features.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.done, size: 16),
                                  const Gap(5),
                                  Expanded(
                                    child: Text(
                                      features[index],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const Gap(40),
                        Column(
                          children: List.generate(
                            dashProvider.products.length,
                            (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() => selectedPlan = index + 1);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedPlan == index + 1
                                            ? context.scheme.primary.withValues(
                                              alpha: .5,
                                            )
                                            : null,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: context.scheme.primary.withValues(
                                        alpha: .5,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dashProvider.products[index].title
                                                  .replaceAll(
                                                    '(TuneFlow : Music & Chat)',
                                                    '',
                                                  ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              dashProvider
                                                  .products[index]
                                                  .description,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        dashProvider.products[index].price,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Gap(10),
                        if (selectedPlan != 0)
                          PrimaryButton(
                            title: 'Unlock My Plan',
                            onPressed: () async {
                              dashProvider.buy(
                                dashProvider.products[selectedPlan - 1],
                              );
                            },
                          ),
                        const Gap(10),
                        if (selectedPlan != 0)
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text:
                                      'Subscriptions auto-renew unless canceled 24 hours before the end of the period. Manage or cancel anytime in Google Play settings. \nBy subscribing, you agree to our ',
                                ),
                                TextSpan(
                                  text: 'Terms.',
                                  style: TextStyle(
                                    color: context.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              child:
                                                  const TermAndConditionScreen(),
                                              type: PageTransitionType.fade,
                                            ),
                                          );
                                        },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: context.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              child:
                                                  const PrivacyPolicyScreen(),
                                              type: PageTransitionType.fade,
                                            ),
                                          );
                                        },
                                ),
                              ],
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            if (dashProvider.isLoading)
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator()),
                  Gap(5),
                  Text(
                    'Please wait...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (!dashProvider.isLoading && dashProvider.gotError)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Somthing went wrong...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: context.scheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
