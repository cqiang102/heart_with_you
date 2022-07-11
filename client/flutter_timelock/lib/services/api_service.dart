import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/models/user.dart';
import 'package:flutter_timelock/services/db_service.dart' as db;
import 'package:retry/retry.dart';
import 'package:http_parser/http_parser.dart';

late Dio dio;
late String? token;

dioInit(String? _token) async {
  token = _token;

  var options = BaseOptions(
      baseUrl: "http://$resourceServer",
      connectTimeout: 500000,
      receiveTimeout: 300000,
      contentType: 'application/json;charset=utf-8');
  dio = Dio(options);
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    print('send request：path:${options.path}，baseURL:${options.baseUrl}');
    if (options.headers['Authorization'] == null && token != null) {
      options.headers['Authorization'] = "Bearer $token";
    }
    if (options.path.contains("/api/register")) {
      options.headers.remove("Authorization");
    }
    handler.next(options);
  }));
  dio.interceptors.add(QueuedInterceptorsWrapper(onResponse: (rsp, handler) {
    // 刷新 token
    if (rsp.data["code"] == "140") {
      String? refreshToken = db.prefs.getString(refreshTokenKey);
      dio.post(
        "http://$authServer/oauth2/token",
        options: Options(headers: {
          "Authorization":
              "Basic ${base64.encode(utf8.encode(clientId + ':' + clientSecret))}"
        }),
        queryParameters: {
          "grant_type": "refresh_token",
          "refresh_token": refreshToken,
        },
      ).then((response) async {
        print(response);
        if (response.data["access_token"] != null) {
          await db.prefs
              .setString(accessTokenKey, response.data["access_token"]);
          token = response.data["access_token"];
          await db.prefs
              .setString(refreshTokenKey, response.data["refresh_token"]);
        }
      }).catchError((error, stackTrace) {
        print(error);
      });
    }
    handler.next(rsp);

    print(rsp);
  }));
}

//class MyException implements Exception{
//  Response resp;
//  MyException(this.resp);
//}
//
//获取个人资料 验证 token
Future userProfile(String? username) async {
  final url = "http://$resourceServer/user/$username";
  print(url);
  Response? response = await retry<Response?>(
    () async {
      Response? retryResponse = await dio.get(url);
      if (retryResponse.data["code"] == "200") {
        return retryResponse;
      }
      throw DioError(requestOptions: retryResponse.requestOptions);
    },
    delayFactor: const Duration(seconds: 2),
    maxAttempts: 8,
    maxDelay: const Duration(seconds: 5),
  ).onError((error, stackTrace) => null);

  print(response);
  if (response == null) return null;
  if (response.data["code"] == "200") {
    await db.bindUserProvider.save(BindUser.fromMap(response.data["data"]));
    return response.data["data"];
  }

  return null;
}

// 密码模式登陆
Future<bool> login(
    String username, String password, Function errorHandler) async {
  final url = "http://$authServer/oauth2/token";
  Response? response;
  try {
    response = await dio.post(
      url,
      queryParameters: {
        "client_id": clientId,
        "client_password": clientSecret,
        "grant_type": "password",
        "username": username,
        "password": password
      },
    );
  } on DioError catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      print("${e.response!.statusCode}");
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
      errorHandler("登录失败,账号或密码错误");
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response);
  if (response == null) {
    return false;
  }
  print(response.data);
  if (response.data["access_token"] != null) {
    // TODO save
    BindUser bindUser = BindUser.fromMap(response.data["info"]);
    token = response.data["access_token"];
    await db.bindUserProvider.save(bindUser);
    await db.prefs.setString(loginUsername, bindUser.username!);
    await db.prefs.setString(accessTokenKey, response.data["access_token"]);
    await db.prefs.setString(refreshTokenKey, response.data["refresh_token"]);
    return true;
  }
  errorHandler(response.data["message"]);
  return false;
}

// 注册
Future<BindUser?> register(String? nickname, String? password, String? email,
    Function errorHandler) async {
  final url = "http://$authServer/api/register";
  Response? response;
  try {
    response = await dio.post(url,
        data: {"nickname": nickname, "email": email, "password": password});
  } on DioError catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      print(e.response!.data);
      errorHandler(e.response?.data["message"]);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response);
  print(response?.data);
  if (response?.data["code"] == "200") {
    BindUser bindUser = BindUser.fromMap(response?.data["data"]);
    db.prefs.setString(registerUsername, bindUser.username!);
    return bindUser;
  }
  errorHandler(response?.data["message"]);
  return null;
}

// 上传图片
Future<String?> uploadImage(Uint8List image) async {
//  image/png
  DateTime now = DateTime.now();
  var formData = FormData.fromMap({
    'file': MultipartFile.fromBytes(image,
        contentType: MediaType.parse("image/png"),
        filename:
            "img${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.microsecond}${Random.secure().nextInt(500)}.png")
  });
  Response response = await dio.post('/file', data: formData);
  if (response.data["code"] == "200") {
    return response.data["data"][0];
  }
  return null;
}

// 上传 new
Future<bool> saveNew(String body, bool view, String image) async {
  Response? response;
  try {
    response = await dio.post("/new",
        data: {"body": body, "view": view ? 1 : 0, "images": image});
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200") {
    return true;
  }
  return false;
}

CancelToken? getNewPageToken;

