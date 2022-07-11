import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/models/message.dart';
import 'package:flutter_timelock/pages/converse_page.dart';
import 'package:flutter_timelock/services/chat_provider.dart';
import 'package:flutter_timelock/services/home_provider.dart';
import 'package:flutter_timelock/widgets/match_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_timelock/services/db_service.dart' as db;
import 'package:flutter_timelock/services/api_service.dart' as api;

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<ChatProvider>().getData();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme
        .of(context)
        .primaryColor;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Ta"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: InkWell(
                onTap: () {
                  showDialog(context: context, builder: (_) {
                    return MatchPage();
                  });
//                showLicensePage(context: context);
                },
                child: Icon(
                  FontAwesomeIcons.connectdevelop,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        body:
        context
            .watch<ChatProvider>()
            .list
            .isEmpty
            ? ListView(children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                "暂无消息",
                style: TextStyle(color: primaryColor),
              ),
            ),
          ),
        ])
            : ListView.builder(
            itemCount: context
                .watch<ChatProvider>()
                .list.length,
            itemBuilder: (_, index) {
          BindMessage e = context
              .watch<ChatProvider>()
              .list[index];
          return ChatList(e);
        })

//          [
//            Padding(
//              padding:
//                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 1),
//              child: TextField(
//                decoration: InputDecoration(
//                  contentPadding: EdgeInsets.all(0),
//                  border: OutlineInputBorder(
//                      borderRadius: BorderRadius.circular(50)),
//                  hintText: "搜索",
//                  hintStyle: TextStyle(fontSize: 14),
//                  prefixIcon: Icon(
//                    FontAwesomeIcons.search,
//                    size: 18,
//                  ),
//                ),
//              ),
//            ),
//            Divider(),
      // for (Message? m in messageList)
      //   if(m != null)
      //     ChatListTile(m),
      // if(messageList.isEmpty)
      //   Center(child: Text("暂无消息"))
      // ListTile(
      //   onTap: () {
      //     Navigator.of(context)
      //         .push(MaterialPageRoute(builder: (context) {
      //       return Scaffold(
      //         appBar: AppBar(
      //           centerTitle: true,
      //           title: Text(
      //             "大头",
      //             style: TextStyle(
      //                 fontSize: 16, color: primaryColor.shade900),
      //           ),
      //           backgroundColor: primaryColor.shade200,
      //           leading: IconButton(
      //             icon: Icon(FontAwesomeIcons.angleLeft),
      //             color: primaryColor.shade900,
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //             },
      //           ),
      //         ),
      //         body: Padding(
      //           padding: const EdgeInsets.all(8.0),
      //           child: Column(
      //             children: [
      //               Expanded(
      //                 child: ListView(
      //                   children: [
      //                     Bubble(
      //                       alignment: Alignment.center,
      //                       color: Color.fromRGBO(212, 234, 244, 1.0),
      //                       child: Text('昨天',
      //                           textAlign: TextAlign.center,
      //                           style: TextStyle(fontSize: 11.0)),
      //                     ),
      //                     Bubble(
      //                       margin: BubbleEdges.only(top: 10),
      //                       alignment: Alignment.topRight,
      //                       nipWidth: 5,
      //                       nipHeight: 20,
      //                       nip: BubbleNip.rightTop,
      //                       color: Color.fromRGBO(225, 255, 199, 1.0),
      //                       child:
      //                       Text('在吗在吗！', textAlign: TextAlign.right),
      //                     ),
      //                     Bubble(
      //                       margin: BubbleEdges.only(top: 10),
      //                       alignment: Alignment.topLeft,
      //                       nipWidth: 8,
      //                       nipHeight: 24,
      //                       nip: BubbleNip.leftTop,
      //                       child: Text('在的在的QaQ'),
      //                     ),
      //                     Bubble(
      //                       margin: BubbleEdges.only(top: 10),
      //                       alignment: Alignment.topRight,
      //                       nipWidth: 30,
      //                       nipHeight: 10,
      //                       nip: BubbleNip.rightTop,
      //                       color: Color.fromRGBO(225, 255, 199, 1.0),
      //                       child: Text('晚上好 ！！！ ',
      //                           textAlign: TextAlign.right),
      //                     ),
      //                     Bubble(
      //                       margin: BubbleEdges.only(top: 10),
      //                       alignment: Alignment.topLeft,
      //                       nipWidth: 10,
      //                       nipHeight: 20,
      //                       nip: BubbleNip.leftCenter,
      //                       child: Text('记得写代码。'),
      //                     ),
      //                     Bubble(
      //                       margin: BubbleEdges.only(top: 10),
      //                       alignment: Alignment.center,
      //                       nip: BubbleNip.no,
      //                       color: Color.fromRGBO(212, 234, 244, 1.0),
      //                       child: Text('今天',
      //                           textAlign: TextAlign.center,
      //                           style: TextStyle(fontSize: 11.0)),
      //                     ),
      //                     Bubble(
      //                       margin: BubbleEdges.only(top: 10),
      //                       alignment: Alignment.topRight,
      //                       nipWidth: 10,
      //                       nipHeight: 20,
      //                       nip: BubbleNip.rightBottom,
      //                       color: Color.fromRGBO(225, 255, 199, 1.0),
      //                       child: Text('早上好。'),
      //                     ),
      //                     Bubble(
      //                       margin: BubbleEdges.only(top: 10),
      //                       alignment: Alignment.topRight,
      //                       nip: BubbleNip.no,
      //                       color: Color.fromRGBO(225, 255, 199, 1.0),
      //                       child: Text('给你买了早饭。'),
      //                     ),
      //                     Bubble(
      //                       margin: BubbleEdges.only(top: 10),
      //                       alignment: Alignment.center,
      //                       nip: BubbleNip.no,
      //                       color: Colors.transparent,
      //                       borderColor: Colors.transparent,
      //                       shadowColor: Colors.transparent,
      //                       child: Text(
      //                           '${TimeOfDay.now().format(context)}',
      //                           textAlign: TextAlign.center,
      //                           style: TextStyle(fontSize: 11.0)),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //               TextField(
      //                 decoration: InputDecoration(
      //                   contentPadding: EdgeInsets.all(0),
      //                   border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(50)),
      //                   hintText: "写",
      //                   hintStyle: TextStyle(fontSize: 14),
      //                   prefixIcon: Icon(
      //                     FontAwesomeIcons.feather,
      //                     size: 18,
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       );
      //     }));
      //   },
      //   dense: true,
      //   trailing: Column(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [
      //       Text("${TimeOfDay.now().format(context)}"),
      //       Container(
      //         width: 10,
      //         height: 10,
      //         decoration: BoxDecoration(
      //             color: Colors.green,
      //             borderRadius: BorderRadius.circular(5)),
      //       )
      //     ],
      //   ),
      //   leading: FlutterLogo(),
      //   title: Text("大头"),
      //   subtitle: Text("现在去干饭"),
      // ),
      // Divider(),
      // ChatListTile(Message(
      //     id: 234,
      //     avatar: '',
      //     type: TYPE.Text,
      //     dateTime: DateTime.now(),
      //     fromUserId: 1.0,
      //     fromUserName: '哈哈哈',
      //     ifRead: false)),
      //Divider(),
      // ChatListTile(Message(
      //     id: 456,
      //     avatar: '',
      //     type: TYPE.Image,
      //     dateTime: DateTime.now(),
      //     fromUserId: 2.0,
      //     fromUserName: '嘿嘿',
      //     ifRead: true)),
      // Divider(),
      // ChatListTile(Message(
      //     id: 567,
      //     avatar: '',
      //     type: TYPE.Text,
      //     dateTime: DateTime.now(),
      //     fromUserId: 3.0,
      //     fromUserName: '大力',
      //     text: "不知道",
      //     ifRead: false)),
      // Divider(),

