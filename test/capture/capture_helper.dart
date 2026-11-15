import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_management/core/theme/app_theme.dart';
import 'package:food_management/features/auth/data/auth_provider.dart';
import 'package:food_management/features/inventory/data/inventory_providers.dart';
import 'package:food_management/features/inventory/data/mock_food_repository.dart';
import 'package:food_management/features/scan/data/pending_requests_provider.dart';
import 'package:food_management/features/scan/domain/models/pending_food_request.dart';

class CaptureAuthNotifier extends AuthNotifier {
  @override
  AuthUserState build() {
    return const AuthUserState(
      isAuthenticated: true,
      uid: '1cfe4919-fe51-461a-8058-48976ad1dd1d',
      name: 'Fariha Yasmeen',
      email: 'farihayasmeen0612@gmail.com',
      phone: '+1 (555) 019-2831',
    );
  }
}

class CapturePendingRequestsNotifier extends PendingRequestsNotifier {
  @override
  List<PendingFoodRequest> build() {
    final now = DateTime.now();
    return [
      PendingFoodRequest(
        id: 'req-intake-1',
        filename: 'input_1731650000_a1b2c3.jpg',
        type: PendingRequestType.intake,
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
        timestamp: now.subtract(const Duration(minutes: 5)),
        hasFood: true,
        aiDetectedName: 'Fresh Bread',
        aiCategory: 'Bakery',
        notes: '[gemini-1.5-flash] Confidence: 0.96',
      ),
      PendingFoodRequest(
        id: 'req-takeout-1',
        filename: 'output_1731650100_d4e5f6.jpg',
        type: PendingRequestType.takeout,
        imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
        timestamp: now.subtract(const Duration(minutes: 2)),
        hasFood: true,
        notes: 'Tactile OUT button pressed on fridge',
      ),
    ];
  }
}

Widget wrapScreen(Widget child, GlobalKey key) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => CaptureAuthNotifier()),
      foodRepositoryProvider.overrideWithValue(MockFoodRepository(populateSeedData: true)),
      pendingRequestsProvider.overrideWith(() => CapturePendingRequestsNotifier()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: RepaintBoundary(
        key: key,
        child: child,
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

Future<void> captureAndExit(GlobalKey key, String filename) async {
  final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 2.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  final file = File('/Users/hello/food_management/docs/screenshots/' + filename);
  file.writeAsBytesSync(bytes);
  print('CAPTURED_SUCCESS: $filename (${file.lengthSync()} bytes)');
  exit(0);
}

