import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timelock/pages/login/screens/loginScreen.dart';
import 'package:flutter_timelock/pages/welcome.dart';
import 'package:flutter_timelock/services/chat_message_model.dart';
import 'package:flutter_timelock/services/chat_provider.dart';
import 'package:flutter_timelock/services/comment_provider.dart';
import 'package:flutter_timelock/services/converse_provider.dart';
import 'package:flutter_timelock/services/draw_provider.dart';
import 'package:flutter_timelock/services/home_provider.dart';
import 'package:flutter_timelock/services/local_provider.dart';
import 'package:flutter_timelock/services/location_service.dart';
import 'package:flutter_timelock/services/new_provider.dart';
import 'package:flutter_timelock/services/profile_provider.dart';
import 'package:flutter_timelock/services/star_provider.dart';
import 'package:flutter_timelock/services/system_provider.dart';
import 'package:flutter_timelock/services/user_profile_provider.dart';
import 'package:provider/provider.dart';

import 'config/common_const.dart';
import 'config/floading.dart';
import 'generated/l10n.dart';
import 'pages/pages.dart';
import 'services/follow_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FLoading.init(
      Image.asset(
        "assets/images/loading_gif.gif",
        width: 200,
        height: 200,
      ),
      backgroundColor: Colors.black38);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => SystemProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
            create: (BuildContext context) => HomeProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ProfileProvider()),
        ChangeNotifierProvider(create: (BuildContext context) => NewProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => LocalProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => DrawProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => CommentProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ChatMessageModel()),
        ChangeNotifierProvider(
            create: (BuildContext context) => UserProfileProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => StarProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => FollowProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ChatProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ConverseProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => LocationProvider()),
      ],
      child: LaciaApp(),
    ),
  );
}

class LaciaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO 判断是否首次使用
    bool showWelcome = false;
    int useCount = context
        .select((SystemProvider systemProvider) => systemProvider.useCount);
    if (useCount == 0) {
      showWelcome = true;
    }
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "心系于你",
        onGenerateTitle: (context) => S.of(context).taskTitle,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
              // backgroundColor: Color(0xFFFAFAFA),
              titleTextStyle:
                  TextStyle(color: primaryColor.shade900, fontSize: 20),
              color: const Color(0xFFFAFAFA),
              elevation: 0),
          primarySwatch: primaryColor,
        ),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: context.select(
                (SystemProvider systemProvider) => systemProvider.initStatus)
            ? (showWelcome
                    ? WelcomePage()
                    : (context.select((SystemProvider s) => s.checkResult)
                        ? const HomePage()
                        : LoginScreen()) // 判断加载页面
                )
            : Scaffold(
                body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/lp2.png"))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(bottom: 60),
                        width: 50,
                        height: 50,
                        child: const CircularProgressIndicator(
                          strokeWidth: 10,
                        ))
                  ],
                ),
              )));
  }
}
