// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:new_tuneflow/core/common/app/cache_helper.dart';
// import 'package:new_tuneflow/core/common/models/models.dart';
// import 'package:new_tuneflow/core/common/singletones/cache.dart';
// import 'package:new_tuneflow/core/common/singletones/user.dart';
// import 'package:new_tuneflow/core/constants/constants.dart';
// import 'package:new_tuneflow/core/extensions/media_item_extenstions.dart';
// import 'package:new_tuneflow/core/services/api_service/room/room_api_service.dart';
// import 'package:new_tuneflow/core/snackbar/snackbar.dart';
// import 'package:new_tuneflow/injection_container.dart';
// import 'package:new_tuneflow/main.dart';
// import 'package:web_socket_client/web_socket_client.dart';
// import 'package:audio_service/audio_service.dart';
// import 'package:just_audio/just_audio.dart';

// class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
//   AudioPlayer audioPlayer = AudioPlayer();
//   ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
//   bool isSocketIsConnect = false;
//   bool isRequestedForConnectSocket = false;
//   late WebSocket webSocket;
//   bool isSocketCall = false;
//   Timer? timer;
//   bool isLoading = false;
//   Timer? _sleepTimer;
//   Duration? _remainingTime;
//   bool hasCliping = false;
//   Duration? clipStart;
//   Duration? clipEnd;
//   bool isFavorite = false;

//   MyAudioHandler() {
//     audioPlayer.playbackEventStream.listen(_broadcastState);
//     _listenForCurrentSongIndexChanges();
//     _listenForDurationChanges();
//     _listenForSequenceStateChanges();
//     _setupClipLoop();
//   }

//   void startSleepTimer(Duration duration) {
//     _sleepTimer?.cancel();
//     _remainingTime = duration;

//     _sleepTimer = Timer(duration, () {
//       audioPlayer.pause();
//       _sleepTimer = null;
//       _remainingTime = null;
//       exit(0);
//     });

