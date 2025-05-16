import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class MessageStatusWidget extends StatelessWidget {
  const MessageStatusWidget({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'sending') {
      return Icon(
        Ionicons.time_outline,
        size: 12.5,
        color: context.onBgColor.withValues(alpha: .8),
      );
    }

    if (status == 'sent') {
      return Icon(
        Ionicons.checkmark,
        size: 12.5,
        color: context.onBgColor.withValues(alpha: .8),
      );
    }

    if (status == 'delivered') {
      return Icon(
        Ionicons.checkmark_done,
        size: 12.5,
        color: context.onBgColor.withValues(alpha: .8),
      );
    }

    return Icon(Ionicons.checkmark_done, size: 12.5, color: context.primary);
  }
}
