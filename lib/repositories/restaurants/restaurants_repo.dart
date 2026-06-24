import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/place.dart';
import '../../models/review.dart';

/// Repository thao tác với collection nhà hàng trên Firestore
class RestaurantsRepo {
  RestaurantsRepo({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Lấy chi tiết nhà hàng theo [placeId]
  Future<Place> getRestaurantDetails(placeId) async {
    final query = await _firestore
        .collection('restaurants')
        .where('placeId', isEqualTo: placeId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw StateError('Restaurant not found: $placeId');
    }

    final Place data = Place.fromMap(query.docs.first.data());
    return data;
  }

  /// Tìm kiếm nhà hàng theo input (tên)
  Future<List<Place>> searchRestaurants(input) async {
    final query = await _firestore
        .collection("restaurants")
        .orderBy('title')
        .startAt([input])
        .limit(5)
        .get();

    final List<Place> list = [];
    for (var i = 0; i < query.docs.length; i++) {
      var restaurant = Place.fromMap(query.docs[i].data());
      list.add(restaurant);
    }
    return list;
  }

  Future<List<Place>> getRestaurants(placeName) async {
    print("Repo: Lấy danh sách nhà hàng thành phố: $placeName");

    final query = await _firestore
        .collection('restaurants')
        .where('city', isEqualTo: placeName)
        .get();

    final List<Place> list = [];
    for (var i = 0; i < query.docs.length; i++) {
      var restaurants = Place.fromMap(query.docs[i].data());
      list.add(restaurants);
    }
    return list;
  }

  Future<List<Review>> getReviews(placeId) async {
    final List<Review> reviewsList = [];
    try {
      final querySnapshot = await _firestore
          .collection('restaurants')
          .where('placeId', isEqualTo: placeId)
          .get();

      // Lấy toàn bộ reviews từ tất cả document trùng placeId
      for (var ele in querySnapshot.docs) {
        final result = await ele.reference.collection('reviews').get();
        for (var reviewDoc in result.docs) {
          reviewsList.add(Review.fromMap(reviewDoc.data()));
        }
      }
    } catch (e) {
      print("Lỗi lấy review nhà hàng: $e");
    }
    return reviewsList;
  }

  /// Thêm 1 danh sách reviews vào nhà hàng (overwrite toàn bộ reviews hiện tại!)
  /// [placeId]: id nhà hàng
  /// [reviews]: danh sách review mới (list dạng map)
  Future<void> addReview({
    required String placeId,
    required List reviews,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('restaurants')
          .where('placeId', isEqualTo: placeId)
          .get();

      final reviewMaps = reviews.map(_reviewData).toList();

      for (var ele in querySnapshot.docs) {
        await ele.reference.update({'reviews': reviewMaps});

        final existingReviews = await ele.reference.collection('reviews').get();
        for (final reviewDoc in existingReviews.docs) {
          await reviewDoc.reference.delete();
        }

        for (final review in reviewMaps) {
          final reviewId = _reviewId(review);
          if (reviewId != null) {
            await ele.reference.collection('reviews').doc(reviewId).set(review);
          }
        }
      }
      print("Đã cập nhật danh sách reviews cho nhà hàng $placeId");
    } catch (e) {
      print("Lỗi khi thêm review nhà hàng: $e");
    }
  }

  Future<void> deleteReview({required String placeId, required List reviews}) {
    return addReview(placeId: placeId, reviews: reviews);
  }

  Map<String, dynamic> _reviewData(dynamic review) {
    if (review is Review) {
      return review.toJson();
    }
    if (review is Map) {
      return Map<String, dynamic>.from(review);
    }
    throw StateError('Unsupported review data: $review');
  }

  String? _reviewId(Map<String, dynamic> review) {
    final reviewId = review['reviewId'];
    return reviewId is String ? reviewId : reviewId?.toString();
  }
}

final restaurantRepo = RestaurantsRepo();
