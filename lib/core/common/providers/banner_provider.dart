import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';

class BannerProvider extends ChangeNotifier {
  List homeBanners = [];
  List socialBanners = [];

  fetchBanners() async {
    try {
      final client = http.Client();
      final url = parseUrl('banners/fetch', {
        'userId': '${Cache.instance.userId}',
      });
      final response = await client.get(url);
      Map data = jsonDecode(response.body);
      if (data['status']) {
        List banners = data['banners'];
        homeBanners = banners.where((e) => e['page'] == 'home').toList();
        socialBanners = banners.where((e) => e['page'] == 'social').toList();
        notifyListeners();
      }
    } catch (e) {
      return;
    }
  }

  clickedOnBanner(int id) async {
    final client = http.Client();
    final url = parseUrl('banner/$id/clicked/${Cache.instance.userId}');
    await client.get(url);
    return;
  }
}
