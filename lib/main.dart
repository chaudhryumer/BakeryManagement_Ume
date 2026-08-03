import 'package:bakery_management/Notification/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart';

import 'HomePage/HomePage.dart';
import 'ProductController.dart';
import 'Database SQLite/DatabaseHelper.dart';
import 'BatchTracking/AddBatches.dart';
import 'ProductListing/ProductListing.dart';
import 'SpalshScreen/SplashScreen.dart';
import 'expiryDasboard/expiry_console.dart';
// 👈 Added custom reference path

const backgroundExpiryCheckTask = "com.smartbite.bakery.expiryCheckTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize notification structures independently for this worker isolate path
      await NotificationService.init();

      final allBatches = await DatabaseHelper.instance.fetchAllBatches();
      DateTime today = DateTime.now();
      DateTime todayMidnight = DateTime(today.year, today.month, today.day);
      DateFormat formatter = DateFormat('d MMM yyyy');

      for (var batch in allBatches) {
        try {
          DateTime expDate = formatter.parse(batch.expiryDate);
          DateTime expMidnight = DateTime(
            expDate.year,
            expDate.month,
            expDate.day,
          );
          int remainingDays = expMidnight.difference(todayMidnight).inDays;

          // ── NOTIFY BEFORE 1 DAY ──
          if (remainingDays == 1) {
            await NotificationService.triggerAlert(
              id: batch.id.hashCode + 11,
              title: "⚠️ Expiry Imminent: ${batch.name}",
              body:
                  "Critical Warning! This batch will expire tomorrow. Process it immediately.",
            );
          }
          // ── NOTIFY EXPIRED ALREADY ──
          else if (remainingDays <= 0) {
            await NotificationService.triggerAlert(
              id: batch.id.hashCode + 22,
              title: "🚨 Dead Stock Alert: ${batch.name}",
              body:
                  "This batch has completely expired and requires clearance from active shelves.",
            );
          }
        } catch (_) {}
      }
    } catch (e) {
      print("Background worker process exception occurred: $e");
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize both engines sequentially
  await NotificationService.init();
  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask(
    "expiry_sync_id",
    backgroundExpiryCheckTask,
    frequency: const Duration(hours: 24),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  Get.put(ProductController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartBakery',
      initialRoute: '/SplashScreen',
      getPages: [
        GetPage(name: '/HomePage', page: () => HomePage()),
        GetPage(name: '/AddBatches', page: () => const AddBatches()),
        GetPage(name: '/ProductListing', page: () => ProductListing()),
        GetPage(name: '/ExpiryConsole', page: () => ExpiryConsole()),
        GetPage(name: '/SplashScreen', page: () => SplashScreen()),
      ],
    );
  }
}
