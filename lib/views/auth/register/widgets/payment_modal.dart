import 'dart:convert';

import 'package:audioclicks/common/others.dart';
import 'package:audioclicks/views/home/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paystack_for_flutter/paystack_for_flutter.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:http/http.dart' as http;

void showPaymentDialog(
  BuildContext context,
  String email,
) {
  Get.dialog(
    AlertDialog(
      title: const Text(
        "Membership Payment",
      ),
      content: const Text(
        "Proceed to make payment of ₦5,000?",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();

            await makePayment(
              context,
              email,
              (bool success) {
                if (success) {
                  Get.snackbar(
                    "Success",
                    "Payment completed",
                  );
                } else {
                  Get.snackbar(
                    "Cancelled",
                    "Payment was cancelled",
                  );
                }
              },
            );
          },
          child: const Text("Proceed"),
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
  Function(bool) onCompleted,
) async {
  final String reference = await generateRef();
  final secKey = "sk_test_5feafcd7578235e11dd02889f10e7ee4ff7ec0f7";

  try {
    final result = await PaystackFlutter().pay(
      context: context,
      secretKey: secKey,
      amount: 500000,
      email: email,
      callbackUrl: "https://callback.com",
      reference: reference,
      showProgressBar: true,
      paymentOptions: [PaymentOption.card],
      currency: Currency.NGN,
      confirmTransaction: true,
      onSuccess: (res) {
        onCompleted(true);
      },
      onCancelled: (res) {
        onCompleted(false);
      },
    );

    // print(result);
    Get.offAll(
      () => const HomeScreen(),
    );

    // await verifyPayment(
    //   reference,
    // );
  } catch (e) {
    debugPrint("make payment ${e.toString()}");
    Get.snackbar(
      "Payment Failed",
      e.toString(),
    );
  }
}

Future<void> verifyPayment(
  String reference,
) async {
  try {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/payment/verify/$reference",
      ),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Get.snackbar(
        "Success",
        "Payment verified successfully!",
      );

      Get.offAll(
        () => const HomeScreen(),
      );
    } else {
      Get.snackbar(
        "Error",
        data['message'] ?? "Verification failed",
      );
    }
  } catch (e) {
    Get.snackbar(
      "Error",
      "Could not verify payment",
    );
  }
}
