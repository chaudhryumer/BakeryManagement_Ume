import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AddBatchesVm.dart';

class AddBatches extends StatelessWidget {
  const AddBatches({super.key});

  @override
  Widget build(BuildContext context) {
    final AddBatchesVm vm = Get.put(AddBatchesVm());

    return Dialog(
      backgroundColor: const Color(0xFFF8F7F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: vm.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Center(
                  child: Text(
                    'Add New Batch',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Item/Batch Name Field
                _buildLabel('Batch / Product Name'),
                _buildInputField(
                  controller: vm.batchNameController,
                  hintText: 'e.g., Chocolate Cake, Wheat Bread...',
                ),
                const SizedBox(height: 16),

                // Quantity & Price Dual Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Quantity/kg/pcs'),
                          _buildInputField(
                            controller: vm.quantityController,
                            hintText: 'e.g., 20 pcs',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Cost Price per KG/pcs (Rs)'),
                          _buildInputField(
                            controller: vm.priceController,
                            hintText: 'e.g., 850',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Manufacture Date Field
                _buildLabel('Manufacture Date'),
                Obx(
                  () => _buildDatePickerField(
                    context,
                    dateText: vm.manufactureDate.value,
                    onTap: () => vm.pickDate(context, vm.manufactureDate),
                  ),
                ),
                const SizedBox(height: 16),

                // Expiry Date Field
                _buildLabel('Expiry Date'),
                Obx(
                  () => _buildDatePickerField(
                    context,
                    dateText: vm.expiryDate.value,
                    onTap: () => vm.pickDate(context, vm.expiryDate),
                  ),
                ),
                const SizedBox(height: 16),

                // Special Note Field
                _buildLabel('Special note / Storage info'),
                _buildInputField(
                  controller: vm.noteController,
                  hintText: 'e.g., Keep in cold storage, extra sugar...',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Action Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: vm.saveBatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save batch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed('/HomePage');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Return To HomePage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget for Text Labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  // Helper Widget for Input Fields matching screenshot text boxes
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF3F4F6), // Exact soft grey container fill
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Field required' : null,
    );
  }

  // Helper Widget for Tap-to-Select Dates
  Widget _buildDatePickerField(
    BuildContext context, {
    required String dateText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateText,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}
