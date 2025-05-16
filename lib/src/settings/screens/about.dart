import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/constants/constants.dart';

class AboutTuneFlow extends StatefulWidget {
  const AboutTuneFlow({super.key});

  @override
  State<AboutTuneFlow> createState() => _AboutTuneFlowState();
}

class _AboutTuneFlowState extends State<AboutTuneFlow> {
  @override
  Widget build(BuildContext context) {
    ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About $appName',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Text(
              'What is $appName?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: scheme.primary,
              ),
            ),
            const Text(
              '$appName is an advanced music player application designed to deliver an unparalleled music streaming experience. It offers a vast collection of songs in multiple languages, empowering users to discover and enjoy their favorite music effortlessly.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Our Mission',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: scheme.primary,
              ),
            ),
            const Text(
              'At $appName our mission is to redefine how people experience music. We aim to provide a seamless platform where users can access an extensive catalog of songs, create personalized playlists, and enjoy high-quality audio streaming anytime, anywhere.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Key Features',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: scheme.primary,
              ),
            ),
            ListView.separated(
              itemCount: aboutUsContent.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: index == 4 || index == 5
                            ? scheme.error
                            : scheme.secondary,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        aboutUsContent[index],
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 10,
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Contact Us',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: scheme.primary,
              ),
            ),
            const Text(
              'We value your feedback and strive to provide the best possible experience for our users. If you have any questions, suggestions, or concerns, please don\'t hesitate to reach out to our customer support team through the app\'s settings menu. Your input is invaluable as we continue to improve and enhance the $appName experience.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
