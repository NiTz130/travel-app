import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'search.dart';
import 'bottomNavigationBar.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'Home.dart';
import 'myFavorite.dart';
import 'myTrips.dart';
import 'profile/myAccount.dart';

class NavigationPage extends StatefulWidget {
  final bool isBackButtonClick;
  final int autoSelectedIndex;

  NavigationPage({required this.isBackButtonClick, required this.autoSelectedIndex, Key? key}) : super(key: key);

  @override
  State<NavigationPage> createState() => _NavigationPageState(isBackButtonClick, autoSelectedIndex);
}

class _NavigationPageState extends State<NavigationPage> {
  bool isBackButtonClick;
  int autoSelectedIndex;
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late StreamSubscription<bool> keyboardSubscription;
  bool isKeyboardVisible = false;

  _NavigationPageState(this.isBackButtonClick, this.autoSelectedIndex);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      isBackButtonClick = true;
      _pages = [
        home(isBackButtonClick: isBackButtonClick),
        const SearchPage(isTextFieldClicked: false, searchType: 'city', isSelectPlaces: false),
        MyTrips(),
        MyFavorite(),
        const myAccount(),
      ];
    });
  }

  @override
  void initState() {
    super.initState();

    if (autoSelectedIndex == 0) {
      isBackButtonClick = isBackButtonClick;
      _selectedIndex = _selectedIndex;
    } else {
      _selectedIndex = autoSelectedIndex;
    }
    var keyboardVisibilityController = KeyboardVisibilityController();
    _pages = [
      home(isBackButtonClick: isBackButtonClick),
      const SearchPage(isTextFieldClicked: false, searchType: 'city', isSelectPlaces: false),
      MyTrips(),
      MyFavorite(),
      const myAccount(),
    ];
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return GestureDetector(
      onTap: () {
        // Ẩn bàn phím khi tap ra ngoài các trường nhập
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          if (_selectedIndex == 0) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Xác nhận thoát'),
                  content: const Text('Bạn có chắc chắn muốn thoát ứng dụng không?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: const Text('Có'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Không'),
                    ),
                  ],
                );
              },
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationPage(isBackButtonClick: true, autoSelectedIndex: 0),
              ),
            );
          }
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _pages[_selectedIndex],
          bottomNavigationBar: Visibility(
            visible: !isKeyboardVisible,
            child: navigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
