import 'package:genesis/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/toast.dart';
import 'package:genesis/models/trip_model.dart';
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
  final _truckShopExpensesController = TextEditingController(text: '0');
  final _finesController = TextEditingController(text: '0');
  final _extraController = TextEditingController(text: '0');
  final _controller = Get.find<TripsController>();
  final _userController = Get.find<UserController>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trip Expenses",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'expenditure',
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
              controller: _fuelExpensesController,
              label: "Fuel Expenses",
              hint: "enter amount",
              icon: Icons.money,
            ),
            DefaultFormfield(
              keyboardType: TextInputType.number,
              controller: _tolgateFeesController,
              label: "Tolgate Fees",
              hint: "enter amount",
              icon: Icons.money,
            ),
            DefaultFormfield(
              keyboardType: TextInputType.number,
              controller: _foodExpensesController,
              label: "Food Expenses",
              hint: "enter amount",
              icon: Icons.food_bank,
            ),
            DefaultFormfield(
              keyboardType: TextInputType.number,
              controller: _truckShopExpensesController,
              label: "Truck Shop",
              hint: "enter amount",
              icon: Icons.car_rental,
            ),
            DefaultFormfield(
              keyboardType: TextInputType.number,
              controller: _finesController,
              label: "Fines",
              hint: "enter amount",
              icon: Icons.edit_road_sharp,
            ),
            DefaultFormfield(
              keyboardType: TextInputType.number,
              controller: _extraController,
              label: "Extras",
              hint: "enter amount",
              icon: Icons.edit_road_sharp,
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
                  () => _controller.processingTrip.value
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

  void _saveChanges() async {
    final fuelExpense = double.tryParse(_fuelExpensesController.text);
    final tolgateExpense = double.tryParse(_tolgateFeesController.text);
    final foodExpense = double.tryParse(_foodExpensesController.text);
    final truckShopExpense = double.tryParse(_truckShopExpensesController.text);
    final finesExpense = double.tryParse(_finesController.text);
    final extrasExpense = double.tryParse(_extraController.text);
    if (fuelExpense == null)
      return Toaster.showErrorTop("Fuel expenses", "invalid number");
    if (tolgateExpense == null)
      return Toaster.showErrorTop("Tolgate Fees", "invalid number");
    if (foodExpense == null)
      return Toaster.showErrorTop("Food expenses", "invalid number");
    if (truckShopExpense == null)
      return Toaster.showErrorTop("TruckShop", "invalid number");
    if (finesExpense == null)
      return Toaster.showErrorTop("Fines", "invalid number");
    if (extrasExpense == null)
      return Toaster.showErrorTop("Extras", "invalid number");

    final response = await _controller.finalizeTrip(
      widget.trip.id,
      data: {
        'fuelExpense': fuelExpense,
        'foodExpense': foodExpense,
        'tolgateExpense': tolgateExpense,
        'truckShopExpense': truckShopExpense,
        'finesExpense': finesExpense,
        'extrasExpense': extrasExpense,
      },
    );
    if (response && mounted) {
      _userController.trip.value!.status = "Finalized";
      _userController.trip.refresh();
      Get.back(result: "Finalized");
    }
    if (response) {
      Toaster.showSuccess2("trip", "Trip has been finalized succefull");
    }
  }
}
