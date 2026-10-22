import '../models/expiry_status.dart';

/// Calculation engine for item shelf-life, expiration urgency, and countdown labels.
class ExpiryCalculator {
  ExpiryCalculator._();

  /// Normalizes a DateTime to midnight (00:00:00.000) for calendar-day accuracy.
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Calculates the difference in whole calendar days between expiryDate and today (or reference date).
  ///
  /// Examples:
  /// - Expiry is today: returns 0
  /// - Expiry was yesterday: returns -1
  /// - Expiry is tomorrow: returns 1
  /// - Expiry is in 5 days: returns 5
  static int calculateDaysRemaining(DateTime expiryDate, [DateTime? referenceDate]) {
    final ref = startOfDay(referenceDate ?? DateTime.now());
    final exp = startOfDay(expiryDate);
    return exp.difference(ref).inDays;
  }

  /// Maps days remaining to an ExpiryStatus tier:
  /// - < 0 days: [ExpiryStatus.expired]
  /// - 0 to 3 days: [ExpiryStatus.expiringSoon]
  /// - > 3 days: [ExpiryStatus.fresh]
  static ExpiryStatus calculateStatus(DateTime expiryDate, [DateTime? referenceDate]) {
    final days = calculateDaysRemaining(expiryDate, referenceDate);
    if (days < 0) {
      return ExpiryStatus.expired;
    } else if (days <= 3) {
      return ExpiryStatus.expiringSoon;
    } else {
      return ExpiryStatus.fresh;
    }
  }

  /// Generates a human-readable countdown string adhering to the UI reference design:
  /// - 'Expired X days ago'
  /// - 'Expires today'
  /// - 'Expires tomorrow'
  /// - 'X days left'
  static String formatCountdown(DateTime expiryDate, [DateTime? referenceDate]) {
    final days = calculateDaysRemaining(expiryDate, referenceDate);
    if (days < 0) {
      final absDays = days.abs();
      return absDays == 1 ? 'Expired 1 day ago' : 'Expired $absDays days ago';
    } else if (days == 0) {
      return 'Expires today';
    } else if (days == 1) {
      return 'Expires tomorrow';
    } else {
      return '$days days left';
    }
  }
}
