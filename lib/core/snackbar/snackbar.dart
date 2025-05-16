import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

errorMessage(BuildContext context, String message, {String? title}) {
  return Get.showSnackbar(
    GetSnackBar(
      titleText: Text(
        title ?? 'Ah, Snap',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: context.scheme.onError,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: context.scheme.onError),
      ),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(milliseconds: 2500),
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      backgroundColor: context.scheme.error,
      borderRadius: 10,
    ),
  );
}

successMessage(BuildContext context, String message) {
  return Get.showSnackbar(
    GetSnackBar(
      titleText: Text(
        'Success',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: context.scheme.onPrimaryContainer,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: context.scheme.onPrimaryContainer),
      ),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(milliseconds: 2500),
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      backgroundColor: context.scheme.primaryContainer,
      borderRadius: 10,
    ),
  );
}
