import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/extensions/list_extenstions.dart';
import 'package:new_tuneflow/core/extensions/media_item_extenstions.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/services/api_service/like/like_api_service.dart';
import 'package:new_tuneflow/core/services/api_service/recent/recent_api_service.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/main.dart';
import 'package:new_tuneflow/src/album/data/data_source/album_data_source.dart';
import 'package:new_tuneflow/src/artist_details/data/data_source/artist_details_data_source.dart';
import 'package:new_tuneflow/src/auth/data/data_source/artist_data_source.dart';
import 'package:new_tuneflow/src/explore/data/data_source/explore_remote_data_source.dart';
import 'package:new_tuneflow/src/player/domain/usecase/player_usecase.dart';
import 'package:new_tuneflow/src/playlist/data/data_source/playlist_data_source.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';
import 'package:new_tuneflow/src/song/data/data_source/song_details_api_service.dart';
import 'package:new_tuneflow/src/song/domain/usecase/song_usecase.dart';

class PlayerProvider extends ChangeNotifier {
  PlayerUseCase playerUseCase = sl();
  SongDetailsUseCase songDetailsUseCase = sl();
  RecentApiService recentApiService = sl();
  SongDetailsApiService service = sl();
  ArtistDetailsApiService artistApiService = sl();
  ExploreAPIService exploreAPIService = sl();
  AlbumApiService albumApiService = sl();
  PlaylistApiService playlistApiService = sl();
  LikeApiService likeApiService = sl();
  ArtistApiService apiService = sl();
  Timer? singleTapTimer;

  bool isPlaying = false;
  bool isLoading = true;
  bool isLoaded = false;
  bool isUserScrolling = false;
  bool isInitiating = true;
  SongModel? nowPlaying;
  PlayingModel playingModel = PlayingModel(type: PlayingType.initial, id: 'id');
  List<SongModel> recentlyPlays = [];
  AudioServiceShuffleMode shuffleMode = AudioServiceShuffleMode.none;
  AudioServiceRepeatMode repeatMode = AudioServiceRepeatMode.all;

  int playingIndex = 0;
  Duration totalDuration = Duration.zero;
  Duration currentDuration = Duration.zero;
  Duration bufferedDuration = Duration.zero;
  List<SongModel> playingList = [];
  PageController controller = PageController();
  bool isSocketCall = false;

  bool isLooping = false;

