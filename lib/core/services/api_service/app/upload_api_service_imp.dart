part of 'upload_api_service.dart';

class UploadApiServiceImp implements UploadApiService {
  @override
  Future<DefaultResponse> uploadFile(String filePath) async {
    try {
      final url = parseUrl('upload');
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final response = await request.send();
      String responseBody = await response.stream.bytesToString();
      Map resBody = json.decode(responseBody);
      if (resBody['status']) {
        return DefaultResponse(
          status: true,
          message: resBody['message'],
          value: resBody['fileUrl'],
        );
      }
      return DefaultResponse(status: false, message: resBody['message']);
    } catch (e) {
      return DefaultResponse(status: false, message: 'Something went wrong');
    }
  }
}
