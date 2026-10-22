/// Urgency status tier based on shelf-life remaining.
enum ExpiryStatus {
  fresh(label: 'Fresh'),
  expiringSoon(label: 'Expiring Soon'),
  expired(label: 'Expired');

  const ExpiryStatus({required this.label});

  final String label;
}

/// Lifecycle status of an inventory item.
enum ItemStatus {
  active,
  consumed,
  discarded;

  static ItemStatus fromString(String? value) {
    if (value == null) return ItemStatus.active;
    return ItemStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ItemStatus.active,
    );
  }
}
