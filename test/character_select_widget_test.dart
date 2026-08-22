import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/core/theme.dart';
import 'package:paper_plane_flight/src/features/characters/character_select_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('character roster exposes requested pilots', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        theme: flightTheme(),
        home: const CharacterSelectPage(mode: CharacterSelectMode.rival),
      ),
    );

    // Rival mode briefly shows an indeterminate progression loader.
    // pumpAndSettle can time out while that spinner is active.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('YAALON'), findsWidgets);
    expect(find.text('UZZIAH'), findsWidgets);
    expect(find.text('NAILS'), findsWidgets);
    expect(find.text('WILD BRATS'), findsWidgets);
    expect(find.text('GRANNY'), findsWidgets);
    expect(find.text('GEORGE'), findsWidgets);
    expect(find.text('ROSE PANTHER'), findsWidgets);
    expect(find.text('PINK PANTHER'), findsWidgets);
  });
}
