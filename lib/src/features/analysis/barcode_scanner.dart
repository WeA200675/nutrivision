/// Platform adapters provide camera access; the domain layer only sees a value.
abstract interface class BarcodeScanner {
  Future<String?> scan();
}

class BarcodeValidation {
  const BarcodeValidation._();

  static bool isSupported(String value) =>
      RegExp(r'^\\d{8,14}$').hasMatch(value.trim());
}
