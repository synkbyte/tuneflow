part of 'playlist_data_source.dart';

class PlaylistApiServiceImp implements PlaylistApiService {
  @override
  Future<DataState<PlaylistModel>> getPlaylistDetails(
    String id,
    String type,
  ) async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'playlist.getDetails',
          'listid': id,
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );

      Map resBody = jsonDecode(response.body);

      List songs = resBody['list'];
      List<SongModel> songsModel =
          songs.map((e) => SongModel.fromJson(e)).toList();

      PlaylistModel playlistModel = PlaylistModel(
        id: resBody['id'],
        title: resBody['title'],
        subtitle:
            '${resBody['more_info']['subtitle_desc'][0]}, ${resBody['more_info']['subtitle_desc'][1]}',
        image: resBody['image'],
        songCount: resBody['more_info']['song_count'] ?? resBody['list_count'],
        type: type,
        songs: songsModel,
      );

      return DataSuccess(playlistModel);
    } catch (e) {
      return DataError('Something went wrong');
    }
  }
}
