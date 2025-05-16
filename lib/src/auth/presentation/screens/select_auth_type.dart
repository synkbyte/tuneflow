// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/services/api_service/otp/otp_api_service.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/verify_otp.dart';
import 'package:page_transition/page_transition.dart';

class SelectAuthType extends StatefulWidget {
  const SelectAuthType({super.key, required this.response});
  final Map response;

  @override
  State<SelectAuthType> createState() => _SelectAuthTypeState();
}

class _SelectAuthTypeState extends State<SelectAuthType> {
  final key = GlobalKey<FormState>();
  bool isLoading = false;

  int selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                      const SizedBox(height: 20),
                      const Text(
                        'Choose verification method',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        'We\'ll send you a verification code to reset your password',
                      ),
                      const SizedBox(height: 20),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() => selectedIndex = 0);
                        },
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                selectedIndex == 0
                                    ? Border.all(
                                      width: 1,
                                      color: context.primary,
                                    )
                                    : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Ionicons.logo_whatsapp,
                                color:
                                    selectedIndex == 0 ? context.primary : null,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                maskPhone(widget.response['phone']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() => selectedIndex = 1);
                        },
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                selectedIndex == 1
                                    ? Border.all(
                                      width: 1,
                                      color: context.primary,
                                    )
                                    : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color:
                                    selectedIndex == 1 ? context.primary : null,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                maskEmail(widget.response['email']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
            if (selectedIndex > 1) {
              errorMessage(context, 'Please choose verification method');
              return;
            }
            setState(() => isLoading = true);
            String firstName = getFirstName(widget.response['userName']);
            OtpApiService service = sl();

            Map response = {};
            if (selectedIndex == 0) {
              response = await service.sendOnWhatsapp(
                phoneNumber: widget.response['phone'],
                name: firstName,
              );
            }
            if (selectedIndex == 1) {
              response = await service.sendOnEmail(
                toEmail: widget.response['email'],
                name: firstName,
              );
            }

            if (response.isEmpty) {
              setState(() => isLoading = false);
              return;
            }

            if (!response['status']) {
              errorMessage(context, response['message']);
              setState(() => isLoading = false);
              return;
            }

            Navigator.pushReplacement(
              context,
              PageTransition(
                child: VerifyOtp(
                  response: widget.response,
                  otp: '${response['otp']}',
                  selectedIndex: selectedIndex,
                ),
                type: PageTransitionType.fade,
              ),
            );
          },
          title: 'Next',
          isLoading: isLoading,
        ),
      ),
    );
  }
}
