import 'dart:convert';
import 'package:audioclicks/common/others.dart';
import 'package:audioclicks/views/auth/register/widgets/payment_modal.dart';
import 'package:audioclicks/views/home/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  // Loading state
  var isLoading = false.obs;
  final box = GetStorage();

  Future<void> register(
    BuildContext context,
    String email,
    String username,
  ) async {
    if (email.isEmpty || username.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        snackPosition: SnackPosition.TOP,
      );

      return;
    }

    showPaymentDialog(
      context,
      email,
    );

    // isLoading.value = true;

    // try {
    //   final response = await http.post(
    //     Uri.parse("$baseUrl/users/create"),
    //     headers: {
    //       "Content-Type": "application/json",
    //     },
    //     body: jsonEncode({
    //       "username": username,
    //       "email": email,
    //       "role": "member",
    //     }),
    //   );

    //   if (response.statusCode == 201) {
    //     final data = jsonDecode(response.body);

    //     final user = data['user'];

    //     /// SAVE TEMP USER DATA
    //     await box.write('userId', user['_id']);
    //     await box.write('username', user['username']);
    //     await box.write('userRole', user['role']);
    //     await box.write('email', user['email']);

    //     Get.snackbar(
    //       "Success",
    //       "Account created successfully!",
    //     );

    //     /// SHOW PAYMENT MODAL
    //     showPaymentDialog(
    //       context,
    //       user['email'],
    //     );
    //   } else {
    //     final data = jsonDecode(response.body);

    //     Get.snackbar(
    //       "Error",
    //       data['error'] ?? "Failed to register",
    //       snackPosition: SnackPosition.TOP,
    //     );
    //   }
    // } catch (e) {
    //   Get.snackbar(
    //     "Error",
    //     "Network error. Please try again.",
    //     snackPosition: SnackPosition.TOP,
    //   );
    // } finally {
    //   isLoading.value = false;
    // }
  }

  Future<void> login(String email) async {
    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter your email",
          snackPosition: SnackPosition.TOP);
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse("$baseUrl/users"));

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);

        var user;
        for (var u in users) {
          if (u['email'] == email.trim()) {
            user = u;
            break;
          }
        }

        if (user != null) {
          await box.write('userId', user['_id']);
          await box.write('username', user['username']);
          await box.write('userRole', user['role']);

          Get.snackbar("Welcome Back", "Hello, ${user['username']}!");

          if (user['role'] == 'admin') {
            Get.snackbar("Error", "This is an admin user",
                snackPosition:
                    SnackPosition.TOP); // Navigate to Admin Dashboard
          } else {
            Get.offAll(
              () => const HomeScreen(),
            ); // Navigate to Member Dashboard
          }
        } else {
          Get.snackbar("Error", "User not found. Please register.",
              snackPosition: SnackPosition.TOP);
        }
      } else {
        Get.snackbar("Error", "Failed to connect to server.",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar("Error", "Network error. Please try again.",
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }
}
