import 'dart:convert';
import 'package:audioclicks/common/others.dart';
import 'package:audioclicks/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DashboardController extends GetxController {
  var isLoading = true.obs;
  var isSubmitting = false.obs;

  var dailyLinks = [].obs;
  var totalRequired = 0.obs;
  var totalWatched = 0.obs;
  var isCompliant = false.obs;

  final AuthController auth = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  // Fetch both the Links and the Compliance Score at the same time
  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    String userId = auth.userId.value;

    try {
      final results = await Future.wait([
        http.get(Uri.parse("$baseUrl/links/daily?userId=$userId")),
        http.get(Uri.parse("$baseUrl/watch/status/$userId"))
      ]);

      if (results[0].statusCode == 200) {
        dailyLinks.value = jsonDecode(results[0].body);
      }

      if (results[1].statusCode == 200) {
        final complianceData = jsonDecode(results[1].body);
        totalRequired.value = complianceData['totalRequired'] ?? 0;
        totalWatched.value = complianceData['totalWatched'] ?? 0;
        isCompliant.value = complianceData['isCompliant'] ?? false;
      }
    } catch (e) {
      debugPrint("Dashboard Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Submit a new link to the community
  Future<void> submitLink(String title, String url) async {
    if (title.isEmpty || url.isEmpty) {
      Get.snackbar("Error", "Please enter both title and URL");
      return;
    }
    final urlRegex = RegExp(r"^(https?:\/\/)?([\w\-]+\.)+[\w\-]{2,}(\/.*)?$");
    if (!urlRegex.hasMatch(url.trim())) {
      Get.snackbar("Invalid Link",
          "Please enter a valid website link (e.g., youtube.com/...)");
      return;
    }

    isSubmitting.value = true;
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/links/submit"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "url": url,
          "submittedBy": auth.userId.value,
        }),
      );

      if (res.statusCode == 201) {
        Get.back(); // Close the bottom sheet
        Get.snackbar("Success", "Link added to the daily list! 🎉",
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchDashboardData(); // Refresh data!
      } else {
        Get.snackbar("Error", "Failed to submit link");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error. Try again.");
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> watchLink(String linkId) async {
    String userId = auth.userId.value;
    if (userId.isEmpty) {
      userId = GetStorage().read('userId') ?? '';
    }

    if (userId.isEmpty) {
      Get.snackbar(
          "Error", "User session lost. Please log out and log in again.");
      return;
    }

    // Construct the secret tracking URL
    // final trackingUrl = Uri.parse("$baseUrl/watch/$linkId?userId=$userId");
    final trackingUrl = Uri.parse("$baseUrl/watch/$linkId/$userId");
    debugPrint("Tracking URL: $trackingUrl");

    // Open it in the browser (which tracks it, then redirects to YouTube)
    if (await canLaunchUrl(trackingUrl)) {
      await launchUrl(trackingUrl, mode: LaunchMode.externalApplication);

      // When they come back to the app, refresh their score!
      Future.delayed(const Duration(seconds: 3), () {
        fetchDashboardData();
      });
    } else {
      Get.snackbar("Error", "Could not open link");
    }
  }
}
