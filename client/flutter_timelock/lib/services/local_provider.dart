import 'package:flutter/cupertino.dart';
import 'package:flutter_timelock/models/sketch.dart';
import 'package:flutter_timelock/services/db_service.dart' as db;

class LocalProvider extends ChangeNotifier{
  List<BindSketch> list = [];

  LocalProvider(){
    getData();
  }
  int offset = 0;
  int limit = 10;

  getData() async {
    print(list);
    if(list.isNotEmpty && list.length < limit){
      return;
    }
    List<BindSketch>? sketches = await db.bindSketchProvider.getSketchPage(offset, limit);
    if(sketches != null){
      if(sketches.length == limit){
        offset = offset + 1;
      }

      list.addAll(sketches);
      notifyListeners();
    }
  }

  refreshData() async {
    offset = 0;
    limit = 10;
    list = [];
    await getData();

  }

  delete(int id){
    db.bindSketchProvider.delete(id);
    list.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
