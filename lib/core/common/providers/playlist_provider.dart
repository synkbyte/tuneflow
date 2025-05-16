// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/services/api_service/playlist/playlist_api_service.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/main.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';

class PlaylistProvider extends ChangeNotifier {
  List<UserPlaylistModel> playlists = [];
  List<UserPlaylistModel> playlistsForExplore = [];
  PlaylistApiServiceGloble service = sl();
  List<PlaylistModel> recommendedPlaylists = [];

  Future<void> initPlaylists() async {
    List items = await CacheHelper().getUserSavedPlaylist();

    if (items.isNotEmpty) {
      playlists = items.map((e) => UserPlaylistModel.fromJson(e)).toList();
      notifyListeners();
    }
    DataState state = await service.getPlaylist(
      userId: await CacheHelper().getUserId(),
    );
    if (state is DataSuccess) {
      playlists = state.data;
      notifyListeners();
      await CacheHelper().saveUserPlaylists(
        playlists.map((e) => e.toJson()).toList(),
      );
    }

    playlistsForExplore = playlists.where((e) => e.songs.isNotEmpty).toList();
    notifyListeners();
  }

  getExpoLen(int index) {
    if (playlistsForExplore.isEmpty) return 0;

    return playlistsForExplore[index].songs.length >= 3
        ? 3
        : playlistsForExplore[index].songs.length;
  }

  Future<void> addToPlaylist(UserPlaylistModel playlist) async {
    playlists.insert(0, playlist);
    notifyListeners();
    await CacheHelper().saveUserPlaylists(
      playlists.map((e) => e.toJson()).toList(),
    );
    await service.addToPlaylist(model: playlist);
    initPlaylists();
  }

  Future<void> removeFromPlaylist(UserPlaylistModel playlist) async {
    UserPlaylistModel? model = playlists.firstWhereOrNull(
      (element) => element.playlistId == playlist.playlistId,
    );
    playlists.removeWhere(
      (element) => element.playlistId == playlist.playlistId,
    );
    notifyListeners();
    await CacheHelper().saveUserPlaylists(
      playlists.map((e) => e.toJson()).toList(),
    );
    if (model != null) {
      await service.removePlaylist(id: model.id);
    }
    initPlaylists();
  }

  Future<DefaultResponse> createPlaylist(UserPlaylistModel playlist) async {
    DefaultResponse response = await service.addToPlaylist(model: playlist);
    if (response.status) {
      await initPlaylists();
    }
    return response;
  }

  Future<DefaultResponse> deletePlaylist(int id) async {
    DefaultResponse response = await service.deletePlaylist(id: id);
    if (response.status) {
      await initPlaylists();
      successMessage(navigatorKey.currentContext!, response.message);
    } else {
      errorMessage(navigatorKey.currentContext!, response.message);
    }
    return response;
  }

  Future<DefaultResponse> updatePlaylist(UserPlaylistModel playlist) async {
    DefaultResponse response = await service.updatePlaylist(model: playlist);
    if (response.status) {
      await initPlaylists();
    }
    return response;
  }

  bool isSavedPlaylist(String playlistId) {
    UserPlaylistModel? model = playlists.firstWhereOrNull(
      (element) => element.playlistId == playlistId,
    );
    return model != null;
  }

  isFromThis(List<SongModel> items, SongModel now) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].id == now.id) {
        return true;
      }
    }
    return false;
  }

  addSongToPlaylist(SongModel model, int index) async {
    UserPlaylistModel playlist = playlists[index];
    playlist.songs.insert(0, model);
    await CacheHelper().saveUserPlaylists(
      playlists.map((e) => e.toJson()).toList(),
    );
    await service.addSongToPlaylist(id: playlist.id, model: model);
    notifyListeners();
    initPlaylists();
  }

  removeSongFromPlaylist(SongModel model, int index) async {
    UserPlaylistModel playlist = playlists[index];
    playlist.songs.removeWhere((element) => element.id == model.id);
    await CacheHelper().saveUserPlaylists(
      playlists.map((e) => e.toJson()).toList(),
    );
    await service.removeSongFromPlaylist(id: playlist.id, songId: model.id);
    notifyListeners();
    initPlaylists();
  }

  getRecommendedPlaylists(String id) async {
    recommendedPlaylists = [];
    notifyListeners();
    DataState state = await service.getRecommendedPlaylists(id: id);
    if (state is DataSuccess) {
      recommendedPlaylists = state.data;
      notifyListeners();
    }
  }
}
