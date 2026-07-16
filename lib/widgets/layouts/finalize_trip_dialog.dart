import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/utils/theme.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/controllers/user_controller.dart';
import 'package:genesis/widgets/loaders/white_loader.dart';
import 'package:genesis/controllers/trips_controller.dart';
import 'package:genesis/widgets/inputs/default_formfield.dart';

class FinalizeTripDialog extends StatefulWidget {
  final TripModel trip;
  final Function setDialogState;
  const FinalizeTripDialog({
    super.key,
    required this.trip,
    required this.setDialogState,
  });

  @override
  State<FinalizeTripDialog> createState() => _FinalizeTripDialogState();
}

class _FinalizeTripDialogState extends State<FinalizeTripDialog> {
  final _fuelExpensesController = TextEditingController(text: '0');
  final _tolgateFeesController = TextEditingController(text: '0');
  final _foodExpensesController = TextEditingController(text: '0');
  final _truckStopExpensesController = TextEditingController(text: '0');
  final _finesController = TextEditingController(text: '0');
  final _extraController = TextEditingController(text: '0');
  final _actualFuelUsageController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  final _controller = Get.find<TripsController>();
  final _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _fuelExpensesController.text = widget.trip.fuelExpense.toStringAsFixed(0);
    _tolgateFeesController.text = widget.trip.tolgateExpense.toStringAsFixed(0);
    _foodExpensesController.text = widget.trip.foodExpense.toStringAsFixed(0);
    _truckStopExpensesController.text = widget.trip.truckStopExpense.toStringAsFixed(0);
    _finesController.text = widget.trip.finesExpense.toStringAsFixed(0);
    _extraController.text = widget.trip.extrasExpense.toStringAsFixed(0);
    _actualFuelUsageController.text = widget.trip.actualFuelUsage.toStringAsFixed(0);
    _notesController.text = widget.trip.notes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        decoration: BoxDecoration(
          color: GTheme.surface(context),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(24),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withBlue(220)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Finalize Trip Details",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Review expenses, notes & fuel consumption",
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Title: Financial Summary
                      _sectionTitle("FINANCIAL SETTLEMENT"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DefaultFormfield(
                              keyboardType: TextInputType.number,
                              controller: _fuelExpensesController,
                              label: "Fuel Expenses (\$)",
                              hint: "0.00",
                              icon: Icons.local_gas_station_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DefaultFormfield(
                              keyboardType: TextInputType.number,
                              controller: _tolgateFeesController,
                              label: "Tollgate Fees (\$)",
                              hint: "0.00",
                              icon: Icons.toll_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DefaultFormfield(
                              keyboardType: TextInputType.number,
                              controller: _foodExpensesController,
                              label: "Food Expenses (\$)",
                              hint: "0.00",
                              icon: Icons.fastfood_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DefaultFormfield(
                              keyboardType: TextInputType.number,
                              controller: _truckStopExpensesController,
                              label: "Truck Stop (\$)",
                              hint: "0.00",
                              icon: Icons.local_parking_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DefaultFormfield(
                              keyboardType: TextInputType.number,
                              controller: _finesController,
                              label: "Fines (\$)",
                              hint: "0.00",
                              icon: Icons.receipt_long_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DefaultFormfield(
                              keyboardType: TextInputType.number,
                              controller: _extraController,
                              label: "Extras (\$)",
                              hint: "0.00",
                              icon: Icons.add_circle_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 40),

                      // Section Title: Fuel Usage
                      _sectionTitle("FUEL CONSUMPTION ANALYTICS"),
                      const SizedBox(height: 12),
                      DefaultFormfield(
                        keyboardType: TextInputType.number,
                        controller: _actualFuelUsageController,
                        label: "Actual Fuel Used (Liters)",
                        hint: "Enter actual fuel usage",
                        icon: Icons.oil_barrel_rounded,
                      ),
                      const Divider(height: 40),

                      // Section Title: Admin Notes
                      _sectionTitle("TRIP CLOSING NOTES"),
                      const SizedBox(height: 12),
                      DefaultFormfield(
                        keyboardType: TextInputType.multiline,
                        controller: _notesController,
                        label: "Finalizer Notes",
                        hint: "Provide any additional closing notes or remarks...",
                        icon: Icons.note_alt_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Save Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _saveChanges(),
                    child: Obx(
                      () => _controller.processingTrip.value
                          ? WhiteLoader()
                          : const Text(
                              "Save & Finalize Trip",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Colors.grey,
        letterSpacing: 1.5,
      ),
    );
  }

  void _saveChanges() async {
    final fuelExpense = double.tryParse(_fuelExpensesController.text);
    final tolgateExpense = double.tryParse(_tolgateFeesController.text);
    final foodExpense = double.tryParse(_foodExpensesController.text);
    final truckStopExpense = double.tryParse(_truckStopExpensesController.text);
    final finesExpense = double.tryParse(_finesController.text);
    final extrasExpense = double.tryParse(_extraController.text);
    final actualFuelUsage = double.tryParse(_actualFuelUsageController.text);

    if (fuelExpense == null)
      return Toaster.showErrorTop("Fuel expenses", "invalid number");
    if (tolgateExpense == null)
      return Toaster.showErrorTop("Tolgate Fees", "invalid number");
    if (foodExpense == null)
      return Toaster.showErrorTop("Food expenses", "invalid number");
    if (truckStopExpense == null)
      return Toaster.showErrorTop("TruckStop", "invalid number");
    if (finesExpense == null)
      return Toaster.showErrorTop("Fines", "invalid number");
    if (extrasExpense == null)
      return Toaster.showErrorTop("Extras", "invalid number");
    if (actualFuelUsage == null)
      return Toaster.showErrorTop("Actual Fuel Usage", "invalid number");

    final response = await _controller.finalizeTrip(
      widget.trip.id,
      data: {
        'fuelExpense': fuelExpense,
        'foodExpense': foodExpense,
        'tolgateExpense': tolgateExpense,
        'truckStopExpense': truckStopExpense,
        'finesExpense': finesExpense,
        'extrasExpense': extrasExpense,
        'actualFuelUsage': actualFuelUsage,
        'notes': _notesController.text.trim(),
      },
    );
    if (response && mounted) {
      _userController.trip.value!.status = "Finalized";
      _userController.trip.value!.actualFuelUsage = actualFuelUsage;
      _userController.trip.refresh();
      Get.back(result: "Finalized");
    }
    if (response) {
      Toaster.showSuccess2("trip", "Trip has been finalized successfully");
    }
  }
}
