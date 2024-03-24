import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class FeedScreenViewModel extends BaseViewModel {
  final GettingBlogPosts _gettingBlogPostsService =
      Injector.appInstance.get<GettingBlogPosts>();
  final GettingProfile _gettingProfileService =
      Injector.appInstance.get<GettingProfile>();

  Future<List<BlogData>?>? blogPostsLoader;

  Future<UserData?> getUserProfileByAuthorID(int authorId) async {
    final userData = await _gettingProfileService.getProfileByAuthorIdFromPost(
        authorId: authorId);
    if (userData == null) {
      FirebaseCrashlytics.instance
          .log("Could not find a user with id $authorId");
    }
    return userData;
  }

  String getUserInitials(UserData userData) {
    String initials = "${userData.name?[0]}${userData.surname?[0]}";
    if (initials.isEmpty) return "?";
    return initials;
  }

  ImageProvider<Object>? getUserAvatar(UserData userData) {
    ImageProvider<Object>? userAvatar;
    if (userData is StudentData) {
      final StudentData studentProfile = userData;
      userAvatar = studentProfile.fullUrlPhoto == null
          ? null
          : CachedNetworkImageProvider(studentProfile.fullUrlPhoto!);
    } else if (userData is EmployeeData) {
      final EmployeeData employeeProfile = userData;
      userAvatar = employeeProfile.fullUrlPhoto == null
          ? null
          : CachedNetworkImageProvider(employeeProfile.fullUrlPhoto!);
    }
    return userAvatar;
  }

  void init() {
    blogPostsLoader = _gettingBlogPostsService.getBlogPosts();
  }
}
