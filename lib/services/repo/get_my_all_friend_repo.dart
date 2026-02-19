

import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/friend/data/my_friends_model.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

class GetMyAllFriendsRepo {
 Future<List<MyFriendsData>> getFriendList()async{
   final List<MyFriendsData> myFriendsList =[];
    try{
      final ApiResponseModel response = await ApiService.get(ApiEndPoint.getMyAllFriend);
      if (response.statusCode == 200) {
        if(response.data["data"] is List) {
          for (var item in response.data["data"]) {
            myFriendsList.add(MyFriendsData.fromJson(item));
          }
        }
      }
    }catch(e){}
    return myFriendsList;
  }
}