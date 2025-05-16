part of 'room_api_service.dart';

class RoomApiServiceImp implements RoomAPIService {
  @override
  Future<Map> updateRoomCreation(int userId) async {
    try {
      final client = http.Client();
      final url = parseUrl('roomCreated/$userId');
      final response = await client.get(url);
      return json.decode(response.body);
    } catch (error) {
      return {'status': false};
    }
  }
}
