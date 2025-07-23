import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/place.dart';
import '../../models/review.dart';

/// Repository thao tác với collection nhà hàng trên Firestore
class RestaurantsRepo {
  const RestaurantsRepo();

  /// Lấy chi tiết nhà hàng theo [placeId]
  Future<Place> getRestaurantDetails(placeId) async {
    final query = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('placeId', isEqualTo: placeId)
        .get();

    final Place data = Place.fromMap(query.docs[0].data());
    return data;
  }

  /// Tìm kiếm nhà hàng theo input (tên)
  Future<List<Place>> searchRestaurants( input) async {
    final query = await FirebaseFirestore.instance
        .collection("restaurants")
        .orderBy('title')
        .startAt([input])
        .limit(5)
        .get();

    final List<Place> list = [];
    for(var i=0;i<query.docs.length;i++){
      var restaurant = Place.fromMap(query.docs[i].data());
      list.add(restaurant);
    }
    return list;
  }

  Future<List<Place>> getRestaurants(placeName)async{
    print("Repo: Lấy danh sách nhà hàng thành phố: $placeName");

    final query = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('city', isEqualTo: placeName)
        .get();

    final List<Place> list = [];
    for(var i=0;i<query.docs.length;i++){
      var restaurants = Place.fromMap(query.docs[i].data());
      list.add(restaurants);
    }
    return list;
  }

  Future<List<Review>> getReviews( placeId) async {
    final List<Review> reviewsList = [];
    try {
      final querySnapshot = await FirebaseFirestore.instance
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
  Future<void> addReview( placeId,  reviews) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('placeId', isEqualTo: placeId)
          .get();

      for (var ele in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(ele.id)
            .update({'reviews': reviews});
      }
      print("Đã cập nhật danh sách reviews cho nhà hàng $placeId");
    } catch (e) {
      print("Lỗi khi thêm review nhà hàng: $e");
    }
  }

  Future<void> deleteReview( placeId,  reviewId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('placeId', isEqualTo: placeId)
          .get();

      for (var ele in querySnapshot.docs) {
        await ele.reference.collection('reviews').doc(reviewId).delete();
      }
      print("Đã xoá review $reviewId của nhà hàng $placeId");
    } catch (e) {
      print("Lỗi xoá review nhà hàng: $e");
    }
  }
}

final restaurantRepo = RestaurantsRepo();
