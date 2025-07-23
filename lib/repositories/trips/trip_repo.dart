import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart' as intl;
import '../../models/trip.dart';

/// Repository thao tác dữ liệu chuyến đi (trip) trên Firestore
class TripRepo {
  final auth.User? user = auth.FirebaseAuth.instance.currentUser;

  /// Tạo mới một chuyến đi
  Future<bool> createTrip(Trip trip) async {
    bool isError = false;
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(user?.uid).collection('trips').add(
          trip.toJson());
    } catch (e) {
      isError = true;
      print('Lỗi khi tạo trip: $e');
    }
    return isError; // isError=true nghĩa là có lỗi!
  }

  /// Cập nhật một chuyến đi đã có (dựa trên tripId)
  Future<bool> updateTrip(Trip trip) async {
    bool isError = false;
    String? tripDocId;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('trips')
          .where('tripId', isEqualTo: trip.tripId)
          .get();

      if (querySnapshot.docs.isEmpty) throw Exception('Không tìm thấy trip!');

      tripDocId = querySnapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('trips')
          .doc(tripDocId)
          .update(trip.toJson());
    } catch (e) {
      isError = true;
      print('Lỗi khi cập nhật trip: $e');
    }

    return isError; // true là lỗi, false là thành công!
  }

  /// Lấy danh sách trip đang diễn ra (chưa kết thúc)
  Future<List<Trip>> onGoingTrips() async {
    final now = DateTime.now();
    final currentDate =
    DateTime.parse(intl.DateFormat("yyyy-MM-dd").format(now));

    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('trips')
        .where('endDate', isGreaterThan: currentDate)
        .get();

    final List<Trip> list = [];
    for (var doc in query.docs) {
      list.add(Trip.fromMap(doc.data()));
    }
    print('onGoingTrips: ${list.length}');
    return list;
  }

  /// Lấy danh sách trip đã kết thúc
  Future<List<Trip>> pastTrips() async {
    final now = DateTime.now();
    final currentDate =
    DateTime.parse(intl.DateFormat("yyyy-MM-dd").format(now));

    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('trips')
        .where('endDate', isLessThan: currentDate)
        .get();

    final List<Trip> list = [];
    for (var doc in query.docs) {
      list.add(Trip.fromMap(doc.data()));
    }
    print('pastTrips: ${list.length}');
    return list;
  }

  /// Lấy chi tiết 1 trip theo tripId
  Future<Trip> getSelectTrip(String tripId) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('trips')
        .where('tripId', isEqualTo: tripId)
        .get();

    if (query.docs.isEmpty) throw Exception('Không tìm thấy trip!');
    return Trip.fromMap(query.docs[0].data());
  }

  /// Đếm tổng số trip của user hiện tại
  Future<int> countTotalTrips() async {
    int count = 0;
    final result = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('trips')
        .count()
        .get();
    count = result.count ?? 0;
    return count;
  }
}

// Singleton dùng chung toàn app
final tripRepo = TripRepo();
