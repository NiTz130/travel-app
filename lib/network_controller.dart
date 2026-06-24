import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>>
  _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    unawaited(initConnectivity());
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Couldn\'t check connectivity status, error:$e');
      }
      return;
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(
    List<ConnectivityResult> connectivityResults,
  ) async {
    final isOffline =
        connectivityResults.isEmpty ||
        connectivityResults.every(
          (result) => result == ConnectivityResult.none,
        );

    if (isOffline) {
      await Future.delayed(const Duration(milliseconds: 100));
      Get.rawSnackbar(
        messageText: const Text(
          'PLEASE CONNECT TO THE INTERNET',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: const Color.fromARGB(255, 97, 97, 97),
        icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}
