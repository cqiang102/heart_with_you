import 'dart:math';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/models/user.dart';
import 'package:flutter_timelock/pages/body/edit_profile.dart';
import 'package:flutter_timelock/pages/body/follow_page.dart';
import 'package:flutter_timelock/pages/body/star_page.dart';
import 'package:flutter_timelock/pages/body/user_profile.dart';
import 'package:flutter_timelock/pages/login/screens/loginScreen.dart';
import 'package:flutter_timelock/services/profile_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as scan;
import 'package:provider/src/provider.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;
import 'package:flutter_timelock/services/mqtt_service.dart' as mqtt;

import 'find_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      "0201.png",
      "0202.png",
      "lacia01.jpg",
      "lacia02.png",
      "leimu01.png",
      "leimu02.png",
      "mei01.jpg"
    ];
    Color primaryColor = Theme.of(context).primaryColor;
    BindUser bindUser = context.watch<ProfileProvider>().bindUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("我"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EditProfile(bindUser)));
              },
              icon: Icon(
                FontAwesomeIcons.feather,
                color: primaryColor,
              ))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          FLoading.show(context);
          context.read<ProfileProvider>().updateUser();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              flexibleSpace: FlexibleSpaceBar(
                  background: bindUser.backgroundUrl != null
                      ? Image.network(
                          "http://$resourceServer/file/${bindUser.backgroundUrl}",
                          fit: BoxFit.cover,
                          headers: {"Authorization": "Bearer ${api.token}"},
                        )
                      : Center(
                          child: Text("空空如也"),
                        )),
              floating: true,
              expandedHeight: 250,
              title:
                  bindUser.nickname != null ? Text(bindUser.nickname!) : null,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
//                Padding(
//                  padding: const EdgeInsets.all(18.0),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceAround,
//                    children: [
//                      _buildBtn("关注"),
//                      _buildBtn("粉丝"),
//                      _buildBtn("获赞"),
//                    ],
//                  ),
//                ),
                _buildItem(
                    color: Colors.green,
                    iconData: FontAwesomeIcons.qrcode,
                    onTap: () {
                      showDialog(context: context, builder: (_){
                        return AlertDialog(
                          content: BarcodeWidget(
                            barcode: Barcode.qrCode(
                              errorCorrectLevel: BarcodeQRCorrectionLevel.high,
                            ),
                            data: '${bindUser.username}',
                            width: 200,
                            height: 200,
                          ),
                        );
                      });
                    },
                    str: "好友码"),
                _buildItem(
                    color: Colors.purpleAccent,
                    iconData: FontAwesomeIcons.code,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => Stack(children: [
                            scan.MobileScanner(
                                allowDuplicates: false,
                                onDetect: (barcode, args) {
                                  final String? code = barcode.rawValue;
                                  int? username = int.tryParse(code ?? "");
                                  if( username!=null ){
                                    Navigator.pop(context);
                                    showDialog(context: context, builder: (_){
                                      return FindPage(username,2);
                                    });
                                  }
                                  debugPrint('Barcode found! $code');
                                }),
                            SpinKitSpinningLines(
                              color: primaryColor,
                              size: double.infinity,
                            ),
                          ],)));
                    },
                    str: "扫一扫"),
                _buildItem(
                    color: Colors.blue,
                    iconData: Icons.timelapse_rounded,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        var map = bindUser.toMap();
                        map['username'] = int.parse('${map['username']}');
                        return UserProfile(map);
                      }));
                    },
                    str: "我的动态"),
                _buildItem(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FollowPage(status: 3,)));
                    },
                    color: Colors.yellow, iconData: Icons.people, str: "我的好友"),
                _buildItem(
                    color: Colors.greenAccent,
                    iconData: FontAwesomeIcons.eye,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FollowPage(status: 1,)));
                    },
                    str: "我的关注"),
                _buildItem(
                    color: Colors.pink,
                    iconData: FontAwesomeIcons.question,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FollowPage(status: 2,)));
                    },
                    str: "我的粉丝"),

                _buildItem(
                    color: Colors.deepOrange,
                    iconData: Icons.star,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => StarPage()));
                    },
                    str: "我的收藏"),
//                _buildItem(
//                    color: primaryColor, iconData: Icons.settings, str: "我的设置"),
                _buildItem(
                    color: Colors.green,
                    iconData: Icons.live_help_outlined,
                    onTap: () {
                      showAboutDialog(
                          context: context,
                          applicationName: "心系于你",
                          applicationVersion: "版本: 0.0.1",
                          applicationIcon: Center(
                              child: Image.asset("assets/images/app_logo.png",
                                  width: 30, height: 30)),
                          useRootNavigator: false,
                          children: [
                            Text("这是一款聊天交友APP，"),
                            Text("在这里，可以通过手中的一笔一划展现自己"),
                            Text(""),
                            Text("Bug 反馈  "),
                            Text("QQ : 2375622526"),
                            Text("Email : lacia.cq@qq.com"),
                          ]);
                    },
                    str: "帮助中心"),
                _buildItem(
                    color: Colors.red,
                    iconData: Icons.power_settings_new,
                    str: "退出登录",
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              content: const Text("如果未绑定邮箱且忘记密码，将无法登录"),
                              title: const Text("确定退出登录吗"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      mqtt.client.disconnect();
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (_) => LoginScreen()),
                                          (route) => false);
                                    },
                                    child: const Text("确定"))
                              ],
                            );
                          });
                    }),
//              _buildItem(
//                  color: Colors.red, iconData: Icons.exit_to_app, str: "注销账号"),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  _buildBtn(String text) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
      width: 60,
      height: 60,
    );
  }

  _buildItem(
      {required Color color,
      required IconData iconData,
      required String str,
      Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          iconData,
          color: color,
        ),
        title: Text(str),
      ),
    );
  }
}
