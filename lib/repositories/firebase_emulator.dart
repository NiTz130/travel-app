import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

const int firebaseAuthEmulatorPort = 9099;
const int firestoreEmulatorPort = 8080;
const int firebaseDatabaseEmulatorPort = 9000;

String? _configuredFirebaseEmulatorHost;

String firebaseEmulatorHostFor({
  TargetPlatform? platform,
  bool? isWeb,
  String? overrideHost,
}) {
  if (overrideHost != null && overrideHost.trim().isNotEmpty) {
    return overrideHost.trim();
  }

  final resolvedIsWeb = isWeb ?? kIsWeb;
  if (resolvedIsWeb) {
    return 'localhost';
  }

  final resolvedPlatform = platform ?? defaultTargetPlatform;
  return resolvedPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
}

@visibleForTesting
bool shouldConfigureFirebaseEmulatorsForHost(String emulatorHost) {
  final configuredHost = _configuredFirebaseEmulatorHost;
  if (configuredHost == null) {
    return true;
  }

  if (configuredHost == emulatorHost) {
    return false;
  }

  throw StateError(
    'Firebase emulators are already configured for $configuredHost; '
    'cannot reconfigure for $emulatorHost.',
  );
}

@visibleForTesting
void debugResetFirebaseEmulatorConfiguration() {
  _configuredFirebaseEmulatorHost = null;
}

@visibleForTesting
void debugMarkFirebaseEmulatorsConfiguredForHost(String emulatorHost) {
  _configuredFirebaseEmulatorHost = emulatorHost;
}

Future<void> configureFirebaseEmulators({
  String? host,
  bool force = false,
}) async {
  if (!force && kReleaseMode) {
    return;
  }

  final emulatorHost = firebaseEmulatorHostFor(overrideHost: host);
  if (!shouldConfigureFirebaseEmulatorsForHost(emulatorHost)) {
    return;
  }

  await FirebaseAuth.instance.useAuthEmulator(
    emulatorHost,
    firebaseAuthEmulatorPort,
  );
  FirebaseFirestore.instance.useFirestoreEmulator(
    emulatorHost,
    firestoreEmulatorPort,
  );
  FirebaseDatabase.instance.useDatabaseEmulator(
    emulatorHost,
    firebaseDatabaseEmulatorPort,
  );
  _configuredFirebaseEmulatorHost = emulatorHost;
}
