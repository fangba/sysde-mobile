import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/core/clock.dart';
import 'package:sysde_mobile/core/theme/app_theme.dart';
import 'package:sysde_mobile/features/home/widgets/home_header.dart';

void main() {
  testWidgets('la date du jour suit l\'horloge, sans pastille de synchro', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clockProvider.overrideWithValue(() => DateTime(2026, 10, 29, 9, 5))],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const Scaffold(body: HomeHeader()),
        ),
      ),
    );

    expect(find.text('Jeudi 29 octobre 2026'), findsOneWidget);
    expect(find.textContaining('synchro'), findsNothing);
    expect(find.text('Hors ligne'), findsNothing);
  });
}
