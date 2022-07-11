import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/models/message.dart';
import 'package:provider/src/provider.dart';
import 'package:scribble/scribble.dart';

import 'chat_message_model.dart';
import 'draw_provider.dart';
import 'db_service.dart' as db;

class HomeProvider extends ChangeNotifier {
  late TabController tabController;
  int msgCount = 0;
  Set<int> msgUser = <int>{};

  msgCountUpdate(flag, BindMessage msg) {
    int username = int.parse(db.prefs.getString(loginUsername)!);
    if(username == msg.fromId){
      //自己发的
      return;
    }
    if (flag) {
      msgUser.add(msg.toId);
      msgUser.add(msg.fromId);
    } else if (msgCount > 0) {
      msgUser.remove(msg.toId);
      msgUser.remove(msg.fromId);
    }
    msgUser.add(username);
    msgCount = msgUser.length - 1;
    notifyListeners();
  }

  DateTime? lastPopTime;

  pop(BuildContext context) async {
    // 点击返回键的操作
    if (lastPopTime == null ||
        DateTime.now().difference(lastPopTime!) > const Duration(seconds: 1)) {
      lastPopTime = DateTime.now();
      final _index = tabController.index;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: primaryColor,
          content: Row(
            mainAxisAlignment:
                _index < 2 ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text("再按一次退出~~~"),
            ],
          )));
    } else {
      lastPopTime = DateTime.now();
      // 退出app
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
    return false;
  }

  editSketch(BuildContext context, Sketch sketch) {
    tabController.index = 2;
    context.read<DrawProvider>().notifier.clear();
    context.read<DrawProvider>().notifier.setSketch(sketch: sketch);
  }

  void init(BuildContext context) {
    context.read<ChatMessageModel>().initMqtt(context);
    tabController = TabController(length: 5, vsync: ScrollableState());
  }
}
