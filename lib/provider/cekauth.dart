import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class authProvider extends ChangeNotifier {
  var enteredLocation = '';
  var postalCode = '';
  var country = '';

  // Function to get current location and fetch address using Geocoding package
  Future<void> getCurrentLocation(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('Current Position: ${position.latitude}, ${position.longitude}');

      // Fetch address using Geocoding package
      await getAddressFromLatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching location: $e")));
    }
  }

  // Fetch address from latitude and longitude using Geocoding package
  Future<void> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      // Use the Geocoding package to get the address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        // Extract address, city, country, etc.
        Placemark place = placemarks.first;
        final fetchedAddress = '${place.name}, ${place.locality}, ${place.country}';
        print("Address: $fetchedAddress");

        // Update the state with the fetched address
        enteredLocation = fetchedAddress;
        postalCode = place.postalCode ?? '';
        country = place.country ?? '';
        
        // Output the fetched information to the log
        print("Location Details: Address: $enteredLocation, Postal Code: $postalCode, Country: $country");
      } else {
        print("No results found for the given coordinates.");
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }
}
