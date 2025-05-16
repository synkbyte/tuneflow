import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/album/domain/entites/album_entity.dart';

abstract class AlbumRepository {
  Future<DataState<AlbumEntity>> getAlbumDetails(String id);
}
