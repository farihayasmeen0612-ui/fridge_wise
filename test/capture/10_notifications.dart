import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/features/notifications/presentation/screens/notifications_screen.dart';
import 'capture_helper.dart';

void main() {
  testWidgets('10_notifications', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    final key = GlobalKey();
    await tester.pumpWidget(wrapScreen(const NotificationsScreen(), key));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await captureAndExit(key, '10_notifications_screen.png');
  });
}

