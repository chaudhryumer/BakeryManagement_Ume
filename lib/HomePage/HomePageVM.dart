import 'dart:async';
import 'package:bakery_management/Database%20SQLite/DatabaseHelper.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Ensure this matches your exact directory helper file layout

class HomePageVm extends GetxController {
  // Observable property string to bind right into the card highlight area
  var urgentExpiryProduct = 'Loading...'.obs;

  var totalBatches = 0.obs;
  var todayExpiries = 0.obs;
  var deadStockCount = 0.obs;

  var alertMessage = ''.obs;
  var showAlert = true.obs;

  var ownerName = 'Man o salwa'.obs;
  var todayDate = ''.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _updateDate();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDate();
    });
  }

  @override
  void onReady() {
    super.onReady();
    updateDashboardMetrics();
  }

  void _updateDate() {
    todayDate.value = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());
  }

  Future<void> updateDashboardMetrics() async {
    try {
      final allBatches = await DatabaseHelper.instance.fetchAllBatches();
      totalBatches.value = allBatches.length;

      if (allBatches.isEmpty) {
        urgentExpiryProduct.value = "No Active Stock";
        todayExpiries.value = 0;
        deadStockCount.value = 0;
        showAlert.value = false;
        return;
      }

      DateTime today = DateTime.now();
      DateTime todayMidnight = DateTime(today.year, today.month, today.day);
      DateFormat formatter = DateFormat('d MMM yyyy');

      int localTodayExpiry = 0;
      int localDeadStock = 0;
      int localNearExpiryCount = 0;

      // Temporary track indicators to pinpoint the closest expiring product item safely
      String closestProduct = "";
      int minimumDaysRemaining = 999999; // Initialize with a high boundary flag

      for (var batch in allBatches) {
        try {
          DateTime expDate = formatter.parse(batch.expiryDate);
          DateTime expMidnight = DateTime(
            expDate.year,
            expDate.month,
            expDate.day,
          );
          int remainingDays = expMidnight.difference(todayMidnight).inDays;

          // ── EVALUATE CRITICAL COUNTS ──
          if (remainingDays == 0) {
            localTodayExpiry++;
          } else if (remainingDays < 0) {
            localDeadStock++;
          }
          if (remainingDays > 0 && remainingDays <= 6) {
            localNearExpiryCount++;
          }

          // ── FIND THE ABSOLUTE CLOSEST EXPIRY MATCH ──
          // We prioritize items expiring today or soonest, ignoring completely dead stock (< 0)
          if (remainingDays >= 0 && remainingDays < minimumDaysRemaining) {
            minimumDaysRemaining = remainingDays;

            if (remainingDays == 0) {
              closestProduct = "${batch.name} (Expires TODAY!)";
            } else {
              closestProduct = "${batch.name} ($remainingDays days left)";
            }
          }
        } catch (_) {}
      }

      // Assign core data loops back to observable references safely
      todayExpiries.value = localTodayExpiry;
      deadStockCount.value = localDeadStock;

      // If an upcoming target item was caught in calculations, display it prominently
      if (closestProduct.isNotEmpty) {
        urgentExpiryProduct.value = closestProduct;
      } else if (localDeadStock > 0) {
        // Fallback option if all remaining batches have already expired
        urgentExpiryProduct.value = "Check Dead Stock Shelf";
      } else {
        urgentExpiryProduct.value = "All Batches Stable";
      }

      // ── DYNAMIC BANNER STRIP STATUS ──
      if (localNearExpiryCount > 0 || localTodayExpiry > 0) {
        int totalUrgent = localNearExpiryCount + localTodayExpiry;
        alertMessage.value =
            "$totalUrgent batches near expiry · Check active shelves";
        showAlert.value = true;
      } else {
        showAlert.value = false;
      }
    } catch (e) {
      print("❌ Error loading updated home screen system metrics: $e");
      urgentExpiryProduct.value = "System Error";
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void goToOrders() => Get.toNamed('/orders');
  void goToBatches() => Get.toNamed('/batches');
  void goToInventory() => Get.toNamed('/inventory');
  void goToDelivery() => Get.toNamed('/delivery');
  void goToReports() => Get.toNamed('/reports');
  void dismissAlert() => showAlert.value = false;
}
