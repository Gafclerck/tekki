enum DebtStatus {
  active('ACTIVE', 'En cours'),
  settled('SETTLED', 'Réglée'),
  overdue('OVERDUE', 'En retard');

  const DebtStatus(this.value, this.label);

  final String value;
  final String label;

  static DebtStatus fromValue(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return DebtStatus.active;
      case 'SETTLED':
        return DebtStatus.settled;
      case 'OVERDUE':
        return DebtStatus.overdue;
      default:
        throw ArgumentError('Unknown DebtStatus: $value');
    }
  }

  String toValue() => value;
}
