import 'package:flutter_timelock/config/common_const.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_timelock/services/db_service.dart' as data;

///{
///   "type":0,
///   "body":"呀呀呀",
///   "message_id":719977607042568192,
///   "from_id":719967203285405696,
///   "to_id":718573320328581121,
///   "create_time":"2022-05-06 15:35:03"
///   }
///
const String tableMessage = "bind_message";

const String columnId = "message_id";
const String columnType = "type";
const String columnBody = "body";
const String columnFromId = "from_id";
const String columnToId = "to_id";
const String columnCreateTime = "create_time";

class BindMessage {
  late int messageId;
  late int type;

  late String body;
  late int fromId;
  late int toId;
  late DateTime createTime;

  BindMessage();

  BindMessage.name(
      {required this.type,
      required this.body,
      required this.messageId,
      required this.fromId,
      required this.toId,
      required this.createTime});

  BindMessage.fromMap(Map<dynamic, dynamic> map) {
    messageId = map[columnId];
    type = map[columnType];
    body = map[columnBody];
    fromId = map[columnFromId];
    toId = map[columnToId];
    createTime = (map[columnCreateTime] is int
        ? DateTime.fromMicrosecondsSinceEpoch(map[columnCreateTime])
        : DateTime.parse(map[columnCreateTime]));
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnId: messageId,
      columnType: type,
      columnBody: body,
      columnFromId: fromId,
      columnToId: toId,
      columnCreateTime: createTime.microsecondsSinceEpoch,
    };
    if (messageId != null) {
      map[columnId] = messageId;
    }
    return map;
  }
}

class BindMessageProvider {
  late Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
      create table $tableMessage( 
        $columnId integer primary key, 
        $columnBody text , 
        $columnType integer , 
        $columnToId integer , 
        $columnFromId integer , 
        $columnCreateTime integer  )
      ''');
    });
  }

  /// 保存消息
  Future<BindMessage> save(BindMessage message) async {
    await db.insert(tableMessage, message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return message;
  }

  ///获取消息列表
  Future<List<BindMessage>?> getMessageList() async {
    List<BindMessage> listData = [];
    // 查询别人发的
    List<Map> mapsReceive = await db.query(tableMessage,
        columns: [
          columnId,
          columnType,
          columnBody,
          columnFromId,
          columnToId,
          columnCreateTime
        ],
        orderBy: "$columnCreateTime",
        where: '$columnFromId != ?',
        whereArgs: [
          data.prefs.getString(loginUsername),
        ],
        groupBy: columnFromId,
      having: 'MAX($columnCreateTime)'
    );
    // 查询我发别人的
    List<Map> mapsSend = await db.query(tableMessage,
        columns: [
          columnId,
          columnType,
          columnBody,
          columnFromId,
          columnToId,
          columnCreateTime
        ],
        orderBy: "$columnCreateTime",
        where: '$columnFromId == ?',
        whereArgs: [
          data.prefs.getString(loginUsername),
        ],
        groupBy: columnToId,
        having: 'MAX($columnCreateTime)'

    );
    List<BindMessage> listReceive = [];
    List<BindMessage> listSend = [];

    if (mapsReceive.isNotEmpty) {
      listReceive
          .addAll(mapsReceive.map((e) => BindMessage.fromMap(e)).toList());
    }
    if (mapsSend.isNotEmpty) {
      listSend.addAll(mapsSend.map((e) => BindMessage.fromMap(e)).toList());
    }
    // 去重
    listReceive.removeWhere((receive) {
      BindMessage msg =
          listSend.firstWhere((send) => receive.fromId == send.toId,orElse: () {
            return BindMessage.name(
                type: 0,
                body: "d",
                messageId: 1,
                fromId: 1,
                toId: 1,
                createTime: DateTime(1999));
          });
      if (receive.createTime.microsecondsSinceEpoch <
          msg.createTime.microsecondsSinceEpoch) {
        return true;
      }
      return false;
    });
    listSend.removeWhere(
      (send) {
        BindMessage msg = listReceive
            .firstWhere((receive) => send.toId == receive.fromId, orElse: () {
          return BindMessage.name(
              type: 0,
              body: "d",
              messageId: 1,
              fromId: 1,
              toId: 1,
              createTime: DateTime(1999));
        });
        if (send.createTime.microsecondsSinceEpoch <
            msg.createTime.microsecondsSinceEpoch) {
          return true;
        }
        return false;
      },
    );
    // 合并
    listData.addAll(listReceive);
    listData.addAll(listSend);
    // 重新排序
    listData.sort((e1, e2) {
      return e1.createTime.microsecondsSinceEpoch -
          e2.createTime.microsecondsSinceEpoch;
    });
    if (listData.isNotEmpty) {
      return listData;
    }
    return null;
  }

  /// 查询与一个人的全部消息 分页 一次五十吧
  Future<List<BindMessage>?> getMessageByUsername(
      int username, int limit, int offset) async {
    List<Map> maps = await db.query(tableMessage,
        columns: [
          columnId,
          columnType,
          columnBody,
          columnFromId,
          columnToId,
          columnCreateTime
        ],
        where: '$columnFromId = ? or $columnToId = ?',
        orderBy: "$columnCreateTime DESC",
        limit: limit,
        offset: offset,
        whereArgs: [username, username]);
    if (maps.isNotEmpty) {
      return maps.map((e) => BindMessage.fromMap(e)).toList();
    }
    return null;
  }

  Future close() async => db.close();
}
