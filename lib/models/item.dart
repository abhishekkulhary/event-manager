enum ItemType { expense, income }

enum PaymentStatus { paid, notPaid }

class Item {
  final num? id;
  final String description;
  final ItemType type;
  final num amount;
  final DateTime date;
  final PaymentStatus status;

  Item({
    this.id,
    required this.description,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status.name,
    };
  }

  Item copyWith({
    num? id,
    String? description,
    ItemType? type,
    num? amount,
    DateTime? date,
    PaymentStatus? status,
  }) {
    return Item(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
