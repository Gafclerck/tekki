import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:uuid/uuid.dart';

class RecordDebtParams {
  const RecordDebtParams({
    required this.debtorName,
    this.debtorPhone,
    required this.amount,
    this.dueDate,
    this.existingDebtorId,
  });

  final String debtorName;
  final String? debtorPhone;
  final int amount;
  final DateTime? dueDate;
  final String? existingDebtorId;
}

class RecordDebtUseCase {
  const RecordDebtUseCase({
    required this.repository,
    this.uuid = const Uuid(),
  });

  final DebtRepository repository;
  final Uuid uuid;

  Future<Result<DebtEntity, Failure>> call(RecordDebtParams params) async {
    if (params.amount <= 0) {
      return const Error(
        ValidationFailure(
          message: 'Le montant de la dette doit être strictement supérieur à zéro.',
        ),
      );
    }

    if (params.amount > 999999999) {
      return const Error(
        ValidationFailure(
          message: 'Le montant dépasse le plafond autorisé (999 999 999 FCFA).',
        ),
      );
    }

    DebtorEntity debtor;
    bool isNewDebtor = false;

    if (params.existingDebtorId != null &&
        params.existingDebtorId!.trim().isNotEmpty) {
      final debtorResult =
          await repository.getDebtorById(params.existingDebtorId!.trim());
      if (debtorResult is Error<DebtorEntity?, Failure>) {
        return Error(debtorResult.failure);
      }
      final existing = (debtorResult as Success<DebtorEntity?, Failure>).data;
      if (existing == null) {
        return const Error(
          ValidationFailure(message: 'Client débiteur introuvable.'),
        );
      }
      debtor = existing;
    } else {
      final trimmedName = params.debtorName.trim();
      if (trimmedName.isEmpty) {
        return const Error(
          ValidationFailure(message: 'Veuillez renseigner le nom du client.'),
        );
      }

      final existingResult = await repository.findDebtorByName(trimmedName);
      if (existingResult is Success<DebtorEntity?, Failure> &&
          existingResult.data != null) {
        debtor = existingResult.data!;
      } else {
        final phone = params.debtorPhone?.trim();
        debtor = DebtorEntity(
          id: uuid.v4(),
          name: trimmedName,
          phoneNumber: (phone == null || phone.isEmpty) ? null : phone,
          syncStatus: 'pending',
          createdAt: DateTime.now().toUtc(),
        );
        isNewDebtor = true;
      }
    }

    final now = DateTime.now().toUtc();
    final effectiveDueDate = params.dueDate?.toUtc() ?? now.add(const Duration(days: 7));

    final debt = DebtEntity(
      id: uuid.v4(),
      debtorId: debtor.id,
      initialAmount: params.amount,
      remainingAmount: params.amount,
      dueDate: effectiveDueDate,
      status: DebtStatus.active,
      syncStatus: 'pending',
      createdAt: now,
      debtor: debtor,
    );

    return repository.recordDebtWithDebtor(
      debtor: debtor,
      debt: debt,
      isNewDebtor: isNewDebtor,
    );
  }
}
