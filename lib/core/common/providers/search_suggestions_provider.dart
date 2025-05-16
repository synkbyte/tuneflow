import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/services/api_service/app/search_suggestion_api_service.dart';
import 'package:new_tuneflow/injection_container.dart';

class SearchSuggestionsProvider extends ChangeNotifier {
  List trending = [];
  SearchSuggestionApiService service = sl();
  List suggestions = [];

  getTrendings() async {
    trending = await service.getTrending();
    notifyListeners();
  }

  getSuggestions(String q) async {
    suggestions = await service.getSuggestion(q);
    notifyListeners();
  }

  clearSuggestions() {
    suggestions = [];
    notifyListeners();
  }
}
