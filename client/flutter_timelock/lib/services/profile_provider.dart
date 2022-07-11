import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/models/user.dart';
import 'package:flutter_timelock/services/db_service.dart' as db;
import 'package:flutter_timelock/services/api_service.dart' as api;

class ProfileProvider extends ChangeNotifier{

  initData() async {
    print("ProfileProvider init");
    String username = db.prefs.getString(loginUsername)!;
    bindUser = (await db.bindUserProvider.getUserByUsername(username))!;
  }
  late BindUser bindUser;
  updateUser()async{
    await api.userProfile(bindUser.username);
    bindUser = (await db.bindUserProvider.getUserByUsername(bindUser.username!))!;
    FLoading.hide();
    notifyListeners();
  }
}
