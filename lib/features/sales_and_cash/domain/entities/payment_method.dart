enum PaymentMethod {
  especes,
  mobileMoney,
  creditClient;

  String toValue() {
    return switch (this) {
      PaymentMethod.especes => 'ESPECES',
      PaymentMethod.mobileMoney => 'MOBILE_MONEY',
      PaymentMethod.creditClient => 'CREDIT_CLIENT',
    };
  }

  static PaymentMethod fromValue(String value) {
    final normalized = value.trim().toUpperCase().replaceAll('-', '_');
    return switch (normalized) {
      'ESPECES' => PaymentMethod.especes,
      'MOBILE_MONEY' || 'MOBILEMONEY' => PaymentMethod.mobileMoney,
      'CREDIT_CLIENT' || 'CREDITCLIENT' => PaymentMethod.creditClient,
      _ => throw ArgumentError('Mode de paiement inconnu ou invalide : $value'),
    };
  }

  static PaymentMethod? tryFromValue(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase().replaceAll('-', '_');
    return switch (normalized) {
      'ESPECES' => PaymentMethod.especes,
      'MOBILE_MONEY' || 'MOBILEMONEY' => PaymentMethod.mobileMoney,
      'CREDIT_CLIENT' || 'CREDITCLIENT' => PaymentMethod.creditClient,
      _ => null,
    };
  }

  String get displayName {
    return switch (this) {
      PaymentMethod.especes => 'Espèces',
      PaymentMethod.mobileMoney => 'Mobile Money',
      PaymentMethod.creditClient => 'Crédit client',
    };
  }
}
