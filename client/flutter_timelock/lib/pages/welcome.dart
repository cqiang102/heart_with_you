import 'package:flutter/material.dart';
import 'package:flutter_timelock/pages/register_page.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

import 'home_page.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({Key? key}) : super(key: key);

  // Making list of pages needed to pass in IntroViewsFlutter constructor.
  final pages = [
    PageViewModel(
//      pageColor: const Color(0xFF03A9F4),
      iconImageAssetPath: 'assets/images/app_logo.png',
      bubbleBackgroundColor: Colors.lightGreenAccent,
//       bubble: Image.asset('assets/images/app_icon.png'),
//      body: const Text(
//        'Hassle-free  booking  of  flight  tickets  with  full  refund  on  cancellation',
//      ),
//      title: const Text(
//        'Flights',
//      ),
//      titleTextStyle:
//      const TextStyle(
//        // fontFamily: 'MyFont',
//          color: Colors.purple),
//      bodyTextStyle: const TextStyle(
//        // fontFamily: 'MyFont',
//          color: Colors.purple),
      pageBackground: Image.asset(
        'assets/images/lp5.png',
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,

        alignment: Alignment.center,
      ),
//      mainImage: Image.asset(
//        'assets/images/lp5.png',
////        height: 285.0,
////        width: 285.0,
//        alignment: Alignment.center,
//      ),
    ),
    PageViewModel(
      iconImageAssetPath: 'assets/images/app_logo.png',
      bubbleBackgroundColor: Colors.greenAccent,
      // pageColor: const Color(0xFF8BC34A),
      pageBackground: Image.asset(
        'assets/images/lp4.png',
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
      // iconImageAssetPath: 'assets/images/app_logo.png',
//      body: const Text(
//        'We  work  for  the  comfort ,  enjoy  your  stay  at  our  beautiful  hotels',
//      ),
//      title: const Text('Hotels'),
      // mainImage: Image.asset(
      //   'assets/images/lp4.png',
      //   height: 285.0,
      //   width: 285.0,
      //   alignment: Alignment.center,
      // ),
//      titleTextStyle:
//      const TextStyle(
//        // fontFamily: 'MyFont',
//          color: Colors.white),
//      bodyTextStyle: const TextStyle(
//        // fontFamily: 'MyFont',
//          color: Colors.white),
    ),
    PageViewModel(
      iconImageAssetPath: 'assets/images/app_logo.png',
      bubbleBackgroundColor: Colors.orange,
      pageBackground: Image.asset(
        'assets/images/lp3.png',
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        fit: BoxFit.cover,

      ),
//      pageBackground: Container(
//        decoration: const BoxDecoration(
//          gradient: LinearGradient(
//            stops: [0.0, 1.0],
//            begin: FractionalOffset.topCenter,
//            end: FractionalOffset.bottomCenter,
//            tileMode: TileMode.repeated,
//            colors: [
//              Colors.orange,
//              Colors.pinkAccent,
//            ],
//          ),
//        ),
//      ),
//      iconImageAssetPath: 'assets/images/background_app_logo.png',
//      body: const Text(
//        'Easy  cab  booking  at  your  doorstep  with  cashless  payment  system',
//      ),
//      title: const Text('Cabs'),
//      mainImage: Image.asset(
//        'assets/images/lp3.png',
//        height: 285.0,
//        width: 285.0,
//        alignment: Alignment.center,
//      ),
//      titleTextStyle:
//      const TextStyle(
//        // fontFamily: 'MyFont',
//          color: Colors.white),
//      bodyTextStyle: const TextStyle(
//        // fontFamily: 'MyFont',
//          color: Colors.white),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => IntroViewsFlutter(
        pages,
        showNextButton: true,
        showBackButton: true,
        backText: Text("上一页"),
        nextText: Text("下一页"),
        doneText: Text("完成"),
        skipText: Text("跳过"),
        onTapDoneButton: () {
          // Use Navigator.pushReplacement if you want to dispose the latest route
          // so the user will not be able to slide back to the Intro Views.
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => RegisterPage()), (_) => false);
        },
        pageButtonTextStyles: const TextStyle(
          color: Colors.purple,
          fontSize: 18.0,
        ),
      ),
    );
  }
}
