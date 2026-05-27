import 'package:audioclicks/controllers/auth_controller.dart';
import 'package:audioclicks/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import your controllers here

class DashboardTab extends StatelessWidget {
  DashboardTab({super.key});

  final DashboardController dashCtrl = Get.put(DashboardController());
  final AuthController auth = Get.find<AuthController>();

  void _showSubmitBottomSheet(BuildContext context) {
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController urlCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Suggest a Track",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter')),
            const SizedBox(height: 8),
            const Text("It will instantly be added to today's list.",
                style: TextStyle(color: Colors.grey, fontFamily: 'Inter')),
            const SizedBox(height: 20),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Song/Video Title",
                filled: true,
                fillColor: Colors.black26.withOpacity(0.1),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "URL (YouTube, Spotify, etc.)",
                filled: true,
                fillColor: Colors.black26.withOpacity(0.1),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                    onPressed: dashCtrl.isSubmitting.value
                        ? null
                        : () => dashCtrl.submitLink(
                            titleCtrl.text.trim(), urlCtrl.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: dashCtrl.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : const Text("Add to Daily List",
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Inter')),
                  )),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true, // Allows it to move up when keyboard appears
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() => Text(
              "Hello, @${auth.username.value}",
              style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold),
            )),
      ),
      // Floating button to submit links!
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubmitBottomSheet(context),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => dashCtrl.fetchDashboardData(),
        color: Colors.black,
        child: Obx(() {
          if (dashCtrl.isLoading.value && dashCtrl.dailyLinks.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }

          double progress = dashCtrl.totalRequired.value > 0
              ? (dashCtrl.totalWatched.value / dashCtrl.totalRequired.value)
              : 0.0;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- COMPLIANCE CARD ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    children: [
                      // Circular Progress
                      SizedBox(
                        height: 70,
                        width: 70,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  dashCtrl.isCompliant.value
                                      ? Colors.green
                                      : Colors.orange),
                            ),
                            Center(
                              child: Text(
                                "${dashCtrl.totalWatched}/${dashCtrl.totalRequired}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Today's Progress",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter')),
                            const SizedBox(height: 4),
                            Text(
                              dashCtrl.isCompliant.value
                                  ? "You're fully compliant! 🎉"
                                  : "Watch remaining links to complete your daily task.",
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- CURATED LINKS SECTION ---
                const Text("🎧 Today's Curated List",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter')),
                const SizedBox(height: 12),

                if (dashCtrl.dailyLinks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                        child: Text("No links available right now.",
                            style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...dashCtrl.dailyLinks.map((link) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_fill,
                              color: Colors.black, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(link['title'] ?? 'Unknown',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Inter')),
                                Text(
                                    "by @${link['submittedBy']?['username'] ?? 'Unknown'}",
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                        fontFamily: 'Inter')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => dashCtrl.watchLink(link['_id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Play",
                                style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 80), // Padding for the floating button
              ],
            ),
          );
        }),
      ),
    );
  }
}
