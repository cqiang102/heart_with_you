import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'api_service.dart' as api;

class NewProvider extends ChangeNotifier {
  List<Map<dynamic, dynamic>> listData = [];
  int offset = 0;
  int limit = 10;
  int count = -1;
  String? searchText;
  TextEditingController textEditingController = TextEditingController();

  NewProvider() {
    getData();
  }

  getData() async {
    if (count == -1 || count > offset+limit) {
      await api.getNewPage(offset, limit, search: searchText).then((value) {
        if (value != null) {
          listData.addAll(value["news"]);
          count = value["count"];
          offset = offset + limit;
        }
        notifyListeners();
      });
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

  refreshData() async {
    offset = 0;
    limit = 10;
    listData = [];
    searchText = null;
    textEditingController.clear();
    await getData();
  }
  updateStr(String str){
    searchText = str;
  }
  void search() async {
    offset = 0;
    limit = 10;
    listData = [];
    await getData();
    FLoading.hide();
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
