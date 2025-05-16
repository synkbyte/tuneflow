import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/premium.dart';
import 'package:page_transition/page_transition.dart';

class PremiumCardsMini extends StatelessWidget {
  const PremiumCardsMini({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            child: const PremiumScreen(),
            type: PageTransitionType.fade,
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.primary,
                context.scheme.secondary.withValues(alpha: .3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.star, color: context.scheme.onPrimary, size: 32),
              Gap(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Upgrade to Premium 🚀",
                      style: TextStyle(
                        color: context.scheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Unlimited Room Credits to Host!",
                      style: TextStyle(
                        fontSize: 9,
                        color: context.scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "No Ads • HD Audio • Offline Mode.",
                      style: TextStyle(
                        fontSize: 9,
                        color: context.scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            child: const PremiumScreen(),
            type: PageTransitionType.fade,
          ),
        );
      },
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.primary, context.scheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: context.scheme.onPrimary, size: 26),
                SizedBox(width: 8),
                Text(
                  "Unlock Premium Experience!",
                  style: TextStyle(
                    color: context.scheme.onPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              "🎵 Ad-free music  •  🎧 High-quality streaming  •  🚀 Exclusive features",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: context.scheme.onPrimary,
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.bgColor,
              ),
              alignment: Alignment.center,
              child: Text(
                'Get Premium',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
