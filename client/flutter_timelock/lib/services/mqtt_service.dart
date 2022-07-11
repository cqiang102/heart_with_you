/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/05/2017
 * Copyright :  S.Hamblett
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'db_service.dart' as db;

late MqttServerClient client;

Future<int> start({required String userTopic, required Function handle}) async {
//  client = MqttServerClient('192.168.2.5', '');
  String token = db.prefs.getString(accessTokenKey)!;
  String username = db.prefs.getString(loginUsername)!;

//  client = MqttServerClient('192.168.2.5',"$username");
  client = MqttServerClient('mqtt.heart.lacia.cn',"$username");
  client.logging(on: false);

  client.keepAlivePeriod = 20;

  client.disconnectOnNoResponsePeriod = 10;

  client.autoReconnect = true;

  client.onAutoReconnect = onAutoReconnect;

  client.onAutoReconnected = onAutoReconnected;

  client.onConnected = onConnected;

  client.onSubscribed = onSubscribed;

  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier('$username')
      .withWillTopic('sys') // 如果你设置了这个，你必须设置一个遗嘱消息
      .withWillMessage('out')
      // .startClean() // 用于测试的非持久会话
      .withWillQos(MqttQos.atLeastOnce);
//  print('示例::Mosquitto 客户端连接....');
  client.connectionMessage = connMess;
  try {
    print("client.connect : $token");
    await client.connect(token, "123456");
  } on Exception catch (e) {
    print('示例::客户端异常 - $e');
    client.disconnect();
  }

  /// 检查我们是否已连接
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('示例::已连接 Mosquitto 客户端');
  } else {
    /// 如果您还需要代理返回代码，请在此处使用状态而不是状态。
    print('示例::错误 Mosquitto 客户端连接失败 - 正在断开连接，状态为 ${client.connectionStatus}');
    client.disconnect();

  }

  /// 好的，让我们尝试订阅
  print('示例::订阅 user/message topic');

  // const topic = 'user/message'; // 不是通配符主题
  String topic = userTopic; // 不是通配符主题
  client.subscribe(topic, MqttQos.atLeastOnce);

  /// 客户端有一个更改通知程序对象，然后我们会侦听该对象以获取每个订阅主题的已发布更新的通知。
  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
//    recMess.setRetain(state: true);
    final pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final sb = StringBuffer();
//    recMess.payload.message.forEach(sb.writeCharCode);
    handle(Utf8Decoder().convert(recMess.payload.message));
    // 回调消息解析器
//    handle(pt);
  });
  return 0;
}

/// 订阅的回调
void onSubscribed(String topic) {
  print('示例::订阅已确认主题 $topic');
}

/// 预自动重新连接回调
void onAutoReconnect() {
  print('示例::onAutoReconnect 客户端回调 - 客户端自动重新连接序列将开始');
}

/// 后自动重新连接回调
void onAutoReconnected() {
  print('示例::onAutoReconnected 客户端回调 - 客户端自动重新连接序列已完成');
}

/// 连接成功回调
void onConnected() {
  print('示例::OnConnected 客户端回调 - 客户端连接成功');
}

/// 乒乓回调
void pong() {
  print('示例::调用了 Ping 响应客户端回调 - 您可能希望在此处停止 ping 响应');
}
