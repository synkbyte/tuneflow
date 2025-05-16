import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/artist_details/data/data_source/artist_details_data_source.dart';
import 'package:new_tuneflow/src/artist_details/domain/repository/artist_details_repository.dart';

class ArtistDetailsRepositoryImp implements ArtistDetailsRepository {
  final ArtistDetailsApiService _apiService;
  const ArtistDetailsRepositoryImp(this._apiService);

  @override
  Future<DataState<ArtistModel>> getArtistDetails(String id) async {
    return await _apiService.getArtistDetails(id);
  }
}
