part of 'signup_data_source.dart';

class SignupApiServiceImp implements SignupApiService {
  @override
  Future<DataState<SignupEntity>> signupRequest(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    try {
      final client = http.Client();
      final url = parseUrl('signup');
      final body = {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password
      };
      final response = await client.post(
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

  @override
  Future<DataState<SignupEntity>> googleLogin(String name, String email) async {
    try {
      final client = http.Client();
      final url = parseUrl('google/auth');
      final body = {
        'name': name,
        'email': email,
      };
      final response = await client.post(
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
