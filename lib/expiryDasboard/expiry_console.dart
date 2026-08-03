import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../ProductController.dart';
import '../HomePage/HomePageVM.dart'; // 👈 Added to update dashboard metrics instantly on deletion

class ExpiryConsole extends StatelessWidget {
  ExpiryConsole({super.key});

  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expiry & Warning Console',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(
          0xFFEF4444,
        ), // Crimson theme for urgency warnings
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.expiredAndWarningList.isEmpty) {
          return const Center(
            child: Text(
              '🎉 All products have safe shelf-lives!',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.expiredAndWarningList.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = controller.expiredAndWarningList[index];

            // Calculate day status layout labels
            int daysRemaining = 0;
            bool isExpired = false;
            try {
              DateTime exp = DateFormat('d MMM yyyy').parse(item.expiryDate);
              DateTime today = DateTime.now();
              daysRemaining = DateTime(
                exp.year,
                exp.month,
                exp.day,
              ).difference(DateTime(today.year, today.month, today.day)).inDays;
              isExpired = daysRemaining < 0;
            } catch (_) {}

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isExpired
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFFFF7ED),
              borderOnForeground: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isExpired
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFFED7AA),
                  width: 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpired
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFF97316),
                  child: Icon(
                    isExpired
                        ? Icons.gavel_rounded
                        : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF111827),
                  ),
                ),
                subtitle: Text(
                  isExpired
                      ? 'Expired on: ${item.expiryDate}'
                      : 'Expires soon: ${item.expiryDate} ($daysRemaining days remaining)',
                  style: TextStyle(
                    color: isExpired
                        ? const Color(0xFF991B1B)
                        : const Color(0xFF9A3412),
                  ),
                ),
                // ── UPDATED: INTERACTIVE CLICK ACTION BUTTONS ──
                trailing: InkWell(
                  onTap: () async {
                    if (isExpired) {
                      // 1. Call controller deletion sequence to purge from SQLite and internal lists
                      // Replace 'removeBatch' with your exact ProductController deletion method name if named differently
                      await controller.removeBatch(item.id);

                      // 2. Synchronize your Home Dashboard counters immediately
                      if (Get.isRegistered<HomePageVm>()) {
                        Get.find<HomePageVm>().updateDashboardMetrics();
                      }

                      // 3. Show confirmation feedback status
                      Get.snackbar(
                        'Stock Cleared',
                        '${item.name} removed from bakery shelf records.',
                        backgroundColor: const Color(0xFFEF4444),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    } else {
                      // Action code for apply a promotional product discount percentage layout if desired
                      print(
                        "Apply quick discount promotional value to: ${item.name}",
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isExpired
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFF97316))
                                  .withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      isExpired ? 'REMOVE' : 'DISCOUNT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
