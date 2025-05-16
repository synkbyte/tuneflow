import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.title,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.fontSize,
    this.height,
  });
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final double? fontSize;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? context.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: height ?? 60,
            alignment: Alignment.center,
            child:
                isLoading
                    ? CircularProgressIndicator(color: context.scheme.onPrimary)
                    : Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize ?? 17,
                        color: context.scheme.onPrimary,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.onBgColor.withValues(alpha: .5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: SizedBox(
            height: 40,
            width: 40,
            child: BackButton(color: context.bgColor),
          ),
        ),
      ),
    );
  }
}

class CircleBookmark extends StatelessWidget {
  const CircleBookmark({
    super.key,
    required this.isActive,
    required this.onTap,
    this.icon,
  });
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.onBgColor.withValues(alpha: .5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: SizedBox(
            height: 40,
            width: 40,
            child:
                isActive
                    ? Icon(icon ?? Icons.bookmark_added, color: context.bgColor)
                    : Icon(
                      icon ?? Icons.bookmark_add_outlined,
                      color: context.bgColor,
                    ),
          ),
        ),
      ),
    );
  }
}
