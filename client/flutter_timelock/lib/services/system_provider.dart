import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/services/db_service.dart' as db;
import 'package:flutter_timelock/services/api_service.dart' as api;

class SystemProvider extends ChangeNotifier {
  SystemProvider() {
    initData();
  }

  bool checkResult = false;
  int useCount = 0;
  String? username;

  String? token;
  bool initStatus = false;

  initData() async {
    print("SystemProvider init");
    await db.sharedPreferencesInit();
    await db.dbInit();
    token = db.prefs.getString(accessTokenKey);
    username = db.prefs.getString(loginUsername);
    useCount = db.prefs.getInt(useCountKey) ?? 0;
    await db.prefs.setInt(useCountKey, 1 + useCount);
    print(token);
    await api.dioInit(token);
    // Token 验证

    if (username != null) {
      checkResult = (await api.userProfile(username) ) != null;
    }
    print("checkResult $checkResult");
    initStatus = true;
    notifyListeners();
  }
}
