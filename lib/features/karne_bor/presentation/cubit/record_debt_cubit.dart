import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/get_debtors_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/record_debt_state.dart';

class RecordDebtCubit extends Cubit<RecordDebtState> {
  RecordDebtCubit({
    required this.recordDebtUseCase,
    required this.getDebtorsUseCase,
  }) : super(const RecordDebtInitial());

  final RecordDebtUseCase recordDebtUseCase;
  final GetDebtorsUseCase getDebtorsUseCase;

  Future<void> loadDebtors() async {
    final result = await getDebtorsUseCase();
    if (result is Success<List<DebtorEntity>, Failure>) {
      emit(RecordDebtInitial(knownDebtors: result.data));
    }
  }

  Future<void> submit({
    required String debtorName,
    String? debtorPhone,
    required int amount,
    DateTime? dueDate,
    String? existingDebtorId,
  }) async {
    emit(const RecordDebtSubmitting());

    final params = RecordDebtParams(
      debtorName: debtorName,
      debtorPhone: debtorPhone,
      amount: amount,
      dueDate: dueDate,
      existingDebtorId: existingDebtorId,
    );

    final result = await recordDebtUseCase(params);

    result.fold(
      onSuccess: (debt) => emit(RecordDebtSuccess(debt: debt)),
      onError: (failure) => emit(RecordDebtFailure(message: failure.message)),
    );
  }
}
