import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';
import 'package:http/http.dart' as http;

class ExploreProvider extends ChangeNotifier {
  bool isLoading = true;

  int fetichingTimes = 0;

  List<ModeModel> modes = [];
  List<PlaylistModel> discover = [];
  List<ArtistModel> popularArtists = [];
  List<SongModel> trendingSongs = [];
  List<String> trendingSongsDynamicID = [];

  String cityModeTitle = '';
  String cityModeSubTitle = '';
  List<PlaylistModel> cityMode = [];

  List homeModules = [];

  fetchExploreApi() async {
    try {
      isLoading = true;
      notifyListeners();

      Map savedContents = await CacheHelper().getExploreContents();
      if (savedContents.isNotEmpty) {
        formateData(savedContents);
      }

      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {...defaultParams, '__call': 'webapi.getLaunchData'},
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      Map resBody = jsonDecode(response.body);
      await CacheHelper().saveExploreContents(resBody);
      formateData(resBody);
    } catch (error) {
      await CacheHelper().deleteExploreContents();
      if (fetichingTimes < 2) {
        fetichingTimes++;
        fetchExploreApi();
        return;
      }
    }
  }

  formateData(Map resBody) {
    List modes = resBody['browse_discover'] ?? [];
    this.modes =
        modes
            .where(
              (e) =>
                  !e['title'].toString().toLowerCase().contains('jio') &&
                  !e['title'].toString().toLowerCase().contains('pod'),
            )
            .map((e) => ModeModel.fromMap(e))
            .toList();
    this.modes.shuffle();

    List topPlaylists = resBody['top_playlists'];
    discover = topPlaylists.map((e) => PlaylistModel.fromJson(e)).toList();
    discover.shuffle();

    List artistRecos = resBody['artist_recos'];
    popularArtists = artistRecos.map((e) => ArtistModel.fromJson(e)).toList();
    popularArtists.shuffle();

    List newTrending = resBody['new_trending'];
    List trendingSongs = newTrending.where((e) => e['type'] == 'song').toList();
    this.trendingSongs =
        trendingSongs.map((e) => SongModel.fromJson(e)).toList();
    int nearestMultipleOfThree =
        this.trendingSongs.length - (this.trendingSongs.length % 3);
    this.trendingSongs = this.trendingSongs.sublist(0, nearestMultipleOfThree);
    trendingSongsDynamicID = List.generate(trendingSongs.length, (index) {
      return generateRandomId();
    });

    if (resBody['city_mod'] != null) {
      List cityMode = resBody['city_mod'];
      List cityModePlaylists =
          cityMode.where((e) => e['type'] == 'playlist').toList();
      cityModeTitle = resBody['modules']['city_mod']['title'];
      cityModeSubTitle = resBody['modules']['city_mod']['subtitle'];
      this.cityMode =
          cityModePlaylists.map((e) => PlaylistModel.fromJson(e)).toList();
      this.cityMode.shuffle();
    }

    List keys = resBody.keys.toList();
    List ignoreKeys = [
      'history',
      'new_trending',
      'top_playlists',
      'new_albums',
      'browse_discover',
      'global_config',
      'charts',
      'radio',
      'artist_recos',
      'city_mod',
      'modules',
    ];
    List filteredKeys = keys.where((e) => !ignoreKeys.contains(e)).toList();

    const List<String> layoutOrder = ['advanced', 'optimal', 'basic'];
    int layoutIndex = 0;

    for (int i = 0; i < filteredKeys.length; i++) {
      String key = filteredKeys[i];
      List items = resBody[key];
      String title = '';
      List hasToAdd = [];

      for (int j = 0; j < items.length; j++) {
        if (items[j]['type'] == 'playlist' || items[j]['type'] == 'album') {
          title = resBody['modules'][key]['title'];
          hasToAdd.add({
            'type': items[j]['type'],
            'data': getDynamicData(items[j]),
          });
        }
      }

      if (hasToAdd.isNotEmpty && hasToAdd.length >= 4) {
        homeModules.add({
          'type': 'content',
          'title': title,
          'data': hasToAdd,
          'layout': layoutOrder[layoutIndex],
        });

        layoutIndex++;
        if (layoutIndex > 2) {
          layoutIndex = 0;
        }
      }
    }
    isLoading = false;
    notifyListeners();
  }

  getAdData() {
    return 'ad';
  }

  getDynamicData(Map map) {
    if (map['type'] == 'playlist') {
      return PlaylistModel.fromJson(map);
    }
    if (map['type'] == 'album') {
      return AlbumModel.fromJson(map);
    }
  }
}
