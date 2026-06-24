import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

const int firebaseAuthEmulatorPort = 9099;
const int firestoreEmulatorPort = 8080;
const int firebaseDatabaseEmulatorPort = 9000;

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

Future<void> configureFirebaseEmulators({
  String? host,
  bool force = false,
}) async {
  if (!force && kReleaseMode) {
    return;
  }

  final emulatorHost = firebaseEmulatorHostFor(overrideHost: host);
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
}
