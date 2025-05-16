part of 'deep_link_api_service.dart';

class DeepLinkApiServiceImp implements DeepLinkApiService {
  @override
  Future<String> createDefferLink(String link) async {
    try {
      final client = http.Client();
      final response = await client.post(
        Uri.parse('https://link.tuneflow.info/create-link'),
        body: jsonEncode({'androidUrl': link}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['dynamicLink'];
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Future<String> extractLink(String id) async {
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('https://link.tuneflow.info/$id/extract'),
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