/// 分页获取动态
Future<Map<dynamic, dynamic>?> getNewPage(int offset, int limit,
    {String? search}) async {
  Response? response;
  try {
    if (getNewPageToken == null) {
      getNewPageToken = CancelToken();
    } else {
      getNewPageToken?.cancel();
    }
    response = await dio.get("/new/page/$limit/$offset",
        cancelToken: getNewPageToken,
        queryParameters: {
          "search": search,
        });
    getNewPageToken = null;
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  if (response?.data["code"] == "200" && response?.data["data"] != null) {
//    print(response?.data["data"]);
    List<dynamic> list = response?.data["data"]["news"] as List<dynamic>;
    List<Map<dynamic, dynamic>> listData = list.map((e) {
      return {
        "body": e["body"],
        "images": e["images"],
        "view": e["view"],
        "new_id": e["new_id"],
        "create_time": e["create_time"],
        "star_count": e["star_count"],
        "up_count": e["up_count"],
        "comment_count": e["comment_count"],
        "user_id": e["user_id"],
        "nickname": e["nickname"],
        "ifUp": e["ifUp"],
        "ifStar": e["ifStar"],
      };
    }).toList();
    print(list);
    return {"count": response?.data["data"]["count"], "news": listData};
  }

  return null;
}

// 点赞或者收藏
Future<bool> operator(int newId, int status, int flag) async {
  Response? response;
  try {
    if (flag == 1) {
      response = await dio.put("/new/operator/$newId/$status");
    } else if (flag == 0) {
      response = await dio.delete(
        "/new/operator/$newId/$status",
      );
    }
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200") {
    return true;
  }
  return false;
}

// 获取评论
Future getComment(int newId) async {
  Response? response;
  try {
    response = await dio.get("/comment/$newId");
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200" && response?.data["data"] != null) {
    print(response?.data["data"]);

    return response?.data["data"];
  }
  return null;
}

/// 评论
Future<bool> comment(int newId, String body) async {
  Response? response;
  try {
    response =
        await dio.post("/comment/$newId", queryParameters: {"body": body});
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200" && response?.data["data"] != null) {
    print(response?.data["data"]);

    return true;
  }
  return false;
}

/// 设置自己背景图
Future<bool> saveBackground(String image) async {
  Response? response;
  try {
    response = await dio.put("/user", queryParameters: {"image": image});
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200" && response?.data["data"] != null) {
    print(response?.data["data"]);

    return true;
  }
  return false;
}

/// 关注或取消关注
Future<bool> follow(int username, bool flag) async {
  Response? response;
  try {
    if (flag) {
      response = await dio.post("/msg/follow/$username");
    } else {
      response = await dio.delete("/msg/follow/$username");
    }
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  if (response?.data["code"] == "200") {
    return true;
  }
  print(response);
  return false;
}

/// 查询是否关注
Future<bool> getIfFollow(int username) async {
  Response? response;
  try {
    response = await dio.get("/msg/follow/$username");
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200") {
    print(response?.data);

    return response?.data['data'];
  }
  return false;
}

/// 查询用户动态
Future getUserNew(int username) async {
  Response? response;
  try {
    response = await dio.get("/new/user/$username");
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200") {
    print(response?.data);

    return response?.data['data'];
  }
  return null;
}

/// 查询用户的动态
Future getUserFollow(int username) async {
  Response? response;
  try {
    response = await dio.get("/new/user/$username");
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200") {
    print(response?.data);

    return response?.data['data'];
  }
  return null;
}

/// 发消息
/// {
//    "from_id":1243,
//    "to_id":713181262038306817,
//    "type":0,
//    "body":"hahaha3"
//
//}
Future sendMsg(int toUsername, String body) async {
  String? fromUser = db.prefs.getString(loginUsername);
  Response? response;
  try {
    response = await dio.post("/msg", data: {
      "from_id": int.parse(fromUser!),
      "type": 0,
      "to_id": toUsername,
      "body": body
    });
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response);
  if (response?.data["code"] == "200") {
    return true;
  }
  return false;
}

/// 收藏动态列表
getStarList() async {
  Response? response;
  try {
    response = await dio.get("/new/star");
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200" && response?.data['data'] != null) {
    return response?.data['data'];
  }
  return null;
}

/// 关注用户列表
getFollowUserList() async {
  Response? response;
  try {
    response = await dio.get("/user/follow");
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200") {
    print(response?.data);

    return response?.data['data'];
  }
  return null;
}

/// 关注我的用户列表
getFollowedUserList() async {
  Response? response;
  try {
    response = await dio.get("/user/followed");
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200") {
    print(response?.data);

    return response?.data['data'];
  }
  return null;
}

// 互相关注
getFriends() async {
  Response? response;
  try {
    response = await dio.get("/user/friends");
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200") {
    print(response?.data);

    return response?.data['data'];
  }
  return null;
}

// 获取附近的人
// 上传位置
putAddress(String city, double longitude, double latitude) async {
  Response? response;
  try {
    response = await dio.post("/map", queryParameters: {
      "city": city,
      "longitude": longitude,
      "latitude": latitude
    });
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response);
  if (response?.data["code"] == "200") {
    print(response?.data);

    return response?.data;
  }
  return null;
}

Future<bool> updateUser(
    {String? nickname,
    String? email,
    String? old,
    String? password,
    Function? errorHandle}) async {
  Response? response;
  try {
    response = await dio.post("/user", data: {
      "nickname": nickname,
      "email": email,
      "password": password,
      "old": old,
    });
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
  print(response?.data);
  if (response?.data["code"] == "200") {
    print(response?.data["data"]);

    return true;
  }
  if (errorHandle != null) {
    errorHandle(response?.data['message']);
  }
  return false;
}
