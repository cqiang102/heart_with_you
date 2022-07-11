import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/pages/body/find_page.dart';
import 'package:flutter_timelock/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;

class MatchPage extends StatefulWidget {
  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("获取位置，匹配最近的人"),
      content: SpinKitPumpingHeart(
        color: primaryColor.shade300,
        size: 120,
      ),
      actions: [
        TextButton(
            child: Text("开始匹配"),
            onPressed: () async {
              FLoading.show(
                context,
              );
              // 获取位置
              context.read<LocationProvider>().startLocation((result) async {
//                city : Mountain View
//                latitude : 37.421948
//                longitude : -122.083977
                // 提交 位置
                // 匹配用户
                // 取消 load
                if(result == null ||  result['city'] == null){
                  return;
                }
                print(result.toString());
                context.read<LocationProvider>().stopLocation();

                var matchUser = await api.putAddress(
                    result['city'], result['longitude'], result['latitude']);
                FLoading.hide();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Row(
                      children: [
                        Text("${matchUser['message']}"),
                      ],
                    )));
                if (matchUser['data'] != null) {

                  Navigator.pop(context);
                  double distance = matchUser['data']['distance'];
                  String textDistance;
                  if(distance < 1.0){
                    distance = (distance * 1000.0);
                    textDistance = '${'$distance'.substring(0,3)} m';
                  }else{
                    textDistance = '${'$distance'.substring(0,3)} ${matchUser['data']['unit']}';
                  }
                  showDialog(
                      context: context,
                      builder: (_) {
                        return FindPage(int.parse(matchUser['data']['user']),1,distance: textDistance,);
                      });
                }
              });
            }),
      ],
    );
  }
}
