import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "ChatSphere",
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      getPages: AppPages.routes,
    );
  }
}