  getInitialSongs() async {
    if (!await isConnected()) {
      return;
    }

    List history = await CacheHelper().getPlayedSongs();
    int index = await CacheHelper().getPlayedIndex();
    String source = await CacheHelper().getPlayedSource();
    if (history.isNotEmpty) {
      List<SongModel> initialSongs =
          history.map((e) => SongModel.fromJson(e)).toList();
      isInitiating = false;
      playingIndex = index;
      notifyListeners();
      startPlaying(
        source: initialSongs,
        i: index,
        type: stringToType(source),
        startPlaying: false,
      );
    }
    notifyListeners();
    // return;
    // List<SongModel> response = [];
    // List stored = await CacheHelper().getInitialSongs();
    // if (stored.isNotEmpty) {
    //   stored.shuffle();
    //   List<SongModel> initialSongs =
    //       stored.map((e) => SongModel.fromJson(e)).toList();
    //   isInitiating = false;
    //   notifyListeners();
    //   if (initialSongs.isNotEmpty) {
    //     startPlaying(source: initialSongs, i: 0, type: PlayingType.initial);
    //   }
    // }

    // DataState favState = await likeApiService.getUserLikedSongs(
    //   Cache.instance.userId,
    // );
    // List<SongModel> favItems = favState is DataSuccess ? favState.data : [];
    // if (favItems.isNotEmpty) {
    //   favItems.shuffle();
    //   int loopLength = favItems.length >= 3 ? 3 : favItems.length;
    //   for (int i = 0; i < loopLength; i++) {
    //     DataState state = await service.getSongDetails(favItems[i].id);
    //     if (state is DataSuccess) {
    //       SongDetailsModel songs = state.data;
    //       response.addAll(songs.songs);
    //     }
    //   }
    // }

    // DataState artistState =
    //     await apiService.getSavedArtists(Cache.instance.userId);
    // List<ArtistModel> artists =
    //     artistState is DataSuccess ? artistState.data : [];
    // for (int i = 0; i < artists.length; i++) {
    //   DataState state = await artistApiService.getArtistDetails(
    //     artists[i].id,
    //   );
    //   if (state is DataSuccess) {
    //     ArtistModel artistDetails = state.data;
    //     List<SongModel> songs = artistDetails.songs;
    //     response.addAll(songs);
    //   }
    // }

    // DataState state = await exploreAPIService.getTrending();
    // if (state is DataSuccess) {
    //   List<TrendingModel> trending = state.data;
    //   int loopLength = trending.length >= 5 ? 5 : trending.length;
    //   for (int i = 0; i < loopLength; i++) {
    //     if (trending[i].type == 'album') {
    //       DataState albumState = await albumApiService.getAlbumDetails(
    //         trending[i].id!,
    //       );
    //       if (albumState is DataSuccess) {
    //         AlbumModel albumDetails = albumState.data;
    //         if (albumDetails.songs.isNotEmpty) {
    //           response.addAll(albumDetails.songs);
    //         }
    //       }
    //     }
    //     if (trending[i].type == 'playlist') {
    //       DataState playlistState = await playlistApiService.getPlaylistDetails(
    //         trending[i].id!,
    //         'remote',
    //       );
    //       if (playlistState is DataSuccess) {
    //         PlaylistModel playlistDetails = playlistState.data;
    //         if (playlistDetails.songs.isNotEmpty) {
    //           response.addAll(playlistDetails.songs);
    //         }
    //       }
    //     }
    //   }
    // }

    // Set<SongModel> songSet = response.toSet();
    // List<SongModel> uni = songSet.toList();
    // uni.shuffle();
    // await CacheHelper().saveInitialSongs(uni.map((e) => e.toJson()).toList());
    // if (isInitiating && uni.isNotEmpty) {
    //   isInitiating = false;
    //   notifyListeners();
    //   startPlaying(source: uni, i: 0, type: PlayingType.initial);
    // }
  }

  startPlaying({
    required List<SongModel> source,
    required int i,
    required PlayingType type,
    String id = 'id',
    bool hasToAddMoreSource = false,
    Duration? duration,
    List<PlaylistModel>? discoverPlaylist,
    bool isSocketCall = false,
    bool startPlaying = true,
  }) async {
    this.isSocketCall = isSocketCall;
    if (!roomProvider.hasPermissionToChange &&
        !roomProvider.isHost &&
        !isSocketCall) {
      errorMessage(
        navigatorKey.currentContext!,
        'Hold up! Only the room admin has the player controls. 🎧',
      );
      return;
    }

    if (controller.positions.isNotEmpty) controller.jumpToPage(0);
    audioHandler.setLoopMode(AudioServiceRepeatMode.all);
    playingModel = PlayingModel(type: type, id: id);
    playingList = List.from(source);
    List<MediaItem> mediaItems =
        source
            .map(
              (e) => e.toMediaItem(
                playingModel.type == PlayingType.download ||
                    playingModel.type == PlayingType.downloadedAlbum ||
                    playingModel.type == PlayingType.downloadedPlaylist,
              ),
            )
            .toList();
    audioHandler.initSongs(
      songs: mediaItems,
      index: i,
      duration: duration,
      startPlaying: startPlaying,
    );
    if (playingList.isEmpty) return;
    if (playingList.length < i) {
      return;
    }
    nowPlaying = playingList[i];
    isLoading = true;
    isLoaded = true;
    isInitiating = false;
    notifyListeners();
    if (!audioHandler.isSocketCall && roomProvider.isInRoom) {
      audioHandler.updatePlaylist(
        mediaItems,
        i,
        playingModel.type.name,
        playingModel.id,
      );
    }
    listenToChangesInPlaylist();
    controller.addListener(setUpMusicUI);
    listenToTotalDuration();
    listenToCurrentPosition();
    listenToBufferedPosition();
    listenToChangesInSong();
    listenToPlaybackState();
    notifyListeners();
    if (hasToAddMoreSource) {
      addMoreSources(source.first);
    }
    if (discoverPlaylist != null) {
      getSongsFromPlaylist(discoverPlaylist);
    }
  }

