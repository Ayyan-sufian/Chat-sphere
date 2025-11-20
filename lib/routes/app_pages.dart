import 'package:get/get.dart';
import 'package:messanger/controllers/profile_controller.dart';
import 'package:messanger/routes/app_routes.dart';
import 'package:messanger/view/main_screen.dart';

import '../view/forget_pass_screen.dart';
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
    GetPage(name:  AppRoutes.main, page: () => const MainScreen(),),
    GetPage(name:  AppRoutes.forgetPass, page: () => const ForgetPassScreen(),),
    // GetPage(name:  AppRoutes.changePass, page: () => const ChangePassScreen(),),
    GetPage(name:  AppRoutes.profile, page: () => const ProfileScreen(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      },),),
    // GetPage(name:  AppRoutes.chat, page: () => const ChatScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(ChatController());
    //   },),),
    // GetPage(name:  AppRoutes.userList, page: () => const UserListScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(UserListController());
    //   },),),
    // GetPage(name:  AppRoutes.friends, page: () => const FriendsScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(FriendsController());
    //   },),),
    // GetPage(name:  AppRoutes.friendRequests, page: () => const FriendRequestScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.put(NotificationController());
    //   },),),
    // GetPage(name:  AppRoutes.notifications, page: () => const NotificationsScreen(),
    // binding: BindingsBuilder(() {
    //   Get.put(NotificationController());
    // },),
    // ),
  ];
}