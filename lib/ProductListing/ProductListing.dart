import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ProductController.dart';

class ProductListing extends StatelessWidget {
  ProductListing({super.key});

  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Active Product Inventory',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16A34A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.activeProductsList.isEmpty) {
          return const Center(
            child: Text(
              'No active stock items registered.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.activeProductsList.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = controller.activeProductsList[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(
                    0xFF16A34A,
                  ).withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.bakery_dining,
                    color: Color(0xFF16A34A),
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Qty: ${item.quantity}  •  Exp: ${item.expiryDate}',
                ),
                trailing: Text(
                  'Rs ${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
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
