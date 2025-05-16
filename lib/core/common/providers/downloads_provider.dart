import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/models/user_model.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/main.dart';
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/album/domain/entites/album_entity.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';
import 'package:new_tuneflow/src/playlist/domain/entites/playlist_entity.dart';
import 'package:path_provider/path_provider.dart';

class DownloadsProvider extends ChangeNotifier {
  List userDownloadsLocal = [];
  List currentUserDown = [];
  List<SongModel> userDownloads = [];
  List<PlaylistModel> userDownloadsPlaylist = [];
  List<AlbumModel> userDownloadsAlbum = [];
  List<SongModel> downloadingNow = [];
  List<PlaylistEntity> downloadingNowPlaylist = [];
  List<AlbumEntity> downloadingNowAlbum = [];
  Map<String, double> downloadingPercentage = {};
  Map<String, double> downloadingPercentagePlaylist = {};
  Map<String, double> downloadingPercentageAlbum = {};

  Future<void> initUserDownloads() async {
    userDownloadsLocal = await CacheHelper().getUserDownloads();
    if (userDownloadsLocal.isNotEmpty) {
      for (var download in userDownloadsLocal) {
        if (download['id'] == await CacheHelper().getUserId()) {
          currentUserDown.add(download);
          if (download['type'] == 'song') {
            userDownloads.add(SongModel.fromJson(download['song']));
          } else if (download['type'] == 'playlist') {
            userDownloadsPlaylist.add(PlaylistModel.fromJson(download['song']));
          } else if (download['type'] == 'album') {
            userDownloadsAlbum.add(AlbumModel.fromJson(download['song']));
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> downloadFile(SongModel model, UserModel user) async {
    if (isDownloading(model.id)) return;

    downloadingNow.insert(0, model);
    downloadingPercentage[model.id] = 0;
    notifyListeners();

    String url = model.playUrl.excellent;
    if (Cache.instance.defaultDownloadQuality == 'Good') {
      url = model.playUrl.good;
    } else if (Cache.instance.defaultDownloadQuality == 'Regular') {
      url = model.playUrl.regular;
    }

    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      final contentLength = response.contentLength ?? 0;
      int downloadedBytes = 0;

      final appDir = await getApplicationDocumentsDirectory();
      String now = '${DateTime.now().microsecondsSinceEpoch}';
      final file = File('${appDir.path}/$now.${url.split('.').last}');

      final fileStream = file.openWrite();

      response.stream.listen(
        (chunk) {
          fileStream.add(chunk);
          downloadedBytes += chunk.length;

          downloadingPercentage[model.id] =
              (downloadedBytes / contentLength) * 100;
          notifyListeners();
        },
        onDone: () async {
          await fileStream.close();
          _onDownloadComplete(model, user, file);
        },
        onError: (error) {
          _onDownloadError(model);
        },
        cancelOnError: true,
      );
    } catch (e) {
      _onDownloadError(model);
    }
  }

  Future<void> downloadPlaylist(PlaylistEntity playlist) async {
    if (isDownloadingPlaylist(playlist.id)) return;
    downloadingNowPlaylist.insert(0, playlist);
    downloadingPercentagePlaylist[playlist.id] = 0;
    notifyListeners();

    late PlaylistModel downloadedItem;
    List<SongModel> songs = [];
    for (int i = 0; i < playlist.songs.length; i++) {
      String url = playlist.songs[i].playUrl.excellent;
      if (Cache.instance.defaultDownloadQuality == 'Good') {
        url = playlist.songs[i].playUrl.good;
      } else if (Cache.instance.defaultDownloadQuality == 'Regular') {
        url = playlist.songs[i].playUrl.regular;
      }
      final response = await http.get(Uri.parse(url));
      final appDir = await getApplicationDocumentsDirectory();
      String now = '${DateTime.timestamp().microsecondsSinceEpoch}';
      final file = File('${appDir.path}/$now.${url.split('.').last}');
      await file.writeAsBytes(response.bodyBytes);
      Map json = playlist.songs[i].toJson();
      json['more_info']['localPath'] = file.path;
      songs.add(SongModel.fromJson(json));
      downloadingPercentagePlaylist[playlist.id] =
          downloadingPercentagePlaylist[playlist.id]! + 1;
      notifyListeners();
    }
    downloadedItem = PlaylistModel(
      id: playlist.id,
      image: playlist.image,
      songCount: playlist.songCount,
      subtitle: playlist.subtitle,
      title: playlist.title,
      type: playlist.type,
      songs: songs,
      userDetails: playlist.userDetails,
    );
    userDownloadsLocal.insert(0, {
      'id': Cache.instance.userId,
      'song': downloadedItem.toJson(),
      'type': 'playlist',
    });
    currentUserDown.insert(0, {
      'id': Cache.instance.userId,
      'song': downloadedItem.toJson(),
      'type': 'playlist',
    });
    userDownloadsPlaylist.insert(0, downloadedItem);
    downloadingNowPlaylist.removeWhere((e) => e.id == playlist.id);
    downloadingPercentagePlaylist.remove(playlist.id);
    await CacheHelper().saveUserDownloads(userDownloadsLocal);
    notifyListeners();
  }

  Future<void> downloadAlbum(AlbumEntity album) async {
    if (isDownloadingAlbum(album.id)) return;
    downloadingNowAlbum.insert(0, album);
    downloadingPercentageAlbum[album.id] = 0;
    notifyListeners();

    late AlbumEntity downloadedItem;
    List<SongModel> songs = [];
    for (int i = 0; i < album.songs.length; i++) {
      String url = album.songs[i].playUrl.excellent;
      if (Cache.instance.defaultDownloadQuality == 'Good') {
        url = album.songs[i].playUrl.good;
      } else if (Cache.instance.defaultDownloadQuality == 'Regular') {
        url = album.songs[i].playUrl.regular;
      }
      final response = await http.get(Uri.parse(url));
      final appDir = await getApplicationDocumentsDirectory();
      String now = '${DateTime.timestamp().microsecondsSinceEpoch}';
      final file = File('${appDir.path}/$now.${url.split('.').last}');
      await file.writeAsBytes(response.bodyBytes);
      Map json = album.songs[i].toJson();
      json['more_info']['localPath'] = file.path;
      songs.add(SongModel.fromJson(json));
      downloadingPercentageAlbum[album.id] =
          downloadingPercentageAlbum[album.id]! + 1;
      notifyListeners();
    }
    downloadedItem = AlbumEntity(
      id: album.id,
      image: album.image,
      subtitle: album.subtitle,
      title: album.title,
      songs: songs,
    );
    userDownloadsLocal.insert(0, {
      'id': Cache.instance.userId,
      'song': downloadedItem.toJson(),
      'type': 'album',
    });
    currentUserDown.insert(0, {
      'id': Cache.instance.userId,
      'song': downloadedItem.toJson(),
      'type': 'album',
    });
    userDownloadsAlbum.insert(0, AlbumModel.fromEntity(downloadedItem));
    downloadingNowAlbum.removeWhere((e) => e.id == album.id);
    downloadingPercentageAlbum.remove(album.id);
    await CacheHelper().saveUserDownloads(userDownloadsLocal);
    notifyListeners();
  }

  void _onDownloadComplete(SongModel model, UserModel user, File file) async {
    Map<String, dynamic> json = model.toJson();
    json['more_info']['localPath'] = file.path;

    userDownloadsLocal.insert(0, {'id': user.id, 'song': json, 'type': 'song'});
    currentUserDown.insert(0, {'id': user.id, 'song': json, 'type': 'song'});

    userDownloads.insert(0, SongModel.fromJson(json));

    downloadingNow.removeWhere((e) => e.id == model.id);
    downloadingPercentage.remove(model.id);
    notifyListeners();

    await CacheHelper().saveUserDownloads(userDownloadsLocal);
  }

  void _onDownloadError(SongModel model) {
    String message = 'Failed to download ${model.title}';
    downloadingNow.removeWhere((e) => e.id == model.id);
    downloadingPercentage.remove(model.id);
    errorMessage(navigatorKey.currentContext!, message);
    notifyListeners();
  }

  bool isDownloaded(SongModel model) {
    return userDownloads.any((e) => e.id == model.id);
  }

  bool isDownloading(String id) {
    return downloadingNow.any((e) => e.id == id);
  }

  bool isDownloadedPlaylist(PlaylistEntity model) {
    return userDownloadsPlaylist.any((e) => e.id == model.id);
  }

  bool isDownloadedAlbum(AlbumEntity model) {
    return userDownloadsAlbum.any((e) => e.id == model.id);
  }

  bool isDownloadingPlaylist(String id) {
    return downloadingNowPlaylist.any((e) => e.id == id);
  }

  bool isDownloadingAlbum(String id) {
    return downloadingNowAlbum.any((e) => e.id == id);
  }

  Future<void> deletePlaylist(PlaylistEntity playlist) async {
    final downloadEntry = userDownloadsLocal.firstWhere(
      (entry) =>
          entry['type'] == 'playlist' &&
          entry['id'] == Cache.instance.userId &&
          entry['song']['id'] == playlist.id,
      orElse: () => null,
    );
    if (downloadEntry != null) {
      PlaylistEntity entity = PlaylistEntity(
        id: playlist.id,
        image: playlist.image,
        songCount: playlist.songCount,
        subtitle: playlist.subtitle,
        title: playlist.title,
        type: playlist.type,
        songs: playlist.songs,
        userDetails: playlist.userDetails,
      );
      for (int i = 0; i < entity.songs.length; i++) {
        Map song = entity.songs[i].toJson();
        String filePath = song['more_info']['encrypted_media_url'];
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      userDownloadsLocal.removeWhere(
        (entry) =>
            entry['id'] == Cache.instance.userId &&
            entry['song']['id'] == playlist.id,
      );
      userDownloadsPlaylist.removeWhere((e) => e.id == playlist.id);
      notifyListeners();
      currentUserDown.removeWhere(
        (e) =>
            e['type'] == 'playlist' &&
            e['id'] == Cache.instance.userId &&
            e['song']['id'] == playlist.id,
      );
      notifyListeners();
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: '${entity.title} Deleted from Downloads');
      await CacheHelper().saveUserDownloads(userDownloadsLocal);
    }
  }

  Future<void> deleteAlbum(AlbumModel album) async {
    final downloadEntry = userDownloadsLocal.firstWhere(
      (entry) =>
          entry['type'] == 'album' &&
          entry['id'] == Cache.instance.userId &&
          entry['song']['id'] == album.id,
      orElse: () => null,
    );
    if (downloadEntry != null) {
      AlbumEntity entity = AlbumEntity(
        id: album.id,
        image: album.image,
        subtitle: album.subtitle,
        title: album.title,
        songs: album.songs,
      );
      for (int i = 0; i < entity.songs.length; i++) {
        Map song = entity.songs[i].toJson();
        String filePath = song['more_info']['encrypted_media_url'];
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      userDownloadsLocal.removeWhere(
        (entry) =>
            entry['id'] == Cache.instance.userId &&
            entry['song']['id'] == album.id,
      );
      userDownloadsAlbum.removeWhere((e) => e.id == album.id);
      currentUserDown.removeWhere(
        (e) =>
            e['type'] == 'album' &&
            e['id'] == Cache.instance.userId &&
            e['song']['id'] == album.id,
      );
      notifyListeners();
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: '${entity.title} Deleted from Downloads');
      await CacheHelper().saveUserDownloads(userDownloadsLocal);
    }
  }

  Future<void> deleteDownloadedFile(SongModel song, UserModel user) async {
    final downloadEntry = userDownloadsLocal.firstWhere(
      (entry) =>
          entry['type'] == 'song' &&
          entry['id'] == user.id &&
          entry['song']['id'] == song.id,
      orElse: () => null,
    );

    if (downloadEntry != null) {
      String filePath =
          downloadEntry['song']['more_info']['encrypted_media_url'];
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      userDownloadsLocal.remove(downloadEntry);
      userDownloads.removeWhere((e) => e.id == song.id);
      notifyListeners();
      currentUserDown.removeWhere(
        (e) =>
            e['type'] == 'song' &&
            e['id'] == Cache.instance.userId &&
            e['song']['id'] == song.id,
      );
      notifyListeners();
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: '${song.title} Deleted from Downloads');
      await CacheHelper().saveUserDownloads(userDownloadsLocal);
    }
  }
}
