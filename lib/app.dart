import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'config/route/app_routes.dart';
import 'config/theme/light_theme.dart';

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics;
  const MyApp({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      ensureScreenSize: true,
      minTextAdapt: true,
      splitScreenMode: true,
      designSize: const Size(428, 926),
      child: GetMaterialApp(
        title: 'Just Clicker',
        debugShowCheckedModeBanner: false,
        navigatorKey: Get.key,
        defaultTransition: Transition.fadeIn,
        theme: themeData,
        transitionDuration: const Duration(milliseconds: 300),
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.routes,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
      ),
    );
  }
}
