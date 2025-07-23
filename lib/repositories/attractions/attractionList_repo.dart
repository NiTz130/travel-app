import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/review.dart';
import '../../models/place.dart';

// Repository quản lý danh sách điểm tham quan (attractions)
class attractionListRepo {

  const attractionListRepo();

  // Lấy chi tiết 1 địa điểm tham quan qua placeId
  Future<Place> getAttractionDetailes(placeId) async {
    final query = await FirebaseFirestore.instance
        .collection('attractions')
        .where('placeId', isEqualTo: placeId)
        .get();

    Place data = Place.fromMap(query.docs[0].data());
    return data;
  }

  // Tìm kiếm các điểm tham quan theo input (title)
  Future<List<Place>> searchAttractions(input) async {
    final query = await FirebaseFirestore.instance.collection("attractions")
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
    final query = await FirebaseFirestore.instance
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
    var result;
    final List<Review> reviewsList = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('attractions')
          .where('placeId', isEqualTo: placeId)
          .get();
      for (var ele in querySnapshot.docs) {
        result = await ele.reference.collection('reviews').get();
      }

      for (var i = 0; i < result.docs.length; i++) {
        var review = Review.fromMap(result.docs[i].data());
        reviewsList.add(review);
      }
    } catch (e) {
      print("Lỗi lấy review: $e");
    }

    return reviewsList;
  }

  // Thêm review cho địa điểm
  Future<void> addReview(placeId, reviews, userId) async {
    List<String> userIds = [];
    try {
      QuerySnapshot attractionsQuery = await FirebaseFirestore.instance.collection('attractions')
          .where('placeId', isEqualTo: placeId).get();

      for (var ele in attractionsQuery.docs) {
        var value = await FirebaseFirestore.instance.collection('attractions').doc(ele.id).get();
        List<dynamic>? ids = value.data()?['userIds'];
        if (ids != null) {
          userIds.addAll(ids.cast<String>());
        }
        if (!userIds.contains(userId)) {
          userIds.add(userId);
        }
      }

      for (var ele in attractionsQuery.docs) {
        FirebaseFirestore.instance
            .collection('attractions')
            .doc(ele.id)
            .update({'reviews': reviews});
      }

      for (var ele in attractionsQuery.docs) {
        await FirebaseFirestore.instance.collection('attractions').doc(ele.id).update({
          'userIds': userIds,
        });
      }
    } catch (e) {
      print("Lỗi thêm review: $e");
    }
  }

  // Xóa review
  Future<void> deleteReview(reviews, placeId, userId) async {
    bool isUserFound = false;
    List userIds = [];
    try {
      QuerySnapshot attractionsQuery = await FirebaseFirestore.instance.collection('attractions')
          .where('placeId', isEqualTo: placeId).get();

      for (var ele in attractionsQuery.docs) {
        FirebaseFirestore.instance
            .collection('attractions')
            .doc(ele.id)
            .update({'reviews': reviews});
      }

      QuerySnapshot attractionsQuery2 = await FirebaseFirestore.instance.collection('attractions')
          .where('placeId', isEqualTo: placeId).get();

      for (var ele in attractionsQuery2.docs) {
        reviews = ele.get("reviews");
      }

      for (var i = 0; i < reviews.length; i++) {
        if (reviews[i]["userId"] == userId) {
          isUserFound = true;
          print("Tìm thấy userId trong reviews");
          break;
        } else {
          isUserFound = false;
        }
      }

      // Nếu không tìm thấy userId nữa thì loại khỏi userIds
      if (isUserFound == false) {
        for (var ele in attractionsQuery.docs) {
          var value = await FirebaseFirestore.instance.collection('attractions').doc(ele.id).get();
          List<dynamic>? ids = value.data()?['userIds'];
          if (ids != null) {
            userIds.addAll(ids);
          }
          userIds.removeWhere((element) => element == userId);
        }
        for (var ele in attractionsQuery.docs) {
          await FirebaseFirestore.instance.collection('attractions').doc(ele.id).update({
            'userIds': userIds,
          });
        }
      }
    } catch (e) {
      print("Lỗi xóa review: $e");
    }
  }
}

// Biến singleton để gọi repository này ở các nơi khác
final attractionListRep = attractionListRepo();
