import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/models/user.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;

import '../converse_page.dart';
import 'user_profile.dart';

class FindPage extends StatefulWidget {
  late int username;

  late int from;

  String? distance;

  FindPage(this.username, this.from, {this.distance});

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  BindUser? bindUser;

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  getData() async {
    var value = await api.userProfile("${widget.username}");
    if (value != null) {
      bindUser = BindUser.fromMap(value);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: primaryColor);
    return AlertDialog(
      title: Text("${widget.from == 1 ? "匹配成功" : "扫码成功"}"),
      content: bindUser == null
          ? SpinKitWave(
              color: primaryColor,
            )
          : InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=>UserProfile({
            "username":widget.username,
            "nickname":bindUser!.nickname
          })));
        },
            child: SizedBox(
        height: 260,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("${bindUser!.nickname}",style: textStyle,),
                        Spacer(),
                        Text(getTime(bindUser!.createTime.toString()),style: textStyle),
                      ],
                    ),


                    Image.network(
                      "http://$resourceServer/file/${bindUser!.backgroundUrl}",
                      fit: BoxFit.cover,
                      headers: {"Authorization": "Bearer ${api.token}"},
                    ),
                    if (widget.distance != null) Text('距离你 ${widget.distance}'),
                  ],
                ),
              ),
          ),
      actions: [
        TextButton(onPressed: () {
          var map = bindUser!.toMap();
          map['username'] = int.parse('${map['username']}');
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ConversePage(map)));
        }, child: Text("聊一聊",style: TextStyle(fontSize: 20),)),
      ],
    );
  }
}
