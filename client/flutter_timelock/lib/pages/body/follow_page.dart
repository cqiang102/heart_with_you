import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/pages/body/user_profile.dart';
import 'package:flutter_timelock/pages/converse_page.dart';
import 'package:flutter_timelock/services/follow_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;

class FollowPage extends StatefulWidget {
  late int status;

  FollowPage({Key? key, required this.status}) : super(key: key);

  @override
  _FollowPageState createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  var textTitle = {
    1: "关注",
    2: "粉丝",
    3: "好友",
  };

  @override
  void initState() {
    // TODO: implement initState
    context.read<FollowProvider>().getData(widget.status);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的${textTitle[widget.status]}"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: primaryColor,
          ),
        ),
      ),
      body: ListView(
        children: context.watch<FollowProvider>().listData.isEmpty
            ? ([
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    "一个人都没",
                    style: TextStyle(color: primaryColor),
                  ),
                ))
              ])
            : context.watch<FollowProvider>().listData.map((e) {
                return _buildItem(e);
              }).toList(),
      ),
    );
  }

  Widget _buildItem(e) {
    return (widget.status == 1)
        ? Dismissible(
            background: Container(
              color: Colors.red,
            ),
            key: ValueKey(e['username']),
            onDismissed: (d) {
              context.read<FollowProvider>().removeFollow(e['username']);
            },
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => UserProfile(e)));
              },
              title: Text("${e['nickname']}"),
              subtitle: Row(
                children: [
                  Text("${e['email'] ?? ""}"),
                  Spacer(),
                  Text(getTime(e['create_time'])),
                ],
              ),
              leading: e["background_url"] != null
                  ? Image.network(
                      "http://$resourceServer/file/${e["background_url"]}",
                  width: 60,
                  headers: {"Authorization": "Bearer ${api.token}"})
                  : Icon(Icons.person),
            ),
          )
        : ListTile(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => UserProfile(e)));
            },
            title: Text("${e['nickname']}"),
            subtitle: Row(
              children: [
                Text("${e['email'] ?? ""}",overflow: TextOverflow.ellipsis,),
                Spacer(),
                Text(getTime(e['create_time'])),
              ],
            ),
            trailing: (widget.status == 3)
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ConversePage(e)));
                    },
                    child: Text("发消息"),
                  )
                : null,
            leading: e["background_url"] != null
                ? Image.network(
                    "http://$resourceServer/file/${e["background_url"]}",
                width: 60,
                    headers: {"Authorization": "Bearer ${api.token}"})
                : Icon(Icons.person),
          );
  }
}
