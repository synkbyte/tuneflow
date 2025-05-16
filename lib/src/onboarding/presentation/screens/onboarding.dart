// import 'package:blurrycontainer/blurrycontainer.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:new_tuneflow/core/common/app/cache_helper.dart';
// import 'package:new_tuneflow/core/common/widget/buttons.dart';
// import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
// import 'package:new_tuneflow/core/res/media.dart';
// import 'package:new_tuneflow/src/auth/presentation/screens/signin_or_signup.dart';
// import 'package:page_transition/page_transition.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.edgeToEdge,
//       overlays: [SystemUiOverlay.top],
//     );

//     return AnnotatedRegion(
//       value: SystemUiOverlayStyle(
//         systemStatusBarContrastEnforced: true,
//         statusBarColor: context.bgColor.withValues(alpha: .002),
//         systemNavigationBarColor: context.bgColor.withValues(alpha: .002),
//         systemNavigationBarDividerColor: context.bgColor.withValues(alpha: .002),
//         statusBarIconBrightness: context.brightness,
//         systemNavigationBarIconBrightness: context.brightness,
//       ),
//       child: Scaffold(
//         body: Stack(
//           children: [
//             Container(
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   fit: BoxFit.cover,
//                   image: AssetImage(Media.onboardingBg),
//                 ),
//               ),
//             ),
//             Container(
//               color: context.bgColor.withValues(alpha: .6),
//             ),
//             BlurryContainer(
//               blur: 10,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Spacer(),
//                     const Center(
//                       child: Text(
//                         'Enjoy Listening To Music',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                         ),
//                       ),
//                     )
//                         .animate()
//                         .slideY(
//                           begin: -.5,
//                           duration: const Duration(milliseconds: 300),
//                         )
//                         .fadeIn(
//                           duration: const Duration(milliseconds: 300),
//                         ),
//                     const Text(
//                       'Stream high-quality music from your favorite artists, albums, and playlists. Collaborate with friends using the ‘Listen Together’ feature, and explore a vast library of songs across genres. Enjoy seamless playback and discover new tracks!” 🎶🌐🎧',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 13,
//                       ),
//                     ).animate().fadeIn(
//                           duration: const Duration(milliseconds: 300),
//                         ),
//                     const SizedBox(height: 20),
//                     PrimaryButton(
//                       title: 'Get Started',
//                       onPressed: () async {
//                         CacheHelper().saveIsNewInstaller(false);
//                         Navigator.push(
//                           context,
//                           PageTransition(
//                             child: const SignInOrSignUpScreen(),
//                             type: PageTransitionType.fade,
//                           ),
//                         );
//                       },
//                     )
//                         .animate()
//                         .slideY(
//                           begin: .5,
//                           duration: const Duration(milliseconds: 300),
//                         )
//                         .fadeIn(
//                           duration: const Duration(milliseconds: 300),
//                         ),
//                     SizedBox(
//                       height: MediaQuery.of(context).padding.bottom + 40,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
