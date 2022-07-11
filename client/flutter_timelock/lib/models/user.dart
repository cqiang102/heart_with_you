import 'package:sqflite/sqflite.dart';

const String tableUser = "bind_user";
const String columnId = "id";
const String columnUsername = "username";
const String columnPassword = "password";
const String columnNickname = "nickname";
const String columnEmail = "email";
const String columnBackgroundUrl = "background_url";
const String columnCreateTime= "create_time";

class BindUser {
  int? id;
  String? username;
  String? password;
  String? nickname;
  String? email;
  String? backgroundUrl;
  DateTime? createTime;

  BindUser();

  BindUser.name({this.id, this.username, this.password,this.nickname,this.email,this.backgroundUrl,this.createTime});

  BindUser.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    password = map[columnPassword];
    username = "${map[columnUsername]}";
    nickname = map[columnNickname];
    email = map[columnEmail];
    backgroundUrl = map[columnBackgroundUrl];
    createTime = map[columnCreateTime] is int ? DateTime.fromMicrosecondsSinceEpoch(map[columnCreateTime]) : DateTime.tryParse(map[columnCreateTime]);
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnId: id,
      columnUsername: username,
      columnPassword: password,
      columnBackgroundUrl: backgroundUrl,
      columnEmail: email,
      columnCreateTime: createTime?.microsecondsSinceEpoch,
      columnNickname: nickname
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

class BindUserProvider {
  late Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
      create table $tableUser( 
        $columnId integer primary key, 
        $columnUsername text , 
        $columnNickname text , 
        $columnBackgroundUrl text , 
        $columnEmail integer , 
        $columnCreateTime integer , 
        $columnPassword text )
      ''');
    });
  }

  Future<BindUser> save(BindUser user) async {
    await db.insert(tableUser, user.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
    return user;
  }

  Future<BindUser?> getInfoById(int id) async {
    List<Map> maps = await db.query(tableUser,
        columns: [columnId, columnPassword, columnUsername],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return BindUser.fromMap(maps.first);
    }
    return null;
  }

  /// limit 每页数量
  /// offset 起始位置
  Future<List<BindUser>?> getInfoPage(int offset, int limit) async {
    List<Map> maps = await db.query(tableUser,
        columns: [columnId, columnPassword, columnUsername],
        limit: limit,
        offset: offset,
        orderBy: "$columnId DESC");
    if (maps.isNotEmpty) {
      return maps.map((e) => BindUser.fromMap(e)).toList();
    }
    return null;
  }

  Future<int> deleteById(int id) async {
    return await db.delete(tableUser, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateById(BindUser user) async {
    return await db.update(tableUser, user.toMap(),
        where: '$columnId = ?', whereArgs: [user.id]);
  }

  Future close() async => db.close();

  Future<BindUser?> getUserByUsername(String loginUsername) async {
    List<Map> maps = await db.query(tableUser,
        columns: [columnId,columnBackgroundUrl,columnEmail,columnNickname,columnCreateTime,columnPassword, columnUsername],
        where: '$columnUsername = ?',
        whereArgs: [loginUsername]);
    if (maps.isNotEmpty) {
      return BindUser.fromMap(maps.first);
    }
    return null;
  }
}
