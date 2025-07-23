import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/trip/trip_bloc.dart';
import '../blocs/trip/trip_event.dart';
import '../blocs/trip/trip_state.dart';
import '../models/place.dart';
import '../models/trip.dart';
import 'components/emptyTripPlaces.dart';
import 'components/modalBottomSheetButton.dart';
import 'navigationPage.dart';

class TripDetailsPlan extends StatefulWidget {
  bool isEditPlace;
  bool isAddPlace;
  Trip trip;
  Place place;
  TripDetailsPlan({
    required this.isEditPlace,
    required this.isAddPlace,
    required this.trip,
    required this.place,
    Key? key,
  }) : super(key: key);

  @override
  State<TripDetailsPlan> createState() =>
      _TripDetailsPlanState(isEditPlace, isAddPlace, trip, place);
}

class _TripDetailsPlanState extends State<TripDetailsPlan> {
  bool isEditPlace;
  bool isAddPlace;
  Trip trip;
  Place place;
  List listTiles = [];
  var newEndDate;
  var newDurationCount;
  var day = 1;
  bool isTextFieldClicked = false;
  String inputData = '';
  List dailogBoxState = [
    {
      'isSelectCity': false,
      'isTextfiledEmpty': false,
      'selectedPlaces': [],
    }
  ];

  var currentIndex = 0;
  var tripPlaces;
  var addPlaces = [];
  var tripDays = {};
  var storeTripDays = {};
  late List<dynamic> selectedData;
  bool isDaySelect = false;
  bool isAddDay = false;
  List selectedIds = [];
  var dayInPlacesList = [];
  var allTripPlaces = {};
  ScrollController scrollController = ScrollController();

  _TripDetailsPlanState(
      this.isEditPlace, this.isAddPlace, this.trip, this.place);

