import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/constants/constants.dart';

class ArtistSongsProvider extends ChangeNotifier {
  String artistName = '';
  String artistId = '';
  bool isLoading = true;
  String error = '';
  List<SongModel> songs = [];
  int currentPage = 0;
  bool isLastPage = false;

  artistAllSongs({
    required String artistId,
    required int page,
    String? artistName,
  }) async {
    if (page == 0) {
      this.artistName = artistName ?? this.artistName;
      this.artistId = artistId;
      songs = [];
    }
    isLoading = true;
    notifyListeners();
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'artist.getArtistMoreSong',
          'artistId': artistId,
          'size': '100',
          'page': '$page',
        },
      );
      final response = await client.get(url);
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        isLastPage = data['topSongs']['last_page'];
        currentPage = page;
        List songs = data['topSongs']['songs'];
        this.songs.addAll(songs.map((s) => SongModel.fromJson(s)));
      } else {
        error = 'Somthing went wrong';
      }
      isLoading = false;
      notifyListeners();
    } catch (error) {
      isLoading = false;
      this.error = 'Somthing went wrong';
      return;
    }
  }
}
