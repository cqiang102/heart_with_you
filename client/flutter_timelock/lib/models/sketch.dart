import 'dart:convert';
import 'dart:typed_data';

import 'package:scribble/scribble.dart';
import 'package:sqflite/sqflite.dart';

const String tableSketch = "bind_sketch";
const String columnId = "id";
const String columnSketch = "sketch";
const String columnCreateTime= "create_time";
const String columnImage= "image";
class BindSketch{
  int? id;
  Sketch? sketch;
  Uint8List? image;
  DateTime? createTime;
  BindSketch();

  BindSketch.name({this.id, this.sketch, this.createTime,this.image});
  BindSketch.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    createTime = map[columnCreateTime] is int ? DateTime.fromMicrosecondsSinceEpoch(map[columnCreateTime]) : DateTime.tryParse(map[columnCreateTime]);
    sketch = Sketch.fromJson(json.decoder.convert(map[columnSketch]));
    image = map[columnImage];
  }
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnSketch: json.encoder.convert(sketch?.toJson()),
      columnCreateTime: createTime?.microsecondsSinceEpoch,
      columnImage: image,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}
class BindSketchProvider{
  late Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
      create table $tableSketch( 
        $columnId integer primary key autoincrement, 
        $columnSketch text , 
        $columnImage blob , 
        $columnCreateTime integer )
      ''');
        });
  }
  Future<int> save(BindSketch user) async {
    return await db.insert(tableSketch, user.toMap());
  }
  Future<int> delete(int id) async{
    return db.delete(tableSketch,where: "$columnId = ?",whereArgs: [id]);
  }
  Future<BindSketch?> getInfoById(int id) async {
    List<Map> maps = await db.query(tableSketch,
        columns: [columnId, columnSketch, columnCreateTime,columnImage],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return BindSketch.fromMap(maps.first);
    }
    return null;
  }
  Future<List<BindSketch>?> getSketchPage(int offset, int limit) async {
    List<Map> maps = await db.query(tableSketch,
        columns: [columnId, columnSketch, columnCreateTime,columnImage],
        limit: limit,
        offset: offset,
        orderBy: "$columnCreateTime DESC");
    if (maps.isNotEmpty) {
      return maps.map((e) => BindSketch.fromMap(e)).toList();
    }
    return null;
  }
  Future close() async => db.close();

}