//     Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingTime != null && _remainingTime!.inSeconds > 0) {
//         _remainingTime = _remainingTime! - const Duration(seconds: 1);
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   void cancelSleepTimer() {
//     _sleepTimer?.cancel();
//     _sleepTimer = null;
//     _remainingTime = null;
//   }

//   bool isSleepTimerActive() {
//     return _sleepTimer != null;
//   }

//   Duration? getRemainingTime() {
//     return _remainingTime;
//   }

//   UriAudioSource _createAudioSource(MediaItem mediaItem) {
//     final url = mediaItem.extras!['url'] as String;
//     if (Platform.isAndroid) {
//       return ProgressiveAudioSource(Uri.parse(url), tag: mediaItem);
//     }

//     bool isLocalFile = false;
//     if (url.startsWith('http://') || url.startsWith('https://')) {
//       isLocalFile = false;
//     } else if (url.startsWith('file://')) {
//       isLocalFile = false;
//     } else {
//       isLocalFile = true;
//     }

//     if (isLocalFile) {
//       return AudioSource.file(url, tag: mediaItem);
//     } else {
//       return ProgressiveAudioSource(Uri.parse(url), tag: mediaItem);
//     }
//   }

//   void _listenForCurrentSongIndexChanges() {
//     audioPlayer.currentIndexStream.listen((index) {
//       final playlist = queue.value;
//       if (index == null || playlist.isEmpty) return;
//       mediaItem.add(playlist[index]);
//     });
//   }

//   void _listenForDurationChanges() {
//     audioPlayer.durationStream.listen((duration) {
//       var index = audioPlayer.currentIndex;
//       final newQueue = queue.value;
//       if (index == null || newQueue.isEmpty) return;
//       final oldMediaItem = newQueue[index];
//       final newMediaItem = oldMediaItem.copyWith(duration: duration);
//       newQueue[index] = newMediaItem;
//       queue.add(newQueue);
//       mediaItem.add(newMediaItem);
//     });
//   }

//   void _listenForSequenceStateChanges() {
//     audioPlayer.sequenceStateStream.listen((SequenceState? sequenceState) {
//       final sequence = sequenceState?.effectiveSequence;
//       if (sequence == null || sequence.isEmpty) return;
//       final items = sequence.map((source) => source.tag as MediaItem);
//       queue.add(items.toList());
//     });
//   }

//   void _broadcastState(PlaybackEvent event) {
//     final currentState = playbackState.value;
//     playbackState.add(
//       currentState.copyWith(
//         controls: [
//           MediaControl.skipToPrevious,
//           if (audioPlayer.playing) MediaControl.pause else MediaControl.play,
//           MediaControl.skipToNext,
//           MediaControl.custom(
//             androidIcon: 'drawable/fav_outline',
//             label: isFavorite ? 'Unfavorite' : 'Favorite',
//             name: 'favorite',
//           ),
//         ],
//         systemActions: {
//           MediaAction.seek,
//           MediaAction.seekForward,
//           MediaAction.seekBackward,
//         },
//         processingState:
//             const {
//               ProcessingState.idle: AudioProcessingState.idle,
//               ProcessingState.loading: AudioProcessingState.loading,
//               ProcessingState.buffering: AudioProcessingState.buffering,
//               ProcessingState.ready: AudioProcessingState.ready,
//               ProcessingState.completed: AudioProcessingState.completed,
//             }[audioPlayer.processingState]!,
//         playing: audioPlayer.playing,
//         updatePosition: audioPlayer.position,
//         bufferedPosition: audioPlayer.bufferedPosition,
//         speed: audioPlayer.speed,
//         queueIndex: event.currentIndex,
//       ),
//     );
//   }

//   Future<void> initSongs({
//     required List<MediaItem> songs,
//     required int index,
//     Duration? duration,
//     bool startPlaying = true,
//     bool isLocalFile = false,
//   }) async {
//     removeClipping();
//     try {
//       final newQueue = queue.value..replaceRange(0, queue.value.length, songs);
//       queue.add(newQueue);
//       final audioSource = songs.map(_createAudioSource);
//       _playlist = ConcatenatingAudioSource(children: audioSource.toList());
//       await audioPlayer.setAudioSource(
//         _playlist,
//         initialIndex: index,
//         initialPosition: duration,
//       );
//       if (startPlaying) await audioPlayer.play();
//       isSocketCall = false;
//     } catch (error) {
//       errorMessage(
//         navigatorKey.currentContext!,
//         'The player is corrupted. Please restart the app.',
//       );
//       return;
//     }
//   }

//   @override
//   Future<void> addQueueItems(List<MediaItem> mediaItems) async {
//     if (!isSocketCall && roomProvider.isInRoom) {
//       updateMoreSource(mediaItems);
//     }
//     queue.add(queue.value..addAll(mediaItems));
//     final audioSource = mediaItems.map(_createAudioSource);
//     _playlist.addAll(audioSource.toList());
//     await super.addQueueItems(mediaItems);
//     isSocketCall = false;
//   }

//   @override
//   Future<void> play() async {
//     if (!isSocketCall && roomProvider.isInRoom) {
//       updatePlaybackState(true);
//     }
//     await audioPlayer.play();
//     isSocketCall = false;
//   }

//   @override
//   Future<void> pause() async {
//     if (!isSocketCall && roomProvider.isInRoom) {
//       updatePlaybackState(false);
//     }
//     await audioPlayer.pause();
//     isSocketCall = false;
//   }

//   @override
//   Future<void> seek(Duration position) async {
//     if (!isSocketCall && roomProvider.isInRoom) {
//       seekDuration(position);
//     }
//     await audioPlayer.seek(position);
//     isSocketCall = false;
//   }

//   @override
//   Future<void> skipToQueueItem(int index) async {
//     removeClipping();
//     if (!isSocketCall && roomProvider.isInRoom) {
//       changeIndex(index);
//     }
//     await audioPlayer.seek(Duration.zero, index: index);
//     await audioPlayer.play();
//     isSocketCall = false;
//   }

//   @override
//   Future<void> skipToNext() async {
//     removeClipping();
//     if (roomProvider.isInRoom) {
//       if (audioPlayer.hasNext) {
//         updateSkipToNext();
//       }
//     }
//     await audioPlayer.seekToNext();
//   }

//   @override
//   Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
//     if (!isSocketCall && roomProvider.isInRoom) {
//       insertQueueItemUpdate(index, mediaItem);
//     }
//     queue.add(queue.value..insert(index, mediaItem));
//     final audioSource = _createAudioSource(mediaItem);
//     _playlist.insert(index, audioSource);
//     super.insertQueueItem(index, mediaItem);
//     isSocketCall = false;
//   }

//   @override
//   Future<void> skipToPrevious() async {
//     removeClipping();
//     if (roomProvider.isInRoom) {
//       if (audioPlayer.hasPrevious) {
//         updateSkipToPrevious();
//       }
//     }
//     audioPlayer.seekToPrevious();
//   }

//   Future<void> setLoopMode(AudioServiceRepeatMode repeatMode) async {
//     switch (repeatMode) {
//       case AudioServiceRepeatMode.none:
//         audioPlayer.setLoopMode(LoopMode.off);
//         break;
//       case AudioServiceRepeatMode.one:
//         audioPlayer.setLoopMode(LoopMode.one);
//         break;
//       case AudioServiceRepeatMode.group:
//       case AudioServiceRepeatMode.all:
//         audioPlayer.setLoopMode(LoopMode.all);
//         break;
//     }
//     return super.setRepeatMode(repeatMode);
//   }

//   @override
//   Future<void> stop() async {
//     audioPlayer.stop();
//     await super.stop();
//   }

//   @override
//   Future<void> onTaskRemoved() async {
//     audioPlayer.stop();
//     await super.onTaskRemoved();
//     exit(0);
//   }

//   updateSocketCall(bool status) {
//     isSocketCall = status;
//   }

//   initializeWebSocket([String? action, String? roomId]) async {
//     isRequestedForConnectSocket = true;
//     const timeout = Duration(seconds: 10);
//     webSocket = WebSocket(Uri.parse(webSocketBaseUrl), timeout: timeout);

//     webSocket.connection.listen((event) async {
//       if (event is Disconnected || event is Disconnecting) {
//         isSocketIsConnect = false;
//         roomProvider.update();
//         webSocket = WebSocket(Uri.parse(webSocketBaseUrl), timeout: timeout);
//         if (roomProvider.isHost) {
//           roomProvider.handleRoomClosed();
//         } else {
//           roomProvider.handleRoomLeaved();
//         }
//       } else if (event is Connected || event is Reconnected) {
//         roomProvider.update();
//         isSocketIsConnect = true;
//         initialize();
//         if (action == 'create') {
//           createRoom();
//         }
//         if (action == 'join') {
//           joinRoom(roomId!);
//         }
//       }
//     });
//   }

//   initialize() async {
//     int userId = await CacheHelper().getUserId();
//     if (userId != 0) {
//       webSocket.send(
//         json.encode({'type': 'init', 'userId': userId, 'version': buildNumber}),
//       );
//       webSocket.send(json.encode({'type': 'myChats', 'userId': userId}));
//       if (chatProvider.selectedChatId != 0) {
//         chatProvider.getChatById(
//           chatProvider.selectedChatId,
//           chatProvider.selectedChat['chat']['user'],
//         );
//       }
//       _listenServerMessages();
//     }
//   }

//   closeSocket() async {
//     webSocket.close();
//     isSocketIsConnect = false;
//     roomProvider.update();
//   }

//   _listenServerMessages() async {
//     webSocket.messages.listen((event) {
//       Map message = json.decode(event);
//       if (message['type'] == 'initialized') {
//         defferLinkProvider.checkIfHasNavigation();
//         return;
//       }
//       if (message['type'] == 'updatedSubState') {
//         userProvider.updateUserRoom();
//         return;
//       }
//       if (message['type'] == 'playbackState') {
//         isSocketCall = true;
//         if (message['isPlaying']) {
//           play();
//         } else {
//           pause();
//         }
//         return;
//       }
//       if (message['type'] == 'created') {
//         isLoading = false;
//         roomProvider.update();
//         roomProvider.roomCreated(
//           message['roomId'],
//           message['users'],
//           message['isPrivate'],
//         );
//         updateTimer();
//         return;
//       }
//       if (message['type'] == 'userJoined') {
//         roomProvider.handleMessages({
//           'type': 'action',
//           'message': '${message['user']['name']} joined the room.',
//         }, message['users']);
//         return;
//       }
//       if (message['type'] == 'userLeft') {
//         roomProvider.handleMessages({
//           'type': 'action',
//           'message': '${message['user']['name']} left the room.',
//         }, message['users']);
//         return;
//       }
//       if (message['type'] == 'message') {
//         roomProvider.handleMessages(message, message['users']);
//         return;
//       }
//       if (message['type'] == 'removedUser') {
//         roomProvider.handleMessages({
//           'type': 'action',
//           'message': 'Admin removed ${message['name']} from the room.',
//         }, message['users']);
//         return;
//       }
//       if (message['type'] == 'roomEnded') {
//         isLoading = false;
//         roomProvider.update();
//         roomProvider.handleRoomClosed();
//         return;
//       }
//       if (message['type'] == 'joined') {
//         isLoading = false;
//         roomProvider.update();
//         roomProvider.roomJoined(
//           message['room'],
//           message['users'],
//           message['isPrivate'],
//           message['hasPermissionToChange'],
//         );
//         return;
//       }
//       if (message['type'] == 'changeIndex') {
//         isSocketCall = true;
//         skipToQueueItem(message['index']);
//         return;
//       }
//       if (message['type'] == 'seekPosition') {
//         isSocketCall = true;
//         seek(Duration(milliseconds: message['position']));
//         return;
//       }
//       if (message['type'] == 'changePlaylist') {
//         isSocketCall = true;
//         List p = message['playlist'];
//         List<SongModel> source = p.map((e) => SongModel.fromJson(e)).toList();
//         playerProvider.startPlaying(
//           source: source,
//           i: message['index'],
//           type: stringToType(message['method']),
//           id: message['methodId'],
//           isSocketCall: true,
//         );
//         return;
//       }
//       if (message['type'] == 'addQueue') {
//         isSocketCall = true;
//         List p = message['playlist'];
//         List<SongModel> source = p.map((e) => SongModel.fromJson(e)).toList();
//         List<MediaItem> items =
//             source
//                 .map(
//                   (e) => e.toMediaItem(
//                     playerProvider.playingModel.type == PlayingType.download ||
//                         playerProvider.playingModel.type ==
//                             PlayingType.downloadedAlbum ||
//                         playerProvider.playingModel.type ==
//                             PlayingType.downloadedPlaylist,
//                   ),
//                 )
//                 .toList();
//         addQueueItems(items);
//         return;
//       }
//       if (message['type'] == 'insertQueue') {
//         isSocketCall = true;
//         Map p = message['item'];
//         SongModel source = SongModel.fromJson(p);
//         insertQueueItem(
//           message['index'],
//           source.toMediaItem(
//             playerProvider.playingModel.type == PlayingType.download ||
//                 playerProvider.playingModel.type ==
//                     PlayingType.downloadedAlbum ||
//                 playerProvider.playingModel.type ==
//                     PlayingType.downloadedPlaylist,
//           ),
//         );
//         return;
//       }
//       if (message['type'] == 'popRooms') {
//         roomProvider.updatePopRooms(message['rooms']);
//         return;
//       }
//       if (message['type'] == 'locationRooms') {
//         roomProvider.updateLocationRooms(message['rooms']);
//         return;
//       }
//       if (message['type'] == 'countryRooms') {
//         roomProvider.updateCountryRooms(message['rooms']);
//         return;
//       }
//       if (message['type'] == 'removed') {
//         isLoading = false;
//         roomProvider.update();
//         roomProvider.handleRemoved();
//         return;
//       }
//       if (message['type'] == 'left') {
//         roomProvider.handleRoomLeaved();
//         return;
//       }
//       if (message['type'] == 'popUpMessage') {
//         roomProvider.showPopupMessage(
//           message['title'],
//           message['body'],
//           message['actionType'],
//           message['actionText'],
//           message['action'],
//         );
//         return;
//       }
//       if (message['type'] == 'error') {
//         errorMessage(navigatorKey.currentContext!, message['message']);
//         roomProvider.reset();
//         return;
//       }
//       if (message['type'] == 'updateSettings') {
//         roomProvider.updateSettings(
//           message['isPrivate'],
//           message['hasPermissionToChange'],
//         );
//         return;
//       }
//       if (message['type'] == 'changedAdmin') {
//         roomProvider.changedAdmin();
//         return;
//       }
//       if (message['type'] == 'changeAdmin') {
//         roomProvider.changeAdmin();
//         return;
//       }
//       if (message['type'] == 'updateUsers') {
//         roomProvider.updateUsers(message['users']);
//         return;
//       }
//       chatProvider.listenServerMessages(message);
//     });
//   }

//   createRoom() async {
//     removeClipping();
//     if (isLoading) return;
//     if (!isRequestedForConnectSocket) {
//       isLoading = true;
//       roomProvider.update();
//       initializeWebSocket('create');
//       return;
//     }
//     if (webSocket.connection.state is Connected) {
//       isLoading = true;
//       roomProvider.update();
//       if (!(User.instance.user?.isPremium ?? false)) {
//         if ((User.instance.user?.leftRoomCredits ?? 0) == 0) {
//           errorMessage(
//             navigatorKey.currentContext!,
//             'You have no room creation credits left this month. Upgrade to premium to create more rooms.',
//           );
//           isLoading = false;
//           roomProvider.update();
//           return;
//         }

//         RoomAPIService service = sl();
//         await service.updateRoomCreation(User.instance.user?.id ?? 0);
//       }

//       userProvider.updateUserRoom();
//       webSocket.send(json.encode(roomProvider.payload));
//     } else {
//       initializeWebSocket('create');
//     }
//   }

//   sendMessage(
//     String text,
//     bool isReplied,
//     String repliedId,
//     String repliedOnMessage,
//   ) {
//     webSocket.send(
//       json.encode({
//         'type': 'msg',
//         'roomId': roomProvider.roomId,
//         'text': text,
//         'name': User.instance.user?.name ?? '$appName User',
//         'avatar':
//             User.instance.user?.avatar ?? '$imageBaseUrl$defaultPersonAvatar',
//         'clientId': Cache.instance.userId,
//         'isReplied': isReplied,
//         'repliedId': repliedId,
//         'repliedOnMessage': repliedOnMessage,
//         'batch': User.instance.user?.getBatch() ?? {'hasBatch': false},
//       }),
//     );
//   }

//   removeUser(int userId, String name) {
//     webSocket.send(
//       json.encode({
//         'type': 'removeUsers',
//         'name': name,
//         'userId': userId,
//         'roomId': roomProvider.roomId,
//       }),
//     );
//   }

//   closeRoom() {
//     webSocket.send(
//       json.encode({'type': 'closeRoom', 'roomId': roomProvider.roomId}),
//     );
//   }

//   joinRoom(String roomId) {
//     removeClipping();
//     if (isLoading) return;
//     if (!isRequestedForConnectSocket) {
//       isLoading = true;
//       roomProvider.update();
//       initializeWebSocket('join', roomId);
//       return;
//     }
//     if (webSocket.connection.state is Connected) {
//       isLoading = true;
//       roomProvider.update();
//       webSocket.send(
//         json.encode({
//           'type': 'join',
//           'name': User.instance.user?.name ?? '$appName User',
//           'userName': User.instance.user?.userName ?? '',
//           'clientId': Cache.instance.userId,
//           'roomId': roomId,
//           'avatar': User.instance.user!.avatar,
//           'version': buildNumber,
//           'batch': User.instance.user?.getBatch() ?? {'hasBatch': false},
//         }),
//       );
//     } else {
//       initializeWebSocket('join', roomId);
//     }
//   }

//   leaveRoom() {
//     String roomId = roomProvider.roomId;
//     webSocket.send(
//       json.encode({
//         'type': 'leaveRoom',
//         'name': User.instance.user?.name ?? '$appName User',
//         'clientId': Cache.instance.userId,
//         'roomId': roomId,
//       }),
//     );
//   }

//   changeIndex(int index) {
//     webSocket.send(
//       json.encode({
//         "type": "changeIndex",
//         "roomId": roomProvider.roomId,
//         "index": index,
//       }),
//     );
//   }

//   updateTimer() async {
//     timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
//       if (roomProvider.isHost && playerProvider.isPlaying) {
//         final payload = jsonEncode({
//           "type": "updatePosition",
//           "roomId": roomProvider.roomId,
//           "position": playerProvider.currentDuration.inMilliseconds,
//           "index": playerProvider.playingIndex,
//         });
//         webSocket.send(payload);
//       }
//     });
//   }

//   seekDuration(Duration position) {
//     webSocket.send(
//       json.encode({
//         "type": "seek",
//         "roomId": roomProvider.roomId,
//         "position": position.inMilliseconds,
//       }),
//     );
//   }

//   updatePlaybackState(bool state) {
//     webSocket.send(
//       json.encode({
//         "type": "playbackState",
//         "roomId": roomProvider.roomId,
//         "isPlaying": state,
//         "userId": Cache.instance.userId,
//       }),
//     );
//   }

//   updateSkipToNext() {
//     webSocket.send(
//       json.encode({"type": "skipToNext", "roomId": roomProvider.roomId}),
//     );
//   }

//   changeRoomSetting(bool isPrivate, bool hasPermissionToChange) {
//     webSocket.send(
//       json.encode({
//         "type": "updateSettings",
//         "roomId": roomProvider.roomId,
//         "canAnyPlay": hasPermissionToChange,
//         "isPrivate": isPrivate,
//       }),
//     );
//   }

//   changeAdmin(int id) {
//     webSocket.send(
//       json.encode({
//         "type": "changeAdmin",
//         "roomId": roomProvider.roomId,
//         "newAdminId": id,
//       }),
//     );
//   }

//   updateSkipToPrevious() {
//     webSocket.send(
//       json.encode({"type": "skipToPrevious", "roomId": roomProvider.roomId}),
//     );
//   }

//   updatePlaylist(
//     List<MediaItem> playlist,
//     int index,
//     String method,
//     String methodId,
//   ) {
//     webSocket.send(
//       json.encode({
//         "type": "changePlaylist",
//         "roomId": roomProvider.roomId,
//         "playlist": playlist.map((e) => e.songModel).toList(),
//         "index": index,
//         "method": method,
//         "methodId": methodId,
//       }),
//     );
//   }

//   updateMoreSource(List<MediaItem> playlist) {
//     webSocket.send(
//       json.encode({
//         "type": "addQueue",
//         "roomId": roomProvider.roomId,
//         'playlist': playlist.map((e) => e.songModel).toList(),
//       }),
//     );
//   }

//   insertQueueItemUpdate(int index, MediaItem item) {
//     webSocket.send(
//       json.encode({
//         "type": "insertQueue",
//         "roomId": roomProvider.roomId,
//         'item': item.songModel,
//         'index': index,
//       }),
//     );
//   }

//   getPopRooms() {
//     webSocket.send(
//       json.encode({'type': 'getPopRooms', 'userId': Cache.instance.userId}),
//     );
//   }

//   getLocationRooms(String city) {
//     webSocket.send(
//       json.encode({
//         'type': 'getLocationRooms',
//         'userId': Cache.instance.userId,
//         'city': city,
//       }),
//     );
//   }

//   getCountryRooms(String country) {
//     webSocket.send(
//       json.encode({
//         'type': 'getCountryRooms',
//         'userId': Cache.instance.userId,
//         'country': country,
//       }),
//     );
//   }

//   void _setupClipLoop() {
//     audioPlayer.positionStream.listen((position) {
//       if (hasCliping && clipStart != null && clipEnd != null) {
//         if (position >= clipEnd!) {
//           audioPlayer.seek(clipStart!, index: audioPlayer.currentIndex);
//         }
//       }
//     });
//   }

//   void setClipping(Duration start, Duration end) {
//     if (start >= end) {
//       return;
//     }

//     audioPlayer.seek(start);
//     clipStart = start;
//     clipEnd = end;
//     hasCliping = true;

//     if (audioPlayer.position < clipStart! || audioPlayer.position > clipEnd!) {
//       audioPlayer.seek(clipStart!, index: audioPlayer.currentIndex);
//     }
//   }

//   void removeClipping() {
//     hasCliping = false;
//     clipStart = null;
//     clipEnd = null;
//     playerProvider.isLooping = false;
//     playerProvider.update();
//   }

//   bool isClippingActive() {
//     return hasCliping;
//   }

//   Map<String, Duration?> getClipRange() {
//     return {'start': clipStart, 'end': clipEnd};
//   }

//   @override
//   Future<dynamic> customAction(
//     String name, [
//     Map<String, dynamic>? extras,
//   ]) async {
//     if (name == 'favorite') {
//       isFavorite = !isFavorite;
//       // Force update the notification
//       final currentState = playbackState.value;
//       playbackState.add(currentState);
//       return isFavorite;
//     }
//     return super.customAction(name, extras);
//   }
// }
