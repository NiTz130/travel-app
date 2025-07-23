import 'dart:convert';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fechLastViews.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../blocs/user/user_bloc.dart';

class home extends StatefulWidget {
  final bool isBackButtonClick;
  const home({required this.isBackButtonClick, Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState(isBackButtonClick);
}

class _homeState extends State<home> {
  late List<Map<String, dynamic>> hotelList = [];
  late List<Map<String, dynamic>> lastViewsList = [];
  late List<Map<String, dynamic>> myLocationList = [];
  bool isBackButtonClick;
  String nextPageToken = '';
  var userdata = {};

  var favorites = [];
  List<bool> isaddAttractionToFavorite = [];
  _homeState(this.isBackButtonClick);

  // Danh mục đã việt hóa
  late List<Map<String, dynamic>> categorieList = [
    {"photo": "assets/images/hotel.png", "name": "Khách sạn"},
    {"photo": "assets/images/burger.png", "name": "Quán cà phê"},
    {"photo": "assets/images/forest.png", "name": "Công viên"},
    {"photo": "assets/images/flash.png", "name": "Điểm tham quan"},
    {"photo": "assets/images/gas-pump.png", "name": "Trạm xăng"},
  ];

  void getData() async {
    // Hàm này giữ nguyên logic
  }

  Future<void> getNearByPlaces() async {
    // Hàm này giữ nguyên logic
  }

  @override
  void initState() {
    super.initState();
    // getData();
    // getNearByPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (lastViewsList.isNotEmpty) {
      return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        child: Center(
          child: Column(
            children: [
              // Lời chào
              Padding(
                padding: const EdgeInsets.only(left: 13.0, top: 30.0, bottom: 15.0),
                child: Row(
                  children: [
                    FutureBuilder(
                      future: userBlo.getUserDetails(),
                      builder: (BuildContext context, AsyncSnapshot<auth.User?> snapshot) {
                        if (snapshot.hasData) {
                          return SizedBox(
                            width: 250,
                            child: Text(
                              "Xin chào, ${snapshot.data!.displayName ?? "bạn"}",
                              style: GoogleFonts.nunito(
                                textStyle: const TextStyle(
                                  color: Color(0xFF1B1B1B),
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Danh mục
              Padding(
                padding: const EdgeInsets.only(left: 13.0, right: 6),
                child: SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categorieList.length,
                    itemBuilder: (context, index) {
                      final categorie = categorieList[index];
                      final catName = categorie['name'];
                      final catPhoto = categorie['photo'];
                      return GestureDetector(
                        onTap: () => print("Chọn $catName"),
                        child: Card(
                          elevation: 0,
                          color: const Color.fromARGB(255, 240, 238, 238),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 101,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      catPhoto,
                                      width: 23,
                                      height: 23,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: Text(
                                          catName,
                                          style: GoogleFonts.cabin(
                                            textStyle: const TextStyle(
                                              color: Color(0xFF1B1B1B),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // "Bạn có thể thích những địa điểm này"
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Gợi ý
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0, top: 16),
                        child: Row(
                          children: [
                            Text(
                              "Bạn có thể thích những địa điểm này",
                              style: GoogleFonts.cabin(
                                textStyle: const TextStyle(
                                  color: Color(0xFF1B1B1B),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              "Khám phá thêm tại Việt Nam",
                              style: GoogleFonts.cabin(
                                textStyle: const TextStyle(
                                  color: Color(0xFF8F8E8E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Danh sách khách sạn
                      Padding(
                        padding: const EdgeInsets.only(left: 13.0),
                        child: SizedBox(
                          height: 190,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hotelList.length,
                            itemBuilder: (context, index) {
                              final hotel = hotelList[index];
                              final hotelName = hotel['name'];
                              final hotelRating = hotel['rating'];
                              final photoUrl = hotel['image'];
                              final address = hotel['address'];
                              final type = hotel['type'];
                              return GestureDetector(
                                onTap: () => print("Xem chi tiết khách sạn $hotelName"),
                                child: Card(
                                  elevation: 0,
                                  color: const Color.fromARGB(255, 240, 238, 238),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Container(
                                    width: 230,
                                    child: Column(
                                      children: [
                                        // Ảnh khách sạn
                                        Row(
                                          children: [
                                            Container(
                                              width: 230,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(photoUrl),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      // Loại hình
                                                      SizedBox(
                                                        height: 25,
                                                        width: 60,
                                                        child: Card(
                                                          elevation: 0,
                                                          color: const Color.fromARGB(200, 240, 238, 238),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5.0),
                                                          ),
                                                          child: FittedBox(
                                                            fit: BoxFit.cover,
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(10.0),
                                                              child: Text(
                                                                '$type',
                                                                style: GoogleFonts.cabin(
                                                                  textStyle: const TextStyle(
                                                                    color: Color(0xFF5F5F5F),
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Nút yêu thích
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 119, top: 5),
                                                        child: SizedBox(
                                                          width: 37,
                                                          height: 37,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              print("Yêu thích $hotelName");
                                                              // TODO: xử lý thêm/xoá khỏi danh sách yêu thích
                                                            },
                                                            child: Card(
                                                              elevation: 0,
                                                              color: const Color.fromARGB(200, 240, 238, 238),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(50.0),
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Image.asset("assets/images/heart.png", width: 18, height: 18),
                                                                    ],
                                                                  ),
                                                                ],
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
                                          ],
                                        ),
                                        // Tên khách sạn + Đánh giá
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 190,
                                              height: 30,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 6, top: 5),
                                                child: Text(
                                                  hotelName,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.cabin(
                                                    textStyle: const TextStyle(
                                                      color: Color(0xFF1B1B1B),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Image.asset("assets/images/star.png", width: 14, height: 14),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4),
                                              child: Text(
                                                "$hotelRating",
                                                style: GoogleFonts.cabin(
                                                  textStyle: const TextStyle(
                                                    color: Color(0xFF1B1B1B),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Địa chỉ
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4),
                                              child: Image.asset('assets/images/location.png', width: 15, height: 15),
                                            ),
                                            SizedBox(
                                              width: 200,
                                              height: 7,
                                              child: Text(
                                                address,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.cabin(
                                                  textStyle: const TextStyle(
                                                    color: Color(0xFF5E5E5E),
                                                    fontSize: 7,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // LAST VIEWS
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Card(
                              elevation: 0,
                              color: const Color.fromARGB(200, 240, 238, 238),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Container(
                                width: 326,
                                height: 230,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(lastViewsList[0]['image']),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 13, left: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            width: 70,
                                            child: Card(
                                              elevation: 0,
                                              color: const Color.fromARGB(200, 240, 238, 238),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(3.0),
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    'GẦN ĐÂY',
                                                    style: GoogleFonts.cabin(
                                                      textStyle: const TextStyle(
                                                        color: Color(0xFF5F5F5F),
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 115),
                                        child: Row(
                                          children: [
                                            Text(
                                              lastViewsList[0]['city'],
                                              style: GoogleFonts.cabin(
                                                textStyle: const TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontSize: 27,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 300,
                                            child: Text(
                                              lastViewsList[0]['name'],
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.cabin(
                                                textStyle: const TextStyle(
                                                  color: Color(0xFFCFCFCF),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
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
                          )
                        ],
                      ),
                      // Trải nghiệm gần bạn
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 10),
                            child: Text(
                              "Trải nghiệm gần bạn",
                              style: GoogleFonts.cabin(
                                textStyle: const TextStyle(
                                  color: Color(0xFF1B1B1B),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      // Danh sách địa điểm gần đây
                      Padding(
                        padding: const EdgeInsets.only(left: 13.0, top: 10),
                        child: SizedBox(
                          height: 190,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 0, // TODO: attractionList.length
                            itemBuilder: (context, index) {
                              // TODO: Điền dữ liệu địa điểm gần đây nếu cần
                              return SizedBox();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
