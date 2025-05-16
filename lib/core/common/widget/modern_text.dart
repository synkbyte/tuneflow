import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class ModernText extends StatelessWidget {
  const ModernText({
    super.key,
    required this.isActive,
    required this.text,
    this.onPressed,
  });
  final bool isActive;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: text.split('-').first,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isActive ? 14 : 12,
              ),
            ),
            TextSpan(
              text: text.split('-').last,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isActive ? 14 : 12,
                color: isActive ? context.scheme.primary : null,
                decoration: isActive ? TextDecoration.underline : null,
                decorationColor: context.scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
