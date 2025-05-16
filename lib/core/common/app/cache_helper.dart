import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:new_tuneflow/core/common/models/user_model.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/extensions/string_extensions.dart';

class CacheHelper {
  final _box = Hive.box('app');
  static const _userIdKey = 'user-id';
  static const _userModelKey = 'user-model-key';
  static const _themeModeKey = 'theme-mode';
  static const _isNewInstallerKey = 'is-new-installer';
  static const _exploreContentsKey = 'explore-contents';
  static const _discoverContentsKey = 'explore-discover';
  static const _userSelectedLanguagesKey = 'user-selected-language';
  static const _userSelectedArtistsKey = 'user-selected-artists';
  static const _userFavoriteSongsKey = 'user-favorite-songs';
  static const _userSavedPlaylistKey = 'saved-playlist';
  static const _userDownloadsKey = 'downloaded-songs';
  static const _defaultMusicQualityKey = 'default-music-quality';
  static const _defaultDownloadQualityKey = 'default-download-quality';
  static const _userRecentPlaysKey = 'user-recent-plays';
  static const _initialSongsKey = 'initial-songs';
  static const _savePlayedHistory = 'save-played-history';
  static const _savePlayedIndex = 'save-played-index';
  static const _savePlayedSource = 'save-played-source';
  static const _dataSaverKey = 'data-saver';

  Future<void> saveUserId(int userId) async {
    await _box.put(_userIdKey, userId);
    Cache.instance.setUserId(userId);
  }

  Future<int> getUserId() async {
    int? userId = await _box.get(_userIdKey);
    if (userId case int()) {
      Cache.instance.setUserId(userId);
    }
    return userId ?? 0;
  }

  Future<void> savePlayedSource(String source) async {
    await _box.put(_savePlayedSource, source);
  }

  Future<String> getPlayedSource() async {
    String? userId = await _box.get(_savePlayedSource);
    return userId ?? '0';
  }

  Future<void> savePlayedIndex(int userId) async {
    await _box.put(_savePlayedIndex, userId);
  }

  Future<int> getPlayedIndex() async {
    int? userId = await _box.get(_savePlayedIndex);
    return userId ?? 0;
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _box.put(_themeModeKey, themeMode.name);
    Cache.instance.setThemeMode(themeMode);
  }

  Future<ThemeMode> getThemeMode() async {
    String? themeMode = await _box.get(_themeModeKey);
    if (themeMode case String()) {
      Cache.instance.setThemeMode(themeMode.toTheme);
    }
    return (themeMode ?? 'default').toTheme;
  }

  Future<void> saveIsNewInstaller(bool isNewInstaller) async {
    await _box.put(_isNewInstallerKey, isNewInstaller);
    Cache.instance.setIsNewInstaller(isNewInstaller);
  }

  Future<bool> getIsNewInstaller() async {
    bool? isNewInstaller = await _box.get(_isNewInstallerKey);
    if (isNewInstaller case bool()) {
      Cache.instance.setIsNewInstaller(isNewInstaller);
    }
    return isNewInstaller ?? true;
  }

  Future<void> saveExploreContents(Map contents) async {
    await _box.put(_exploreContentsKey, contents);
  }

  Future<Map> getExploreContents() async {
    Map? contents = await _box.get(_exploreContentsKey);
    return contents ?? {};
  }

  Future<void> deleteExploreContents() async {
    await _box.delete(_exploreContentsKey);
  }

  Future<void> saveDiscoverContents(List contents) async {
    await _box.put(_discoverContentsKey, contents);
    Cache.instance.setDiscoverContents(contents);
  }

  Future<List> getDiscoverContents() async {
    List? contents = await _box.get(_discoverContentsKey);
    if (contents case List()) {
      Cache.instance.setDiscoverContents(contents);
    }
    return contents ?? [];
  }

  Future<void> saveSelectedUserLanguages(List userLanguages) async {
    await _box.put(_userSelectedLanguagesKey, userLanguages);
    Cache.instance.saveSelectedUserLanguages(userLanguages);
  }

  Future<List> getUserSelectedLanguages() async {
    List? userLanguages = await _box.get(_userSelectedLanguagesKey);
    if (userLanguages case List()) {
      Cache.instance.saveSelectedUserLanguages(userLanguages);
    }
    return userLanguages ?? [];
  }

  Future<void> saveSelectedUserArtists(List userArtists) async {
    await _box.put(_userSelectedArtistsKey, userArtists);
    Cache.instance.saveSelectedUserArtists(userArtists);
  }

  Future<List> getUserSelectedArtists() async {
    List? userArtists = await _box.get(_userSelectedArtistsKey);
    if (userArtists case List()) {
      Cache.instance.saveSelectedUserArtists(userArtists);
    }
    return userArtists ?? [];
  }

