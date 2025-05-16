import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialCard extends StatelessWidget {
  const SocialCard({
    super.key,
    required this.title,
    required this.des,
    required this.url,
  });
  final String title;
  final String des;
  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchUrl(Uri.parse(url));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              context.scheme.primary.withValues(alpha: .3),
              context.scheme.onPrimary.withValues(alpha: .3),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: context.onBgColor,
              ),
            ),
            Text(des, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
