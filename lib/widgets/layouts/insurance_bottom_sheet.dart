import 'package:flutter/material.dart';
import 'package:genesis/controllers/insurance_controller.dart';
import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:get/get.dart';

class InsuranceBottomSheet extends StatefulWidget {
  final List<DeductionItem> items;
  final VoidCallback onPayAll;

  const InsuranceBottomSheet({
    super.key,
    required this.items,
    required this.onPayAll,
  });

  @override
  State<InsuranceBottomSheet> createState() => _InsuranceBottomSheetState();
}

class _InsuranceBottomSheetState extends State<InsuranceBottomSheet> {
  final _insurancesController = Get.find<InsuranceController>();
  @override
  Widget build(BuildContext context) {
    // Calculate total deduction amount
    final double totalAmount = widget.items.fold(
      0,
      (sum, item) => sum + item.value,
    );

    return Container(
      decoration: BoxDecoration(
        color: GTheme.cardColor(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar for modern look
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const Text(
            'Insurance Deductions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your active insurance policies and total monthly cost.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Scrollable list of insurance items
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final calculatedValue = item.value;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GTheme.surface(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.security,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              item.deductionType == DeductionType.percentage
                                  ? '${item.value}% of base'
                                  : 'Fixed monthly rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${calculatedValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Summary Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payable',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                widget.onPayAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Obx(
                () => _insurancesController.payingInsurances.value
                    ? WhiteLoader()
                    : const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
