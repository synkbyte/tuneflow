import 'dart:convert';

import 'package:http/http.dart' as http;

part 'deep_link_api_service_imp.dart';

abstract class DeepLinkApiService {
  Future<String> createDefferLink(String link);
  Future<String> extractLink(String id);
}
