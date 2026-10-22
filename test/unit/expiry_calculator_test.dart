import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/features/inventory/domain/models/expiry_status.dart';
import 'package:food_management/features/inventory/domain/utils/expiry_calculator.dart';

void main() {
  group('ExpiryCalculator Tests', () {
    final referenceDate = DateTime(2026, 10, 22, 12, 0);

    test('Expired dates return negative days and ExpiryStatus.expired', () {
      final twoDaysAgo = DateTime(2026, 10, 20, 18, 0);
      final oneDayAgo = DateTime(2026, 10, 21, 9, 0);

      expect(ExpiryCalculator.calculateDaysRemaining(twoDaysAgo, referenceDate), -2);
      expect(ExpiryCalculator.calculateStatus(twoDaysAgo, referenceDate), ExpiryStatus.expired);
      expect(ExpiryCalculator.formatCountdown(twoDaysAgo, referenceDate), 'Expired 2 days ago');

      expect(ExpiryCalculator.calculateDaysRemaining(oneDayAgo, referenceDate), -1);
      expect(ExpiryCalculator.calculateStatus(oneDayAgo, referenceDate), ExpiryStatus.expired);
      expect(ExpiryCalculator.formatCountdown(oneDayAgo, referenceDate), 'Expired 1 day ago');
    });

    test('Today returns 0 days and ExpiryStatus.expiringSoon', () {
      final todayEvening = DateTime(2026, 10, 22, 23, 59);

      expect(ExpiryCalculator.calculateDaysRemaining(todayEvening, referenceDate), 0);
      expect(ExpiryCalculator.calculateStatus(todayEvening, referenceDate), ExpiryStatus.expiringSoon);
      expect(ExpiryCalculator.formatCountdown(todayEvening, referenceDate), 'Expires today');
    });

    test('Tomorrow returns 1 day and ExpiryStatus.expiringSoon', () {
      final tomorrow = DateTime(2026, 10, 23, 8, 0);

      expect(ExpiryCalculator.calculateDaysRemaining(tomorrow, referenceDate), 1);
      expect(ExpiryCalculator.calculateStatus(tomorrow, referenceDate), ExpiryStatus.expiringSoon);
      expect(ExpiryCalculator.formatCountdown(tomorrow, referenceDate), 'Expires tomorrow');
    });

    test('2 to 3 days return ExpiryStatus.expiringSoon', () {
      final twoDays = DateTime(2026, 10, 24, 15, 0);
      final threeDays = DateTime(2026, 10, 25, 10, 0);

      expect(ExpiryCalculator.calculateDaysRemaining(twoDays, referenceDate), 2);
      expect(ExpiryCalculator.calculateStatus(twoDays, referenceDate), ExpiryStatus.expiringSoon);
      expect(ExpiryCalculator.formatCountdown(twoDays, referenceDate), '2 days left');

      expect(ExpiryCalculator.calculateDaysRemaining(threeDays, referenceDate), 3);
      expect(ExpiryCalculator.calculateStatus(threeDays, referenceDate), ExpiryStatus.expiringSoon);
      expect(ExpiryCalculator.formatCountdown(threeDays, referenceDate), '3 days left');
    });

    test('More than 3 days return ExpiryStatus.fresh', () {
      final fiveDays = DateTime(2026, 10, 27, 12, 0);
      final tenDays = DateTime(2026, 11, 1, 12, 0);

      expect(ExpiryCalculator.calculateDaysRemaining(fiveDays, referenceDate), 5);
      expect(ExpiryCalculator.calculateStatus(fiveDays, referenceDate), ExpiryStatus.fresh);
      expect(ExpiryCalculator.formatCountdown(fiveDays, referenceDate), '5 days left');

      expect(ExpiryCalculator.calculateDaysRemaining(tenDays, referenceDate), 10);
      expect(ExpiryCalculator.calculateStatus(tenDays, referenceDate), ExpiryStatus.fresh);
      expect(ExpiryCalculator.formatCountdown(tenDays, referenceDate), '10 days left');
    });
  });
}
