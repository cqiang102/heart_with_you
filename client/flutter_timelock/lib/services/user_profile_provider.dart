

import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'api_service.dart' as api;

class UserProfileProvider extends ChangeNotifier{
  Map<dynamic,dynamic> bindUser = {};
  late int username ;
  bool followFlag = false;
  setUsername(int username){
    this.username = username;
  }
  List<dynamic> listData = [];

  getData()async{
    //  请求用户信息
    bindUser =await api.userProfile(username.toString());
    // 获取用户动态
    listData = await api.getUserNew(username);

    followFlag = await api.getIfFollow(username);
    notifyListeners();
  }
  follow(bool flag) async {
    // 关注操作
    await api.follow(bindUser['username'], flag);
    followFlag = !followFlag;
    FLoading.hide();
    notifyListeners();
  }

  operator(int newId, int status, int flag) async {
    await api.operator(newId, status, flag);
    for (var element in listData) {
      if (element["new_id"] == newId) {
        if (status == 1) {
          if (flag == 1) {
            element['ifUp'] = 1;
            element["up_count"] = element["up_count"] + 1;
          } else {
            element['ifUp'] = 0;
            element["up_count"] = element["up_count"] - 1;
          }
        }
        if (status == 2) {
          if (flag == 1) {
            element['ifStar'] = 1;
            element["star_count"] = element["star_count"] + 1;
          } else {
            element['ifStar'] = 0;
            element["star_count"] = element["star_count"] - 1;
          }
        }
      }
    }
    FLoading.hide();
    notifyListeners();
  }
  void updateCommentCount(int newId) {
    for (var value in listData) {
      if (value['new_id'] == newId) {
        value['comment_count'] = value['comment_count'] + 1;
        notifyListeners();
        return ;
      }
    }

  }

}
