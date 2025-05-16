import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/services/api_service/like/like_api_service.dart';
import 'package:new_tuneflow/injection_container.dart';

class FavoriteProvider extends ChangeNotifier {
  List<SongModel> favoriteSongs = [];
  LikeApiService service = sl();

  Future<void> initFavoriteSongs() async {
    List items = await CacheHelper().getUserFavoriteSongs();

    if (items.isNotEmpty) {
      favoriteSongs = items.map((e) => SongModel.fromJson(e)).toList();
      notifyListeners();
    }
    DataState state = await service.getUserLikedSongs(
      await CacheHelper().getUserId(),
    );
    if (state is DataSuccess) {
      favoriteSongs = state.data;
      await CacheHelper().saveUserFavoriteSongs(
        favoriteSongs.map((e) => e.toJson()).toList(),
      );
      notifyListeners();
    }

    notifyListeners();
  }

  Future<void> addFavoriteSong(SongModel song) async {
    favoriteSongs.insert(0, song);
    audioHandler.broadcastState();
    notifyListeners();
    await CacheHelper().saveUserFavoriteSongs(
      favoriteSongs.map((e) => e.toJson()).toList(),
    );
    service.toggleLikeSong(Cache.instance.userId, song.id, song.toJson());
  }

  Future<void> removeFavoriteSong(SongModel song) async {
    favoriteSongs.removeWhere((element) => element.id == song.id);
    audioHandler.broadcastState();
    notifyListeners();
    await CacheHelper().saveUserFavoriteSongs(
      favoriteSongs.map((e) => e.toJson()).toList(),
    );
    service.toggleLikeSong(Cache.instance.userId, song.id, song.toJson());
  }

  bool isInLikedSong(SongModel song) {
    SongModel? model = favoriteSongs.firstWhereOrNull(
      (element) => element.id == song.id,
    );
    return model != null;
  }
}
