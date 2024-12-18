import 'package:education_apps/app/modules/connection/views/no_connection_view.dart';
import 'package:education_apps/app/modules/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText(); // Speech-to-Text instance
  final TextEditingController searchController = TextEditingController();
  bool _isListening = false;
  final Connectivity _connectivity = Connectivity();
  var isConnected = true.obs; // Connectivity status

  @override
  void onInit() {
    super.onInit();
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((connectivityResult) {
      _updateConnectionStatus(connectivityResult.first); // Update connection status
    });
  }

  // Update connection status and show a snackbar
  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      isConnected.value = false;
      Get.snackbar(
        'No Internet Connection',
        'You are not connected to the internet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } else {
      if (!isConnected.value) {
        isConnected.value = true;
        Get.snackbar(
          'Connected to the Internet',
          'You are now connected to the internet.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    }
  }

  // Toggle speech-to-text listening
  void toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(onResult: (result) {
          searchController.text = result.recognizedWords;
        });
        _isListening = true;
      }
    } else {
      _speech.stop();
      _isListening = false;
    }
  }

  // Fetch courses from Firestore
  Stream<QuerySnapshot> fetchCourses() {
    return FirebaseFirestore.instance.collection('courses').snapshots();
  }
}
