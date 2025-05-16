import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class ContentPolicyScreen extends StatefulWidget {
  const ContentPolicyScreen({super.key});

  @override
  State<ContentPolicyScreen> createState() => _ContentPolicyScreenState();
}

class _ContentPolicyScreenState extends State<ContentPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return EdgeToEdge(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Content Policy',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              Text(
                '$appName is committed to providing a safe and respectful platform for users. This Content Policy outlines acceptable use of our app.',
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
                '1. Content Ownership and Sources',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                '$appName provides music and other media content from third-party providers via API integrations. We do not claim ownership of or control over the content provided by these services.',
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
                '2. Acceptable Use',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'While using $appName, users must respect third-party content rights and adhere to any terms imposed by the content providers.',
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
                'Users may not:',
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
                  '• Reproduce, distribute, or misuse third-party content in ways that violate third-party rights.',
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
                  '• Use $appName in a way that violates the rights of others or breaches the terms set by our content providers.',
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
                  '• Engage in activities that disrupt or degrade the service quality for other users.',
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
                '4. Reporting Violations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'If you notice any violations or issues with third-party content, please report it using our in-app features or contact us at $appName.',
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
                '5. Consequences for Policy Violations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.primary,
                ),
              ),
              const Gap(5),
              Text(
                'Users found violating this Content Policy may be subject to content removal, suspension, or other corrective actions.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.onBgColor.withValues(alpha: .8),
                  wordSpacing: 3,
                  letterSpacing: 3,
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
