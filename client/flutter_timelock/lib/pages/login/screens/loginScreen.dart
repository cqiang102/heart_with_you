import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/pages/home_page.dart';
import 'package:flutter_timelock/pages/login/components/buttonLoginAnimation.dart';
import 'package:flutter_timelock/pages/login/components/customTextfield.dart';
import 'package:flutter_timelock/pages/register_page.dart';
import 'package:flutter_timelock/services/db_service.dart' as db;
import 'package:flutter_timelock/services/api_service.dart' as api;


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final week = ["壹", "贰", "叁", "肆", "伍", "陆", "柒"];
  String? username;

  String? password;
  FocusNode focusNodeAccount = FocusNode();
  FocusNode focusNodePassword = FocusNode();

  final textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var loginUsernameText = db.prefs.getString(loginUsername) ;
    var registerUsernameText = db.prefs.getString(registerUsername) ;
    if (loginUsernameText != null) {
      setState(() {
        textEditingController.text = loginUsernameText;
        username = loginUsernameText;
      });
    }else if (registerUsernameText != null){
      setState(() {
        textEditingController.text = registerUsernameText;
        username = registerUsernameText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/lp1.png"),
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter)),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
//                          IconButton(
//                            icon: Icon(Icons.arrow_back, color: _primaryColor,size:32),
//                            onPressed: (){
//                              Navigator.pop(context);
//                            },
//                          ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Icon(Icons.slow_motion_video,
                                color: _primaryColor, size: 32),
                            Text(" ${week[DateTime.now().weekday - 1]} ",
                                style: TextStyle(
                                    color: _primaryColor, fontSize: 18)),
                            Text(
                                "${DateTime.now().toString().split("-")[1]}.${DateTime.now().toString().split("-")[2].split(" ")[0]}",
                                style: TextStyle(
                                    color: _primaryColor, fontSize: 12))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  height: MediaQuery.of(context).size.height * 0.70,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("欢迎",
                          style: TextStyle(
                              color: _primaryColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                      Text("登录一下",
                          style: TextStyle(
                              color: _primaryColor.withAlpha(120),
                              fontSize: 25)),
                      SizedBox(height: 40),
                      CustomTextField(
                        focusNode: focusNodeAccount,
                        controller: textEditingController,
                        label: "邮箱 \\ 账号",
                        onChanged: (str) => username = str,
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        focusNode: focusNodePassword,
                        label: "密码",
                        isPassword: true,
                        icon: Icon(
                          Icons.https,
                          size: 27,
                          color: _primaryColor,
                        ),
                        onChanged: (str) => password = str,
                      ),
                      SizedBox(height: 10),
                      ButtonLoginAnimation(
                        label: "登录",
                        fontColor: Colors.white,
                        background: _primaryColor.withOpacity(0.6),
                        borderColor: _primaryColor,
                        onTap: () async {
                          // TODO 获取账号密码
                          if (username == null) {
                            focusNodeAccount.requestFocus();
                            _showMessage("账号不能为空");
                            return false;
                          }
                          if (password == null) {
                            _showMessage("密码不能为空");
                            focusNodePassword.requestFocus();
                            return false;
                          }
                          focusNodePassword.unfocus();
                          focusNodeAccount.unfocus();
                          // TODO login request
                          // TODO Save Token and User
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 1),
                              // backgroundColor: primaryColor,
                              content: Row(
                                children: [
                                  Text("登录中~zzZZZ"),
                                ],
                              )));
                          FLoading.show(context);
                          bool flag = await api.login(
                              username!, password!, (msg) => _showMessage(msg));
                          FLoading.hide();
                          return flag;
//                            bool login = await api.login("admin","123456");
//                            print("login $login");
//                            db.prefs.setString(tokenKey, "123");
//                            return login;
//                          return true;
                        },
                        child: HomePage(),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => RegisterPage()));
                          },
                          child: Text("暂无账号，去注册"))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        content: Row(
          children: [
            Text(msg),
          ],
        )));
  }
}
