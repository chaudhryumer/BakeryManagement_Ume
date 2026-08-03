import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'HomePageVM.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final HomePageVm vm = Get.put(HomePageVm());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        // Using SingleChildScrollView at the base instead of Column avoids the web height collapsing bug
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ), // Perfect mobile dashboard look on web
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header Greeting ──
                  _buildHeader(vm),
                  const SizedBox(height: 20),

                  // ── Today's Revenue Card ──
                  _buildRevenueCard(vm),
                  const SizedBox(height: 20),

                  // ── Alert Banner ──
                  Obx(
                    () => vm.showAlert.value
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildAlertBanner(vm),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // ── Section Label ──
                  const Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Quick Actions Grid (Icon Cards instead of Wide Buttons) ──
                  _buildActionsGrid(vm),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),

      // ── Bottom Navigation Bar ──
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        child: _buildBottomNav(vm),
      ),
    );
  }

  // ── Header Section ───────────────────────────────────────────────────────
  Widget _buildHeader(HomePageVm vm) {
    return Row(
      children: [
        // 👈 FIXED: Wrapped Column in Expanded to allow auto-wrapping and remove yellow text overflow lines
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Obx(
                      () => Text(
                        'Good morning, ${vm.ownerName.value}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  vm.todayDate.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Urgent Status Card Section (Replaces Static Revenue) ──────────────────
  Widget _buildRevenueCard(HomePageVm vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16A34A), // Rich dashboard green matching mock
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CRITICAL EXPIRY ITEM", // Updated label context
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              vm
                  .urgentExpiryProduct
                  .value, // 👈 Displays the urgent batch product title dynamically
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize:
                    26, // Decreased size dynamically to allow product names to sit beautifully
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => _buildStatItem('${vm.totalBatches.value}', 'Batches')),
              _buildDivider(),
              Obx(
                () =>
                    _buildStatItem('${vm.todayExpiries.value}', 'Today Expiry'),
              ),
              _buildDivider(),
              Obx(
                () =>
                    _buildStatItem('${vm.deadStockCount.value}', 'Dead Stock'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 24, color: Colors.white30);
  }

  // ── Alert Banner Section ─────────────────────────────────────────────────
  Widget _buildAlertBanner(HomePageVm vm) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => Text(
                vm.alertMessage.value,
                style: const TextStyle(
                  color: Color(0xFF9F1239),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: vm.dismissAlert,
            child: const Icon(Icons.close, size: 16, color: Color(0xFF9F1239)),
          ),
        ],
      ),
    );
  }

  // ── The Grid of Action Buttons ───────────────────────────────────────────
  Widget _buildActionsGrid(HomePageVm vm) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.25, // Creates beautifully proportioned grid buttons
      children: [
        _buildIconButtonCard(
          label: "Product Listing",
          icon: Icons.add_shopping_cart_rounded,
          color: const Color(0xFF16A34A),
          onTap: () => Get.toNamed('/ProductListing'),
        ),
        _buildIconButtonCard(
          label: "Add Batch",
          icon: Icons.post_add_rounded,
          color: const Color(0xFFF97316),
          onTap: () => Get.toNamed('/AddBatches'),
        ),
        _buildIconButtonCard(
          label: "Expiry Product Listing",
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFF2563EB),
          onTap: () => Get.toNamed('/ExpiryConsole'),
        ),
        _buildIconButtonCard(
          label: "Inventory Management",
          icon: Icons.local_shipping_outlined,
          color: const Color(0xFF7C3AED),
          onTap: () => Get.toNamed('/HomePage'),
        ),
      ],
    );
  }

  Widget _buildIconButtonCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color:
              color, // Uses the bright custom action colors from your layout screenshot
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment
              .center, // 👈 FORCES CORE ELEMENT ALIGNMENT TO CENTER
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ), // 👈 PREVENTS EDGE CLIPPING
              child: Text(
                label,
                textAlign: TextAlign
                    .center, // 👈 FIXED: Centers the multi-line module texts perfectly
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav Item Handler ──────────────────────────────────────────────
  Widget _buildBottomNav(HomePageVm vm) {
    final navItems = [
      {'title': 'Home', 'icon': Icons.grid_view_rounded, 'action': () {}},
      {
        'title': 'Orders',
        'icon': Icons.shopping_bag_outlined,
        'action': vm.goToOrders,
      },
      {
        'title': 'Stock',
        'icon': Icons.layers_outlined,
        'action': vm.goToInventory,
      },
      {
        'title': 'Delivery',
        'icon': Icons.local_shipping_outlined,
        'action': vm.goToDelivery,
      },
      {
        'title': 'Reports',
        'icon': Icons.insert_chart_outlined,
        'action': vm.goToReports,
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: List.generate(navItems.length, (index) {
            final isCurrent = index == 0;
            final itemColor = isCurrent
                ? const Color(0xFF16A34A)
                : const Color(0xFF9CA3AF);

            return Expanded(
              child: GestureDetector(
                onTap: navItems[index]['action'] as VoidCallback,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      navItems[index]['icon'] as IconData,
                      color: itemColor,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      navItems[index]['title'] as String,
                      style: TextStyle(
                        color: itemColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
