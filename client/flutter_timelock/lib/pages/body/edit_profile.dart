import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/models/user.dart';
import 'package:flutter_timelock/pages/login/screens/loginScreen.dart';
import 'package:flutter_timelock/services/profile_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;
import 'package:flutter_timelock/services/mqtt_service.dart' as mqtt;
import 'package:flutter_timelock/services/db_service.dart' as db;
import 'package:provider/src/provider.dart';

class EditProfile extends StatelessWidget {
  BindUser user;

  EditProfile(this.user, {Key? key}) : super(key: key);
  String? nickname;
  String? email;
  String? old;
  String? passowrd;
  String? checkPassowrd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("修改资料"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.chevron_left,
              color: primaryColor,
            )),
        actions: [
          IconButton(
              onPressed: () async {
                // TODO 提交数据
                if (old != null) {
                  if (passowrd == null || checkPassowrd == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Row(
                          children: [
                            Text("密码不能为空"),
                          ],
                        )));

                    return;
                  }

                  if ((old!.length < 8 || old!.length > 18) ||
                      (passowrd!.length < 8 || passowrd!.length > 18) ||
                      (checkPassowrd!.length < 8 ||
                          checkPassowrd!.length > 18)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Row(
                          children: [
                            Text("密码长度错误，最少 8 位，最多 18 位"),
                          ],
                        )));
                    return;
                  }
                  if (passowrd != checkPassowrd) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Row(
                          children: [
                            Text("两次密码不一致"),
                          ],
                        )));
                    return;
                  }
                  if (passowrd == old) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Row(
                          children: [
                            Text("新密码与原密码一致"),
                          ],
                        )));

                    return;
                  }
                }

                FLoading.show(context);
                bool flag = await api.updateUser(
                    nickname: nickname,
                    password: passowrd,
                    email: email,
                    old: old,
                    errorHandle: (msg) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Row(
                            children: [
                              Text("$msg"),
                            ],
                          )));
                    });
                if (flag && passowrd != null) {
                  // TODO 重新登录
                  mqtt.client.disconnect();
                  db.prefs.remove(accessTokenKey);
                  db.prefs.remove(refreshTokenKey);

                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => LoginScreen()),
                          (route) => false);
                  return;
                }
                if (flag) Navigator.pop(context);
                context.read<ProfileProvider>().updateUser();
              },
              icon: Icon(
                Icons.check,
                color: primaryColor,
              ))
        ],
      ),
      body: ListView(
        children: [
          TextField(
            onChanged: (str) => nickname = str,
            controller: TextEditingController()..text = user.nickname!,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
              hintText: "昵称",
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(
                FontAwesomeIcons.feather,
                size: 18,
              ),
            ),
          ),
          Divider(),
          TextField(
            onChanged: (str) => old = str,
            obscureText: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
              hintText: "原密码",
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(
                FontAwesomeIcons.feather,
                size: 18,
              ),
            ),
          ),
          Divider(),
          TextField(
            obscureText: true,
            onChanged: (str) => passowrd = str,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
              hintText: "密码",
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(
                FontAwesomeIcons.feather,
                size: 18,
              ),
            ),
          ),
          Divider(),
          TextField(
            onChanged: (str) => checkPassowrd = str,
            obscureText: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
              hintText: "确认密码",
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(
                FontAwesomeIcons.feather,
                size: 18,
              ),
            ),
          ),
          Divider(),
          TextField(
            onChanged: (str) => email = str,
            controller: TextEditingController()..text = user.email!,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
              hintText: "邮箱",
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(
                FontAwesomeIcons.feather,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
