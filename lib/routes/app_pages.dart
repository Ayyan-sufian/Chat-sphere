import 'package:get/get.dart';
import 'package:messanger/controllers/main_controller.dart';
import 'package:messanger/controllers/profile_controller.dart';
import 'package:messanger/controllers/user_list_controller.dart';
import 'package:messanger/routes/app_routes.dart';
import 'package:messanger/view/find_people_screen.dart';
import 'package:messanger/view/friend_request_screen.dart';
import 'package:messanger/view/main_screen.dart';
import 'package:messanger/view/notification_screen.dart';

import '../controllers/friend_request_controller.dart';
import '../controllers/friends_controller.dart';
import '../controllers/notification_controller.dart';
import '../view/change_pass_screen.dart';
import '../view/forget_pass_screen.dart';
import '../view/friends_screen.dart';
import '../view/login_screen.dart';
import '../view/profile_screen.dart';
import '../view/register_screen.dart';
import '../view/splash_screen.dart';

class AppPages {
  static const String initial = AppRoutes.splash;

  static final routes = [
    GetPage(name:  AppRoutes.splash, page: () => const SplashScreen(),
      ),
    GetPage(name:  AppRoutes.login, page: () => const LoginScreen(),),
    GetPage(name:  AppRoutes.register, page: () => const RegisterScreen(),),
    GetPage(
      name: AppRoutes.main, 
      page: () =>  MainScreen(),
      binding: BindingsBuilder(() {
        Get.put(MainController());
      }),
    ),
    GetPage(name:  AppRoutes.forgetPass, page: () => const ForgetPassScreen(),),
    GetPage(name:  AppRoutes.changePass, page: () => const ChangePassScreen(),),
    GetPage(name:  AppRoutes.profile, page: () => const ProfileScreen(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      },),),
    // GetPage(name:  AppRoutes.chat, page: () => const ChatScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(ChatController());
    //   },),),
    GetPage(name:  AppRoutes.userList, page: () => FindPeopleScreen(),
      binding: BindingsBuilder(() {
        Get.put(UsersListController());
      },),),
    GetPage(name:  AppRoutes.friends, page: () => FriendsScreen(),
      binding: BindingsBuilder(() {
        Get.put(FriendsController());
      },),),
    GetPage(name:  AppRoutes.friendRequests, page: () => FriendRequestScreen(),
      binding: BindingsBuilder(() {
        Get.put(FriendRequestController());
      },),),
    GetPage(name:  AppRoutes.notifications, page: () => NotificationScreen(),
    binding: BindingsBuilder(() {
      Get.put(NotificationController());
    },),
    ),
  ];
}