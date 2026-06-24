import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/models/trip.dart';
import 'package:travel_app/repositories/trips/trip_repo.dart';

Trip sampleTrip() {
  return Trip(
    tripId: 'trip-1',
    tripName: 'Da Nang',
    tripBudget: '1000',
    tripLocation: 'Da Nang',
    tripDescription: 'Beach trip',
    tripCoverPhoto: 'cover.jpg',
    tripDuration: '2 days',
    durationCount: 2,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 1, 3),
    places: <String, dynamic>{},
  );
}

void main() {
  test('createTrip writes under the signed-in user at call time', () async {
    final firestore = FakeFirebaseFirestore();
    final firebaseAuth = MockFirebaseAuth(signedIn: false);
    final repo = TripRepo(firestore: firestore, firebaseAuth: firebaseAuth);

    firebaseAuth.mockUser = MockUser(
      uid: 'user-at-call-time',
      email: 'user@example.com',
    );
    await firebaseAuth.signInWithCredential(null);

    final isError = await repo.createTrip(sampleTrip());

    expect(isError, isFalse);
    final trips = await firestore
        .collection('users')
        .doc('user-at-call-time')
        .collection('trips')
        .get();
    expect(trips.docs, hasLength(1));
    expect(trips.docs.single.data()['tripId'], 'trip-1');
  });

  test('createTrip returns true when no user is signed in', () async {
    final repo = TripRepo(
      firestore: FakeFirebaseFirestore(),
      firebaseAuth: MockFirebaseAuth(signedIn: false),
    );

    final isError = await repo.createTrip(sampleTrip());

    expect(isError, isTrue);
  });
}
