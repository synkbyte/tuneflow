import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/data/data_source/artist_data_source.dart';

class ArtistProvider extends ChangeNotifier {
  List<ArtistModel> savedArtists = [];
  ArtistApiService service = sl();

  Future<void> intializeArtist() async {
    List artists = await CacheHelper().getUserSelectedArtists();

    if (artists.isNotEmpty) {
      savedArtists = artists.map((e) => ArtistModel.fromJson(e)).toList();
      notifyListeners();
    }

    DataState state = await service.getSavedArtists(Cache.instance.userId);
    if (state is DataSuccess) {
      savedArtists = state.data;
      await CacheHelper().saveSelectedUserArtists(
        savedArtists.map((e) => e.toMap()).toList(),
      );
    }
    notifyListeners();
  }

  Future<void> toggleArtistBookmark(ArtistModel artist) async {
    if (isSavedArtist(artist)) {
      savedArtists.removeWhere((element) => element.id == artist.id);
      Fluttertoast.showToast(msg: 'Removed from Bookmark');
    } else {
      savedArtists.insert(0, artist);
      Fluttertoast.showToast(msg: 'Saved to Bookmark');
    }
    await CacheHelper().saveSelectedUserArtists(
      savedArtists.map((e) => e.toMap()).toList(),
    );
    await service.updateSelectedArtists(
      Cache.instance.userId,
      savedArtists.map((e) => e.toMap()).toList(),
    );
    notifyListeners();
  }

  bool isSavedArtist(ArtistModel artist) {
    ArtistModel? model =
        savedArtists.firstWhereOrNull((element) => element.id == artist.id);
    return model != null;
  }
}
