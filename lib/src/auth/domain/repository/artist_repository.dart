import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/auth/domain/entites/artist_entity.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';

abstract class ArtistRepository {
  Future<DataState<List<ArtistEntity>>> getTopArtists();
  Future<DataState<List<ArtistEntity>>> getArtistByQuery(String query);
  Future<DataState<SignupEntity>> updateSelectedArtists(
    int userId,
    List artists,
  );
}
