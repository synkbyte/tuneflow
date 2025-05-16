// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/services/api_service/reset_password/reset_password_api_service.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/select_auth_type.dart';
import 'package:page_transition/page_transition.dart';

class FindUserForReset extends StatefulWidget {
  const FindUserForReset({super.key});

  @override
  State<FindUserForReset> createState() => _FindUserForResetState();
}

class _FindUserForResetState extends State<FindUserForReset> {
  TextEditingController identifier = TextEditingController();
  final key = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Password recovery',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        'Enter your username, email or phone number to recover password.',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: identifier,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username, email or phone number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          hintText: 'Enter username, email or phone number',
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 10,
        ),
        child: PrimaryButton(
          onPressed: () async {
            if (isLoading) return;
            if (key.currentState!.validate()) {
              setState(() => isLoading = true);
              ResetPasswordApiService service = sl();
              Map response = await service.checkUserRegistration(
                identifier.text,
              );
              if (response['status']) {
                setState(() => isLoading = false);
                Navigator.push(
                  context,
                  PageTransition(
                    child: SelectAuthType(response: response),
                    type: PageTransitionType.fade,
                  ),
                );
              } else {
                setState(() => isLoading = false);
                errorMessage(context, response['message']);
              }
            }
          },
          title: 'Next',
          isLoading: isLoading,
        ),
      ),
    );
  }
}
