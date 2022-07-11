import 'package:flutter/cupertino.dart';
import 'api_service.dart' as api;
class FollowProvider extends ChangeNotifier {
  List<dynamic> listData =[];
  getData(int status)async{
    listData = [];
    var tempData;
    if(status == 1){
      tempData = await api.getFollowUserList();
    }
    if(status == 2){
      tempData = await api.getFollowedUserList();
    }
    if(status == 3){
      tempData = await api.getFriends();
    }
    if(tempData != null){
      listData = tempData;
    }
    notifyListeners();
  }
  removeFollow(int username){
    api.follow(username, false);
    listData.removeWhere((element) => element['username'] == username);
    notifyListeners();
  }
}
