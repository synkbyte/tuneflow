import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/utils/core_utils.dart';

part 'room_api_service_imp.dart';

abstract class RoomAPIService {
  Future<Map> updateRoomCreation(int userId);
}
