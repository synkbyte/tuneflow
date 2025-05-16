import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/album/data/models/album_model.dart';

class AlbumProvider extends ChangeNotifier {
  bool isLoading = true;
  String error = '';
  late AlbumModel album;
  List<ArtistModel> artists = [];
  List<AlbumModel> recommendedAlbums = [];

  setAlbum(String id) async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();
      final client = http.Client();
      Uri url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'content.getAlbumDetails',
          'albumid': id,
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      http.Response response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );

      Map resBody = jsonDecode(response.body);

      List songs = resBody['list'];
      List<SongModel> songsModel =
          songs.map((e) => SongModel.fromJson(e)).toList();

      AlbumModel albumModel = AlbumModel(
        id: resBody['id'],
        title: filteredText(resBody['title']),
        subtitle: resBody['header_desc'],
        image: createImageLinks(resBody['image']),
        songs: songsModel,
      );

      List artists = resBody['more_info']?['artistMap']?['artists'] ?? [];
      List<ArtistModel> artistsModel =
          artists.map((e) => ArtistModel.fromJson(e)).toList();
      album = albumModel;
      this.artists = artistsModel;
      isLoading = false;
      notifyListeners();
      try {
        url = Uri.parse(baseUrl).replace(
          queryParameters: {
            ...defaultParams,
            '__call': 'reco.getAlbumReco',
            'albumid': id,
          },
        );
        response = await client.get(
          url,
          headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
        );
        List resBody = jsonDecode(response.body);
        List<AlbumModel> recommendedAlbumsModel =
            resBody.map((e) => AlbumModel.fromJson(e)).toList();
        recommendedAlbums = recommendedAlbumsModel;
        notifyListeners();
      } catch (e) {
        return;
      }
    } catch (e) {
      error = 'Something went wrong';
      isLoading = false;
      notifyListeners();
    }
  }
}
