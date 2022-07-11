import 'package:flutter/material.dart';

const amapKey = "2a9b8a84ace347f0fba96ec68e3c2d71";


final primaryColor = MaterialColor(
  const Color(0xFF8F8CF8).value,
  const <int, Color>{
    50: Color(0xFFF1EFFE),
    100: Color(0xFFEFECFE),
    200: Color(0xFFDFDCFD),
    300: Color(0xFFCFCCFC),
    350: Color(0xFFAFACFA),
    // 仅适用于在浅色主题中按下时凸起的按钮
    400: Color(0xFF9F9CF9),
    500: Color(0xFF8F8CF8),
    600: Color(0xFF7F7CE8),
    700: Color(0xFF6F6CD8),
    800: Color(0xFF5F5CC8),
    850: Color(0xFF4F4CB8),
    // 仅适用于深色主题中的背景颜色
    900: Color(0xFF2F2C98),
  },
);


const String accessTokenKey = "access_token";
const String refreshTokenKey = "refresh_token";
const String useCountKey = "useCount";

//const String resourceServer = "192.168.2.5:9100";
const String resourceServer = "res.heart.lacia.cn";
//const String authServer = "192.168.2.5:9200";
const String authServer = "auth.heart.lacia.cn";

const String clientId = "flutter-client";
const String clientSecret = "secret";

const String sqlUserPath = "flutter_lacia_user";
const String sqlSketchPath = "flutter_lacia_sketch";
const String sqlMessagePath = "flutter_lacia_message";
const String loginUsername = "login_username";
const String registerUsername = "register_username";
const String recentColorKey = "recentColor";

const numberToChinese = {1: "一", 2: "两", 3: "三"};

String getTime(String createTime) {
  DateTime? create = DateTime.tryParse(createTime);
  if(create == null ){
    return "";
  }
  DateTime now = DateTime.now();
  Duration difference = now.difference(create);
  if(difference.inDays >=365){
    return create.toString().substring(0, 10);
  }
  if (difference.inDays >= 3) {
    return create.toString().substring(5, 16);
  }
  if (difference.inDays >= 1) {
    return "${numberToChinese[difference.inDays]}天前";
  }
  if (difference.inHours >= 1) {
    return "${difference.inHours}小时前";
  }
  if (difference.inMinutes >= 1) {
    return "${difference.inMinutes}分钟前";
  }
  if (difference.inSeconds >= 1) {
    return "${difference.inSeconds}秒前";
  }
  return "刚刚";
}
