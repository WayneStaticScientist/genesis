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
}
