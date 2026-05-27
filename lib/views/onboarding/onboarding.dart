import 'package:audioclicks/controllers/auth_controller.dart';
import 'package:audioclicks/views/auth/register/pages/register_screen.dart';
import 'package:audioclicks/views/home/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final AuthController auth = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));

    if (auth.userId.value.isNotEmpty) {
      await auth.fetchLatestProfile();
    }

    if (auth.userId.value.isEmpty) {
      Get.offAll(() => const RegisterScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }

    debugPrint("Onboarding complete. User ID: ${auth.userId.value}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          "assets/images/audioswam_splash.png",
          // width: 200,
        ),
      ),
    );
  }
}
