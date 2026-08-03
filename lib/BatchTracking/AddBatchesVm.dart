import 'package:bakery_management/Notification/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../ProductController.dart';
import 'BatchModelClass.dart';
import '../HomePage/HomePageVM.dart'; // 👈 Added the HomePageVm import path to trigger card refresh

class AddBatchesVm extends GetxController {
  final formKey = GlobalKey<FormState>();

  final batchNameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final noteController = TextEditingController();

  var manufactureDate = ''.obs;
  var expiryDate = ''.obs;

  ProductController get productController => Get.find<ProductController>();

  @override
  void onInit() {
    super.onInit();
    String today = DateFormat('d MMM yyyy').format(DateTime.now());
    manufactureDate.value = today;
    expiryDate.value = today;
  }

  Future<void> pickDate(BuildContext context, RxString dateObs) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF16A34A)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateObs.value = DateFormat('d MMM yyyy').format(picked);
    }
  }

  Future<void> saveBatch() async {
    if (formKey.currentState!.validate()) {
      String cleanQuantityText = quantityController.text.trim().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      if (cleanQuantityText.isEmpty) {
        cleanQuantityText = "0";
      }

      final newBatch = BatchModelClass(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: batchNameController.text.trim(),
        quantity: cleanQuantityText,
        price: double.tryParse(priceController.text.trim()) ?? 0.0,
        manufactureDate: manufactureDate.value,
        expiryDate: expiryDate.value,
        note: noteController.text.trim(),
      );

      print("🚀 [AddBatchesVm] saveBatch() Triggered successfully!");

      // Save to SQLite configuration layer
      await productController.addNewBatch(newBatch);

      // 1. ── NOTIFY: BATCH ADDED SUCCESSFULLY ──
      await NotificationService.triggerAlert(
        id: newBatch.id.hashCode,
        title: "📦 Batch Added",
        body:
            "${newBatch.name} (Qty: ${newBatch.quantity}) successfully added to active stock.",
      );

      // Evaluate dates immediately to see if it should trigger an evaluation shift warning
      try {
        DateTime today = DateTime.now();
        DateTime todayMidnight = DateTime(today.year, today.month, today.day);
        DateTime expDate = DateFormat('d MMM yyyy').parse(newBatch.expiryDate);
        DateTime expMidnight = DateTime(
          expDate.year,
          expDate.month,
          expDate.day,
        );
        int daysLeft = expMidnight.difference(todayMidnight).inDays;

        // 2. ── NOTIFY: SHIFTED TO EXPIRES ON CREATION ──
        if (daysLeft <= 0) {
          await NotificationService.triggerAlert(
            id: newBatch.id.hashCode + 1,
            title: "🚨 Shifted immediately to Dead Expiry Console!",
            body:
                "The newly registered batch '${newBatch.name}' is already past its expiration date.",
          );
        } else if (daysLeft <= 6) {
          await NotificationService.triggerAlert(
            id: newBatch.id.hashCode + 2,
            title: "⚠️ Shifted to Critical Expiry Warning Zone",
            body:
                "'${newBatch.name}' entered inventory with only $daysLeft days remaining.",
          );
        }
      } catch (_) {}

      // 3. ── REFRESH HOMEPAGE REVENUE CARD & BANNER METRICS ──
      // This checks if HomePageVm is alive in memory map context and updates it instantly
      if (Get.isRegistered<HomePageVm>()) {
        Get.find<HomePageVm>().updateDashboardMetrics();
      }

      clearFormFields();
      Get.back();

      Get.snackbar(
        'Batch Registered',
        '${newBatch.name} added into inventory.',
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } else {
      print("⚠️ [AddBatchesVm] Form validation failed!");
    }
  }

  void clearFormFields() {
    batchNameController.clear();
    quantityController.clear();
    priceController.clear();
    noteController.clear();

    String today = DateFormat('d MMM yyyy').format(DateTime.now());
    manufactureDate.value = today;
    expiryDate.value = today;
  }

  @override
  void onClose() {
    batchNameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
