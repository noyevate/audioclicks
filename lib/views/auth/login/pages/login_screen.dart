import 'package:audioclicks/common/colors.dart';
import 'package:audioclicks/controllers/auth_controller.dart';
import 'package:audioclicks/views/auth/register/pages/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.put(AuthController());

  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              /// ANIMATION
              Center(
                child: Lottie.asset("assets/images/PlayButtonPulse.json",
                    height: 180),
              ),

              const SizedBox(height: 30),

              /// TITLE
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              /// SUBTITLE
              const Text(
                "Login to continue",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              /// EMAIL FIELD
              TextField(
                controller: emailController,
                style: const TextStyle(
                  color: Colors.black,
                ),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// LOGIN BUTTON (Wrapped in Obx)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null // Disable button while loading
                          : () {
                              authController.login(
                                  context, emailController.text.trim());
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: authController.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Login",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    )),
              ),

              const SizedBox(height: 20),

              /// REGISTER REDIRECT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                  ),
                  TextButton(
                    onPressed: () {
                      /// Navigate to register screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
