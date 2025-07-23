import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../blocs/place/placeList_bloc.dart';
import '../blocs/place/place_event.dart';
import '../models/place.dart';
import 'placeDeatailsScreen/locationDetails.dart';

class SearchPage extends StatefulWidget {
  final bool isTextFieldClicked;
  final String searchType;
  final bool isSelectPlaces;

  const SearchPage({
    required this.isTextFieldClicked,
    required this.searchType,
    required this.isSelectPlaces,
    Key? key,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late bool isTextFieldClicked;
  late String searchType;
  late bool isSelectPlaces;

  String inputData = "";
  Timer? _timer;
  List<Map<String, dynamic>> selectedIds = [
    {'day': "", 'places': <String>[]}
  ];
  bool isOnLongPress = false;
  late List<Place> recentlySearchList = [];

  @override
  void initState() {
    super.initState();
    isTextFieldClicked = widget.isTextFieldClicked;
    searchType = widget.searchType;
    isSelectPlaces = widget.isSelectPlaces;
  }

  String capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tiêu đề tìm kiếm
          Visibility(
            visible: !isTextFieldClicked,
            child: Padding(
              padding: const EdgeInsets.only(left: 13.0, top: 40.0, bottom: 6.0),
              child: Row(
                children: [
                  Text(
                    "Tìm kiếm",
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                        color: Color(0xFF1B1B1B),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Thanh nhập tìm kiếm
          Padding(
            padding: isTextFieldClicked
                ? const EdgeInsets.only(top: 40)
                : const EdgeInsets.only(top: 25),
            child: Row(
              children: [
                Visibility(
                  visible: isTextFieldClicked,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF919090),
                    iconSize: 26,
                    onPressed: () {
                      setState(() {
                        isTextFieldClicked = false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 37,
                      child: TextField(
                        onTap: () {
                          setState(() {
                            isTextFieldClicked = true;
                            isOnLongPress = false;
                          });
                        },
                        onChanged: (value) {
                          if (value != '') {
                            if (_timer?.isActive ?? false) _timer!.cancel();
                            _timer = Timer(const Duration(milliseconds: 1000), () {
                              setState(() {
                                inputData = value;
                              });
                            });
                            isTextFieldClicked = true;
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF0EEEE),
                          hintText: 'Nhập tên địa điểm, thành phố...',
                          prefixIcon: const Icon(Icons.search),
                          hintStyle: GoogleFonts.cabin(
                            textStyle: const TextStyle(
                              color: Color(0xFF919090),
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(19.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 5.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Nhãn lịch sử tìm kiếm
          Visibility(
            visible: !isTextFieldClicked,
            child: Padding(
              padding: const EdgeInsets.only(left: 13, top: 30),
              child: Row(
                children: [
                  Text(
                    "Tìm kiếm gần đây của bạn",
                    style: GoogleFonts.cabin(
                      textStyle: const TextStyle(
                        color: Color(0xFF1B1B1B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Kết quả tìm kiếm
          FutureBuilder(
            future: placeBloc.searchPlaces(capitalize(inputData), searchType),
            builder: (context, results) {
              if (results.connectionState == ConnectionState.waiting) {
                return LoadingAnimationWidget.discreteCircle(
                  color: const Color(0xFF818181),
                  size: 24,
                );
              }

              if (results.hasData && isTextFieldClicked) {
                // Chắc chắn kết quả là List<Place>
                final List<Place> places = results.data as List<Place>;
                return Expanded(
                  child: Stack(
                    children: [
                      ScrollConfiguration(
                        behavior: const ScrollBehavior(),
                        child: GlowingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          color: const Color(0xFF646464),
                          child: ListView.builder(
                            itemCount: places.length,
                            itemBuilder: (context, index) {
                              final searchRe = places[index];
                              final name = searchRe.name;
                              final photoReference = searchRe.photoRef;
                              final placeId = searchRe.id;

                              return Column(
                                children: [
                                  GestureDetector(
                                    onLongPress: () {
                                      if (isSelectPlaces) {
                                        setState(() {
                                          isOnLongPress = true;
                                        });
                                      }
                                    },
                                    onTap: () {
                                      if (!isOnLongPress) {
                                        if (searchType == 'city') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => locationDetails(
                                                placeId: placeId,
                                                searchType: 'city',
                                              ),
                                            ),
                                          );
                                          if (recentlySearchList.isNotEmpty) {
                                            bool contains = recentlySearchList.any(
                                                    (element) => element.name == name);
                                            if (!contains) {
                                              BlocProvider.of<placeListBloc>(
                                                  context)
                                                  .add(addUserRecentlySearch(
                                                id: searchRe.id,
                                                name: searchRe.name,
                                                address: searchRe.address,
                                                openingHours: searchRe.openingHours,
                                                phone: searchRe.phone,
                                                photoRef: searchRe.photoRef,
                                                type: searchRe.type,
                                                latitude: searchRe.latitude,
                                                longitude: searchRe.longitude,
                                              ));
                                            }
                                          } else {
                                            BlocProvider.of<placeListBloc>(context)
                                                .add(addUserRecentlySearch(
                                              id: searchRe.id,
                                              name: searchRe.name,
                                              address: searchRe.address,
                                              openingHours: searchRe.openingHours,
                                              phone: searchRe.phone,
                                              photoRef: searchRe.photoRef,
                                              type: searchRe.type,
                                              latitude: searchRe.latitude,
                                              longitude: searchRe.longitude,
                                            ));
                                          }
                                        } else if (searchType == 'attraction') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => locationDetails(
                                                placeId: placeId,
                                                searchType: 'attraction',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6),
                                          child: Container(
                                            width: 340,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: const Color(0xFFE2E2E2)
                                                      .withOpacity(0.5),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 9),
                                                    child: SizedBox(
                                                      width: 37,
                                                      height: 37,
                                                      child: CircleAvatar(
                                                        radius: 40,
                                                        backgroundImage:
                                                        NetworkImage(
                                                            photoReference ??
                                                                ''),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 6),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(bottom: 4),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 245,
                                                                child: Text(
                                                                  name ?? '',
                                                                  overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                                  style: GoogleFonts
                                                                      .cabin(
                                                                    textStyle:
                                                                    const TextStyle(
                                                                      color: Color(
                                                                          0xFF1B1B1B),
                                                                      fontSize:
                                                                      14,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w700,
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
                                                  Visibility(
                                                    visible: isOnLongPress,
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (selectedIds[0]
                                                          ['places']
                                                              .contains(
                                                              placeId)) {
                                                            selectedIds[0]
                                                            ['places']
                                                                .remove(placeId);
                                                          } else {
                                                            selectedIds[0]
                                                            ['places']
                                                                .add(placeId);
                                                          }
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        height: 25,
                                                        width: 25,
                                                        child: selectedIds[0]
                                                        ['places']
                                                            .contains(placeId)
                                                            ? Image.asset(
                                                            "assets/images/correct.png")
                                                            : Image.asset(
                                                            "assets/images/dry-clean.png"),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isOnLongPress,
                        child: Positioned(
                          top: 565,
                          left: 95,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 155,
                                    height: 45,
                                    child: TextButton(
                                      onPressed: () async {
                                        // TODO: Gắn logic Thêm vào chuyến đi ở đây nếu muốn
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: Text(
                                        'Thêm vào chuyến đi',
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              } else if (results.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Đã xảy ra lỗi khi tìm kiếm!'),
                );
              } else {
                return LoadingAnimationWidget.waveDots(
                  color: const Color(0xFF818181),
                  size: 35,
                );
              }
            },
          ),
          // Lịch sử tìm kiếm
          Visibility(
            visible: !isTextFieldClicked,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<Place>>(
                future: placeBloc.getUserRecentlySearch(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Place>> snapshot) {
                  if (snapshot.hasData) {
                    recentlySearchList = snapshot.data!;
                    return Expanded(
                      child: ScrollConfiguration(
                        behavior: const ScrollBehavior(),
                        child: GlowingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          color: Colors.black,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: recentlySearchList.length,
                            itemBuilder: (context, index) {
                              final place = recentlySearchList[index];
                              return Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              locationDetails(
                                                placeId: place.id,
                                                searchType: 'city',
                                              ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      child: Card(
                                        elevation: 0,
                                        color:
                                        const Color.fromARGB(255, 240, 238, 238),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(17.0),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  FittedBox(
                                                    fit: BoxFit.cover,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                        left: 8,
                                                        right: 8,
                                                        top: 8,
                                                        bottom: 8,
                                                      ),
                                                      child: Text(
                                                        place.name,
                                                        style: GoogleFonts.cabin(
                                                          textStyle:
                                                          const TextStyle(
                                                            color: Color(
                                                                0xFF1B1B1B),
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.bold,
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
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
