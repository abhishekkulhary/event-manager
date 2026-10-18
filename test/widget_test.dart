import 'package:event_manager/data/sample_guests.dart';
import 'package:event_manager/main.dart';
import 'package:event_manager/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app builds with the Event Manager theme', (tester) async {
    await tester.pumpWidget(const MyApp(home: Scaffold(body: GradientText('Event Manager'))));
    expect(find.text('Event Manager'), findsOneWidget);
    final theme = Theme.of(tester.element(find.text('Event Manager')));
    expect(theme.brightness, Brightness.dark);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'SpaceGrotesk');
  });

  test('sample guests are well-formed and uniquely numbered', () {
    expect(sampleGuests, isNotEmpty);
    expect(sampleGuests.map((g) => g.id).toSet(), hasLength(sampleGuests.length));
    expect(sampleGuests.every((g) => g.number > 0 && g.name.isNotEmpty), isTrue);
  });

  test('money and names are formatted for display', () {
    expect(formatMoney(1250000), '₹1,250,000');
    expect(formatMoney(-500), '−₹500');
    expect(formatDate(DateTime(2026, 10, 18)), '18 Oct 2026');
    expect(initials('Arjun Mehra'), 'AM');
    expect(initials('Saroj Bai'), 'SB');
    expect(initials('Cher'), 'C');
  });
}
