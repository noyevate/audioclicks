import 'package:audioclicks/views/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  // 1. Add async here
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // 2. Add await here!
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // use your design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AudioSwam',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.red),
            primarySwatch: Colors.blueGrey,
            textTheme: Typography.englishLike2018.apply(
              fontSizeFactor: 1.sp,
            ),
          ),
          home: const Onboarding(),
        );
      },
    );
  }
}
