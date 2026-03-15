import 'package:genesis/utils/theme.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/date_utils.dart';
import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/controllers/payroll_controller.dart';

class TaxesDialog extends StatefulWidget {
  final Function setDialogState;
  const TaxesDialog({super.key, required this.setDialogState});

  @override
  State<TaxesDialog> createState() => _TaxesDialogState();
}

class _TaxesDialogState extends State<TaxesDialog> {
  final _payrollController = Get.find<PayrollController>();
  late List<DeductionItem> taxes;
  @override
  void initState() {
    taxes = _payrollController.taxes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          "Taxes List(${_payrollController.taxes.length})",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        GenesisDate.formatNormalDate(DateTime.now()),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 32),
            _sectionHeader("Taxes", Icons.security, () {
              _addDeduction(widget.setDialogState);
            }),
            ...taxes.map(
              (i) => _deductionTile(i, () {
                widget.setDialogState(() => taxes.remove(i));
                setState(() {}); // Update the main dashboard net pay
              }),
            ),
            const Divider(height: 40),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _saveChanges(),
                child: Obx(
                  () => _payrollController.addingPayrollTax.value
                      ? WhiteLoader()
                      : const Text("Save Changes"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addDeduction(Function setDialogState) {
    final nameController = TextEditingController();
    final valController = TextEditingController();
    DeductionType selectedType = DeductionType.percentage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text("New Deduction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name (e.g. VAT)"),
              ),
              TextField(
                controller: valController,
                decoration: const InputDecoration(labelText: "Value"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              SegmentedButton<DeductionType>(
                segments: const [
                  ButtonSegment(
                    value: DeductionType.percentage,
                    label: Text("%"),
                  ),
                  ButtonSegment(value: DeductionType.fixed, label: Text("\$")),
                ],
                selected: {selectedType},
                onSelectionChanged: (set) =>
                    setInnerState(() => selectedType = set.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setDialogState(() {
                  taxes.add(
                    DeductionItem(
                      name: nameController.text,
                      value: double.tryParse(valController.text) ?? 0,
                      deductionType: selectedType,
                    ),
                  );
                });
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(
            Icons.add_circle_outline,
            color: Colors.blue,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _deductionTile(DeductionItem item, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GTheme.surface(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(item.name, style: const TextStyle(fontSize: 13)),
          ),
          Text(
            item.deductionType == DeductionType.percentage
                ? "${item.value}%"
                : "\$${item.value}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.remove_circle,
              color: Colors.redAccent,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    await _payrollController.addPayrollTax(taxes);
  }
}
