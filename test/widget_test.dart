import 'package:flutter_test/flutter_test.dart';
import 'package:first_step/main.dart';

void main() {
  testWidgets('Pokedex app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PokedexApp());

    // Verify that the app title is present.
    expect(find.text('Pokédex'), findsOneWidget);
  });
}
