import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:image/image.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/getting_image_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';

class GettingImageImpl implements GettingImage {
  @override
  Future<Image?> getImage(String url) async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(url));
    } catch (e) {
      log(e.toString());
      return null;
    }

    final statusCode = response.statusCode;

    if (statusCode != 200) {
      return null;
    }
    
    return decodeImage(response.bodyBytes) as Image;
  }

  @override
  Future<Image?> getImageOfCurrentUser() async {
    final GettingProfileOfCurrentUser gettingProfileOfCurrentUser =
      Injector.appInstance.get<GettingProfileOfCurrentUser>();
    final url = (await gettingProfileOfCurrentUser.getProfileOfCurrentUser())?.fullUrlPhoto;
    if (url == null) { 
      return null;
    }
    return getImage(url);
  }

}