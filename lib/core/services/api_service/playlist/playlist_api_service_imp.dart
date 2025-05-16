part of 'playlist_api_service.dart';

class PlaylistApiServiceGlobleImp implements PlaylistApiServiceGloble {
  @override
  Future<DataState<List<UserPlaylistModel>>> getPlaylist({
    required int userId,
  }) async {
    try {
      final client = http.Client();
      final url = parseUrl('playlists/get/$userId');
      final response = await client.get(url);
      Map resBody = json.decode(response.body);
      if (resBody['status']) {
        List playlists = resBody['playlists'];
        return DataSuccess(
          playlists
              .map((playlist) => UserPlaylistModel.fromJson(playlist))
              .toList(),
        );
      }
      return DataError('error while getting');
    } catch (e) {
      return DataError(e.toString());
    }
  }

  @override
  Future<DefaultResponse> addToPlaylist({
    required UserPlaylistModel model,
  }) async {
    try {
      final client = http.Client();
      final url = parseUrl('playlists/create');
      final body = {
        'userId': model.userId,
        'name': model.name,
        'isMine': model.isMine,
        'playlistId': model.playlistId,
        'type': model.type,
        'image': model.image,
        'isPublic': model.isPublic,
      };
      final response = await client.post(
        url,
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );
      return DefaultResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return DefaultResponse(status: false, message: 'Somthing went wrong');
    }
  }

  @override
  Future<DefaultResponse> updatePlaylist({
    required UserPlaylistModel model,
  }) async {
    try {
      final client = http.Client();
      final url = parseUrl('playlists/update/${model.id}');
      final body = {
        'name': model.name,
        'image': model.image,
        'isPublic': model.isPublic,
      };
      final response = await client.put(
        url,
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );
      return DefaultResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return DefaultResponse(status: false, message: 'Somthing went wrong');
    }
  }

  @override
  Future<DefaultResponse> removePlaylist({required int id}) async {
    try {
      final client = http.Client();
      final url = parseUrl('playlists/delete/$id');
      final response = await client.delete(url);
      return DefaultResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return DefaultResponse(status: false, message: 'Somthing went wrong');
    }
  }

  @override
  Future<DefaultResponse> addSongToPlaylist({
    required int id,
    required SongModel model,
  }) async {
    try {
      final client = http.Client();
      final url = parseUrl('playlists/add/$id');
      final body = json.encode({'songId': model.id, 'song': model.toJson()});
      final response = await client.put(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      return DefaultResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return DefaultResponse(status: false, message: 'Somthing went wrong');
    }
  }

  @override
  Future<DefaultResponse> removeSongFromPlaylist({
    required int id,
    required String songId,
  }) async {
    try {
      final client = http.Client();
      final url = parseUrl('playlists/remove/$id');
      final body = json.encode({'songId': songId});
      final response = await client.put(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      return DefaultResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return DefaultResponse(status: false, message: 'Somthing went wrong');
    }
  }

  @override
  Future<DefaultResponse> deletePlaylist({required int id}) async {
    try {
      final client = http.Client();
      final url = parseUrl('playlists/delete/$id');
      final response = await client.delete(url);
      return DefaultResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return DefaultResponse(status: false, message: 'Somthing went wrong');
    }
  }

  @override
  Future<DataState<List<PlaylistModel>>> getRecommendedPlaylists({
    required String id,
  }) async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'reco.getPlaylistReco',
          'listid': id,
        },
      );
      final response = await client.get(url);
      List resBody = jsonDecode(response.body);
      return DataSuccess(
        resBody.map((e) => PlaylistModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return DataError(e.toString());
    }
  }
}
