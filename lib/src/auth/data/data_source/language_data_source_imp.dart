part of 'language_data_source.dart';

class LanguageApiServiceImp implements LanguageApiService {
  @override
  Future<DataState<SignupEntity>> updateLanguage(int id, List languages) async {
    try {
      final client = http.Client();
      final url = parseUrl('$id/language');
      final body = {'languages': languages};
      final response = await client.put(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return DataSuccess(SignupModel.fromString(response.body));
    } catch (e) {
      return DataError('Somthing went wrong');
    }
  }
}
