import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/friends_controller.dart';
import 'package:messanger/controllers/home_controller.dart';
import 'package:messanger/controllers/profile_controller.dart';
import 'package:messanger/controllers/user_list_controller.dart';

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

  void changeTabIndex(int index){
    _currentIndex.value = index;
    pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onPageChanged(int index){
    _currentIndex.value = index;
  }

  int getNotificationCount(){
    try{
      final homeController = Get.find<HomeController>();
      return homeController.getTotalUnreadCount();


    }catch(e){
      return 0;
    }
  }

  int getUnread() {
    try {
      final homeController = Get.find<HomeController>();
      return homeController.getTotalUnreadCount();
      
     
    } catch (e) {
      return 0;
    }
  }
}