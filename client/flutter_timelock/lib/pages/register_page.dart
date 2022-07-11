import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/models/user.dart';
import 'package:flutter_timelock/pages/login/screens/loginScreen.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;

import 'home_page.dart';
import 'login/components/buttonLoginAnimation.dart';
import 'login/components/customTextfield.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final week = ["壹", "贰", "叁", "肆", "伍", "陆", "柒"];
  String? nickname;
  String? password;
  String? checkPassword;
  String? email;

  @override
  Widget build(BuildContext context) {
    // 注册输入 昵称
    // 输入 邮箱 选填
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
          child: ListView(
//          mainAxisAlignment: MainAxisAlignment.end,

            children: <Widget>[
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
//                          IconButton(
//                            icon: Icon(Icons.arrow_back,
//                                color: _primaryColor, size: 32),
//                            onPressed: () {
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
                            style:
                            TextStyle(color: _primaryColor, fontSize: 18)),
                        Text(
                            "${DateTime.now().toString().split("-")[1]}.${DateTime.now().toString().split("-")[2].split(" ")[0]}",
                            style:
                            TextStyle(color: _primaryColor, fontSize: 12))
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                height: MediaQuery.of(context).size.height * 0.82,
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
                    Text("加入我们",
                        style: TextStyle(
                            color: _primaryColor.withAlpha(120), fontSize: 25)),
                    SizedBox(height: 20),
                    CustomTextField(
                      label: "昵称",
                      onChanged: (str) => nickname = str,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
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
                    CustomTextField(
                      isPassword: true,
                      label: "确认密码",
                      icon: Icon(
                        Icons.verified,
                        size: 27,
                        color: _primaryColor,
                      ),
                      onChanged: (str) => checkPassword = str,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      textInputType: TextInputType.emailAddress,
                      label: "邮箱", onChanged: (str) => email = str,
//                          isPassword: true,
//                          icon: Icon(Icons.https, size: 27,color: _primaryColor,),
                    ),
                    SizedBox(height: 10),
                    ButtonLoginAnimation(
                      label: "注册",
                      fontColor: Colors.white,
                      background: _primaryColor.withOpacity(0.6),
                      borderColor: _primaryColor,
                      onTap: () async {
                        // TODO 获取账号密码
                        if (nickname == null) {
                          _showMessage("昵称不能为空");
                          return false;
                        }
                        if (password == null || checkPassword == null) {
                          _showMessage("密码不能为空");
                          return false;
                        }
                        if (password != checkPassword) {
                          _showMessage("两次输入密码不一致");
                          return false;
                        }
                        bool flag =true;
                        if (email == null) {
                          flag =  (await showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  content: Text("你未填写邮箱，在忘记密码后将无法找回账号"),
                                  title: Text("确定继续注册吗"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context,true);
                                        }, child: Text("确定"))
                                  ],
                                );
                              })) ?? false;
                        }
                        if(!flag){
                          return false;
                        }
                        _showMessage("注册中...zzZZZ");
                        FLoading.show(context);
                        BindUser? user = await api.register(nickname,password,email,(msg)=>
                          _showMessage(msg));
                        if(user != null){
                          _showMessage("注册成功，正在登陆...zzZZZ");
                          // TODO login request
                          bool  flag = await api.login(user.username!,password!,(msg)=>
                              _showMessage(msg));
                          FLoading.hide();
                          return flag;
                        }
                        FLoading.hide();
                        return false;
                      },
                      child: HomePage(),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => LoginScreen()));
                        },
                        child: Text("已有账号，去登录"))
                  ],
                ),
              )
            ],
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
