import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/features/financial_passport/domain/usecases/calculate_financial_passport_use_case.dart';
import 'package:tekki/features/financial_passport/domain/usecases/generate_signed_passport_use_case.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_event.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_state.dart';

class PassportBloc extends Bloc<PassportEvent, PassportState> {
  PassportBloc({
    required this.calculateFinancialPassportUseCase,
    required this.generateSignedPassportUseCase,
  }) : super(const PassportInitial()) {
    on<LoadPassportEvent>(_onLoadPassport);
    on<RefreshPinTickEvent>(_onRefreshPinTick);
  }

  final CalculateFinancialPassportUseCase calculateFinancialPassportUseCase;
  final GenerateSignedPassportUseCase generateSignedPassportUseCase;

  Future<void> _onLoadPassport(
    LoadPassportEvent event,
    Emitter<PassportState> emit,
  ) async {
    emit(const PassportLoading());

    final now = (event.asOf ?? DateTime.now()).toUtc();
    final passportResult = await calculateFinancialPassportUseCase(asOf: now);

    await passportResult.fold(
      onError: (failure) async {
        emit(PassportError(message: failure.message));
      },
      onSuccess: (passport) async {
        if (!passport.isEligible || passport.totalClosures < 7) {
          final closuresNeeded = max(0, 7 - passport.totalClosures);
          emit(
            PassportEncouragementLoaded(
              passport: passport,
              closuresNeeded: closuresNeeded,
            ),
          );
          return;
        }

        final signResult = await generateSignedPassportUseCase(
          passport: passport,
          shopId: event.shopId,
          pinTimestamp: now,
        );

        signResult.fold(
          onError: (failure) {
            emit(PassportError(message: failure.message));
          },
          onSuccess: (signedPayload) {
            final secondsRemaining = 60 - now.second;
            emit(
              PassportActiveLoaded(
                passport: passport,
                signedPayload: signedPayload,
                secondsRemainingInMinute: secondsRemaining,
                lastUpdated: now,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onRefreshPinTick(
    RefreshPinTickEvent event,
    Emitter<PassportState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PassportActiveLoaded) return;

    final now = (event.now ?? DateTime.now()).toUtc();
    final currentMinute = (now.millisecondsSinceEpoch ~/ 60000);
    final previousMinute =
        (currentState.lastUpdated.millisecondsSinceEpoch ~/ 60000);

    if (currentMinute != previousMinute) {
      final signResult = await generateSignedPassportUseCase(
        passport: currentState.passport,
        shopId: event.shopId,
        pinTimestamp: now,
      );

      signResult.fold(
        onError: (_) {
          // Graceful degradation: en cas d'erreur de régénération, ne pas crasher
        },
        onSuccess: (newPayload) {
          final secondsRemaining = 60 - now.second;
          emit(
            currentState.copyWith(
              signedPayload: newPayload,
              secondsRemainingInMinute: secondsRemaining,
              lastUpdated: now,
            ),
          );
        },
      );
    } else {
      final secondsRemaining = 60 - now.second;
      emit(currentState.copyWith(secondsRemainingInMinute: secondsRemaining));
    }
  }
}