//                  ListTile(
//                    onTap: () {
//                      Navigator.of(context).push(MaterialPageRoute(
//                          builder: (context) => ConversePage({})));
//                    },
//                    dense: true,
//                    trailing: Column(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: [
//                        Text("${TimeOfDay.now().format(context)}"),
//                        Container(
//                          width: 10,
//                          height: 10,
//                          decoration: BoxDecoration(
//                              color: Colors.green,
//                              borderRadius: BorderRadius.circular(5)),
//                        )
//                      ],
//                    ),
//                    leading: FlutterLogo(),
//                    title: Text("大头"),
//                    subtitle: Text("现在去干饭"),
//                  ),
//                  Divider(),
//                  ListTile(
//                    dense: true,
//                    trailing: Column(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: [
//                        Text("${TimeOfDay.now().format(context)}"),
//                        Container(
//                          width: 10,
//                          height: 10,
//                          decoration: BoxDecoration(
//                              color: Colors.green,
//                              borderRadius: BorderRadius.circular(5)),
//                        )
//                      ],
//                    ),
//                    leading: FlutterLogo(),
//                    title: Text("大头"),
//                    subtitle: Text("现在去干饭"),
//                  ),
      // Divider(),
      // ListTile(
      //   dense: true,
      //   trailing: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text("${TimeOfDay.now().format(context)}"),
      //       // Container(
      //       //   width: 10,
      //       //   height: 10,
      //       //   decoration: BoxDecoration(
      //       //       color: Colors.green,
      //       //       borderRadius: BorderRadius.circular(5)),
      //       // )
      //     ],
      //   ),
      //   leading: FlutterLogo(),
      //   title: Text("大头"),
      //   subtitle: Text("现在去干饭"),
      // ),
      // Divider(),
      // ListTile(
      //   dense: true,
      //   trailing: Column(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [
      //       Text("${TimeOfDay.now().format(context)}"),
      //       // Container(
      //       //   width: 10,
      //       //   height: 10,
      //       //   decoration: BoxDecoration(
      //       //       color: Colors.green,
      //       //       borderRadius: BorderRadius.circular(5)),
      //       // )
      //     ],
      //   ),
      //   leading: FlutterLogo(),
      //   title: Text("大头"),
      //   subtitle: Text("现在去干饭"),
      // ),
      // Divider(),