  getSongsFromPlaylist(List<PlaylistModel> discoverPlaylist) async {
    List<SongModel> gotted = [];

    discoverPlaylist.shuffle();
    List<PlaylistModel> selectedPlaylists = discoverPlaylist.take(3).toList();

    for (int i = 0; i < selectedPlaylists.length; i++) {
      DataState state = await playlistApiService.getPlaylistDetails(
        selectedPlaylists[i].id,
        'remote',
      );
      if (state is DataSuccess) {
        PlaylistModel playlistDetails = state.data;
        gotted.addAll(playlistDetails.songs);
      }
    }

    gotted.shuffle();
    Set<SongModel> songSet = gotted.toSet();
    List<SongModel> uni = songSet.toList();
    List<MediaItem> items =
        uni
            .map(
              (e) => e.toMediaItem(
                playingModel.type == PlayingType.download ||
                    playingModel.type == PlayingType.downloadedAlbum ||
                    playingModel.type == PlayingType.downloadedPlaylist,
              ),
            )
            .toList();
    audioHandler.addQueueItems(items);
    notifyListeners();
  }

  addMoreSources(SongModel song) async {
    final dataState = await songDetailsUseCase.call(songId: song.id);
    if (dataState is DataSuccess) {
      List<SongModel> newQueue = dataState.data!.songs;
      newQueue.removeAt(0);
      Set<SongModel> songSet = newQueue.toSet();
      List<SongModel> uni = songSet.toList();
      List<MediaItem> items =
          uni
              .map(
                (e) => e.toMediaItem(
                  playingModel.type == PlayingType.download ||
                      playingModel.type == PlayingType.downloadedAlbum ||
                      playingModel.type == PlayingType.downloadedPlaylist,
                ),
              )
              .toList();
      audioHandler.addQueueItems(items);
      notifyListeners();
    }
  }

