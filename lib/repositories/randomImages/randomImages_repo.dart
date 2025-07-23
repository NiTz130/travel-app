import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Repository lấy ảnh ngẫu nhiên từ Pexels (dùng cho bìa chuyến đi)
class RandomImagesRepo {
  /// Lấy 1 ảnh random theo [tripCount] (số thứ tự chuyến đi)
  Future<String> getRandomImage(int tripCount) async {
    String photoUrl = '';
    const apiUrl = 'https://api.pexels.com/v1/search';
    final apiKey = dotenv.env['pexelsApiKey'].toString();
    const url = '$apiUrl?query=Landscape&per_page=20&orientation=landscape&size=medium';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': apiKey,
      },
    );

    if (response.statusCode == 200) {
      print('Lấy ảnh Pexels thành công');

      final data = jsonDecode(response.body);
      final photos = data['photos'];

      // Nếu số lượng ảnh ít hơn tripCount, lấy ảnh đầu tiên cho chắc cú
      if (photos != null && photos is List && photos.isNotEmpty) {
        int index = (tripCount < photos.length) ? tripCount : 0;
        photoUrl = photos[index]['src']['medium'] ??
            'https://www.pexels.com/photo/mountain-covered-snow-under-star-572897/';
      } else {
        photoUrl = 'https://www.pexels.com/photo/mountain-covered-snow-under-star-572897/';
      }
    } else {
      print('Lỗi lấy ảnh Pexels: ${response.statusCode}');
      photoUrl = 'https://www.pexels.com/photo/mountain-covered-snow-under-star-572897/';
    }

    return photoUrl;
  }
}

// Khởi tạo singleton để import ở mọi nơi
final randomImagesRep = RandomImagesRepo();
