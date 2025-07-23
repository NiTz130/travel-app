import 'dart:convert';
import 'package:http/http.dart' as http;

/// Lấy danh sách lượt xem gần nhất từ API Apify
class FechLastViews {
  /// Hàm lấy gợi ý (fetch suggestions)
  static fetchSuggestions(var apiUrl, final payload) async {
    const apiKey = 'apify_api_i3o0mIz66q0XQLwEJUyefixu3GnZAA1IqEw2';
    var newApiUrl = '$apiUrl$apiKey';
    dynamic runId;
    dynamic keyValue;

    // Gửi request khởi tạo task
    final response = await http.post(
      Uri.parse(newApiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 201) {
      // Thành công
      print("Yêu cầu thành công, status: ${response.statusCode}");
      final decodedData = json.decode(response.body);
      runId = decodedData["data"]["id"];
      print("ID của tiến trình: $runId");
    } else {
      // Lỗi
      print('Yêu cầu thất bại với mã lỗi: ${response.statusCode}.');
    }

    const delayDuration = Duration(seconds: 2);
    bool duLieuSanSang = false;

    // Chờ dữ liệu xử lý xong
    while (!duLieuSanSang) {
      await Future.delayed(delayDuration);

      final datasetStatusResponse = await http.get(
          Uri.parse('https://api.apify.com/v2/actor-runs/$runId?token=$apiKey')
      );
      if (datasetStatusResponse.statusCode == 200) {
        final datasetStatusData = json.decode(datasetStatusResponse.body);
        final trangThaiDuLieu = datasetStatusData['data']['status'];

        print("Trạng thái dữ liệu: $trangThaiDuLieu");
        if (trangThaiDuLieu == 'SUCCEEDED' || trangThaiDuLieu == 'TIMED-OUT') {
          duLieuSanSang = true;
          keyValue = datasetStatusData['data']['defaultDatasetId'];
          print("ID dataset: $keyValue");
        }
      }
    }

    // Danh sách khách sạn/lượt xem gần đây
    late List<Map<String, dynamic>> danhSachKhachSan = [];

    final datasetItemsResponse = await http.get(
        Uri.parse('https://api.apify.com/v2/datasets/$keyValue/items?token=$apiKey')
    );
    if (datasetItemsResponse.statusCode == 200) {
      print("Lấy dữ liệu thành công, status: ${datasetItemsResponse.statusCode}");
      final datasetItemsData = json.decode(datasetItemsResponse.body);
      final ketQua = datasetItemsData as List<dynamic>;
      if (ketQua[0]['city'] != null) {
        danhSachKhachSan = ketQua.map((item) {
          return {
            'name': item['title'] ?? '',
            'image': item['imageUrls'] != null && item['imageUrls'].isNotEmpty ? item['imageUrls'][0] : '',
            'city': item['city'] ?? '',
          };
        }).toList();
      }

      print("Khách sạn/lượt xem đầu tiên: ${danhSachKhachSan[0]}");
      return danhSachKhachSan;
    } else {
      throw Exception('Lỗi khi lấy dữ liệu dataset, status: ${datasetItemsResponse.statusCode}');
    }
  }
}
