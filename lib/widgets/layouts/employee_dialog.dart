import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/models/user_model.dart';
import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/widgets/inputs/default_formfield.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:get/get.dart';

class EmployeeDialog extends StatefulWidget {
  final User emp;
  final Function setDialogState;
  const EmployeeDialog({
    super.key,
    required this.emp,
    required this.setDialogState,
  });

  @override
  State<EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<EmployeeDialog> {
  late final _paymentController = TextEditingController(
    text: widget.emp.payment.toString(),
  );
  final userController = Get.find<UserController>();
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF0F172A),
                  child: Text(
                    widget.emp.firstName[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.emp.firstName} ${widget.emp.lastName}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.emp.role,
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
            DefaultFormfield(
              keyboardType: TextInputType.number,
              controller: _paymentController,
              label: "Payment",
              hint: "Amount in USD",
              icon: Icons.money,
            ),
            "Leaving 0 or empty for payment will not generate payslip for the member"
                .text(style: TextStyle(fontSize: 10)),
            const Divider(height: 32),
            ...widget.emp.taxes.map(
              (t) => _deductionTile(t, () {
                widget.setDialogState(() => widget.emp.taxes.remove(t));
                setState(() {}); // Update the main dashboard net pay
              }),
            ),

            const SizedBox(height: 20),
            _sectionHeader("Insurance", Icons.security, () {
              _addDeduction(
                widget.emp,
                widget.emp.insurance,
                widget.setDialogState,
              );
            }),
            ...widget.emp.insurance.map(
              (i) => _deductionTile(i, () {
                widget.setDialogState(() => widget.emp.insurance.remove(i));
                setState(() {}); // Update the main dashboard net pay
              }),
            ),

            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Calculated Net:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${widget.emp.payment.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
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
                  () => userController.updatingUserPayroll.value
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

  void _addDeduction(
    User emp,
    List<DeductionItem> list,
    Function setDialogState,
  ) {
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
                  list.add(
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
        color: Colors.grey.shade100,
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
    final amount = _paymentController.text.trim().isEmpty
        ? 0.0
        : double.tryParse(_paymentController.text);
    if (amount == null)
      return Toaster.showError("invalid number entered on payment");
    final response = await userController.updateUserPayroll(
      amount,
      widget.emp.insurance,
      widget.emp.id,
    );
    if (response) {
      Toaster.showSuccess("updated success");
    }
  }
}
