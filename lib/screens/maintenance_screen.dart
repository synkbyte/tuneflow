import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/providers/state_provider.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/src/support/presentation/screens/support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StateProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.faultRes['title'] ?? 'We\'re Under Maintenance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              provider.faultRes['message'] ??
                  'This system is undergoing scheduled maintenance. Please check back soon.',
              textAlign: TextAlign.center,
            ),
            Gap(20),
            PrimaryButton(
              title: provider.faultRes['btnTitle'] ?? 'Close',
              onPressed: () {
                if (provider.faultRes['url'] != null) {
                  launchUrl(Uri.parse(provider.faultRes['url']));
                  return;
                }
                exit(0);
              },
            ),
            if (provider.faultRes['showSupport'] ?? true)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: SupportScreen(),
                      type: PageTransitionType.fade,
                    ),
                  );
                },
                child: Text(
                  'Contact Support',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
