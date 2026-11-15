import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/features/expiry/presentation/screens/expiry_calendar_screen.dart';
import 'capture_helper.dart';

void main() {
  testWidgets('07_calendar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    final key = GlobalKey();
    await tester.pumpWidget(wrapScreen(const ExpiryCalendarScreen(), key));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await captureAndExit(key, '07_calendar_screen.png');
  });
}

