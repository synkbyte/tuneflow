part of 'album_data_source.dart';

class AlbumApiServiceImp implements AlbumApiService {
  @override
  Future<DataState<AlbumModel>> getAlbumDetails(String id) async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'content.getAlbumDetails',
          'albumid': id,
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

      AlbumModel albumModel = AlbumModel(
        id: resBody['id'],
        title: filteredText(resBody['title']),
        subtitle: resBody['header_desc'],
        image: createImageLinks(resBody['image']),
        songs: songsModel,
      );

      return DataSuccess(albumModel);
    } catch (e) {
      return DataError('Something went wrong');
    }
  }
}
