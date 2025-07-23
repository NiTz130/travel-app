import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/favorites.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

/// Repository quản lý "Yêu thích"
class FavoritesRepo {
  // Lấy userId hiện tại từ Firebase Auth
  String? getCurrentUserId() {
    return auth.FirebaseAuth.instance.currentUser?.uid;
  }

  /// Kiểm tra các place (danh sách ids) đã được thêm vào favorites chưa
  /// Trả về List<bool>, true nếu đã là yêu thích, false nếu chưa
  Future<List<bool>> checkFavorites(List ids) async {
    List<bool> isaddRestaurantToFavorite  = [];
    for (var e in ids) {
      bool found = false;
      if (e.id != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(getCurrentUserId())
            .collection('favorites')
            .where('placeId', isEqualTo: e.id)
            .get();

        found = querySnapshot.docs.isNotEmpty;
      }
      isaddRestaurantToFavorite .add(found);
    }
    print(isaddRestaurantToFavorite );
    return isaddRestaurantToFavorite ;
  }

  /// Lấy danh sách yêu thích của user, trả về List<Favorite>
  Future<List<Favorite>> getFavorites() async {
    var data = [];
    final List<Favorite> list = [];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(getCurrentUserId())
        .collection('favorites')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        data.add(doc.data());
      });
    });

    for (var element in data) {
      var fav = Favorite.fromMap(element);
      list.add(fav);
    }

    return list;
  }

  /// Thêm 1 địa điểm vào favorites
  /// Trả về true nếu thêm thành công
  Future<bool> addToFavorite(Favorite favorite) async {
    bool isDataAdd = false;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(getCurrentUserId())
        .collection('favorites')
        .add(favorite.toJson())
        .then((value) {
      print('Đã thêm vào yêu thích');
      isDataAdd = true;
    }).catchError((error) {
      print('Thêm vào yêu thích thất bại');
      isDataAdd = false;
    });

    print(isDataAdd);
    return isDataAdd;
  }

  /// Xóa khỏi danh sách yêu thích theo placeId
  /// Trả về true nếu xóa thành công
  Future<bool> removeFavorite(String placeId) async {
    bool isRemove = false;

    // Tìm các document favorites có placeId tương ứng để xóa
    await FirebaseFirestore.instance
        .collection('users')
        .doc(getCurrentUserId())
        .collection('favorites')
        .where('placeId', isEqualTo: placeId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
        print("Đã xóa khỏi yêu thích");
        isRemove = true;
      });
    }).catchError((error) {
      print('Xóa yêu thích thất bại');
      isRemove = false;
    });

    print(isRemove);
    return isRemove;
  }
}

// Singleton để xài lại repo này
final favRepo = FavoritesRepo();
