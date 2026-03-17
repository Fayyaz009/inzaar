// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inzaar/main.dart';
import 'package:inzaar/features/library/library_repository.dart';

void main() {
  testWidgets('Inzaar Reader App smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final libraryRepository = LibraryRepository();

    // Build our app and trigger a frame.
    await tester.pumpWidget(InzaarReaderApp(
      prefs: prefs,
      libraryRepository: libraryRepository,
    ));

    // Initial pump
    await tester.pump();

    // Wait for splash screen timer (3 seconds) + some extra buffer
    await tester.pump(const Duration(seconds: 5));

    // Wait for animations to settle
    await tester.pumpAndSettle();

    // Verify that the InzaarReaderApp is present
    expect(find.byType(InzaarReaderApp), findsOneWidget);
  });
}
