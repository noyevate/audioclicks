import 'package:audioclicks/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import your AuthManager here

class ProfileTab extends StatelessWidget {
  ProfileTab({super.key});

  final AuthController auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      auth.fetchLatestProfile();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Very light gray background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (auth.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.black));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- AVATAR ---
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.black,
                child: Text(
                  auth.username.value.isNotEmpty
                      ? auth.username.value[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // --- NAME & EMAIL ---
              Text(
                "@${auth.username.value}",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter'),
              ),
              const SizedBox(height: 4),
              Text(
                auth.email.value,
                style: const TextStyle(
                    fontSize: 14, color: Colors.grey, fontFamily: 'Inter'),
              ),

              const SizedBox(height: 30),

              // --- SUBSCRIPTION CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Membership Status",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'Inter')),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: auth.hasActiveSubscription
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            auth.hasActiveSubscription ? "ACTIVE" : "INACTIVE",
                            style: TextStyle(
                              color: auth.hasActiveSubscription
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                        height: 30, thickness: 1, color: Color(0xFFEEEEEE)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Time Remaining",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'Inter')),
                        Text(
                          auth.subCountdown,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline, color: Colors.black54),
                title: const Text("App Version",
                    style: TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                trailing: const Text("1.0.0",
                    style: TextStyle(color: Colors.grey, fontFamily: 'Inter')),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Log Out",
                    style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600)),
                onTap: () => auth.logout(),
              ),
            ],
          ),
        );
      }),
    );
  }
}
