import 'package:bubble/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/models/message.dart';
import 'package:flutter_timelock/services/converse_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:flutter_timelock/services/db_service.dart' as db;

class ConversePage extends StatefulWidget {
  var user;

  ConversePage(this.user, {Key? key}) : super(key: key);

  @override
  State<ConversePage> createState() => _ConversePageState();
}

class _ConversePageState extends State<ConversePage> {
  @override
  void initState() {
    // TODO: implement initState

    context.read<ConverseProvider>().initData(widget.user['username']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${widget.user['nickname']}",
          style: TextStyle(fontSize: 16, color: primaryColor.shade900),
        ),
        backgroundColor: primaryColor.shade200,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.angleLeft),
          color: primaryColor.shade900,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: context.watch<ConverseProvider>().chat.isEmpty
                  ? Text("空空如也")
                  : ListView.builder(
                      reverse: true,
                      itemCount:
                          context.watch<ConverseProvider>().chat.length + 1,
                      itemBuilder: (_, index) {
                        if (index ==
                            context.watch<ConverseProvider>().chat.length) {
                          context.read<ConverseProvider>().getData();
                          return Container();
                        }
                        var item =
                            context.watch<ConverseProvider>().chat[index];

                        return _buildItem(item);
                      }),
//              ListView(
//                children: [
//                  Bubble(
//                    alignment: Alignment.center,
//                    color: Color.fromRGBO(212, 234, 244, 1.0),
//                    child: Text('昨天',
//                        textAlign: TextAlign.center,
//                        style: TextStyle(fontSize: 11.0)),
//                  ),
//                  Bubble(
//                    margin: BubbleEdges.only(top: 10),
//                    alignment: Alignment.topRight,
//                    nipWidth: 5,
//                    nipHeight: 20,
//                    nip: BubbleNip.rightTop,
//                    color: Color.fromRGBO(225, 255, 199, 1.0),
//                    child: Text('在吗在吗！', textAlign: TextAlign.right),
//                  ),
//                  Bubble(
//                    margin: BubbleEdges.only(top: 10),
//                    alignment: Alignment.topLeft,
//                    nipWidth: 8,
//                    nipHeight: 24,
//                    nip: BubbleNip.leftTop,
//                    child: Text('在的在的QaQ'),
//                  ),
//                  Bubble(
//                    margin: BubbleEdges.only(top: 10),
//                    alignment: Alignment.topRight,
//                    nipWidth: 30,
//                    nipHeight: 10,
//                    nip: BubbleNip.rightTop,
//                    color: Color.fromRGBO(225, 255, 199, 1.0),
//                    child: Text('晚上好 ！！！ ', textAlign: TextAlign.right),
//                  ),
//                  Bubble(
//                    margin: BubbleEdges.only(top: 10),
//                    alignment: Alignment.topLeft,
//                    nipWidth: 10,
//                    nipHeight: 20,
//                    nip: BubbleNip.leftCenter,
//                    child: Text('记得写代码。'),
//                  ),
//                  Bubble(
//                    margin: BubbleEdges.only(top: 10),
//                    alignment: Alignment.center,
//                    nip: BubbleNip.no,
//                    color: Color.fromRGBO(212, 234, 244, 1.0),
//                    child: Text('今天',
//                        textAlign: TextAlign.center,
//                        style: TextStyle(fontSize: 11.0)),
//                  ),
//                  Bubble(
//                    margin: BubbleEdges.only(top: 10),
//                    alignment: Alignment.topRight,
//                    nipWidth: 10,
//                    nipHeight: 20,
//                    nip: BubbleNip.rightBottom,
//                    color: Color.fromRGBO(225, 255, 199, 1.0),
//                    child: Text('早上好。'),
//                  ),
//                  Bubble(
//                    margin: BubbleEdges.only(top: 10),
//                    alignment: Alignment.topRight,
//                    nip: BubbleNip.no,
//                    color: Color.fromRGBO(225, 255, 199, 1.0),
//                    child: Text('给你买了早饭。'),
//                  ),
//                  Bubble(
//                    margin: BubbleEdges.only(top: 10),
//                    alignment: Alignment.center,
//                    nip: BubbleNip.no,
//                    color: Colors.transparent,
//                    borderColor: Colors.transparent,
//                    shadowColor: Colors.transparent,
//                    child: Text('${TimeOfDay.now().format(context)}',
//                        textAlign: TextAlign.center,
//                        style: TextStyle(fontSize: 11.0)),
//                  ),
//                ],
//              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              child: TextField(
                controller: context.read<ConverseProvider>().controller,
                onChanged: (str) =>
                    context.read<ConverseProvider>().updateMsgBody(str),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50)),
                    hintText: "写",
                    hintStyle: TextStyle(fontSize: 14),
                    prefixIcon: Icon(
                      FontAwesomeIcons.feather,
                      size: 18,
                    ),
                    suffixIcon:
                        context.watch<ConverseProvider>().sendMsgBody.isNotEmpty
                            ? InkWell(
                                onTap: () {
                                  FLoading.show(context);
                                  context.read<ConverseProvider>().sendMessage();
                                },
                                child: Icon(
                                  Icons.send,
                                  color: primaryColor,
                                ))
                            : Icon(Icons.send)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BindMessage item) {
    bool flag = false;
    if (item.fromId == int.parse(db.prefs.getString(loginUsername)!)) {
      flag = true;
    }
    return Bubble(
      margin: BubbleEdges.only(top: 10,bottom: 10),
      alignment: flag ? Alignment.topRight : Alignment.topLeft,
      nip: flag ? BubbleNip.rightCenter : BubbleNip.leftCenter,
      color: flag ? primaryColor : Colors.white,
      child: Text('${item.body}'),
    );
  }
}
