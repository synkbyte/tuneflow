import 'package:flutter/material.dart';

class Cache {
  Cache._internal();

  static final Cache instance = Cache._internal();

  int? _userId;
  bool? _isNewInstaller;
  final themeModeNotifier = ValueNotifier(ThemeMode.system);
  List? _exploreContents;
  List? _discoverContents;
  List? _userSelectedLanguages;
  List? _userSelectedArtists;
  List? _userFavoriteSongs;
  List? _userSavedPlaylist;
  List? _userDownloads;
  String? _defaultMusicQuality;
  String? _defaultDownloadQuality;
  List? _userRecentPlays;
  List? _initialSongs;

  int get userId => _userId ?? 0;
  bool get isNewInstaller => _isNewInstaller ?? true;
  ThemeMode get themeMode => themeModeNotifier.value;
  List? get exploreContents => _exploreContents;
  List? get discoverContents => _discoverContents;
  List? get userSelectedLanguages => _userSelectedLanguages;
  List? get userSelectedArtists => _userSelectedArtists;
  List? get userFavoriteSongs => _userFavoriteSongs;
  List? get userSavedPlaylist => _userSavedPlaylist;
  List? get userDownloads => _userDownloads;
  String? get defaultMusicQuality => _defaultMusicQuality;
  String? get defaultDownloadQuality => _defaultDownloadQuality;
  List? get userRecentPlays => _userRecentPlays;
  List? get initialSongs => _initialSongs;

  void setUserId(int? value) {
    _userId = value;
  }

  void setIsNewInstaller(bool value) {
    _isNewInstaller = value;
  }

  void setThemeMode(ThemeMode themeMode) {
    if (themeModeNotifier.value != themeMode) {
      themeModeNotifier.value = themeMode;
    }
  }

  void setExploreContents(List? value) {
    _exploreContents = value;
  }

  void setDiscoverContents(List? value) {
    _discoverContents = value;
  }

  void saveSelectedUserLanguages(List? value) {
    _userSelectedLanguages = value;
  }

  void saveSelectedUserArtists(List? value) {
    _userSelectedArtists = value;
  }

  void saveUserFavoriteSongs(List? value) {
    _userFavoriteSongs = value;
  }

  void saveUserSavedPlaylist(List? value) {
    _userSavedPlaylist = value;
  }

  void saveUserDownloads(List? value) {
    _userDownloads = value;
  }

  void setDefaultMusicQuality(String? value) {
    _defaultMusicQuality = value;
  }

  void setDefaultDownloadQuality(String? value) {
    _defaultDownloadQuality = value;
  }

  void saveUserRecentSongs(List? value) {
    _userRecentPlays = value;
  }

  void saveInitialSongs(List? value) {
    _initialSongs = value;
  }

  void resetSession() {
    setUserId(null);
    setExploreContents(null);
    saveSelectedUserLanguages(null);
    saveSelectedUserArtists(null);
    saveUserFavoriteSongs(null);
    saveUserSavedPlaylist(null);
    setThemeMode(ThemeMode.system);
    setIsNewInstaller(true);
  }
}
