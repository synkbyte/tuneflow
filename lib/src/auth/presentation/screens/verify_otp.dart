// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/services/api_service/otp/otp_api_service.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/set_password.dart';
import 'package:page_transition/page_transition.dart';

class VerifyOtp extends StatefulWidget {
  const VerifyOtp({
    super.key,
    required this.response,
    required this.otp,
    required this.selectedIndex,
  });
  final Map response;
  final String otp;
  final int selectedIndex;

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  String otp = '';
  String serverOtp = '';
  bool isLoading = false;

  int minutes = 1;
  int seconds = 59;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    serverOtp = widget.otp;
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (minutes > 0 || seconds > 0) {
          if (seconds == 0) {
            minutes--;
            seconds = 59;
          } else {
            seconds--;
          }
        } else {
          timer.cancel();
        }
      });
    });
  }

  updateOtp(String value) {
    if (otp.length == 6) {
      return;
    }
    otp = '$otp$value';
    setState(() {});
    if (otp.length == 6) {
      setState(() {
        isLoading = true;
      });
      verifyOtp();
    }
  }

  verifyOtp() async {
    if (otp == widget.otp) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: SetPassword(response: widget.response),
          type: PageTransitionType.fade,
        ),
      );
    } else {
      errorMessage(context, 'Incorrect OTP.');
      otp = '';
      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  removeOtp() {
    List<String> words = otp.split('');
    if (words.isNotEmpty) {
      words.removeLast();
      otp = words.join('');
      setState(() {});
    } else {
      return;
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'OTP Verification',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'We have sent an OTP to the',
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.selectedIndex == 0
                                    ? 'whatsapp '
                                    : 'email ',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                widget.selectedIndex == 0
                                    ? maskPhone(widget.response['phone'])
                                    : maskEmail(widget.response['email']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    OTPWidget(otp: otp.isNotEmpty ? otp[0] : ''),
                    const SizedBox(width: 20),
                    OTPWidget(otp: otp.length >= 2 ? otp[1] : ''),
                    const SizedBox(width: 20),
                    OTPWidget(otp: otp.length >= 3 ? otp[2] : ''),
                    const SizedBox(width: 20),
                    OTPWidget(otp: otp.length >= 4 ? otp[3] : ''),
                    const SizedBox(width: 20),
                    OTPWidget(otp: otp.length >= 5 ? otp[4] : ''),
                    const SizedBox(width: 20),
                    OTPWidget(otp: otp.length >= 6 ? otp[5] : ''),
                  ],
                ),
                const SizedBox(height: 30),
                if (minutes == 0 && seconds == 0)
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        if (isLoading) return;
                        if (widget.selectedIndex > 1) {
                          errorMessage(
                            context,
                            'Please choose verification method',
                          );
                          return;
                        }
                        setState(() => isLoading = true);
                        String firstName = getFirstName(
                          widget.response['userName'],
                        );
                        OtpApiService service = sl();

                        Map response = {};
                        if (widget.selectedIndex == 0) {
                          response = await service.sendOnWhatsapp(
                            phoneNumber: widget.response['phone'],
                            name: firstName,
                          );
                        }
                        if (widget.selectedIndex == 1) {
                          response = await service.sendOnEmail(
                            toEmail: widget.response['email'],
                            name: firstName,
                          );
                        }

                        isLoading = false;
                        if (response.isEmpty) {
                          return;
                        }
                        if (!response['status']) {
                          errorMessage(context, response['message']);
                          return;
                        }
                        otp = '';
                        serverOtp = '${response['otp']}';
                        setState(() {});
                      },
                      child: const Text(
                        'Resend',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: context.scheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 10),
                      Text(formattedTime),
                    ],
                  ),
                const SizedBox(height: 20),
                const Spacer(),
                Row(
                  children: [
                    NumPaid(
                      text: '1',
                      onTap: () {
                        updateOtp('1');
                      },
                    ),
                    NumPaid(
                      text: '2',
                      onTap: () {
                        updateOtp('2');
                      },
                    ),
                    NumPaid(
                      text: '3',
                      onTap: () {
                        updateOtp('3');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    NumPaid(
                      text: '4',
                      onTap: () {
                        updateOtp('4');
                      },
                    ),
                    NumPaid(
                      text: '5',
                      onTap: () {
                        updateOtp('5');
                      },
                    ),
                    NumPaid(
                      text: '6',
                      onTap: () {
                        updateOtp('6');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    NumPaid(
                      text: '7',
                      onTap: () {
                        updateOtp('7');
                      },
                    ),
                    NumPaid(
                      text: '8',
                      onTap: () {
                        updateOtp('8');
                      },
                    ),
                    NumPaid(
                      text: '9',
                      onTap: () {
                        updateOtp('9');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    NumPaid(
                      text: '0',
                      onTap: () {
                        updateOtp('0');
                      },
                    ),
                    NumPaid(
                      text: '0',
                      onTap: () {
                        removeOtp();
                      },
                      isBackSpace: true,
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
          if (isLoading)
            Container(
              alignment: Alignment.center,
              color: context.scheme.outline.withValues(alpha: .5),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.scheme.primary.withValues(alpha: .7),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(blurRadius: 100, color: context.scheme.primary),
                  ],
                ),
                child: CircularProgressIndicator(
                  color: context.scheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NumPaid extends StatelessWidget {
  const NumPaid({
    super.key,
    required this.text,
    required this.onTap,
    this.isBackSpace = false,
  });
  final String text;
  final Function onTap;
  final bool isBackSpace;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            await onTap();
          },
          child: Container(
            height: 100,
            alignment: Alignment.center,
            child:
                isBackSpace
                    ? const Icon(Icons.backspace)
                    : Text(
                      text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

class OTPWidget extends StatelessWidget {
  const OTPWidget({super.key, required this.otp});
  final String otp;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            otp,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: context.scheme.primary,
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: context.scheme.primary,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
