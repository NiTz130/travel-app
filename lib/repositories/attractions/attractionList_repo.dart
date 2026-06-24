import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/review.dart';
import '../../models/place.dart';

// Repository quản lý danh sách điểm tham quan (attractions)
class attractionListRepo {
  attractionListRepo({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // Lấy chi tiết 1 địa điểm tham quan qua placeId
  Future<Place> getAttractionDetailes(placeId) async {
    final query = await _firestore
        .collection('attractions')
        .where('placeId', isEqualTo: placeId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw StateError('Attraction not found: $placeId');
    }

    Place data = Place.fromMap(query.docs.first.data());
    return data;
  }

  // Tìm kiếm các điểm tham quan theo input (title)
  Future<List<Place>> searchAttractions(input) async {
    final query = await _firestore
        .collection("attractions")
        .orderBy('title')
        .startAt([input])
        .limit(5)
        .get();

    final List<Place> list = [];
    for (var i = 0; i < query.docs.length; i++) {
      var attraction = Place.fromMap(query.docs[i].data());
      list.add(attraction);
    }
    return list;
  }

  // Lấy danh sách điểm tham quan trong 1 thành phố
  Future<List<Place>> getAttractionPlaces(placeName) async {
    print("→ [Repo] Lấy địa điểm tham quan cho thành phố: $placeName");
    final query = await _firestore
        .collection('attractions')
        .where('city', isEqualTo: placeName)
        .get();

    final List<Place> list = [];
    for (var i = 0; i < query.docs.length; i++) {
      var attraction = Place.fromMap(query.docs[i].data());
      list.add(attraction);
    }
    return list;
  }

  // Lấy danh sách review cho 1 địa điểm tham quan
  Future<List<Review>> getReviews(placeId) async {
    final List<Review> reviewsList = [];
    try {
      final querySnapshot = await _firestore
          .collection('attractions')
          .where('placeId', isEqualTo: placeId)
          .get();
      for (var ele in querySnapshot.docs) {
        final result = await ele.reference.collection('reviews').get();
        for (var reviewDoc in result.docs) {
          var review = Review.fromMap(reviewDoc.data());
          reviewsList.add(review);
        }
      }
    } catch (e) {
      print("Lỗi lấy review: $e");
    }

    return reviewsList;
  }

  // Thêm review cho địa điểm
  Future<void> addReview({
    required String placeId,
    required List reviews,
    required String userId,
  }) async {
    try {
      QuerySnapshot attractionsQuery = await _firestore
          .collection('attractions')
          .where('placeId', isEqualTo: placeId)
          .get();

      for (var ele in attractionsQuery.docs) {
        final data = ele.data() as Map<String, dynamic>;
        final userIds = List.from(data['userIds'] as List? ?? []);
        if (!userIds.contains(userId)) {
          userIds.add(userId);
        }

        await ele.reference.update({'reviews': reviews, 'userIds': userIds});
      }
    } catch (e) {
      print("Lỗi thêm review: $e");
    }
  }

  // Xóa review
  Future<void> deleteReview({
    required String placeId,
    required List reviews,
    required String userId,
  }) async {
    final hasRemainingReview = reviews.any((review) {
      return _reviewUserId(review) == userId;
    });

    try {
      QuerySnapshot attractionsQuery = await _firestore
          .collection('attractions')
          .where('placeId', isEqualTo: placeId)
          .get();

      for (var ele in attractionsQuery.docs) {
        final data = ele.data() as Map<String, dynamic>;
        final userIds = List.from(data['userIds'] as List? ?? []);
        if (!hasRemainingReview) {
          userIds.removeWhere((element) => element == userId);
        }

        await ele.reference.update({'reviews': reviews, 'userIds': userIds});
      }
    } catch (e) {
      print("Lỗi xóa review: $e");
    }
  }

  String? _reviewUserId(dynamic review) {
    if (review is Review) {
      return review.userId;
    }
    if (review is Map) {
      final userId = review['userId'];
      return userId is String ? userId : userId?.toString();
    }
    return null;
  }
}

// Biến singleton để gọi repository này ở các nơi khác
final attractionListRep = attractionListRepo();
