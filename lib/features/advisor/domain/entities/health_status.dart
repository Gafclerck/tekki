/// Statut d'évaluation de santé financière du Conseiller Tekki.
/// Système de feux tricolores systématiquement doublés d'un symbole de forme
/// pour garantir l'accessibilité visuelle sans dépendre de la couleur seule.
enum HealthStatus {
  /// Vert : Gestion conforme et saine.
  conforme(label: 'Conforme', symbol: '✓'),

  /// Orange : Point de vigilance nécessitant de l'attention.
  attention(label: 'Attention', symbol: '⏳'),

  /// Rouge : Dérive critique nécessitant une action immédiate.
  urgent(label: 'Urgent', symbol: '!');

  const HealthStatus({required this.label, required this.symbol});

  final String label;
  final String symbol;

  bool get isConforme => this == HealthStatus.conforme;
  bool get isAttention => this == HealthStatus.attention;
  bool get isUrgent => this == HealthStatus.urgent;
}