  @override
  void initState() {
    super.initState();
    if (isEditPlace == true) {
      setTripDetails();
      editTrip();
    } else {
      setTripDetails();
    }
    scrollController;
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Future<void> setTripDetails() async {
    currentIndex = 0;
    scrollController.animateTo(
      currentIndex * 100,
      duration: const Duration(milliseconds: 800),
      curve: Curves.decelerate,
    );

    for (var i = 0; i <= trip.durationCount; i++) {
      if (!listTiles.contains(i)) {
        listTiles.add(i);
      }
    }
    setState(() {});
  }

  Future<void> editTrip() async {
    BlocProvider.of<tripBloc>(context).add(editPlaces(trip.places));
  }

  Future<void> reorderData(int oldIndex, int newIndex) async {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final item = dayInPlacesList.removeAt(oldIndex);
      dayInPlacesList.insert(newIndex, item);
    });
  }

  void createTrip() {
    Trip newTrip = Trip(
      tripId: trip.tripId,
      tripName: trip.tripName,
      tripBudget: trip.tripBudget,
      tripLocation: trip.tripLocation,
      tripDescription: trip.tripDescription,
      tripCoverPhoto: trip.tripCoverPhoto,
      tripDuration:
      '${DateFormat('yyyy-MM-dd').format(trip.startDate)} - ${DateFormat('yyyy-MM-dd').format(newEndDate ?? trip.endDate)}',
      durationCount: newDurationCount ?? trip.durationCount,
      startDate: trip.startDate,
      endDate: newEndDate ?? trip.endDate,
      places: allTripPlaces,
    );

    if (allTripPlaces.isNotEmpty) {
      if (!isEditPlace) {
        BlocProvider.of<tripBloc>(context).add(creatTrip(newTrip));
      } else {
        BlocProvider.of<tripBloc>(context).add(updateTrip(newTrip));
      }
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(
            "Chọn ngày",
            style: GoogleFonts.cabin(
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior(),
                    child: GlowingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      color: const Color(0xFF535353),
                      child: ListView.builder(
                        cacheExtent: 9999,
                        scrollDirection: Axis.vertical,
                        itemCount: listTiles.length,
                        itemBuilder: (context, index) {
                          if (index == listTiles.length - 1) {
                            return GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 40,
                                height: 40,
                                color: Colors.transparent,
                                child:
                                Image.asset('assets/images/add-black.png'),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () async {
                                BlocProvider.of<tripBloc>(context)
                                    .add(planingPlaces([place], index));
                                setState(() {
                                  day = listTiles[index];
                                  isAddPlace = false;
                                  currentIndex = index;
                                  scrollController.animateTo(index * 100,
                                      duration:
                                      const Duration(milliseconds: 800),
                                      curve: Curves.decelerate);
                                  tripDays;
                                });
                                Navigator.pop(context, true);
                              },
                              child: Card(
                                elevation: 0,
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Container(
                                  height: 60,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Ngày ${index + 1}',
                                    style: GoogleFonts.cabin(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.pop(context, true);
                Navigator.pop(context, true);
              },
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext parentContext) {
    if (isAddPlace == true) {
      Future.delayed(Duration.zero, () => _showDialog());
      return buildBody(parentContext);
    } else {
      return buildBody(parentContext);
    }
  }

  Widget buildBody(BuildContext parentContext) {
    return WillPopScope(
      onWillPop: () async {
        bool confirmExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thông báo'),
            content: const Text('Bạn có muốn lưu thay đổi này không?'),
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('Có'),
              ),
              TextButton(
                onPressed: () async {
                  BlocProvider.of<tripBloc>(context).add(cancelPlaningPlaces());
                  dayInPlacesList = [];
                  Navigator.pop(context, true);
                },
                child: const Text('Không'),
              ),
            ],
          ),
        );
        return confirmExit;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {},
          ),
          toolbarHeight: 180,
          flexibleSpace: Container(
            color: const Color(0xFFFAFAFA),
            child: Column(
              children: [
                Container(
                  color: const Color.fromARGB(98, 255, 255, 255),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 22, left: 10),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 100, top: 35),
                              child: Text(
                                "Kế hoạch chuyến đi",
                                style: GoogleFonts.cabin(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF1B1B1B),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, left: 240),
                        child: TextButton(
                          onPressed: () async {
                            createTrip();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF025E0E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Tạo chuyến đi',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 9, left: 10, right: 10),
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              Expanded(
                                child: ScrollConfiguration(
                                  behavior: const ScrollBehavior(),
                                  child: GlowingOverscrollIndicator(
                                    axisDirection: AxisDirection.right,
                                    color: const Color(0xFF535353),
                                    child: ListView.builder(
                                      controller: scrollController,
                                      cacheExtent: 9999,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: listTiles.length,
                                      itemBuilder: (context, index) {
                                        if (index == listTiles.length - 1) {
                                          return GestureDetector(
                                            onTap: () async {
                                              currentIndex = 0;
                                              setState(() {
                                                listTiles.add(listTiles.length + 1);
                                                isAddDay = true;
                                                currentIndex = index;
                                              });

                                              if (newEndDate != null &&
                                                  newDurationCount != null) {
                                                var oldDate = newEndDate;
                                                var newDate = DateTime(
                                                    oldDate.year,
                                                    oldDate.month,
                                                    oldDate.day + 1);
                                                newEndDate = newDate;
                                                newDurationCount += 1;
                                              } else {
                                                var oldDate = trip.endDate;
                                                var newDate = DateTime(
                                                    oldDate.year,
                                                    oldDate.month,
                                                    oldDate.day + 1);
                                                newEndDate = newDate;
                                                newDurationCount =
                                                    trip.durationCount + 1;
                                              }

                                              scrollController.animateTo(
                                                  scrollController.offset + 130,
                                                  curve: Curves.linear,
                                                  duration: const Duration(milliseconds: 500));
                                              BlocProvider.of<tripBloc>(context)
                                                  .add(planingPlaces([], currentIndex));
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              color: Colors.transparent,
                                              child: Image.asset(
                                                  'assets/images/add-black.png'),
                                            ),
                                          );
                                        } else {
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                day = listTiles[index];
                                                currentIndex = index;
                                                tripDays;
                                              });
                                            },
                                            child: Card(
                                              elevation: 0,
                                              color: currentIndex == index
                                                  ? Colors.black
                                                  : const Color(0xFFE6E6E6),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10.0),
                                              ),
                                              child: Container(
                                                width: 100,
                                                height: 30,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Ngày ${index + 1}',
                                                  style: GoogleFonts.cabin(
                                                    textStyle: TextStyle(
                                                      color: currentIndex == index
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
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
              ],
            ),
          ),
        ),
        body: tripList(parentContext),
      ),
    );
  }

  Widget tripList(BuildContext parentContext) {
    return BlocConsumer<tripBloc, tripState>(
      listener: (context, state) {
        if (state is tripCreateErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại!")),
          );
        } else if (state is tripCreatingSuccessState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationPage(
                isBackButtonClick: true,
                autoSelectedIndex: 2,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is storeTripPlacesState) {
          if (state.storeTripPlaces['$currentIndex'] != null &&
              state.storeTripPlaces['$currentIndex'].isNotEmpty) {
            allTripPlaces = state.storeTripPlaces;
            return Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ScrollConfiguration(
                          behavior: const ScrollBehavior(),
                          child: GlowingOverscrollIndicator(
                            axisDirection: AxisDirection.down,
                            color: const Color(0xFF535353),
                            child: ReorderableListView(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                              onReorder: reorderData,
                              children: <Widget>[
                                for (int index = 0;
                                index <
                                    state.storeTripPlaces[
                                    '$currentIndex']
                                        .length;
                                index += 1)
                                  Card(
                                    color: const Color(0xFFF0EEEE),
                                    key: ValueKey(index),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(17.0),
                                    ),
                                    elevation: 2,
                                    child: SizedBox(
                                      height: 90,
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 90,
                                            width: 90,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(17),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  state.storeTripPlaces[
                                                  '$currentIndex']
                                                  [index]['imageUrls'],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 6, top: 5),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                        state.storeTripPlaces[
                                                        '$currentIndex']
                                                        [index]['title'],
                                                        style:
                                                        GoogleFonts.cabin(
                                                          textStyle:
                                                          const TextStyle(
                                                            color: Color(
                                                                0xFF1B1B1B),
                                                            fontSize: 15,
                                                            fontWeight:
                                                            FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 35),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: 30,
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: GoogleFonts.cabin(
                                                      textStyle:
                                                      const TextStyle(
                                                        color:
                                                        Color(0xFF1B1B1B),
                                                        fontSize: 20,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: state.storeTripPlaces['$currentIndex']
                              .isNotEmpty,
                          child: Positioned(
                            top: 410,
                            left: 100,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: modalBottomSheetButton(
                                      currentIndex: currentIndex,
                                      parentContext: parentContext),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          } else {
            return emptyTripPlaces(
                currentIndex: currentIndex, parentContext: context);
          }
        } else {
          return emptyTripPlaces(
              currentIndex: currentIndex, parentContext: context);
        }
      },
    );
  }
}
