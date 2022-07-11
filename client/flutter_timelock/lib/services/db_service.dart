// TODO DB Service

import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/models/message.dart';
import 'package:flutter_timelock/models/sketch.dart';
import 'package:flutter_timelock/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

BindUserProvider bindUserProvider = BindUserProvider();
BindSketchProvider bindSketchProvider = BindSketchProvider();
BindMessageProvider bindMessageProvider = BindMessageProvider();

sharedPreferencesInit() async {
  prefs = await SharedPreferences.getInstance();
}

dbInit() async {
  await bindUserProvider.open(sqlUserPath);
  await bindSketchProvider.open(sqlSketchPath);
  await bindMessageProvider.open(sqlMessagePath);
}
