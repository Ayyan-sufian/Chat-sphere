import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/routes/app_routes.dart';
import 'package:messanger/theme/app_theme.dart';

import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 3));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));

    _animationController.forward();

    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate () async{
    await Future.delayed(Duration(seconds: 2));
    // Ensure AuthController is initialized only once
    final authController = Get.put(AuthController(), permanent: true);
    // Initialize the auth controller
    authController.checkInitialAuthState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: AnimatedBuilder(animation: _animationController, builder: (context, child) {
          return FadeTransition(opacity: _fadeAnimation, child: ScaleTransition(scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10)
                    )
                  ]
                ),
                child: Icon(Icons.chat,size: 60,color: AppTheme.primaryColor,),
              ),
              SizedBox(height: 30,),
              Text("ChatSphere",style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),
              SizedBox(height: 30,),
              Text("Connect with your friends",style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),
              SizedBox(height: 30,),
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            ],
          ),
          ),);
        },),
      ),
    );
  }
}