import 'dart:math';

import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/constants/constants.dart';

bool isActive(
  PlayerProvider provider,
  String type,
  String? songId,
  String? playlistId,
) {
  if (songId == null) {
    return provider.playingModel
        .isPlayingFromThis(stringToType(type), playlistId ?? 'id');
  }
  return provider.playingModel
          .isPlayingFromThis(stringToType(type), playlistId ?? 'id') &&
      provider.nowPlaying!.isThisSong(songId);
}

Uri parseUrl(
  String endpoint, [
  Map<String, String>? params,
  bool isForAuth = false,
]) {
  return Uri.https(isForAuth ? authApiBaseUrl : apiBaseUrl, endpoint, params);
}

String generateRandomId() {
  const String chars = 'abcdefghijklmnopqrstuvwxyz';
  Random random = Random();
  return List.generate(7, (index) => chars[random.nextInt(chars.length)])
      .join();
}

String formatFollowersCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
  } else {
    return count.toString();
  }
}
