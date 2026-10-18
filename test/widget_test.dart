import 'package:event_manager/data/sample_guests.dart';
import 'package:event_manager/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home offers guest and money management', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Guests Management'), findsOneWidget);
    expect(find.text('Money Management'), findsOneWidget);
    // Native test runs never show the web-only download entry.
    expect(find.text('Get the app'), findsNothing);
  });

  test('sample guests are well-formed and uniquely numbered', () {
    expect(sampleGuests, isNotEmpty);
    expect(sampleGuests.map((g) => g.id).toSet(), hasLength(sampleGuests.length));
    expect(sampleGuests.every((g) => g.number > 0 && g.name.isNotEmpty), isTrue);
  });
}
