import 'package:flutter/cupertino.dart';
import 'package:flutter_timelock/models/message.dart';
import 'db_service.dart' as db;
import 'package:flutter_timelock/services/home_provider.dart';
import 'package:provider/provider.dart';

class ChatProvider extends ChangeNotifier {
  List<BindMessage> list = [];
  late BuildContext context;

  init(BuildContext context) {
    this.context = context;
  }

  getData() async {
    List<BindMessage>? msgList = await db.bindMessageProvider.getMessageList();
    if (msgList != null) {
      for (var msg in msgList) {
//    BindMessage? removeMsg;
        list.removeWhere((e) {
          if(e.messageId == msg.messageId){
            return true;
          }
          if ((e.fromId == msg.fromId && e.toId == msg.toId) ||
              (e.toId == msg.fromId && e.fromId == msg.toId)) {
            return true;
          }
          return false;
        });
//    for (var value in list) {
//      if (value.fromId == msg.fromId ||
//          value.fromId == msg.toId ||
//          value.toId == msg.toId ||
//          value.toId == msg.fromId) {
//
//      }
//    }
        list.add(msg);
      }
//      list.addAll(msgList);
      notifyListeners();
    }
  }

  // 列表页面
  handle(BindMessage msg) {
//    BindMessage? removeMsg;
    list.removeWhere((e) {
      if(e.messageId == msg.messageId){
        return true;
      }
      if ((e.fromId == msg.fromId && e.toId == msg.toId) ||
          (e.toId == msg.fromId && e.fromId == msg.toId)) {
        return true;
      }
      return false;
    });
//    for (var value in list) {
//      if (value.fromId == msg.fromId ||
//          value.fromId == msg.toId ||
//          value.toId == msg.toId ||
//          value.toId == msg.fromId) {
//
//      }
//    }
    list.add(msg);
list.sort((m1,m2 ){
  return m2.createTime.microsecondsSinceEpoch - m1.createTime.microsecondsSinceEpoch;
});
    context.read<HomeProvider>().msgCountUpdate(true, msg);

    notifyListeners();
  }
}
