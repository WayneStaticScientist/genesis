import 'package:flutter/material.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/number_utils.dart';
import 'package:genesis/widgets/inputs/white_formfield.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

class TripClearingScreen extends StatefulWidget {
  final TripModel trip;
  const TripClearingScreen({super.key, required this.trip});

  @override
  State<TripClearingScreen> createState() => _TripClearingScreenState();
}

class _TripClearingScreenState extends State<TripClearingScreen> {
  final _userController = Get.find<UserController>();
  final List<OtherExpense> _expenses = [];
  final _expenseNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();

  void _addExpense() {
    if (_expenseNameController.text.isEmpty ||
        _expenseAmountController.text.isEmpty) {
      Toaster.showError("Please fill both name and amount");
      return;
    }
    final amount = double.tryParse(_expenseAmountController.text);
    if (amount == null) {
      Toaster.showError("Invalid amount");
      return;
    }

    setState(() {
      _expenses.add(
        OtherExpense(name: _expenseNameController.text.trim(), amount: amount),
      );
      _expenseNameController.clear();
      _expenseAmountController.clear();
    });
  }

  void _removeExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  void _handleClearTrip() async {
    final success = await _userController.clearTrip(
      tripId: widget.trip.id,
      expenses: _expenses.map((e) => e.toJson()).toList(),
    );

    if (success) {
      Get.back(); // Go back to details
      Toaster.showSuccess("Trip Cleared Successfully and marked Active");
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.trip.driver;
    final vehicle = widget.trip.vehicle;

    return Scaffold(
      backgroundColor: GTheme.surface(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Clear Trip",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Driver Information"),
            _buildProfileCard(
              title: "${driver['firstName']} ${driver['lastName']}",
              subtitle: driver['email'],
              details: [
                _DetailRow(
                  LineIcons.identificationCard,
                  "Passport",
                  driver['passport']?['passportNumber'] ?? "N/A",
                ),
                _DetailRow(
                  LineIcons.cardboardVr,
                  "License",
                  driver['licence']?['licenceNumber'] ?? "N/A",
                ),
                _DetailRow(
                  LineIcons.checkCircle,
                  "License Class",
                  driver['licence']?['licenceClass']?.toString() ?? "N/A",
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle("Vehicle Information"),
            _buildProfileCard(
              title: vehicle.carModel,
              subtitle: vehicle.licencePlate ?? "N/A",
              details: [
                _DetailRow(
                  LineIcons.cog,
                  "Engine",
                  vehicle.engineNumber ?? "N/A",
                ),
                _DetailRow(
                  LineIcons.fingerprint,
                  "Chassis (VIN)",
                  vehicle.vinNumber ?? "N/A",
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle("Trip Routing"),
            _buildProfileCard(
              title: "Destination",
              subtitle: widget.trip.destination,
              details: [
                _DetailRow(
                  LineIcons.ship,
                  "Port of Exit",
                  widget.trip.portOfExit ?? "N/A",
                ),
                _DetailRow(
                  LineIcons.truckLoading,
                  "Port of Entry",
                  widget.trip.portOfEntry ?? "N/A",
                ),
              ],
            ),
            if (widget.trip.tollgates.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSectionTitle("Tollgates"),
              const SizedBox(height: 10),
              _buildTollgateList(),
            ],
            const SizedBox(height: 32),

            _buildSectionTitle("Clearing Costs (Prices Paid)"),
            _buildExpenseInput(),
            const SizedBox(height: 16),
            _buildExpenseList(),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _handleClearTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GTheme.primary(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 8,
                ),
                child: Obx(
                  () => _userController.processingTrip.value
                      ? const WhiteLoader()
                      : const Text(
                          "Complete Clearing & Activate",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required String subtitle,
    required List<_DetailRow> details,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GTheme.emmense(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          ...details.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(d.icon, size: 18, color: GTheme.primary(context)),
                  const SizedBox(width: 10),
                  Text(
                    d.label,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    d.value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTollgateList() {
    return Column(
      children: widget.trip.tollgates.map((toll) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: GTheme.emmense(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 5),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.toll, size: 20, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  toll.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                NumberUtils.formatCurrency(toll.amount),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpenseInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.withAlpha(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: WhiteFormfield(
                  "Cost Description",
                  LineIcons.tag,
                  controller: _expenseNameController,
                  hint: "e.g. Customs Port Fees",
                  obscurePassword: false,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: WhiteFormfield(
                  "Amount",
                  LineIcons.dollarSign,
                  controller: _expenseAmountController,
                  keyboardType: TextInputType.number,
                  obscurePassword: false,
                  hint: "0.00",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _addExpense,
            icon: const Icon(LineIcons.plus),
            label: const Text(
              "Add to Clearing Costs",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              foregroundColor: GTheme.primary(context),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    if (_expenses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "No clearing costs added yet",
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Column(
      children: _expenses.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: GTheme.emmense(context),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 5),
            ],
          ),
          child: Row(
            children: [
              const Icon(LineIcons.receipt, size: 20, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  e.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                NumberUtils.formatCurrency(e.amount),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _removeExpense(i),
                icon: const Icon(LineIcons.trash, color: Colors.red, size: 20),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DetailRow {
  final IconData icon;
  final String label;
  final String value;
  _DetailRow(this.icon, this.label, this.value);
}
