import 'package:genesis/models/deducton_item.dart';
import 'package:genesis/models/trip_model.dart';
import 'package:genesis/models/user_model.dart';

class NumberUtils {
  static String formatCurrency(num amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}k';
    } else {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }

  static String formatNumber(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    } else {
      return '${amount.toStringAsFixed(2)}';
    }
  }

  static double calculatePriceFold(
    User emp,
    List<DeductionItem> taxes,
    List<DeductionItem> insurances,
  ) {
    final insuranceFold = splitDeductions(insurances);
    final taxFold = splitDeductions(taxes);
    return (emp.payment *
            (1 -
                insuranceFold.totalPercent / 100 -
                taxFold.totalPercent / 100)) -
        insuranceFold.totalValue -
        taxFold.totalValue;
  }

  static String calculatePriceFoldString(
    User emp, {
    List<DeductionItem> taxes = const [],
    List<DeductionItem> insurances = const [],
  }) {
    return formatCurrency(calculatePriceFold(emp, taxes, insurances));
  }

  static ({double totalPercent, double totalValue}) splitDeductions(
    List<DeductionItem> deductions,
  ) {
    double totalTaxPercentage = deductions.fold(
      0.0,
      (prev, DeductionItem tax) => tax.deductionType == DeductionType.percentage
          ? prev + tax.value
          : 0.0 + prev,
    );
    double totalTaxValue = deductions.fold(
      0.0,
      (prev, DeductionItem tax) => tax.deductionType == DeductionType.fixed
          ? prev + tax.value
          : 0.0 + prev,
    );
    return (totalPercent: totalTaxPercentage, totalValue: totalTaxValue);
  }

  static num getTripExpenseTotal(TripModel trip) {
    return trip.extrasExpense +
        trip.finesExpense +
        trip.foodExpense +
        trip.fuelExpense +
        trip.truckShopExpense +
        trip.tolgateExpense;
  }
}
