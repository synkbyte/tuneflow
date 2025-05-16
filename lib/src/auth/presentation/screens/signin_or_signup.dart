// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/helpers/google_login.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/main.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:new_tuneflow/src/auth/domain/usecase/signup_usecase.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/select_language.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/signin.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/signup.dart';
import 'package:new_tuneflow/src/auth/presentation/widget/button.dart';
import 'package:new_tuneflow/src/home/presentation/screens/home.dart';
import 'package:new_tuneflow/src/settings/providers/delete_account_provider.dart';
import 'package:new_tuneflow/src/settings/screens/content_policy.dart';
import 'package:new_tuneflow/src/settings/screens/privacy_policy.dart';
import 'package:new_tuneflow/src/settings/screens/term_and_condition.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SignInOrSignUpScreen extends StatefulWidget {
  const SignInOrSignUpScreen({super.key});

  @override
  State<SignInOrSignUpScreen> createState() => _SignInOrSignUpScreenState();
}

class _SignInOrSignUpScreenState extends State<SignInOrSignUpScreen> {
  bool isGoogleLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );

    return Stack(
      children: [
        Scaffold(
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 50),
                const Text(
                  appName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
                const Spacer(),
                const Text(
                  'Musical Journeys Await',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Text(
                  'Discover a symphony of possibilities—your favorite tunes, just a tap away. 🎵🔓',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
                const Gap(20),
                ContainerTextButton(
                  title: 'Register',
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: const SignupScreen(),
                        type: PageTransitionType.fade,
                      ),
                    );
                  },
                ),
                const Gap(15),
                ContainerTextButton(
                  title: 'Sign In',
                  bgColor: Colors.transparent,
                  textColor: context.onBgColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: const SigninScreen(),
                        type: PageTransitionType.fade,
                      ),
                    );
                  },
                ),
                const Gap(50),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: context.onBgColor.withValues(alpha: .5),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text('Or'),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: context.onBgColor.withValues(alpha: .5),
                      ),
                    ),
                  ],
                ),
                const Gap(50),
                Container(
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        setState(() => isGoogleLoading = true);
                        UserCredential? userCredential =
                            await signInWithGoogle();
                        if (userCredential == null ||
                            userCredential.user == null) {
                          setState(() => isGoogleLoading = false);
                          errorMessage(context, 'Failed');
                          return;
                        }
                        SignupUseCase useCase = sl();
                        DataState state = await useCase.googleLogin(
                          userCredential.user!.displayName!,
                          userCredential.user!.email!,
                        );
                        if (state is DataError) {
                          setState(() => isGoogleLoading = false);
                          errorMessage(context, 'Failed');
                          return;
                        }
                        SignupEntity entity = state.data;

                        if (entity.isDeleted != null) {
                          setState(() => isGoogleLoading = false);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  "Account Deletion Scheduled",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Your account has been scheduled for deletion on ${DateFormat('dd MMM, yyyy').format(DateTime.parse(entity.isDeleted!['deletionTime']))}. "
                                      "You can cancel the deletion before this date.\n"
                                      "Do you want to cancel the deletion or continue?",
                                    ),
                                    Gap(10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: PrimaryButton(
                                            height: 45,
                                            fontSize: 13,
                                            title: 'Cancel',
                                            onPressed: () async {
                                              successMessage(
                                                context,
                                                'Please wait...',
                                              );
                                              Navigator.pop(context);
                                              Map res = await navigatorKey
                                                  .currentContext!
                                                  .read<DeleteAccountProvider>()
                                                  .cancelDeleteAccount(
                                                    entity.id,
                                                  );
                                              if (!res['status']) {
                                                errorMessage(
                                                  navigatorKey.currentContext!,
                                                  res['message'],
                                                );
                                              } else {
                                                successMessage(
                                                  navigatorKey.currentContext!,
                                                  res['message'],
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: PrimaryButton(
                                            height: 45,
                                            fontSize: 13,
                                            title: 'Keep',
                                            color: context.scheme.error,
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          return;
                        }

                        await CacheHelper().saveUserId(entity.id);
                        if (entity.message == 'true') {
                          setState(() => isGoogleLoading = false);
                          successMessage(context, 'Signup Successfully');
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageTransition(
                              child: const SelectLanguageScreen(),
                              type: PageTransitionType.fade,
                            ),
                            (route) => false,
                          );
                        } else {
                          await userProvider.initializeUser();
                          setState(() => isGoogleLoading = false);
                          successMessage(context, 'Login Successfully');
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageTransition(
                              child: const HomeScreen(),
                              type: PageTransitionType.fade,
                            ),
                            (route) => false,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(Media.google, height: 25),
                            const Gap(10),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.onBgColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Center(child: Text('by continuing, you agree to our')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const TermAndConditionScreen(),
                            type: PageTransitionType.fade,
                          ),
                        );
                      },
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: context.onBgColor,
                          decorationThickness: 2,
                          decorationColor: context.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const PrivacyPolicyScreen(),
                            type: PageTransitionType.fade,
                          ),
                        );
                      },
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: context.onBgColor,
                          decorationThickness: 2,
                          decorationColor: context.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const ContentPolicyScreen(),
                            type: PageTransitionType.fade,
                          ),
                        );
                      },
                      child: Text(
                        'Content Policy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: context.onBgColor,
                          decorationThickness: 2,
                          decorationColor: context.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(MediaQuery.of(context).padding.bottom + 50),
              ],
            ),
          ),
        ),
        if (isGoogleLoading)
          Scaffold(
            backgroundColor: context.scheme.primaryContainer.withValues(
              alpha: .8,
            ),
            body: Center(
              child: CircularProgressIndicator(
                color: context.scheme.onPrimaryContainer,
              ),
            ),
          ),
      ],
    );
  }
}
