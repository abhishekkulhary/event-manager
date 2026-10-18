import '../models/item.dart';

/// Fictional ledger entries seeded on a fresh install alongside the sample
/// guests, so the money screen and dashboard show how the app works.
final sampleItems = <Item>[
  Item(description: 'Shagun — Mehra family', type: ItemType.income, amount: 5100, date: DateTime(2026, 10, 12), status: PaymentStatus.paid),
  Item(description: 'Gift — Rathore family', type: ItemType.income, amount: 2100, date: DateTime(2026, 10, 12), status: PaymentStatus.paid),
  Item(description: 'Shagun — Yadav family', type: ItemType.income, amount: 3100, date: DateTime(2026, 10, 13), status: PaymentStatus.notPaid),
  Item(description: 'Tent & decoration', type: ItemType.expense, amount: 45000, date: DateTime(2026, 10, 2), status: PaymentStatus.paid),
  Item(description: 'Catering advance', type: ItemType.expense, amount: 60000, date: DateTime(2026, 10, 4), status: PaymentStatus.paid),
  Item(description: 'Catering balance', type: ItemType.expense, amount: 40000, date: DateTime(2026, 10, 14), status: PaymentStatus.notPaid),
  Item(description: 'Invitation cards printing', type: ItemType.expense, amount: 8500, date: DateTime(2026, 9, 25), status: PaymentStatus.paid),
];