  void listenToChangesInPlaylist() {
    audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) return;
      final newList = playlist.map((item) => item).toList();
      playingList = newList.map((e) => e.songModel).toList();
      CacheHelper().savePlayedSongs(
        playingList.map((e) => e.toJson()).toList(),
      );
      CacheHelper().savePlayedSource(playingModel.type.name);
      notifyListeners();
    });
  }

  void listenToCurrentPosition() {
    AudioService.position.listen((position) {
      currentDuration = position;
      notifyListeners();
    });
  }

  void listenToBufferedPosition() {
    audioHandler.playbackState.listen((playbackState) {
      bufferedDuration = playbackState.bufferedPosition;
      notifyListeners();
    });
  }

  void listenToTotalDuration() {
    audioHandler.mediaItem.listen((mediaItem) {
      totalDuration = mediaItem?.duration ?? Duration.zero;
      notifyListeners();
    });
  }

  void listenToPlaybackState() {
    audioHandler.playbackState.listen((playbackState) {
      isPlaying = playbackState.playing;
      notifyListeners();
      final processingState = playbackState.processingState;

      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playingIndex = playbackState.queueIndex ?? 0;
        isLoading = true;
        notifyListeners();
      } else if (!isPlaying) {
        isPlaying = false;
        isLoading = false;
        notifyListeners();
      } else if (processingState != AudioProcessingState.completed) {
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        audioHandler.seek(Duration.zero);
        audioHandler.pause();
      }
    });
  }

  void listenToChangesInSong() {
    audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem == null) return;
      nowPlaying = mediaItem.songModel;
      isLoaded = true;
      playingIndex = songIndex(playingList, nowPlaying!);
      if (controller.positions.isNotEmpty) {
        if (controller.page != playingIndex.toDouble()) {
          controller.jumpToPage(playingIndex);
          notifyListeners();
        }
      }
      CacheHelper().savePlayedIndex(playingIndex);
      updateRecentPlayed();
      notifyListeners();
    });
  }

  seekPosition(Duration duration) async {
    await audioHandler.seek(duration);
    notifyListeners();
  }

  void changeTrack(bool isNext) async {
    if (isNext) {
      if (playingIndex < playingList.length - 1) {
        playingIndex++;
      } else {
        playingIndex = 0;
      }
    } else {
      if (playingIndex > 0) {
        playingIndex--;
      } else {
        playingIndex = playingList.length - 1;
      }
    }

    nowPlaying = playingList[playingIndex];
    audioHandler.setLoopMode(AudioServiceRepeatMode.all);
    repeatMode = AudioServiceRepeatMode.all;
    isNext ? audioHandler.skipToNext() : audioHandler.skipToPrevious();
    notifyListeners();
  }

  togglePlayer() async {
    audioHandler.audioPlayer.playing
        ? await audioHandler.pause()
        : await audioHandler.play();
    notifyListeners();
  }

  List<SongModel> getNextFiveOrRemaining() {
    if (songIndex(playingList, nowPlaying!) >= playingList.length) {
      return [];
    } else if (songIndex(playingList, nowPlaying!) + 5 < playingList.length) {
      return playingList.sublist(
        songIndex(playingList, nowPlaying!) + 1,
        songIndex(playingList, nowPlaying!) + 6,
      );
    } else {
      return playingList.sublist(songIndex(playingList, nowPlaying!) + 1);
    }
  }

  changeLoopMode(AudioServiceRepeatMode repeatMode) {
    audioHandler.setLoopMode(repeatMode);
    this.repeatMode = repeatMode;
    notifyListeners();
  }

  changeToIndex(int index, [bool hasToUpdate = true]) async {
    if (!roomProvider.hasPermissionToChange &&
        !roomProvider.isHost &&
        !isSocketCall) {
      errorMessage(
        navigatorKey.currentContext!,
        'Hold up! Only the room admin has the player controls. 🎧',
      );
      return;
    }

    if (isSocketCall) {
      await Future.delayed(const Duration(seconds: 4));
      isSocketCall = false;
      return;
    }
    audioHandler.skipToQueueItem(index);
    notifyListeners();
  }

  setUpMusicUI() {
    double currentPageValue = controller.page ?? 0.0;
    if (currentPageValue == currentPageValue.floorToDouble() &&
        isUserScrolling) {
      if (playingIndex != controller.page) {
        changeToIndex(controller.page!.round());
      }
    }
  }

  initializeRecentList() async {
    await CacheHelper().getUserRecentSongs();
    DataState state = await recentApiService.getRecentSongs(
      Cache.instance.userId,
    );
    if (state is DataSuccess) {
      List oldRecents = await CacheHelper().getUserRecentSongs();
      List recents = state.data;
      List combined = [...oldRecents, ...recents];
      List uniqueItems = combined.toSetBy((e) => e['model']['id']).toList();
      await CacheHelper().saveUserRecentSongs(uniqueItems);
      recentApiService.updateRecentSongs(Cache.instance.userId, uniqueItems);
    }
  }

  updateRecentPlayed() async {
    if (!isPlaying || nowPlaying == null) return;
    List stored = await CacheHelper().getUserRecentSongs();
    Map? song = stored.firstWhereOrNull(
      (e) => e['model']['id'] == nowPlaying!.id,
    );
    int listenCount = 0;
    if (song != null) {
      listenCount = song['listenCount'] + 1;
    } else {
      listenCount = 1;
    }
    stored.removeWhere((e) => e['model']['id'] == nowPlaying!.id);
    stored.insert(0, {
      'model': nowPlaying!.toJson(),
      'listenCount': listenCount,
    });
    await CacheHelper().saveUserRecentSongs(stored);
    notifyListeners();
  }

  update() {
    notifyListeners();
  }
}
