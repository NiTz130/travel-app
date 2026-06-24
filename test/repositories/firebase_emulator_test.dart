import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/repositories/firebase_emulator.dart';
import 'package:travel_app/repositories/firebase_options.dart';

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

  test('override host is trimmed', () {
    expect(
      firebaseEmulatorHostFor(
        platform: TargetPlatform.android,
        isWeb: false,
        overrideHost: '  192.168.1.50  ',
      ),
      '192.168.1.50',
    );
  });

  test('blank override falls back to platform default', () {
    expect(
      firebaseEmulatorHostFor(
        platform: TargetPlatform.android,
        isWeb: false,
        overrideHost: '   ',
      ),
      '10.0.2.2',
    );
  });

  test('uses localhost for web targets', () {
    expect(
      firebaseEmulatorHostFor(platform: TargetPlatform.android, isWeb: true),
      'localhost',
    );
  });

  group('emulator configuration idempotency', () {
    tearDown(debugResetFirebaseEmulatorConfiguration);

    test('allows first configuration attempt', () {
      expect(shouldConfigureFirebaseEmulatorsForHost('localhost'), isTrue);
    });

    test('skips repeated configuration for the same host', () {
      expect(shouldConfigureFirebaseEmulatorsForHost('localhost'), isTrue);
      debugMarkFirebaseEmulatorsConfiguredForHost('localhost');

      expect(shouldConfigureFirebaseEmulatorsForHost('localhost'), isFalse);
    });

    test('rejects repeated configuration for a different host', () {
      debugMarkFirebaseEmulatorsConfiguredForHost('localhost');

      expect(
        () => shouldConfigureFirebaseEmulatorsForHost('10.0.2.2'),
        throwsStateError,
      );
    });
  });

  group('dev Firebase options guard', () {
    test('allows dev Firebase options outside release mode', () {
      expect(
        () => ensureDevFirebaseOptionsAllowed(releaseMode: false),
        returnsNormally,
      );
    });

    test('blocks dev Firebase options in release mode', () {
      expect(
        () => ensureDevFirebaseOptionsAllowed(releaseMode: true),
        throwsStateError,
      );
    });
  });
}