  Future<void> saveUserFavoriteSongs(List favoriteSongs) async {
    await _box.put(_userFavoriteSongsKey, favoriteSongs);
    Cache.instance.saveUserFavoriteSongs(favoriteSongs);
  }

  Future<List> getUserFavoriteSongs() async {
    List? favoriteSongs = await _box.get(_userFavoriteSongsKey);
    if (favoriteSongs case List()) {
      Cache.instance.saveUserFavoriteSongs(favoriteSongs);
    }
    return favoriteSongs ?? [];
  }

  Future<void> saveUserPlaylists(List playlists) async {
    await _box.put(_userSavedPlaylistKey, playlists);
    Cache.instance.saveUserSavedPlaylist(playlists);
  }

  Future<List> getUserSavedPlaylist() async {
    List? playlists = await _box.get(_userSavedPlaylistKey);
    if (playlists case List()) {
      Cache.instance.saveUserSavedPlaylist(playlists);
    }
    return playlists ?? [];
  }

  Future<void> saveUserDownloads(List songs) async {
    await _box.put(_userDownloadsKey, songs);
    Cache.instance.saveUserDownloads(songs);
  }

  Future<List> getUserDownloads() async {
    List? songs = await _box.get(_userDownloadsKey);
    if (songs case List()) {
      Cache.instance.saveUserDownloads(songs);
    }
    return songs ?? [];
  }

  Future<void> saveDefaultMusicQuality(String? quality) async {
    await _box.put(_defaultMusicQualityKey, quality ?? 'Excellent');
    Cache.instance.setDefaultMusicQuality(quality ?? 'Excellent');
  }

  Future<String> getDefaultMusicQuality() async {
    String quality = await _box.get(_defaultMusicQualityKey) ?? 'Excellent';
    if (quality case String()) {
      Cache.instance.setDefaultMusicQuality(quality);
    }
    return quality;
  }

  Future<void> saveDefaultDownloadQuality(String? quality) async {
    await _box.put(_defaultDownloadQualityKey, quality ?? 'Excellent');
    Cache.instance.setDefaultDownloadQuality(quality ?? 'Excellent');
  }

  Future<String> getDefaultDownloadQuality() async {
    String quality = await _box.get(_defaultDownloadQualityKey) ?? 'Excellent';
    if (quality case String()) {
      Cache.instance.setDefaultDownloadQuality(quality);
    }
    return quality;
  }

  Future<void> saveUserRecentSongs(List recentlyPlays) async {
    await _box.put(_userRecentPlaysKey, recentlyPlays);
    Cache.instance.saveUserRecentSongs(recentlyPlays);
  }

  Future<List> getUserRecentSongs() async {
    List? recentlyPlays = await _box.get(_userRecentPlaysKey);
    if (recentlyPlays case List()) {
      Cache.instance.saveUserRecentSongs(recentlyPlays);
    }
    return recentlyPlays ?? [];
  }

  Future<void> saveInitialSongs(List initialSongs) async {
    await _box.put(_initialSongsKey, initialSongs);
    Cache.instance.saveInitialSongs(initialSongs);
  }

  Future<List> getInitialSongs() async {
    List? initialSongs = await _box.get(_initialSongsKey);
    if (initialSongs case List()) {
      Cache.instance.saveUserRecentSongs(initialSongs);
    }
    return initialSongs ?? [];
  }

  Future<void> savePlayedSongs(List initialSongs) async {
    await _box.put(_savePlayedHistory, initialSongs);
  }

  Future<List> getPlayedSongs() async {
    List? initialSongs = await _box.get(_savePlayedHistory);
    return initialSongs ?? [];
  }

  Future<void> saveUserModel(UserModel model) async {
    await _box.put(_userModelKey, model.toJson());
  }

  Future<UserModel?> getUserModel() async {
    Map? userModel = await _box.get(_userModelKey);
    return userModel == null ? null : UserModel.fromJson(userModel);
  }

  Future<void> saveDataSaver(bool value) async {
    await _box.put(_dataSaverKey, value);
  }

  bool getDataSaver() {
    return _box.get(_dataSaverKey, defaultValue: false);
  }

  Future<void> resetSession() async {
    await _box.delete(_userIdKey);
    await _box.delete(_themeModeKey);
    await _box.delete(_isNewInstallerKey);
    await _box.delete(_exploreContentsKey);
    await _box.delete(_userSelectedLanguagesKey);
    await _box.delete(_userSelectedArtistsKey);
    await _box.delete(_userFavoriteSongsKey);
    await _box.delete(_userSavedPlaylistKey);
    await _box.delete(_userRecentPlaysKey);
    await _box.delete(_defaultMusicQualityKey);
    await _box.delete(_defaultDownloadQualityKey);
    Cache.instance.resetSession();
  }
}
