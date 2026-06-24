import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;

import '../../models/trip.dart';

class TripRepo {
  TripRepo({FirebaseFirestore? firestore, auth.FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _firebaseAuth;

  auth.User _currentUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to access trips.');
    }
    return user;
  }

  CollectionReference<Map<String, dynamic>> _tripsCollection() {
    return _firestore
        .collection('users')
        .doc(_currentUser().uid)
        .collection('trips');
  }

  Future<bool> createTrip(Trip trip) async {
    bool isError = false;
    try {
      await _tripsCollection().add(trip.toJson());
    } catch (e) {
      isError = true;
      debugPrint('Error creating trip: $e');
    }
    return isError;
  }

  Future<bool> updateTrip(Trip trip) async {
    bool isError = false;

    try {
      final tripsCollection = _tripsCollection();
      final querySnapshot = await tripsCollection
          .where('tripId', isEqualTo: trip.tripId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw StateError('Trip not found: ${trip.tripId}');
      }

      await tripsCollection
          .doc(querySnapshot.docs.first.id)
          .update(trip.toJson());
    } catch (e) {
      isError = true;
      debugPrint('Error updating trip: $e');
    }

    return isError;
  }

  Future<List<Trip>> onGoingTrips() async {
    final now = DateTime.now();
    final currentDate = DateTime.parse(
      intl.DateFormat('yyyy-MM-dd').format(now),
    );

    final query = await _tripsCollection()
        .where('endDate', isGreaterThan: currentDate)
        .get();

    final List<Trip> list = [];
    for (var doc in query.docs) {
      list.add(Trip.fromMap(doc.data()));
    }
    debugPrint('onGoingTrips: ${list.length}');
    return list;
  }

  Future<List<Trip>> pastTrips() async {
    final now = DateTime.now();
    final currentDate = DateTime.parse(
      intl.DateFormat('yyyy-MM-dd').format(now),
    );

    final query = await _tripsCollection()
        .where('endDate', isLessThan: currentDate)
        .get();

    final List<Trip> list = [];
    for (var doc in query.docs) {
      list.add(Trip.fromMap(doc.data()));
    }
    debugPrint('pastTrips: ${list.length}');
    return list;
  }

  Future<Trip> getSelectTrip(String tripId) async {
    final query = await _tripsCollection()
        .where('tripId', isEqualTo: tripId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw StateError('Trip not found: $tripId');
    }

    return Trip.fromMap(query.docs.first.data());
  }

  Future<int> countTotalTrips() async {
    final result = await _tripsCollection().count().get();
    return result.count ?? 0;
  }
}

final tripRepo = TripRepo();
