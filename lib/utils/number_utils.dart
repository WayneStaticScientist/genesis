import 'package:genesis/models/deducton_item.dart';
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
    double totalTaxPercentage = insurances.fold(
      0.0,
      (prev, DeductionItem tax) => tax.deductionType == DeductionType.percentage
          ? prev + tax.value
          : 0.0 + prev,
    );
    double totalTaxValue = insurances.fold(
      0.0,
      (prev, DeductionItem tax) => tax.deductionType == DeductionType.fixed
          ? prev + tax.value
          : 0.0 + prev,
    );
    return (emp.payment - emp.payment * (totalTaxPercentage / 100)) -
        totalTaxValue;
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
}
