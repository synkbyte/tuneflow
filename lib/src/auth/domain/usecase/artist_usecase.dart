import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/auth/domain/entites/artist_entity.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:new_tuneflow/src/auth/domain/repository/artist_repository.dart';

class ArtistUseCase implements UseCase<DataState<List<ArtistEntity>>, void> {
  final ArtistRepository _artistRespository;
  ArtistUseCase(this._artistRespository);

  @override
  Future<DataState<List<ArtistEntity>>> call({void params}) async {
    return await _artistRespository.getTopArtists();
  }

  Future<DataState<List<ArtistEntity>>> getArtistByQuery(String query) async {
    return await _artistRespository.getArtistByQuery(query);
  }

  Future<DataState<SignupEntity>> updateSelectedArtists(
    int userId,
    List artists,
  ) async {
    return await _artistRespository.updateSelectedArtists(userId, artists);
  }
}
