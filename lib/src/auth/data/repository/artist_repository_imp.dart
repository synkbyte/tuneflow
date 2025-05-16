import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/auth/data/data_source/artist_data_source.dart';
import 'package:new_tuneflow/src/auth/data/models/signup_model.dart';
import 'package:new_tuneflow/src/auth/domain/repository/artist_repository.dart';

class ArtistRepositoryImp implements ArtistRepository {
  final ArtistApiService _artistApiService;
  ArtistRepositoryImp(this._artistApiService);

  @override
  Future<DataState<List<ArtistModel>>> getArtistByQuery(String query) async {
    return await _artistApiService.getArtistByQuery(query: query);
  }

  @override
  Future<DataState<List<ArtistModel>>> getTopArtists() async {
    return await _artistApiService.getTopArtists();
  }

  @override
  Future<DataState<SignupModel>> updateSelectedArtists(
    int userId,
    List artists,
  ) async {
    return await _artistApiService.updateSelectedArtists(userId, artists);
  }
}
