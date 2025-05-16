import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tuneflow/core/common/providers/state_provider.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:provider/provider.dart';

class EdgeToEdge extends StatefulWidget {
  const EdgeToEdge({super.key, required this.child, this.value});
  final Widget child;
  final SystemUiOverlayStyle? value;

  @override
  State<EdgeToEdge> createState() => _EdgeToEdgeState();
}

class _EdgeToEdgeState extends State<EdgeToEdge> {
  @override
  Widget build(BuildContext context) {
    int sdkInt = Provider.of<StateProvider>(context).sdkInt;

    if (sdkInt > 34) {
      return AnnotatedRegion(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: context.scheme.surface,
          systemNavigationBarDividerColor: context.scheme.surface,
        ),
        child: widget.child,
      );
    }

    return AnnotatedRegion(
      value:
          widget.value ??
          SystemUiOverlayStyle(
            statusBarColor: context.scheme.surface,
            systemNavigationBarColor: context.scheme.surface,
            systemNavigationBarDividerColor: context.scheme.surface,
          ),
      child: widget.child,
    );
  }
}
