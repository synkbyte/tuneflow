part of 'search_suggestion_api_service.dart';

class SearchSuggestionApiServiceImp implements SearchSuggestionApiService {
  @override
  Future<List<Map>> getTrending() async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'content.getTopSearches',
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List resBody = json.decode(response.body);
      List<Map> result = resBody
          .where((item) => item['type'] != 'playlist')
          .map((item) => item as Map)
          .toList();
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map>> getSuggestion(String query) async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'search.getResults',
          'q': query,
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List resBody = json.decode(response.body)['results'];
      List<Map> result = resBody
          .where((item) => item['type'] != 'playlist')
          .map((item) =>
              {'title': filteredText(item['title']), 'image': item['image']})
          .toList();
      return result;
    } catch (e) {
      return [];
    }
  }
}
