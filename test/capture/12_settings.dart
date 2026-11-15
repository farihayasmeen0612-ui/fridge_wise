import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/features/settings/presentation/screens/settings_screen.dart';
import 'capture_helper.dart';

void main() {
  testWidgets('12_settings', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    final key = GlobalKey();
    await tester.pumpWidget(wrapScreen(const SettingsScreen(), key));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await captureAndExit(key, '12_settings_screen.png');
  });
}

