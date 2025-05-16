// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/helpers/google_login.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/main.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:new_tuneflow/src/auth/domain/usecase/signup_usecase.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/select_language.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/signin.dart';
import 'package:new_tuneflow/src/auth/presentation/widget/button.dart';
import 'package:new_tuneflow/src/home/presentation/screens/home.dart';
import 'package:new_tuneflow/src/settings/providers/delete_account_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool obscureText = true;
  final key = GlobalKey<FormState>();
  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 10),
              const CircleBackButton(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: key,
                        child: Column(
                          children: [
                            const Text(
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            const SupportButton(),
                            const SizedBox(height: 40),
                            TextFormField(
                              controller: name,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                if (value.trim().isEmpty) {
                                  return 'Name cannot be only whitespace';
                                }
                                if (value.length < 4) {
                                  return 'Please enter valid full name';
                                }
                                RegExp nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
                                if (!nameRegExp.hasMatch(value)) {
                                  return 'Name can only contain letters and spaces';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: phone,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                final phoneRegex = RegExp(r'^\+?1?\d{9,15}$');
                                if (!phoneRegex.hasMatch(value)) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                final emailRegex = RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: password,
                              obscureText: obscureText,
                              decoration: InputDecoration(
                                labelText: 'Pick a strong password',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscureText = !obscureText;
                                    });
                                  },
                                  icon: Icon(
                                    obscureText
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters long';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            PrimaryButton(
                              title: 'Create Account',
                              isLoading: isLoading,
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (key.currentState!.validate()) {
                                  setState(() => isLoading = true);
                                  SignupUseCase useCase = sl();
                                  DataState state = await useCase.call(
                                    name: name.text,
                                    phone: phone.text,
                                    email: email.text,
                                    password: password.text,
                                  );

                                  bool hasAnyError = hasAnyErrors(state);
                                  if (hasAnyError) {
                                    return;
                                  }

                                  SignupEntity entity = state.data;
                                  await CacheHelper().saveUserId(entity.id);
                                  await userProvider.initializeUser();
                                  navigateUser(entity);
                                }
                              },
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: context.onBgColor.withValues(
                                      alpha: .5,
                                    ),
                                  ),
                                ),
                                const Text('   Or   '),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: context.onBgColor.withValues(
                                      alpha: .5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SocialLogin(
                              onTap: () async {
                                setState(() => isGoogleLoading = true);
                                UserCredential? userCredential =
                                    await signInWithGoogle();
                                if (userCredential == null ||
                                    userCredential.user == null) {
                                  setState(() {
                                    isGoogleLoading = false;
                                  });
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
                                                      Map
                                                      res = await navigatorKey
                                                          .currentContext!
                                                          .read<
                                                            DeleteAccountProvider
                                                          >()
                                                          .cancelDeleteAccount(
                                                            entity.id,
                                                          );
                                                      if (!res['status']) {
                                                        errorMessage(
                                                          navigatorKey
                                                              .currentContext!,
                                                          res['message'],
                                                        );
                                                      } else {
                                                        successMessage(
                                                          navigatorKey
                                                              .currentContext!,
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
                                  successMessage(
                                    context,
                                    'Signup Successfully',
                                  );
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
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Do you have an Account?'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                        child: const SigninScreen(),
                                        type: PageTransitionType.fade,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

  bool hasAnyErrors(DataState state) {
    if (state is DataError) {
      errorMessage(context, state.error!);
      setState(() => isLoading = false);
      return true;
    }

    SignupEntity entity = state.data;
    if (!entity.status) {
      errorMessage(context, entity.message);
      setState(() => isLoading = false);
      return true;
    }

    return false;
  }

  navigateUser(SignupEntity entity) {
    setState(() => isLoading = false);
    successMessage(context, 'Signup Successfully');
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        child: const SelectLanguageScreen(),
        type: PageTransitionType.fade,
      ),
      (route) => false,
    );
  }
}
