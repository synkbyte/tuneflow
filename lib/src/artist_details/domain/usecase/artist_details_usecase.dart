import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/artist_details/domain/repository/artist_details_repository.dart';
import 'package:new_tuneflow/src/auth/domain/entites/artist_entity.dart';

class ArtistDetailsUseCase extends UseCase<DataState<ArtistEntity>, void> {
  final ArtistDetailsRepository _playlistRepository;
  ArtistDetailsUseCase(this._playlistRepository);

  @override
  Future<DataState<ArtistEntity>> call({void params, String? id}) async {
    return await _playlistRepository.getArtistDetails(id!);
  }
}
