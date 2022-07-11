import 'package:flutter/cupertino.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/models/message.dart';

import 'api_service.dart' as api;
import 'db_service.dart' as db;

class ConverseProvider extends ChangeNotifier {
  List<BindMessage> chat = [];
  String sendMsgBody = "";

  updateMsgBody(String string) {
    sendMsgBody = string;
    notifyListeners();
  }

  TextEditingController controller = TextEditingController();
  int limit = 50;
  int offset = 0;
  int count = -1;
  late int username;

  initData(int username) {
    this.username = username;
    chat = [];
    count = -1;
    offset = 0;
    sendMsgBody = "";
    getData();
  }

  getData() async {
    List<BindMessage>? temp = await db.bindMessageProvider
        .getMessageByUsername(username, limit, offset);
    if ((temp != null && temp.isNotEmpty) && (count == -1 || count == limit)) {
      chat.addAll(temp);
      count = temp.length;
      if (count == limit) {
        offset + limit;
      }
      notifyListeners();
    }
  }

  // 个人聊天页面
  handle(BindMessage msg) {

    if (msg.fromId == username || msg.toId == username) {
      // 去重
      chat.removeWhere((e) {
        return e.messageId == msg.messageId;
      });
      chat.insert(0, msg);
    }
    notifyListeners();
  }

  sendMessage() async {
    if (sendMsgBody.isNotEmpty) {
      await api.sendMsg(username, sendMsgBody);
    }
    // 清空对话框
    controller.clear();
    sendMsgBody = "";
    FLoading.hide();
    notifyListeners();
  }
}
