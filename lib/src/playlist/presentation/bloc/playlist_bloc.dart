import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/models/user_model.dart';
import 'package:new_tuneflow/core/common/providers/playlist_provider.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/main.dart';
import 'package:new_tuneflow/src/playlist/domain/entites/playlist_entity.dart';
import 'package:new_tuneflow/src/playlist/domain/usecase/playlist_usecase.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistUseCase _playlistUseCase;
  PlaylistBloc(this._playlistUseCase) : super(PlaylistInitial()) {
    on<PlaylistFetch>(getPlaylistDetails);
  }

  void getPlaylistDetails(PlaylistFetch event, Emitter emit) async {
    try {
      emit(PlaylistLoading());

      if (event.type == 'favorite') {
        List items = Cache.instance.userFavoriteSongs!;
        emit(
          PlaylistLoaded(
            PlaylistEntity(
              id: 'favorite',
              image: '',
              songCount: '${items.length}',
              songs: items.map((e) => SongModel.fromJson(e)).toList(),
              subtitle: 'Default',
              title: 'Liked Songs',
              type: 'favorite',
              userDetails: null,
            ),
          ),
        );
        return;
      } else if (event.type == 'recent') {
        List items = Cache.instance.userRecentPlays!;
        items = items.take(20).toList();
        emit(
          PlaylistLoaded(
            PlaylistEntity(
              id: 'recent',
              image: '',
              songCount: '${items.length}',
              songs: items.map((e) => SongModel.fromJson(e['model'])).toList(),
              subtitle: 'Default',
              title: 'Recent Played',
              type: 'recent',
              userDetails: null,
            ),
          ),
        );
        return;
      } else if (event.type == 'local') {
        emit(
          PlaylistLoaded(
            PlaylistEntity(
              id: '${event.playlist!.id}',
              image: event.playlist!.image,
              songCount: '${event.playlist!.songs.length}',
              songs: event.playlist!.songs,
              subtitle: 'Playlist',
              title: event.playlist!.name,
              type: 'local',
              userDetails: null,
            ),
          ),
        );
        return;
      } else if (event.type == 'localSecond') {
        emit(
          PlaylistLoaded(
            PlaylistEntity(
              id: '${event.playlist!.id}',
              image: event.playlist!.image,
              songCount: '${event.playlist!.songs.length}',
              songs: event.playlist!.songs,
              subtitle: '${getFirstName(event.user!.name)}\'s Playlist',
              title: event.playlist!.name,
              type: 'localSecond',
              userDetails: event.user,
            ),
          ),
        );
        return;
      } else if (event.type == 'downloaded') {
        emit(
          PlaylistLoaded(
            PlaylistEntity(
              id: event.playlist!.playlistId,
              image: event.playlist!.image,
              songCount: '${event.playlist!.songs.length}',
              songs: event.playlist!.songs,
              subtitle: 'Downloaded',
              title: event.playlist!.name,
              type: 'downloaded',
              userDetails: null,
            ),
          ),
        );
        return;
      }

      final dataState = await _playlistUseCase.call(
        id: event.id,
        type: event.type,
      );

      if (dataState is DataSuccess) {
        navigatorKey.currentContext!
            .read<PlaylistProvider>()
            .getRecommendedPlaylists(event.id);
        emit(PlaylistLoaded(dataState.data!));
      } else {
        emit(PlaylistError(dataState.error!));
      }
    } catch (e) {
      emit(const PlaylistError('Somthing went wrong'));
    }
  }
}
