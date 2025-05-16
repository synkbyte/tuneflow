import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/services/api_service/user/user_api_service.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:stream_transform/stream_transform.dart';

class SocialProvider extends ChangeNotifier {
  final UserApiService service = sl();

  List leaderboards = [];
  List batchedUsers = [];
  List searchedUsers = [];

  bool isSearching = true;
  final _searchController = StreamController<String>.broadcast();

  SocialProvider() {
    _searchController.stream
        .debounceBuffer(const Duration(milliseconds: 500))
        .listen((queries) {
          if (queries.isNotEmpty) {
            searchUser(queries.last);
          }
        });
  }

  Future<void> fetchLeaderboards() async {
    try {
      Map response = await service.fetchLeaderboard();
      if (response['status']) {
        leaderboards = response['users'];
        notifyListeners();
      }
      fetchBatchedUsers();
    } catch (e) {
      return;
    }
  }

  Future<void> fetchBatchedUsers() async {
    try {
      Map response = await service.fetchBatchedUsers();
      if (response['status']) {
        batchedUsers = response['users'];
        notifyListeners();
      }
    } catch (e) {
      return;
    }
  }

  void onSearchTextChanged(String value) {
    isSearching = true;
    notifyListeners();
    _searchController.add(value);
  }

  Future<void> searchUser(String query) async {
    if (query.isEmpty) return;
    isSearching = true;
    notifyListeners();

    try {
      Map response = await service.searchUsers(query);
      if (response['status']) {
        searchedUsers = response['users'];
      } else {
        searchedUsers = [];
      }
    } catch (e) {
      searchedUsers = [];
    }

    isSearching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }
}
