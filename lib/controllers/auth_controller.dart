import 'dart:convert';
import 'package:audioclicks/common/others.dart';
import 'package:audioclicks/views/auth/login/pages/login_screen.dart';
import 'package:audioclicks/views/auth/register/widgets/payment_modal.dart';
import 'package:audioclicks/views/home/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  var isLoading = false.obs;
  final box = GetStorage();

  // --- PROFILE & SUBSCRIPTION OBSERVABLES ---
  var userId = ''.obs;
  var username = ''.obs;
  var email = ''.obs;
  var subStatus = 'inactive'.obs;
  var subExpiry = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load local storage data into memory when controller starts
    userId.value = box.read('userId') ?? '';
    username.value = box.read('username') ?? '';
    email.value = box.read('email') ?? '';
  }

  // --- SUBSCRIPTION HELPERS ---
  bool get hasActiveSubscription {
    if (subStatus.value != 'active' || subExpiry.value.isEmpty) return false;
    DateTime expiry = DateTime.parse(subExpiry.value);
    return DateTime.now().isBefore(expiry); // True if today is before expiry
  }

  String get subCountdown {
    if (!hasActiveSubscription) return "Expired";
    DateTime expiry = DateTime.parse(subExpiry.value);
    Duration diff = expiry.difference(DateTime.now());
    return "${diff.inDays} days, ${diff.inHours % 24} hrs left";
  }

  // --- FETCH LATEST DATA (For Profile Tab & App Restart) ---
  Future<void> fetchLatestProfile() async {
    if (userId.value.isEmpty) return;
    try {
      final res = await http.get(Uri.parse("$baseUrl/users/${userId.value}"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        username.value = data['username'] ?? '';
        email.value = data['email'] ?? '';
        subStatus.value = data['subscriptionStatus'] ?? 'inactive';
        subExpiry.value = data['subscriptionExpiryDate'] ?? '';
      }
    } catch (e) {
      debugPrint("Failed to fetch latest profile: $e");
    }
  }

  // --- REGISTER ---
  Future<void> register(
      BuildContext context, String email, String username) async {
    if (email.isEmpty || username.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields",
          snackPosition: SnackPosition.TOP);
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"username": username, "email": email, "role": "member"}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        // Save local data
        await box.write('userId', user['_id']);
        await box.write('username', user['username']);
        await box.write('userRole', user['role']);
        await box.write('email', user['email']);

        // Update observables
        this.userId.value = user['_id'];
        this.username.value = user['username'];
        this.email.value = user['email'];

        Get.snackbar("Success", "Account created successfully!");
        showPaymentDialog(context, user['email']);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error", data['error'] ?? "Failed to register",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar("Error", "Network error. Please try again.",
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIN ---
  // NOTE: Added BuildContext here so we can pop up the payment dialog if needed!
  Future<void> login(BuildContext context, String inputEmail) async {
    if (inputEmail.isEmpty) {
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
          if (u['email'] == inputEmail.trim()) {
            user = u;
            break;
          }
        }
        // debugPrint(user);

        if (user != null) {
          debugPrint(
              "User found: ${user['username']} with sub status: ${user['subscriptionStatus']}");
          debugPrint("User sub expiry: ${user['subscriptionExpiryDate']}");
          debugPrint("userId: ${user['_id']}");
          // Save local data
          await box.write('userId', user['_id']);
          await box.write('username', user['username']);
          await box.write('userRole', user['role']);
          await box.write('email', user['email']);

          // Update observables
          userId.value = user['_id'];
          username.value = user['username'];
          email.value = user['email'];
          subStatus.value = user['subscriptionStatus'] ?? 'inactive';
          subExpiry.value = user['subscriptionExpiryDate'] ?? '';

          Get.snackbar("Welcome Back", "Hello, ${user['username']}!",
              snackPosition: SnackPosition.TOP);

          if (user['role'] == 'admin') {
            Get.snackbar("Error", "This is an admin user",
                snackPosition: SnackPosition.TOP);
          } else {
            // SUBSCRIPTION CHECK!
            if (hasActiveSubscription) {
              Get.offAll(() => const HomeScreen());
            } else {
              // They logged in, but their sub is dead. Make them pay!
              showPaymentDialog(context, email.value);
            }
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

  // --- LOGOUT ---
  void logout() {
    box.erase(); // Clears GetStorage
    Get.offAll(() => const LoginScreen()); // Add your login screen route here
  }
}
