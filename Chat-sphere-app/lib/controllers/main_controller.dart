import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'friends_controller.dart';
import 'home_controller.dart';
import 'profile_controller.dart';
import 'user_list_controller.dart';

class MainController extends GetxController {
  final RxInt _currentIndex = 0.obs;
  late final PageController pageController;

  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => FriendsController());
    Get.lazyPut(() => UsersListController());
    Get.lazyPut(() => ProfileController());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changeTabIndex(int index) {
    _currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void onPageChanged(int index) {
    _currentIndex.value = index;
  }

  int getNotificationCount() {
    try {
      return Get.find<HomeController>().getTotalUnreadCount();
    } catch (e) {
      return 0;
    }
  }

  int getUnread() {
    try {
      return Get.find<HomeController>().getTotalUnreadCount();
    } catch (e) {
      return 0;
    }
  }
}
