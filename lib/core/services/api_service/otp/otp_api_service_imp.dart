part of 'otp_api_service.dart';

class OtpApiServiceImp implements OtpApiService {
  @override
  Future<Map> sendOnEmail({
    required String toEmail,
    required String name,
  }) async {
    try {
      final client = http.Client();
      final url = parseUrl('sendEmail', null, true);
      final body = {
        'toEmail': toEmail,
        'name': name,
      };
      final response = await client.post(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Something went wrong'};
    }
  }

  @override
  Future<Map> sendOnWhatsapp({
    required String phoneNumber,
    required String name,
  }) async {
    try {
      final client = http.Client();
      final url = parseUrl('sendOTP', null, true);
      final body = {
        'phoneNumber': phoneNumber,
        'name': name,
      };
      final response = await client.post(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Something went wrong'};
    }
  }
}
