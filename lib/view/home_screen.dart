import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to Home Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add action for new chat/message
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}