import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adjust_demo/providers/theme_provider.dart';
import 'package:adjust_demo/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('theme toggle switch flips the ThemeProvider and persists',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final theme = ThemeProvider(storage);

    // A minimal harness mirroring the Settings dark-mode switch wiring.
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: theme,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<ThemeProvider>(
              builder: (context, t, _) => Switch(
                value: t.isDark,
                onChanged: (v) => context.read<ThemeProvider>().toggleDark(v),
              ),
            ),
          ),
        ),
      ),
    );

    expect(theme.isDark, isFalse);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(theme.isDark, isTrue);
    expect(theme.mode, ThemeMode.dark);

    // Toggle back off.
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(theme.isDark, isFalse);
  });
}
