import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/auth/domain/entites/artist_entity.dart';

abstract class ArtistDetailsRepository {
  Future<DataState<ArtistEntity>> getArtistDetails(String id);
}
