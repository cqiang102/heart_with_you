import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:scribble/scribble.dart';
import 'db_service.dart' as db;

class DrawProvider extends ChangeNotifier {
  double penSize = 10.0;
  bool showTool = false;
  List<Color> recentColors = [];
  late Color backgroundColor;

  late Timer backgoundChange;

  ScribbleNotifier notifier = ScribbleNotifier();

  DrawProvider() {
    initData();
  }
  updateShowTool(){
    showTool = ! showTool;
    notifyListeners();
  }
  clear(){
    notifier.clear();
    notifier.setColor(recentColors.first);
  }
  updatePenSize(double penSize) {
    this.penSize = penSize;
    notifier..setStrokeWidth(penSize);
    notifyListeners();
  }

  updateRecentColors(Color color) {
    recentColors = recentColors.reversed.toList();
    if (recentColors.length > 10) {
      recentColors.removeLast();
    }
    if (recentColors.contains(color)) {
      recentColors.removeWhere((element) => element == color);
    }
    recentColors.add(color);


    notifier.setColor(color);
    recentColors = recentColors.reversed.toList();

    notifyListeners();
    db.prefs.setStringList(
        recentColorKey, recentColors.map((e) => e.value.toString()).toList());
  }

  initData() {
    List<String>? recentColorStringList =
        db.prefs.getStringList(recentColorKey);
    if (recentColorStringList == null) {
      recentColors.add(primaryColor);
    } else {
      recentColorStringList.forEach((colorStr) {
        recentColors.add(Color(int.parse(colorStr)));
      });
    }
    backgroundColor = recentColors.first;
    notifier.setColor(recentColors.first);
    backgoundChange = Timer.periodic(Duration(seconds: 5), (timer) {
      if (recentColors.length > 3) {
        backgroundColor =
            recentColors[Random.secure().nextInt(recentColors.length)];
        notifyListeners();
      }
    });
  }
}
