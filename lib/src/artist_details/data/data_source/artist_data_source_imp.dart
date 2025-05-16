part of 'artist_details_data_source.dart';

class ArtistDetailsApiServiceImp implements ArtistDetailsApiService {
  @override
  Future<DataState<ArtistModel>> getArtistDetails(String id) async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'artist.getArtistPageDetails',
          'artistId': id,
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

      List songs = resBody['topSongs'];
      List<SongModel> songsModel =
          songs.map((e) => SongModel.fromJson(e)).toList();

      List topAlbums = resBody['topAlbums'];
      List<AlbumModel> topAlbumsModel =
          topAlbums.map((e) => AlbumModel.fromJson(e)).toList();

      List dedicatedArtistPlaylist = resBody['dedicated_artist_playlist'];
      List<PlaylistModel> dedicatedArtistPlaylistModel = dedicatedArtistPlaylist
          .map((e) => PlaylistModel.fromJson(e))
          .toList();

      List featuredArtistPlaylist = resBody['featured_artist_playlist'];
      List<PlaylistModel> featuredArtistPlaylistModel =
          featuredArtistPlaylist.map((e) => PlaylistModel.fromJson(e)).toList();

      List singles = resBody['singles'];
      List<AlbumModel> singlesModel =
          singles.map((e) => AlbumModel.fromJson(e)).toList();

      List latestRelease = resBody['latest_release'];
      List<AlbumModel> latestReleaseModel =
          latestRelease.map((e) => AlbumModel.fromJson(e)).toList();

      ArtistModel albumModel = ArtistModel(
        id: resBody['artistId'],
        name: filteredText(resBody['name']),
        image: createImageLinks(resBody['image']),
        songs: songsModel,
        topAlbums: topAlbumsModel,
        dedicatedArtistPlaylist: dedicatedArtistPlaylistModel,
        featuredArtistPlaylist: featuredArtistPlaylistModel,
        singles: singlesModel,
        latestRelease: latestReleaseModel,
      );

      return DataSuccess(albumModel);
    } catch (e) {
      return DataError('Something went wrong');
    }
  }
}
