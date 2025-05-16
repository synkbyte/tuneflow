// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/signin.dart';
import 'package:new_tuneflow/src/settings/providers/delete_account_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class DeleteAccountField extends StatefulWidget {
  const DeleteAccountField({super.key});

  @override
  State<DeleteAccountField> createState() => _DeleteAccountFieldState();
}

class _DeleteAccountFieldState extends State<DeleteAccountField> {
  TextEditingController controller = TextEditingController();

  bool isLoading = false;

  late DeleteAccountProvider provider;

  requestForAccountDelete() async {
    setState(() => isLoading = true);

    Map response = await provider.requestForDeleteAccount(controller.text);
    setState(() => isLoading = false);
    if (!response['status']) {
      errorMessage(context, response['message']);
      return;
    }
    successMessage(context, response['message']);
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
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<DeleteAccountProvider>(context);

    if (isLoading) {
      return Scaffold(body: LoadingWidget());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Gap(10),
            Text(
              'If you’d like, please share your feedback on how we can make TuneFlow better:',
            ),
            Gap(15),
            TextField(
              maxLines: 5,
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Let us know how we can improve (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Gap(15),
            Text(
              'Note: Your account will be deleted in 1 week. If you change your mind, you can cancel the deletion within this period.',
              style: TextStyle(fontSize: 10, color: context.scheme.error),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 10,
          top: 10,
        ),
        child: PrimaryButton(
          title: 'Delete Account',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Center(
                    child: Text(
                      'You Want to Delete Your Account?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'This action will schedule your account for deletion in 7 days. You can cancel the deletion within this period. Click \'Delete Account\' to proceed or \'Cancel\' to keep your account.',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              requestForAccountDelete();
                            },
                            child: Text(
                              'Delete Account',
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
        ),
      ),
    );
  }
}
