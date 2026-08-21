import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/core/theme.dart';
import 'package:paper_plane_flight/src/features/characters/character_select_page.dart';

void main() {
  testWidgets('character roster exposes requested pilots', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: flightTheme(), home: const CharacterSelectPage(mode: CharacterSelectMode.rival)));
    await tester.pumpAndSettle();
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
