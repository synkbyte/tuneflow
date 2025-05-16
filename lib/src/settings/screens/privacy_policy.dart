import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return EdgeToEdge(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              Text(
                '$appName values your privacy and is committed to protecting your personal information. This Privacy Policy outlines how we collect, use, and protect your data.',
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
                '1. Information Collection',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '• Personal Information: '),
                      TextSpan(
                        text:
                            'We may collect personal data, such as name, email address, and phone number, provided by users during registration or usage of the app.',
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '• Usage Data: '),
                      TextSpan(
                        text:
                            'We collect data about your interactions with our app, such as device information, and app usage metrics, for improving user experience.',
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: '• Cookies and Tracking Technologies: ',
                      ),
                      TextSpan(
                        text:
                            'We may use cookies to store information about user preferences and track activity within the app.',
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Gap(15),
              Text(
                '2. Use of Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '• Service Provision: '),
                      TextSpan(
                        text:
                            'We use collected data to provide and improve our services.',
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '• Communication: '),
                      TextSpan(
                        text:
                            'We may use your contact information to send updates, respond to inquiries, or notify you about changes in our services.',
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '• Analytics: '),
                      TextSpan(
                        text:
                            'We analyze app usage patterns to improve our services and make data-driven decisions.',
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Gap(15),
              Text(
                '3. Data Sharing',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'We do not sell or share your personal information with third parties except as necessary to provide our services or comply with legal obligations.',
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
                '4. Data Security',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'We take appropriate measures to protect your data from unauthorized access, alteration, or destruction. However, no system is completely secure, and we cannot guarantee absolute security.',
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
                '5. User Rights',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'You may access, update, or delete your personal data by contacting us. Additionally, you have the right to opt out of marketing communications.',
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
                '6. Changes to This Privacy Policy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'We may update our Privacy Policy periodically. Users will be notified of significant changes via email or an in-app notification.',
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
                '7. Third-Party Content and Services',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'Our app, $appName, provides music and other media content through third-party services. We do not control or assume responsibility for the content provided by these third-party providers. These providers may have their own privacy policies, which we encourage you to review.',
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
                          'If you have any questions regarding this Privacy Policy, please contact us at $emailAddress.',
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
