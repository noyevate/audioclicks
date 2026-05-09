import 'package:audioclicks/views/auth/register/pages/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/atEEM.jpg",
        ),

        // child: Lottie.asset(
        //   'assets/images/audioswam_logo.json',
        //   width: 200,
        //   height: 200,
        //   repeat: true,
        // ),
      ),
    );
  }
}
