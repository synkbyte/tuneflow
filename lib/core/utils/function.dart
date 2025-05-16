import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:dart_des/dart_des.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/constants/constants.dart';

MediaFormat createDownloadLinks(String encryptedMediaUrl) {
  try {
    const key = '38346591';
    final encrypted = base64Decode(encryptedMediaUrl);
    final decipher = DES(
      key: key.codeUnits,
      mode: DESMode.ECB,
      paddingType: DESPaddingType.PKCS7,
    );
    final decryptedLink = decipher.decrypt(encrypted);
    return MediaFormat(
      excellent: utf8
          .decode(decryptedLink)
          .replaceAll('http://', 'https://')
          .replaceAll('_96', '_320')
          .replaceAll('_160', '_320'),
      good: utf8
          .decode(decryptedLink)
          .replaceAll('http://', 'https://')
          .replaceAll('_96', '_160')
          .replaceAll('_320', '_160'),
      regular: utf8
          .decode(decryptedLink)
          .replaceAll('http://', 'https://')
          .replaceAll('_160', '_96')
          .replaceAll('_320', '_96'),
    );
  } catch (e) {
    return MediaFormat(
      excellent: encryptedMediaUrl
          .replaceAll('http://', 'https://')
          .replaceAll('_96', '_320')
          .replaceAll('_160', '_320'),
      good: encryptedMediaUrl
          .replaceAll('http://', 'https://')
          .replaceAll('_96', '_160')
          .replaceAll('_320', '_160'),
      regular: encryptedMediaUrl
          .replaceAll('http://', 'https://')
          .replaceAll('_160', '_96')
          .replaceAll('_320', '_96'),
    );
  }
}

String defaultLocalPath(MediaFormat formate) {
  if (Cache.instance.defaultMusicQuality == 'Good') {
    return formate.good;
  } else if (Cache.instance.defaultMusicQuality == 'Regular') {
    return formate.regular;
  }
  return formate.excellent;
}

MediaFormat createImageLinks(String image) {
  if (image.contains('share-image')) {
    return MediaFormat(
      excellent: '$imageBaseUrl/uploads/logo.png',
      good: '$imageBaseUrl/uploads/logo.png',
      regular: '$imageBaseUrl/uploads/logo.png',
    );
  }
  if (image.contains('default')) {
    return MediaFormat(
      excellent: '$imageBaseUrl/uploads/logo.png',
      good: '$imageBaseUrl/uploads/logo.png',
      regular: '$imageBaseUrl/uploads/logo.png',
    );
  }

  // if (CacheHelper().getDataSaver()) {
  //   return MediaFormat(
  //     excellent: image
  //         .replaceAll('500x500', '150x150')
  //         .replaceAll('50x50', '150x150'),
  //     good: image
  //         .replaceAll('500x500', '150x150')
  //         .replaceAll('50x50', '150x150'),
  //     regular: image
  //         .replaceAll('500x500', '150x150')
  //         .replaceAll('50x50', '150x150'),
  //   );
  // }

  return MediaFormat(
    excellent: image
        .replaceAll('150x150', '500x500')
        .replaceAll('50x50', '500x500'),
    good: image.replaceAll('50x50', '150x150').replaceAll('500x500', '150x150'),
    regular: image
        .replaceAll('500x500', '50x50')
        .replaceAll('150x150', '50x50'),
  );
}

String createHighQualityImage(String link) {
  return link.replaceAll('50x50', '500x500').replaceAll('150x150', '500x500');
}

String generateSubTitleForMusic(List artists) {
  String subTitle = '';
  for (var i = 0; i < artists.length; i++) {
    subTitle += filteredText(artists[i]['name']);
    if (i != artists.length - 1) {
      subTitle += ', ';
    }
  }
  return subTitle;
}

String filteredText(String text) {
  return text
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&#039;', "'")
      .replaceAll(' - JioTunes', '')
      .replaceAll('JioTunes - ', '')
      .replaceAll('JioTunes', '');
}

int songIndex(List<SongModel> items, SongModel model) {
  for (int i = 0; i < items.length; i++) {
    if (items[i].id == model.id) {
      return i;
    }
  }
  return -1;
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}

Future<Map> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return {
      'deviceOS': 'Android',
      'model': androidInfo.data['name'] ?? androidInfo.model,
      'osVersion': androidInfo.version.sdkInt,
      'manufacturer': androidInfo.manufacturer,
      'appVersion': appVersion,
    };
  }

  if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return {
      'deviceOS': 'Apple',
      'model': iosInfo.utsname.machine,
      'osVersion': iosInfo.systemVersion,
      'manufacturer': 'Apple',
    };
  }

  return {};
}

Future<File?> pickImage() async {
  XFile? picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (picked == null) return null;
  return File(picked.path);
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

String formateLangaugeForPayload(List languages) {
  String language = '';
  for (var i = 0; i < languages.length; i++) {
    language += languages[i]['key'];
    if (i != languages.length - 1) {
      language += ',';
    }
  }
  return language;
}

Future<bool> isConnected() async {
  Uri testHost = Uri.parse('https://example.com');
  try {
    Response res = await http.get(testHost);
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}

Future<bool> isAdBlockEnabled() async {
  if (await isConnected()) {
    try {
      Response res = await http.get(
        Uri.parse("https://www.googleadservices.com"),
      );
      if (res.statusCode != 404) {
        return true;
      }
      return false;
    } catch (e) {
      return true;
    }
  }
  return true;
}

Future<bool> isUpdateAvailable() async {
  try {
    AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
    return updateInfo.updateAvailability == UpdateAvailability.updateAvailable;
  } catch (e) {
    return false;
  }
}

Color hexStringToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse(hex, radix: 16));
}

Color getInside(Color color) {
  if (color.computeLuminance() < 0.5) {
    return Colors.white;
  } else {
    return Colors.black;
  }
}

String formatePath(String path) {
  if (path.startsWith('https://') || path.startsWith('http://')) {
    return path;
  } else {
    return '$imageBaseUrl$path';
  }
}

Color getBatchColor(String color) {
  if (color == 'red') {
    return const Color(0xFFE74C3C);
  }

  return const Color(0xFF1DA1F2);
}

String getFirstName(String fullName) {
  if (fullName.contains(' ')) {
    return fullName.split(' ')[0];
  }
  return fullName;
}

String getGreeting() {
  final now = DateTime.now();
  final hour = now.hour;

  if (hour < 12) {
    return 'Good Morning';
  } else if (hour < 18) {
    return 'Good Afternoon';
  } else {
    return 'Good Evening';
  }
}

String maskPhone(String input) {
  if (input.length <= 4) {
    return input;
  }

  String first = input.substring(0, 1);
  String last = input.substring(input.length - 4);
  return '$first*****$last';
}

String maskEmail(String email) {
  List<String> parts = email.split('@');
  if (parts.length != 2) {
    return email;
  }

  String localPart = parts[0];
  String domainPart = parts[1];

  String maskedLocalPart =
      '${localPart.substring(0, 1)}******${localPart.substring(localPart.length - 4)}';
  return '$maskedLocalPart@$domainPart';
}
