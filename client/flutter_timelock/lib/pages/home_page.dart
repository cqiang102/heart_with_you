import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/main.dart';
import 'package:flutter_timelock/pages/body/chat_page.dart';
import 'package:flutter_timelock/pages/body/draw_page.dart';
import 'package:flutter_timelock/pages/body/local_page.dart';
import 'package:flutter_timelock/pages/body/news_page.dart';
import 'package:flutter_timelock/pages/body/profile_page.dart';
import 'package:flutter_timelock/services/chat_message_model.dart';
import 'package:flutter_timelock/services/chat_provider.dart';
import 'package:flutter_timelock/services/home_provider.dart';
import 'package:flutter_timelock/services/profile_provider.dart';
import 'package:provider/provider.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

@override
class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    context.read<ChatProvider>().init(context);
    context.read<HomeProvider>().init(context);

  }

  @override
  Widget build(BuildContext context) {
    context.read<ProfileProvider>().initData();

    return WillPopScope(
      onWillPop: ()=>context.read<HomeProvider>().pop(context),
      child: Scaffold(
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: context.read<HomeProvider>().tabController,
          children: const [
            NewsPage(),
            LocalPage(),// TODO 匹配页面 点击匹配，刷新位置
            DrawPage(),
            ChatPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  _buildBottomNavigationBar() {
    return Builder(builder: (context) {
      Color primaryColor = Theme.of(context).primaryColor;

      // int count = context.select((ChatMessageModel value) => value.allTotal);
      int count = context.watch<HomeProvider>().msgCount;
      return ConvexAppBar.badge(
        count == 0 ? {} : {3: "$count"},
        badgeTextColor: Colors.white,
        curve: Curves.fastOutSlowIn,
        backgroundColor: Color(0xfffafafa),
        color: Color(0xffD8D8D8),
        // height: 50,
        curveSize: 80,
        activeColor: primaryColor,
        style: TabStyle.react,
        badgeMargin: EdgeInsets.only(bottom: 20, left: 20),
        controller: context.read<HomeProvider>().tabController,
        items: const [
          TabItem(
            icon: Icons.timelapse_rounded,
          ),
          TabItem(
            icon: Icons.settings_input_antenna_rounded,
          ),
          TabItem(
            icon: Icons.publish_sharp,
          ),
          TabItem(
            icon: Icons.messenger_outline,
          ),
          TabItem(
            icon: Icons.lock,
          ),
        ],
        initialActiveIndex: 2,
        //optional, default as 0
        onTap: (int i) => print('click index=$i'),
      );
    });
  }
}
