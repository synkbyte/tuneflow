import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/user_provider.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/select_language.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/signin.dart';
import 'package:new_tuneflow/src/equalizer/presentation/screens/equalizer_screen.dart';
import 'package:new_tuneflow/src/settings/screens/about.dart';
import 'package:new_tuneflow/src/settings/screens/content_policy.dart';
import 'package:new_tuneflow/src/settings/delete_account/delete_account.dart';
import 'package:new_tuneflow/src/settings/screens/faq.dart';
import 'package:new_tuneflow/src/settings/screens/privacy_policy.dart';
import 'package:new_tuneflow/src/settings/screens/term_and_condition.dart';
import 'package:new_tuneflow/src/support/presentation/screens/support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    Provider.of<PlayerProvider>(context);

    return EdgeToEdge(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: SelectLanguageScreen(
                      isNewUser: false,
                      languageList: userProvider.languages,
                    ),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Music Language',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userProvider.languagesString,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 20),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Center(
                        child: Text(
                          'Music Quality',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading:
                                  Cache.instance.defaultMusicQuality ==
                                          'Excellent'
                                      ? Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: context.primary,
                                            width: 1,
                                          ),
                                          color: context.primary.withValues(
                                            alpha: .4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.done,
                                          size: 15,
                                          color: context.scheme.primary,
                                        ),
                                      )
                                      : const SizedBox(height: 20, width: 20),
                              title: const Text(
                                'Excellent',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                CacheHelper().saveDefaultMusicQuality(
                                  'Excellent',
                                );
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading:
                                  Cache.instance.defaultMusicQuality == 'Good'
                                      ? Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: context.primary,
                                            width: 1,
                                          ),
                                          color: context.primary.withValues(
                                            alpha: .4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.done,
                                          size: 15,
                                          color: context.scheme.primary,
                                        ),
                                      )
                                      : const SizedBox(height: 20, width: 20),
                              title: const Text(
                                'Good',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                CacheHelper().saveDefaultMusicQuality('Good');
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading:
                                  Cache.instance.defaultMusicQuality ==
                                          'Regular'
                                      ? Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: context.primary,
                                            width: 1,
                                          ),
                                          color: context.primary.withValues(
                                            alpha: .4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.done,
                                          size: 15,
                                          color: context.scheme.primary,
                                        ),
                                      )
                                      : const SizedBox(height: 20, width: 20),
                              title: const Text(
                                'Regular',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                CacheHelper().saveDefaultMusicQuality(
                                  'Regular',
                                );
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Default Music Quality',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            Cache.instance.defaultMusicQuality ?? 'Excellent',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 20),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Center(
                        child: Text(
                          'Download Quality',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading:
                                  Cache.instance.defaultDownloadQuality ==
                                          'Excellent'
                                      ? Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: context.primary,
                                            width: 1,
                                          ),
                                          color: context.primary.withValues(
                                            alpha: .4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.done,
                                          size: 15,
                                          color: context.scheme.primary,
                                        ),
                                      )
                                      : const SizedBox(height: 20, width: 20),
                              title: const Text(
                                'Excellent',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                CacheHelper().saveDefaultDownloadQuality(
                                  'Excellent',
                                );
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading:
                                  Cache.instance.defaultDownloadQuality ==
                                          'Good'
                                      ? Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: context.primary,
                                            width: 1,
                                          ),
                                          color: context.primary.withValues(
                                            alpha: .4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.done,
                                          size: 15,
                                          color: context.scheme.primary,
                                        ),
                                      )
                                      : const SizedBox(height: 20, width: 20),
                              title: const Text(
                                'Good',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                CacheHelper().saveDefaultDownloadQuality(
                                  'Good',
                                );
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading:
                                  Cache.instance.defaultDownloadQuality ==
                                          'Regular'
                                      ? Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: context.primary,
                                            width: 1,
                                          ),
                                          color: context.primary.withValues(
                                            alpha: .4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.done,
                                          size: 15,
                                          color: context.scheme.primary,
                                        ),
                                      )
                                      : const SizedBox(height: 20, width: 20),
                              title: const Text(
                                'Regular',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                CacheHelper().saveDefaultDownloadQuality(
                                  'Regular',
                                );
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Download Quality',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            Cache.instance.defaultDownloadQuality!,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 20),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                Navigator.push(
                  context,
                  PageTransition(
                    child: EqualizerScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Equalizer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(Ionicons.pulse_outline, size: 20),
                  ],
                ),
              ),
            ),

            // InkWell(
            //   onTap: () async {
            //     Navigator.push(
            //       context,
            //       PageTransition(
            //         child: const NotificationSettings(),
            //         type: PageTransitionType.fade,
            //       ),
            //     );
            //   },
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 20,
            //       vertical: 15,
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text(
            //           'Notifications',
            //           style: TextStyle(fontWeight: FontWeight.bold),
            //         ),
            //         svg.SvgPicture.asset(
            //           Media.notificationSettings,
            //           height: 24,
            //           width: 24,
            //           colorFilter: ColorFilter.mode(
            //             context.onBgColor,
            //             BlendMode.srcIn,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const Divider(),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Center(
                        child: Text(
                          'Theme Mode',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading:
                                Hive.box('app').get('themeMode') == 'Light'
                                    ? Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: context.primary,
                                          width: 1,
                                        ),
                                        color: context.primary.withValues(
                                          alpha: .4,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.done,
                                        size: 15,
                                        color: context.scheme.primary,
                                      ),
                                    )
                                    : const SizedBox(height: 20, width: 20),
                            title: const Text(
                              'Light',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              Hive.box('app').put('themeMode', 'Light');
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading:
                                Hive.box('app').get('themeMode') == 'Dark'
                                    ? Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: context.primary,
                                          width: 1,
                                        ),
                                        color: context.primary.withValues(
                                          alpha: .4,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.done,
                                        size: 15,
                                        color: context.scheme.primary,
                                      ),
                                    )
                                    : const SizedBox(height: 20, width: 20),
                            title: const Text(
                              'Dark',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              Hive.box('app').put('themeMode', 'Dark');
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading:
                                Hive.box('app').get('themeMode') ==
                                            'System Default' ||
                                        Hive.box('app').get('themeMode') == null
                                    ? Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: context.primary,
                                          width: 1,
                                        ),
                                        color: context.primary.withValues(
                                          alpha: .4,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.done,
                                        size: 15,
                                        color: context.scheme.primary,
                                      ),
                                    )
                                    : const SizedBox(height: 20, width: 20),
                            title: const Text(
                              'System Default',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              Hive.box(
                                'app',
                              ).put('themeMode', 'System Default');
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Theme',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            Hive.box('app').get('themeMode') ??
                                'System Default',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 20),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await launchUrl(Uri.parse(igLink));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Follow us',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(Ionicons.logo_instagram, size: 20),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const FaqScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: const Text(
                  'FAQ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const AboutTuneFlow(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: const Text(
                  'About us',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const SupportScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: const Text(
                  'Contact us',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const PrivacyPolicyScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const ContentPolicyScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: const Text(
                  'Content Policy',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const TermAndConditionScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: const Text(
                  'Terms & Conditions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Center(
                        child: Text(
                          'Are You Sure You Want to Log Out?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'This action will sign you out of your current session. Click \'Logout\' to proceed or \'Cancel\' to return to your session.',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  audioHandler.stop();
                                  CacheHelper().resetSession();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    PageTransition(
                                      child: const SigninScreen(),
                                      type: PageTransitionType.fade,
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: context.scheme.error,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.scheme.error,
                      ),
                    ),
                    Icon(Ionicons.log_out_outline, color: context.scheme.error),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const DeleteAccountScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delete Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.scheme.error,
                      ),
                    ),
                    Icon(
                      Icons.delete_forever_outlined,
                      color: context.scheme.error,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            const Center(
              child: Text(
                'Version: $appVersion',
                style: TextStyle(fontSize: 10),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
