import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class TermAndConditionScreen extends StatefulWidget {
  const TermAndConditionScreen({super.key});

  @override
  State<TermAndConditionScreen> createState() => _TermAndConditionScreenState();
}

class _TermAndConditionScreenState extends State<TermAndConditionScreen> {
  @override
  Widget build(BuildContext context) {
    return EdgeToEdge(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Terms & Conditions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              Text(
                'By using $appName, you agree to the following Terms and Conditions. Please read them carefully.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.onBgColor.withValues(alpha: .9),
                  wordSpacing: 3,
                  letterSpacing: 3,
                ),
              ),
              const Gap(20),
              Text(
                '1. Acceptance of Terms',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'Your use of $appName indicates acceptance of these terms. If you disagree with any part, please refrain from using the app.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.onBgColor.withValues(alpha: .8),
                  wordSpacing: 3,
                  letterSpacing: 3,
                ),
              ),
              const Gap(15),
              Text(
                '2. Account Responsibilities',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'You are responsible for maintaining the confidentiality of your account and password and restricting access to your device.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.onBgColor.withValues(alpha: .8),
                  wordSpacing: 3,
                  letterSpacing: 3,
                ),
              ),
              const Gap(15),
              Text(
                '3. Prohibited Conduct',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'You agree not to misuse our app, including but not limited to:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.onBgColor.withValues(alpha: .8),
                  wordSpacing: 3,
                  letterSpacing: 3,
                ),
              ),
              const Gap(5),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  '• Posting illegal or harmful content.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.onBgColor.withValues(alpha: .9),
                    wordSpacing: 3,
                    letterSpacing: 3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  '• Attempting to breach the app’s security or functionality.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.onBgColor.withValues(alpha: .9),
                    wordSpacing: 3,
                    letterSpacing: 3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  '• Harassing other users or violating their rights.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.onBgColor.withValues(alpha: .9),
                    wordSpacing: 3,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const Gap(15),
              Text(
                '4. Intellectual Property',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'While $appName owns the app’s design and code, all media content is owned by third-party providers. Users must comply with any restrictions set by these providers.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.onBgColor.withValues(alpha: .8),
                  wordSpacing: 3,
                  letterSpacing: 3,
                ),
              ),
              const Gap(15),
              Text(
                '5. Limitation of Liability',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                '$appName is not liable for any damages arising from the use of third-party content or from service interruptions caused by content providers.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.onBgColor.withValues(alpha: .8),
                  wordSpacing: 3,
                  letterSpacing: 3,
                ),
              ),
              const Gap(15),
              Text(
                '6. Third-Party Content',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                '$appName sources content (e.g., music) through third-party API services. We do not claim ownership of the content provided and do not control its availability, accuracy, or legality. $appName is not liable for any issues related to the use of this content, and you agree to use third-party content solely at your own risk.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.onBgColor.withValues(alpha: .8),
                  wordSpacing: 3,
                  letterSpacing: 3,
                ),
              ),
              const Gap(15),
              Text(
                '7. Changes to Terms',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'We may update these Terms periodically. Continued use of the app implies acceptance of the revised terms.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.onBgColor.withValues(alpha: .8),
                  wordSpacing: 3,
                  letterSpacing: 3,
                ),
              ),
              const Gap(15),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Contact Us: '),
                    TextSpan(
                      text:
                          'If you have any questions about these Terms, please contact us at $emailAddress.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.onBgColor.withValues(alpha: .8),
                        wordSpacing: 3,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(35),
            ],
          ),
        ),
      ),
    );
  }
}
