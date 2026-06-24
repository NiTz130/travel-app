import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../models/place.dart';

// Repository quản lý dữ liệu thành phố
class cityRepo {
  cityRepo({FirebaseFirestore? firestore, auth.FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _firebaseAuth;

  // Lấy userId hiện tại (nếu có đăng nhập)
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Lấy chi tiết 1 thành phố theo placeId
  Future<Place> getcityDetailes(placeId) async {
    print("→ [Repo] Lấy chi tiết thành phố: $placeId");

    final query = await _firestore
        .collection('cities')
        .where('placeId', isEqualTo: placeId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw StateError('City not found: $placeId');
    }

    final Place data = Place.fromMap(query.docs.first.data());

    return data;
  }

  // Tìm kiếm thành phố theo tên (title)
  Future<List<Place>> searchCities(input) async {
    final query = await _firestore
        .collection("cities")
        .orderBy('title')
        .startAt([input])
        .limit(5)
        .get();

    final List<Place> list = [];
    for (var i = 0; i < query.docs.length; i++) {
      var city = Place.fromMap(query.docs[i].data());
      list.add(city);
    }
    return list;
  }

  // Lưu thành phố vừa tìm kiếm vào lịch sử recentlySearch của user
  Future addUserRecentlySearch(Place place) async {
    await _firestore
        .collection('users')
        .doc(getCurrentUserId())
        .collection('recentlySearch')
        .add(place.toJson());
  }

  // Lấy danh sách thành phố user đã tìm kiếm gần đây
  Future<List<Place>> getUserRecentlySearch() async {
    final query = await _firestore
        .collection('users')
        .doc(getCurrentUserId())
        .collection('recentlySearch')
        .get();

    final List<Place> list = [];
    for (var i = 0; i < query.docs.length; i++) {
      var city = Place.fromMap(query.docs[i].data());
      list.add(city);
    }
    return list;
  }
}

// Singleton cho repo này để dùng ở nhiều nơi
final cityRep = cityRepo();
