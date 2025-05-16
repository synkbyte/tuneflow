import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/src/support/presentation/screens/support.dart';
import 'package:page_transition/page_transition.dart';

class ContainerTextButton extends StatelessWidget {
  const ContainerTextButton({
    super.key,
    required this.title,
    this.bgColor,
    this.textColor,
    required this.onPressed,
  });
  final String title;
  final Color? bgColor;
  final Color? textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? context.primary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.primary, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor ?? context.scheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 70,
            width: 70,
            alignment: Alignment.center,
            child: Image.asset(Media.google, height: 40),
          ),
        ),
        // const SizedBox(width: 20),
        // InkWell(
        //   onTap: () {},
        //   borderRadius: BorderRadius.circular(10),
        //   child: Container(
        //     height: 70,
        //     width: 70,
        //     alignment: Alignment.center,
        //     child: Image.asset(
        //       Media.apple,
        //       height: 40,
        //       color: context.onBgColor,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class SupportButton extends StatelessWidget {
  const SupportButton({super.key, this.title});
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title ?? 'If You Need Any Support'),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                child: const SupportScreen(),
                type: PageTransitionType.fade,
              ),
            );
          },
          child: const Text(
            'Click here',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
