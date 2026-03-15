extension StringOptionalUtils on String? {
  /// Returns the string if it's not null and not empty.
  /// Otherwise, returns the provided [defaultValue].
  String empty(String defaultValue) {
    if (this == null || this!.isEmpty) {
      return defaultValue;
    }
    return this!;
  }

  String from(String? firstString, String? secondString) {
    if (firstString == null || secondString == null) {
      return this!;
    }
    return '${firstString} ${secondString}';
  }
}
