import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;
import 'package:flutter_timelock/services/new_provider.dart';
import 'package:flutter_timelock/services/star_provider.dart';
import 'package:flutter_timelock/services/user_profile_provider.dart';
import 'package:provider/provider.dart';

class CommentProvider extends ChangeNotifier {
  List<dynamic> listData = [];

//  CommentProvider(){
//    getData();
//  }
  String body = "";

  setSendBody(String str) {
    body = str;
    notifyListeners();
  }

  void getData(int newId) async {
    // get data
    listData = await api.getComment(newId);
    notifyListeners();
  }

  addComment(int newId, BuildContext context) async {
    // comment + 1
    context.read<NewProvider>().updateCommentCount(newId);
    context.read<UserProfileProvider>().updateCommentCount(newId);
    context.read<StarProvider>().updateCommentCount(newId);

    if (body.isNotEmpty) {
      // post comment
      await api.comment(newId, body);
      body = "";
    }
    // pop
    FLoading.hide();
    Navigator.pop(context);
    notifyListeners();
  }
}
