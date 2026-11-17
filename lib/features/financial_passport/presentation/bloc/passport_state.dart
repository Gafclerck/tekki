import 'package:equatable/equatable.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financial_passport/domain/entities/signed_passport_payload_entity.dart';

abstract class PassportState extends Equatable {
  const PassportState();

  @override
  List<Object?> get props => [];
}

/// État initial avant le premier chargement.
class PassportInitial extends PassportState {
  const PassportInitial();
}

/// État de chargement pendant le calcul ou la signature cryptographique.
class PassportLoading extends PassportState {
  const PassportLoading();
}

/// État d'encouragement lorsque la boutique compte moins de 7 clôtures (< 7).
/// Affiche la progression et le nombre de clôtures restantes sans générer de QR code officiel.
class PassportEncouragementLoaded extends PassportState {
  const PassportEncouragementLoaded({
    required this.passport,
    required this.closuresNeeded,
  });

  final FinancialPassportEntity passport;
  final int closuresNeeded;

  @override
  List<Object?> get props => [passport, closuresNeeded];
}

/// État actif lorsque le passeport est éligible (>= 7 clôtures).
/// Contient le score complet, la payload Base45 signée Ed25519,
/// le code PIN 4 chiffres dynamique et le décompte vers la prochaine minute.
class PassportActiveLoaded extends PassportState {
  const PassportActiveLoaded({
    required this.passport,
    required this.signedPayload,
    required this.secondsRemainingInMinute,
    required this.lastUpdated,
    this.isSharingPdf = false,
    this.sharePdfError,
    this.pdfSharedSuccessfully = false,
  });

  final FinancialPassportEntity passport;
  final SignedPassportPayloadEntity signedPayload;
  final int secondsRemainingInMinute;
  final DateTime lastUpdated;
  final bool isSharingPdf;
  final String? sharePdfError;
  final bool pdfSharedSuccessfully;

  PassportActiveLoaded copyWith({
    FinancialPassportEntity? passport,
    SignedPassportPayloadEntity? signedPayload,
    int? secondsRemainingInMinute,
    DateTime? lastUpdated,
    bool? isSharingPdf,
    String? sharePdfError,
    bool? pdfSharedSuccessfully,
    bool clearShareError = false,
  }) {
    return PassportActiveLoaded(
      passport: passport ?? this.passport,
      signedPayload: signedPayload ?? this.signedPayload,
      secondsRemainingInMinute:
          secondsRemainingInMinute ?? this.secondsRemainingInMinute,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSharingPdf: isSharingPdf ?? this.isSharingPdf,
      sharePdfError: clearShareError
          ? null
          : (sharePdfError ?? this.sharePdfError),
      pdfSharedSuccessfully:
          pdfSharedSuccessfully ?? this.pdfSharedSuccessfully,
    );
  }

  @override
  List<Object?> get props => [
    passport,
    signedPayload,
    secondsRemainingInMinute,
    lastUpdated,
    isSharingPdf,
    sharePdfError,
    pdfSharedSuccessfully,
  ];
}

/// État d'erreur non-bloquante avec message d'explication.
class PassportError extends PassportState {
  const PassportError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
