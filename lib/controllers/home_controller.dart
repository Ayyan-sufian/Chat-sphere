import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt _unreadCount = 0.obs;
  
  int get unreadCount => _unreadCount.value;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize any home screen data
    loadHomeData();
  }
  
  void loadHomeData() {
    // Load home screen data
    // For now, we'll just set a dummy unread count
    _unreadCount.value = 5;
  }
  
  int getTotalUnreadCount() {
    return _unreadCount.value;
  }
}