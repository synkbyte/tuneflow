part of 'support_api_service.dart';

class SupportApiServiceImp implements SupportApiService {
  @override
  Future<DefaultResponse> supportRequest(
    String name,
    String email,
    String phone,
    String message,
  ) async {
    try {
      final client = http.Client();
      final url = parseUrl('supportRequest');
      final body = json.encode({
        'name': name,
        'email': email,
        'phone': phone,
        'message': message,
      });
      final response = await client.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      Map resBody = json.decode(response.body);
      return DefaultResponse.fromJson(resBody);
    } catch (e) {
      return DefaultResponse(status: false, message: 'Somthing went wrong');
    }
  }
}
