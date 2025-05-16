import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/common/providers/state_provider.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.scheme.error.withValues(alpha: .1),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.wifi_off_outlined,
                color: context.scheme.error,
                size: 27,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'No Internet Connection',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Text(
            'Please check your internet connection and try again.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          PrimaryButton(
            title: 'Retry',
            onPressed: () {
              context.read<StateProvider>().updateRetry(true);
            },
          ),
        ],
      ),
    );
  }
}
