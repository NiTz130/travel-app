import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/repositories/firebase_emulator.dart';

void main() {
  test('uses Android emulator loopback host for Android', () {
    expect(
      firebaseEmulatorHostFor(platform: TargetPlatform.android, isWeb: false),
      '10.0.2.2',
    );
  });

  test('uses localhost for non-Android desktop targets', () {
    expect(
      firebaseEmulatorHostFor(platform: TargetPlatform.windows, isWeb: false),
      'localhost',
    );
  });

  test('override host wins over platform defaults', () {
    expect(
      firebaseEmulatorHostFor(
        platform: TargetPlatform.android,
        isWeb: false,
        overrideHost: '192.168.1.50',
      ),
      '192.168.1.50',
    );
  });
}
