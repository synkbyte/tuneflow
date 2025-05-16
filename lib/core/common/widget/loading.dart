import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: context.scheme.onSurface,
            size: 25,
          ),
        ),
        const Text(
          'Please Wait 😊',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
