import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/src/forum/domain/forum_model.dart';

class ForumProvider extends ChangeNotifier {
  int currentPageExplore = 0;
  int totalPageExplore = 1;
  List<ForumModel> exploreFeed = [];
  ScrollController exploreController = ScrollController();
  bool isFetchingExplore = true;
  bool isFetchingNextExplore = true;

  int currentPageMine = 0;
  int totalPageMine = 1;
  List<ForumModel> mineFeed = [];
  ScrollController mineController = ScrollController();
  bool isFetchingMine = true;
  bool isFetchingNextMine = true;

  late ForumModel model;
  bool isFetchingForumDetails = true;
  bool gotErrorWhileDetails = false;
  String errorMsgWhileDetails = '';

  List notifications = [];

  fetchExploreFeed() async {
    int userId = await CacheHelper().getUserId();
    try {
      currentPageExplore++;
      final client = http.Client();
      final url = parseUrl(
        'post/getAll/$userId',
        {'page': '$currentPageExplore'},
      );
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List data = jsonResponse['posts'];
        currentPageExplore = jsonResponse['currentPage'];
        totalPageExplore = jsonResponse['totalPages'];
        exploreFeed.addAll(data.map((e) => ForumModel.fromJson(e)).toList());
        isFetchingExplore = false;
        notifyListeners();
        exploreListListener();
      }
    } catch (error) {
      return;
    }
  }

  exploreListListener() {
    exploreController.addListener(() {
      if (exploreController.position.maxScrollExtent ==
          exploreController.offset) {
        if (currentPageExplore < totalPageExplore) {
          fetchExploreFeed();
        }
      }
    });
  }

  fetchMineFeed() async {
    int userId = await CacheHelper().getUserId();
    try {
      currentPageMine++;
      final client = http.Client();
      final url = parseUrl(
        'post/get/$userId',
        {'page': '$currentPageMine'},
      );
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List data = jsonResponse['posts'];
        currentPageMine = jsonResponse['currentPage'];
        totalPageMine = jsonResponse['totalPages'];
        mineFeed.addAll(data.map((e) => ForumModel.fromJson(e)).toList());
        isFetchingMine = false;
        notifyListeners();
        mineListListener();
      }
    } catch (error) {
      return;
    }
  }

  mineListListener() {
    mineController.addListener(() {
      if (mineController.position.maxScrollExtent == mineController.offset) {
        if (currentPageMine < totalPageMine) {
          fetchMineFeed();
        }
      }
    });
  }

  fetchForumDetails(int postId) async {
    int userId = await CacheHelper().getUserId();
    try {
      isFetchingForumDetails = true;
      final client = http.Client();
      final url = parseUrl('post/details/$postId/$userId');
      final response = await client.get(url);
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        model = ForumModel.fromJson(jsonResponse['post']);
        isFetchingForumDetails = false;
        gotErrorWhileDetails = false;
        notifyListeners();
      } else {
        isFetchingForumDetails = false;
        gotErrorWhileDetails = true;
        errorMsgWhileDetails = jsonResponse['message'];
        notifyListeners();
      }
    } catch (e) {
      return;
    }
  }

  likeForum(int postId, [bool isSingle = false]) async {
    int userId = await CacheHelper().getUserId();
    try {
      updateLikeForMe(postId);
      if (isSingle) {
        updateLikeForMeSignle();
      }
      final client = http.Client();
      final url = parseUrl('post/like/$postId/$userId');
      await client.put(url);
    } catch (error) {
      updateLikeForMe(postId);
      if (isSingle) {
        updateLikeForMeSignle();
      }
      return;
    }
  }

  likeForumReply(int id) async {
    int userId = await CacheHelper().getUserId();
    try {
      updateLikeReplyForMe(id);
      final client = http.Client();
      final url = parseUrl('post/like/reply/$id/$userId');
      await client.put(url);
    } catch (error) {
      updateLikeReplyForMe(id);
      return;
    }
  }

  replyOfForum(int postId, String content) async {
    int userId = await CacheHelper().getUserId();
    try {
      final client = http.Client();
      final url = parseUrl('post/reply/$postId');
      final body = jsonEncode({
        'userId': userId,
        'content': content,
      });
      final response = await client.put(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        model.postReplies.insert(
          0,
          PostReplyModel.fromJson(jsonResponse['reply']),
        );
        model.repliedCount++;
        notifyListeners();
      }
    } catch (error) {
      return;
    }
  }

  deleteForum(ForumModel model) async {
    try {
      final client = http.Client();
      final url = parseUrl('post/delete/${model.id}');
      final response = await client.delete(url);
      if (response.statusCode == 200) {
        mineFeed.removeWhere((e) => e.id == model.id);
        exploreFeed.removeWhere((e) => e.id == model.id);
        notifyListeners();
        Fluttertoast.showToast(msg: 'Post deleted');
      }
    } catch (error) {
      return;
    }
  }

  Future<Map> addForum(String title, String content) async {
    int userId = await CacheHelper().getUserId();
    try {
      final client = http.Client();
      final url = parseUrl('post/create');
      final body = jsonEncode({
        'userId': userId,
        'title': title,
        'content': content,
      });
      final response = await client.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      Map resBody = jsonDecode(response.body);
      return resBody;
    } catch (error) {
      return {'status': false, 'message': 'Something went wrong'};
    }
  }

  reportPost(int postId, String reason) async {
    int userId = await CacheHelper().getUserId();
    try {
      final client = http.Client();
      final url = parseUrl('post/report');
      final body = jsonEncode({
        'userId': userId,
        'postId': postId,
        'reason': reason,
      });
      await client.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      return;
    } catch (error) {
      return;
    }
  }

  updateLikeForMe(int postId) {
    final index = exploreFeed.indexWhere((e) => e.id == postId);
    if (index != -1) {
      bool status = exploreFeed[index].likedStatus;
      if (!status) {
        exploreFeed[index].likeCount++;
      } else {
        exploreFeed[index].likeCount--;
      }
      exploreFeed[index].likedStatus = !status;
      notifyListeners();
    }
    final indexForMine = mineFeed.indexWhere((e) => e.id == postId);
    if (indexForMine != -1) {
      bool status = mineFeed[indexForMine].likedStatus;
      if (!status) {
        mineFeed[indexForMine].likeCount++;
      } else {
        mineFeed[indexForMine].likeCount--;
      }
      mineFeed[indexForMine].likedStatus = !status;
      notifyListeners();
    }
  }

  updateLikeForMeSignle() {
    bool status = model.likedStatus;
    if (!status) {
      model.likeCount++;
    } else {
      model.likeCount--;
    }
    model.likedStatus = !status;
    notifyListeners();
  }

  updateLikeReplyForMe(int id) {
    final index = model.postReplies.indexWhere((e) => e.id == id);
    if (index != -1) {
      bool status = model.postReplies[index].likedStatus;
      if (!status) {
        model.postReplies[index].likeCount++;
      } else {
        model.postReplies[index].likeCount--;
      }
      model.postReplies[index].likedStatus = !status;
      notifyListeners();
    }
  }

  fetchNotifications() async {
    int userId = await CacheHelper().getUserId();
    try {
      final client = http.Client();
      final url = parseUrl('userNotification/$userId');
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        notifications = jsonResponse['userNotifications'];
        notifyListeners();
      }
    } catch (error) {
      return;
    }
  }

  deleteReply(PostReplyModel model) async {
    try {
      updateDeleteReplyForMe(model.id);
      final client = http.Client();
      final url = parseUrl('post/reply/${model.id}');
      await client.delete(url);
      return;
    } catch (error) {
      return;
    }
  }

  updateDeleteReplyForMe(int id) {
    final index = model.postReplies.indexWhere((e) => e.id == id);
    if (index != -1) {
      model.postReplies.removeAt(index);
      model.repliedCount--;
      notifyListeners();
    }
  }

  reset() {
    currentPageExplore = 0;
    totalPageExplore = 1;
    exploreFeed.clear();
    isFetchingExplore = true;
    isFetchingNextExplore = true;

    currentPageMine = 0;
    totalPageMine = 1;
    mineFeed.clear();
    isFetchingMine = true;
    isFetchingNextMine = true;
    fetchExploreFeed();
    fetchMineFeed();
  }

  @override
  void dispose() {
    super.dispose();
    exploreController.dispose();
    mineController.dispose();
  }
}
