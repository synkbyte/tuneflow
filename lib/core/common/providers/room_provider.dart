import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:just_audio/just_audio.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/bloc/state_bloc.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/main.dart';
import 'package:new_tuneflow/src/forum/presentation/screens/forum_screen.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/premium.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class RoomProvider extends ChangeNotifier {
  Map payload = {};
  bool isInRoom = false;
  bool isHost = false;
  bool isMuted = true;
  String roomId = '';
  List messages = [];
  Map? replyingMessage;
  List users = [];
  List<RoomModel> popRooms = [];
  List<RoomModel> locationRoom = [];
  List<RoomModel> countryRoom = [];
  bool isServicEnabled = false;
  String location = '';
  bool doesWeHaveLocation = false;
  bool isPressedOnLater = false;
  String city = '';
  String country = '';
  bool isNewUpdateAvailable = false;
  bool hasPermissionToChange = true;
  bool isPrivate = true;

  insertPayload(List playlist, int index, bool isPrivate) {
    payload = {
      'type': 'create',
      'clientId': Cache.instance.userId,
      'name': User.instance.user?.name ?? '$appName User',
      'userName': User.instance.user?.userName ?? '',
      'avatar': User.instance.user!.avatar,
      'playlist': playlist,
      'index': index,
      'lat': 0.0,
      'lng': 0.0,
      'city': city,
      'country': country,
      'isPrivate': isPrivate,
      'method': playerProvider.playingModel.type.name,
      'methodId': playerProvider.playingModel.id,
      'version': buildNumber,
      'batch': User.instance.user?.getBatch() ?? {'hasBatch': false},
    };
  }

  roomCreated(String roomId, List users, bool isPrivate) {
    payload = {};
    messages = [];
    this.roomId = roomId;
    this.users = users;
    this.isPrivate = isPrivate;
    isInRoom = true;
    isHost = true;
    messages.add({'type': 'action', 'message': 'You created the room.'});
    notifyListeners();
    audioHandler.isLoading = false;
    stateBloc.add(const StateChangeIndex(0));
  }

  handleMessages(Map message, List users) async {
    messages.insert(0, message);
    if (message['userId'] != Cache.instance.userId && !isMuted) {
      AudioPlayer player = AudioPlayer();
      await player.setAudioSource(
        AudioSource.asset('assets/audios/new_action.wav'),
      );
      player.play();
    }
    this.users = users;
    notifyListeners();
  }

  updateReplyingMessage(Map message) {
    replyingMessage = message;
    notifyListeners();
  }

  clearReplyingMessage() {
    replyingMessage = null;
    notifyListeners();
  }

  roomJoined(Map room, List users, bool isPrivate, bool hasPermissionToChange) {
    payload = {};
    messages = [];
    roomId = room['id'];
    List p = room['playlist'];
    List<SongModel> source = p.map((e) => SongModel.fromJson(e)).toList();
    playerProvider.startPlaying(
      source: source,
      i: room['currentIndex'],
      type: stringToType(room['method']),
      id: room['methodId'],
      duration: Duration(milliseconds: room['position']),
    );
    this.users = users;
    isInRoom = true;
    isHost = false;
    messages.add({'type': 'action', 'message': 'You joined the room.'});
    notifyListeners();
    audioHandler.isLoading = false;
    this.isPrivate = isPrivate;
    this.hasPermissionToChange = hasPermissionToChange;
    stateBloc.add(const StateChangeIndex(0));
  }

  handleRoomClosed() {
    payload = {};
    isInRoom = false;
    isHost = false;
    audioHandler.isLoading = false;
    roomId = '';
    users = [];
    messages.insert(0, {'type': 'action', 'message': 'The room is closed.'});
    notifyListeners();
  }

  handleRemoved() {
    payload = {};
    isInRoom = false;
    isHost = false;
    audioHandler.isLoading = false;
    hasPermissionToChange = true;
    roomId = '';
    users = [];
    messages.insert(0, {
      'type': 'action',
      'message': 'Admin removed you from the room.',
    });
    notifyListeners();
  }

  handleRoomLeaved() {
    payload = {};
    isInRoom = false;
    isHost = false;
    audioHandler.isLoading = false;
    hasPermissionToChange = true;
    roomId = '';
    users = [];
    messages.insert(0, {'type': 'action', 'message': 'You leaved the room.'});
    notifyListeners();
  }

  updatePopRooms(List rooms) {
    popRooms = rooms.map((e) => RoomModel.fromJson(e)).toList();
    notifyListeners();
  }

  updateLocationRooms(List rooms) {
    locationRoom = rooms.map((e) => RoomModel.fromJson(e)).toList();
    notifyListeners();
  }

  updateCountryRooms(List rooms) {
    countryRoom = rooms.map((e) => RoomModel.fromJson(e)).toList();
    notifyListeners();
  }

  getRooms() {
    audioHandler.getPopRooms();
    if (isServicEnabled) {
      audioHandler.getLocationRooms(city);
      audioHandler.getCountryRooms(country);
    }
  }

  checkUpdate() async {
    isNewUpdateAvailable = await isUpdateAvailable();
    notifyListeners();
  }

  showPopupMessage(
    String title,
    String message,
    String actionType,
    String actionText,
    String action,
  ) async {
    int userId = await CacheHelper().getUserId();
    if (userId == 0) {
      return;
    }
    if (actionType == 'joinRoom' && isInRoom) {
      return;
    }
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              minWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height,
              minHeight: 100,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Gap(5),
                Text(message),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Later',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.scheme.error,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (actionType == 'room') {
                          context.read<StateBloc>().add(
                            const StateChangeIndex(2),
                          );
                        }
                        if (actionType == 'url') {
                          launchUrl(Uri.parse(action));
                        }
                        if (actionType == 'joinRoom') {
                          audioHandler.joinRoom(action);
                        }
                        if (actionType == 'premiumScreen') {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: const PremiumScreen(),
                              type: PageTransitionType.fade,
                            ),
                          );
                        }
                        if (actionType == 'forumScreen') {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: const ForumScreen(),
                              type: PageTransitionType.fade,
                            ),
                          );
                        }
                      },
                      child: Text(
                        actionText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  toggleMute() {
    isMuted = !isMuted;
    notifyListeners();
  }

  updateSettings(bool isPrivate, bool hasPermissionToChange) {
    this.isPrivate = isPrivate;
    this.hasPermissionToChange = hasPermissionToChange;
    notifyListeners();
  }

  changeAdmin() {
    isHost = true;
    notifyListeners();
  }

  changedAdmin() {
    isHost = false;
    notifyListeners();
  }

  updateUsers(List users) {
    this.users = users;
    notifyListeners();
  }

  reset() {
    payload = {};
    messages = [];
    isInRoom = false;
    isHost = false;
    roomId = '';
    users = [];
    audioHandler.isLoading = false;
    hasPermissionToChange = true;
    notifyListeners();
  }

  update() {
    notifyListeners();
  }
}
