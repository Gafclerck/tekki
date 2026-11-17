import 'package:equatable/equatable.dart';

abstract class PassportEvent extends Equatable {
  const PassportEvent();

  @override
  List<Object?> get props => [];
}

/// Événement déclenchant le calcul et le chargement du Passeport Financier.
class LoadPassportEvent extends PassportEvent {
  const LoadPassportEvent({this.asOf, this.shopId = 'default-shop'});

  final DateTime? asOf;
  final String shopId;

  @override
  List<Object?> get props => [asOf, shopId];
}

/// Événement périodique (chaque seconde) mettant à jour le décompte du code PIN
/// et régénérant automatiquement le PIN anti-rejeu lors du changement de minute.
class RefreshPinTickEvent extends PassportEvent {
  const RefreshPinTickEvent({this.now, this.shopId = 'default-shop'});

  final DateTime? now;
  final String shopId;

  @override
  List<Object?> get props => [now, shopId];
}

/// Événement déclenchant la génération et le partage 1-clic WhatsApp de l'attestation PDF.
class SharePassportPdfEvent extends PassportEvent {
  const SharePassportPdfEvent({this.shopName, this.emissionDate});

  final String? shopName;
  final DateTime? emissionDate;

  @override
  List<Object?> get props => [shopName, emissionDate];
}
