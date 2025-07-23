import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'createTrip.dart';
import '../blocs/trip/trip_bloc.dart';
import '../models/trip.dart';

class MyTrips extends StatefulWidget {
  const MyTrips({super.key});

  @override
  State<MyTrips> createState() => _MyTripsState();
}

class _MyTripsState extends State<MyTrips> {
  late List<Trip> onGoingTrips;
  late List<Trip> pastTrips;
  var isDataReady = false;

  @override
  void initState() {
    super.initState();
    getTripList();
  }

  Future<void> getTripList() async {
    onGoingTrips = await tripBlo.getOnGoingTrips();
    pastTrips = await tripBlo.pastTrips();

    setState(() {
      isDataReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isDataReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 2,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(0, 255, 255, 255),
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SizedBox(
        width: 360,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 13, bottom: 10, top: 12),
              child: Row(
                children: [
                  Text(
                    "Lịch trình của bạn",
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 27, 27, 27),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Ongoing trips section
            Padding(
              padding: const EdgeInsets.only(left: 13, bottom: 17, top: 12),
              child: Row(
                children: [
                  Text(
                    "Đang diễn ra",
                    style: GoogleFonts.cabin(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 27, 27, 27),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: onGoingTrips.isNotEmpty
                  ? ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: GlowingOverscrollIndicator(
                  axisDirection: AxisDirection.right,
                  color: const Color.fromARGB(255, 83, 83, 83),
                  child: ListView.builder(
                    cacheExtent: 9999,
                    itemCount: onGoingTrips.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14, left: 8),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => createTrip(
                                      placeName: '',
                                      placePhotoUrl: '',
                                      isEditTrip: true,
                                      trip: onGoingTrips[index],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 11),
                                child: Container(
                                  width: 230,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 216, 99, 99),
                                    borderRadius: BorderRadius.circular(17),
                                    image: DecorationImage(
                                      image: NetworkImage(onGoingTrips[index].tripCoverPhoto),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 13, top: 11),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 25,
                                              width: 60,
                                              child: Card(
                                                elevation: 0,
                                                color: const Color.fromARGB(200, 240, 238, 238),
                                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.cover,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Text(
                                                      '${onGoingTrips[index].places.length} ngày',
                                                      style: GoogleFonts.cabin(
                                                        textStyle: const TextStyle(
                                                          color: Color.fromARGB(255, 95, 95, 95),
                                                          fontSize: 12,
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
                                          padding: const EdgeInsets.only(top: 70),
                                          child: Row(
                                            children: [
                                              Text(
                                                onGoingTrips[index].tripName,
                                                style: GoogleFonts.cabin(
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 23,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              Text(
                                                onGoingTrips[index].tripDuration,
                                                style: GoogleFonts.cabin(
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
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
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.only(top: 47),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/destination.png', width: 45, height: 45),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Chưa có lịch trình đang diễn ra",
                          style: GoogleFonts.cabin(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 27, 27, 27),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            // Past trips section
            Padding(
              padding: const EdgeInsets.only(left: 13, bottom: 17),
              child: Row(
                children: [
                  Text(
                    "Đã hoàn thành",
                    style: GoogleFonts.cabin(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 27, 27, 27),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Past trip list
            Expanded(
              child: pastTrips.isNotEmpty
                  ? ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: GlowingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  color: const Color.fromARGB(255, 83, 83, 83),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 190,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 10,
                    ),
                    cacheExtent: 9999,
                    itemCount: pastTrips.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Có thể show chi tiết lịch sử chuyến đi ở đây nếu muốn
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 11, left: 10),
                          child: Container(
                            width: 180,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 216, 99, 99),
                              borderRadius: BorderRadius.circular(17),
                              image: DecorationImage(
                                image: NetworkImage(pastTrips[index].tripCoverPhoto),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 9, top: 11),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 50,
                                        child: Card(
                                          elevation: 0,
                                          color: const Color.fromARGB(200, 240, 238, 238),
                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Text(
                                                '${pastTrips[index].places.length} ngày',
                                                style: GoogleFonts.cabin(
                                                  textStyle: const TextStyle(
                                                    color: Color.fromARGB(255, 95, 95, 95),
                                                    fontSize: 8,
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
                                    padding: const EdgeInsets.only(top: 45),
                                    child: Row(
                                      children: [
                                        Text(
                                          pastTrips[index].tripName,
                                          style: GoogleFonts.cabin(
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          pastTrips[index].tripDuration,
                                          style: GoogleFonts.cabin(
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
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
                      );
                    },
                  ),
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/destination.png', width: 45, height: 45),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Chưa có lịch trình đã hoàn thành",
                        style: GoogleFonts.cabin(
                          textStyle: const TextStyle(
                            color: Color.fromARGB(255, 27, 27, 27),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // Button tạo mới chuyến đi
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: SizedBox(
                width: 170,
                height: 45,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => createTrip(
                          placeName: '',
                          placePhotoUrl: '',
                          isEditTrip: false,
                          trip: Trip(
                            tripId: '',
                            tripName: '',
                            tripBudget: '',
                            tripLocation: '',
                            tripDescription: '',
                            tripCoverPhoto: '',
                            tripDuration: '',
                            durationCount: 0,
                            startDate: DateTime(0),
                            endDate: DateTime(0),
                            places: {},
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Color.fromARGB(255, 253, 90, 90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Tạo lịch trình mới',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
