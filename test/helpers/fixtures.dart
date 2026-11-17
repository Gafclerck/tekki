import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/shop_entity.dart';

ShopEntity createTestShop({
  String id = 'test-shop-1',
  String name = 'Boutique Test',
  double refLatitude = 14.67100,
  double refLongitude = -17.43800,
  String publicKey = 'pk-test-1234567890',
  DateTime? createdAt,
}) {
  return ShopEntity(
    id: id,
    name: name,
    refLatitude: refLatitude,
    refLongitude: refLongitude,
    publicKey: publicKey,
    createdAt: createdAt ?? DateTime.utc(2026, 1, 1),
  );
}

SaleEntity createTestSale({
  String id = 'test-sale-1',
  int amount = 5000,
  PaymentMethod paymentMethod = PaymentMethod.especes,
  DateTime? recordedAt,
  String? closureId,
  String syncStatus = 'pending',
}) {
  return SaleEntity(
    id: id,
    amount: amount,
    paymentMethod: paymentMethod,
    recordedAt: recordedAt ?? DateTime.utc(2026, 11, 17, 10, 0),
    closureId: closureId,
    syncStatus: syncStatus,
  );
}

DebtorEntity createTestDebtor({
  String id = 'debtor-1',
  String name = 'Moussa Ndiaye',
  String? phoneNumber = '+221771234567',
  DateTime? createdAt,
}) {
  return DebtorEntity(
    id: id,
    name: name,
    phoneNumber: phoneNumber,
    createdAt: createdAt ?? DateTime.utc(2026, 11, 10),
  );
}

DebtEntity createTestDebt({
  String id = 'debt-1',
  String debtorId = 'debtor-1',
  int initialAmount = 20000,
  int remainingAmount = 20000,
  DateTime? dueDate,
  DateTime? createdAt,
  DebtStatus status = DebtStatus.active,
}) {
  return DebtEntity(
    id: id,
    debtorId: debtorId,
    initialAmount: initialAmount,
    remainingAmount: remainingAmount,
    dueDate: dueDate ?? DateTime.utc(2026, 12, 1),
    createdAt: createdAt ?? DateTime.utc(2026, 11, 10),
    status: status,
  );
}

DebtPaymentEntity createTestDebtPayment({
  String id = 'payment-1',
  String debtId = 'debt-1',
  int paymentAmount = 5000,
  String paymentMethod = 'ESPECES',
  DateTime? paidAt,
  String? closureId,
}) {
  return DebtPaymentEntity(
    id: id,
    debtId: debtId,
    paymentAmount: paymentAmount,
    paymentMethod: paymentMethod,
    paidAt: paidAt ?? DateTime.utc(2026, 11, 17, 10, 0),
    closureId: closureId,
  );
}

DailyClosureEntity createTestDailyClosure({
  String id = 'closure-1',
  String shopId = 'test-shop-1',
  String closureDate = '2026-11-17',
  DateTime? cutoffTimestamp,
  int totalSalesAmount = 15000,
  int totalCashDebtInflow = 5000,
  int totalCreditSalesAmount = 0,
  int totalExpensesAmount = 0,
  int cashCounted = 20000,
  double? gpsLatitude,
  double? gpsLongitude,
  double? distanceMeters,
  bool isFlaggedLocation = false,
  String syncStatus = 'pending',
  DateTime? createdAt,
}) {
  return DailyClosureEntity(
    id: id,
    shopId: shopId,
    closureDate: closureDate,
    cutoffTimestamp: cutoffTimestamp ?? DateTime.utc(2026, 11, 17, 21, 0),
    totalSalesAmount: totalSalesAmount,
    totalCashDebtInflow: totalCashDebtInflow,
    totalCreditSalesAmount: totalCreditSalesAmount,
    totalExpensesAmount: totalExpensesAmount,
    cashCounted: cashCounted,
    gpsLatitude: gpsLatitude,
    gpsLongitude: gpsLongitude,
    distanceMeters: distanceMeters,
    isFlaggedLocation: isFlaggedLocation,
    syncStatus: syncStatus,
    createdAt: createdAt ?? DateTime.utc(2026, 11, 17, 21, 0),
  );
}

RecoveryVelocityEntity createTestRecoveryVelocity({
  int rate = 85,
  int totalDueAmount = 100000,
  int totalRecoveredAmount = 85000,
  String healthStatus = 'Très bonne vitesse de recouvrement',
  RecoveryHealthLevel healthLevel = RecoveryHealthLevel.excellent,
  int windowDays = 30,
}) {
  return RecoveryVelocityEntity(
    rate: rate,
    totalDueAmount: totalDueAmount,
    totalRecoveredAmount: totalRecoveredAmount,
    healthStatus: healthStatus,
    healthLevel: healthLevel,
    windowDays: windowDays,
  );
}