//                ],
    );
  }
}

class ChatList extends StatefulWidget {
  BindMessage msg;

  ChatList(this.msg);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  dynamic? user;

  @override
  void initState() {
    // TODO: implement initState
//    getData();
    super.initState();
  }

  getData() async {
    String loginUser = db.prefs.getString(loginUsername)!;
    user = await api.userProfile("${widget.msg.fromId}" != loginUser
        ? "${widget.msg.fromId}"
        : "${widget.msg.toId}");
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (_,data){
          if(! data.hasData){
            return ListTile(
              dense: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "${TimeOfDay.fromDateTime(widget.msg.createTime).format(
                          context)}"),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.green, borderRadius: BorderRadius.circular(5)),
                  )
                ],
              ),
              leading: Image.asset(
                "assets/images/app_logo.png",
              ),
              title: Text("", overflow: TextOverflow.ellipsis,),
              subtitle: Text("${widget.msg.body}", overflow: TextOverflow.ellipsis),
            );
          }
         return ListTile(
            onTap: () {
              context.read<HomeProvider>().msgCountUpdate(false, widget.msg);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ConversePage(user)));
            },
            dense: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "${TimeOfDay.fromDateTime(widget.msg.createTime).format(
                        context)}"),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.green, borderRadius: BorderRadius.circular(5)),
                )
              ],
            ),
            leading: user ? ['background_url'] != null
                ? Image.network(
                "http://$resourceServer/file/${user ? ["background_url"]}",
                width: 60,
                headers: {"Authorization": "Bearer ${api.token}"})
                : Image.asset(
              "assets/images/app_logo.png",
            ),
            title: Text("${user ? ['nickname']}", overflow: TextOverflow.ellipsis,),
            subtitle: Text("${widget.msg.body}", overflow: TextOverflow.ellipsis),
          );
    });
  }
}
