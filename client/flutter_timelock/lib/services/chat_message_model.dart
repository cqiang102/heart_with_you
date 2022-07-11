import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/models/message.dart';
import 'package:flutter_timelock/services/chat_provider.dart';
import 'package:flutter_timelock/services/converse_provider.dart';
import 'package:provider/provider.dart';
import 'mqtt_service.dart' as mqtt;
import 'db_service.dart' as db;
class ChatMessageModel extends ChangeNotifier {


  void initMqtt(BuildContext context) async{
    String username = db.prefs.getString(loginUsername)!;
    mqtt.start(userTopic: username, handle: (msg) {
      print("msg $msg");
      BindMessage receive =  BindMessage.fromMap(jsonDecode(msg));
      db.bindMessageProvider.save(receive);
      // chat 通知
      // list 通知
      context.read<ChatProvider>().handle(receive);
      context.read<ConverseProvider>().handle(receive);
    });
  }

}
