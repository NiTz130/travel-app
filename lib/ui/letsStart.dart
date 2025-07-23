// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'customPageRoutes.dart';
import 'navigationPage.dart';

// Hàm lấy vị trí hiện tại và lưu lại
Future<String?> getLocation() async {
  Location location = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData? _locationData;

  // Kiểm tra dịch vụ định vị đã bật chưa
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) return null;
  }

  // Kiểm tra quyền truy cập vị trí
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) return null;
  }

  // Lấy vị trí hiện tại
  _locationData = await location.getLocation();
  if (_locationData == null) return null;

  // Lưu lat/lon vào local
  final prefs = await SharedPreferences.getInstance();
  final currentLocation = jsonEncode({
    "lat": '${_locationData.latitude}',
    "lng": '${_locationData.longitude}'
  });
  prefs.setString('currentLocation', currentLocation);

  // Đổi tọa độ thành tên thành phố
  List<Placemark> placemarks = await placemarkFromCoordinates(
    _locationData.latitude!,
    _locationData.longitude!,
  );
  if (placemarks.isEmpty) return null;

  String cityName = placemarks.first.locality ?? '';
  prefs.setString('currentCity', cityName);

  return cityName;
}

class LetsStartPage extends StatefulWidget {
  const LetsStartPage({super.key});

  @override
  State<LetsStartPage> createState() => _LetsStartPageState();
}

class _LetsStartPageState extends State<LetsStartPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool confirmExit = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Xác nhận thoát'),
              content: Text('Bạn chắc chắn muốn thoát ứng dụng?'),
              actions: [
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: Text('Thoát'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Hủy'),
                ),
              ],
            );
          },
        );
        return confirmExit;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Center(
            child: Column(
              children: [
                // Ảnh động checklist
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: SizedBox(
                    height: 250,
                    width: 300,
                    child: Lottie.asset(
                      "assets/images/143784-checklist.json",
                      repeat: false,
                    ),
                  ),
                ),
                // Tiêu đề lớn
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "BẮT ĐẦU HÀNH TRÌNH",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                // Tiêu đề nhỏ
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Cùng khám phá thế giới của bạn!",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                // Nút lấy vị trí tự động
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 30.0),
                      child: SizedBox(
                        width: 320,
                        height: 45,
                        child: TextButton(
                          onPressed: () async {
                            String? cityName = await getLocation();
                            if (cityName != null) {
                              Navigator.of(context).pushReplacement(
                                customPageRoutes(
                                  child: NavigationPage(
                                    isBackButtonClick: false,
                                    autoSelectedIndex: 0,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Không thể xác định vị trí hiện tại!'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Color.fromARGB(255, 177, 152, 152),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Định vị tự động',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Nút chọn vị trí thủ công
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 18.0),
                      child: SizedBox(
                        width: 320,
                        height: 45,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Thêm trang chọn vị trí thủ công nếu có
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Chức năng này đang phát triển!")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide(color: Colors.black12),
                          ),
                          child: Text(
                            'Chọn vị trí thủ công',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
