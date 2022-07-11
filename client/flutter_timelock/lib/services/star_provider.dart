import 'package:flutter/cupertino.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'api_service.dart' as api;

class StarProvider extends ChangeNotifier {
  List<dynamic> listData = [];

  getData() async {
    // 获取用户动态
    var tempData = await api.getStarList();
    if (tempData != null) {
      listData = tempData;
    }

    notifyListeners();
  }

  void updateCommentCount(int newId) {
    for (var value in listData) {
      if (value['new_id'] == newId) {
        value['comment_count'] = value['comment_count'] + 1;
        notifyListeners();
        return;
      }
    }
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
}
