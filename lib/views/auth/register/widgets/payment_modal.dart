import 'dart:convert';

import 'package:audioclicks/common/others.dart';
import 'package:audioclicks/controllers/auth_controller.dart';
import 'package:audioclicks/views/home/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:paystack_for_flutter/paystack_for_flutter.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:http/http.dart' as http;

final box = GetStorage();

void showPaymentDialog(BuildContext context, String email) {
  Get.dialog(
    AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Membership Payment",
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text(
          "Proceed to make your monthly subscription payment of ₦5,000?",
          style: TextStyle(color: Colors.black87)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();

            String? userId = box.read('userId');

            if (userId == null) {
              String? userId = "temp_${DateTime.now().millisecondsSinceEpoch}";
              Get.snackbar(
                  "Error", "User session not found. Please log in again.");
              // return;
            }

            await makePayment(
              context,
              email,
              userId!,
              (bool success) {
                if (success) {
                  print("Payment flow finished successfully!");
                } else {
                  print("Payment was cancelled or failed.");
                }
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Proceed", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// Future<void> makePayment(
//   BuildContext context,
//   String email,
// ) async {

//   try {
//       // final isTest = param['mode'] == 'test';
//       // final secKey = isTest ? keys['testSecretKey'] : keys['secretKey'];

//       final secKey =

//       final double rawAmount = double.parse(param['amount'].toString());
//       final double amountInKobo = (rawAmount * 100).toDouble();

//       await PaystackFlutter().pay(
//         context: Get.context!,
//         secretKey: secKey ?? '',
//         amount: amountInKobo,
//         reference: reference,
//         email: param['email'],
//         callbackUrl: 'https://inventory.classcube.online/payment.php',
//         showProgressBar: true,
//         paymentOptions: [PaymentOption.card],
//         currency: Currency.NGN,
//         confirmTransaction: true,
//         onSuccess: (res) {
//           onCompleted(true);
//         },
//         onCancelled: (res) {
//           onCompleted(false);
//         },
//       );
//     } catch (e) {
//       onCompleted(false);
//     }
// }

Future<String> generateRef() async {
  final now = DateTime.now().millisecondsSinceEpoch;

  return "AUDIOSWAM-$now";
}

Future<void> makePayment(
  BuildContext context,
  String email,
  String userId,
  Function(bool) onCompleted,
) async {
  final String reference = await generateRef();
  final pubKey = "sk_test_5feafcd7578235e11dd02889f10e7ee4ff7ec0f7";

  try {
    final result = await PaystackFlutter().pay(
      context: context,
      secretKey: pubKey,
      amount: 500000,
      email: email,
      callbackUrl: "https://callback.com",
      reference: reference,
      showProgressBar: true,
      paymentOptions: [PaymentOption.card],
      currency: Currency.NGN,
      confirmTransaction: true,
      onSuccess: (res) async {
        // Only verify if Paystack says success
        await verifyPayment(reference, userId);
        onCompleted(true);
      },
      onCancelled: (res) {
        Get.snackbar("Cancelled", "Payment was cancelled.");
        onCompleted(false);
      },
    );
  } catch (e) {
    debugPrint("make payment ${e.toString()}");
    Get.snackbar("Payment Failed", e.toString());
  }
}

Future<void> verifyPayment(String reference, String userId) async {
  try {
    Get.snackbar("Verifying", "Please wait while we confirm your payment...");

    final response = await http.get(
      Uri.parse("$baseUrl/payment/verify/$reference?userId=$userId"),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Get.snackbar("Success", "Payment verified successfully!");

      final auth = Get.find<AuthController>();
      await auth.fetchLatestProfile();

      Get.offAll(() => const HomeScreen());
    } else {
      Get.snackbar("Error", data['message'] ?? "Verification failed");
    }
  } catch (e) {
    Get.snackbar("Error", "Could not verify payment");
  }
}
