part of 'reset_password_api_service.dart';

class ResetPasswordApiServiceImp implements ResetPasswordApiService {
  @override
  Future<Map> checkUserRegistration(String identifier) async {
    try {
      final client = http.Client();
      final url = parseUrl('$identifier/identifier');
      final response = await client.get(url);
      Map resBody = json.decode(response.body);
      return resBody;
    } catch (e) {
      return {
        'status': false,
        'message': 'Somthing went wrong',
      };
    }
  }

  @override
  Future<Map> changePassword(String phone, String password) async {
    try {
      final client = http.Client();
      final url = parseUrl('reset/password');
      final body = {
        'phone': phone,
        'password': password,
      };
      final response = await client.put(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': 'Somthing went wrong',
      };
    }
  }
}
