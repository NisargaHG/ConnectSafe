import 'package:flutter/foundation.dart';

import '../models/location_data.dart';

class LocationService {
  Future<LocationData> getCurrentLocation() async {
    // TODO:
    // Replace with geolocator/location package implementation.

    debugPrint('Fetching current location...');

    await Future.delayed(const Duration(seconds: 1));

    return LocationData(
      latitude: 12.9716,
      longitude: 77.5946,
      address: 'Bengaluru, Karnataka',
      timestamp: DateTime.now(),
    );
  }

  Future<bool> requestLocationPermission() async {
    // TODO:
    // Request runtime location permission.

    debugPrint('Requesting location permission...');
    return true;
  }

  Future<bool> isLocationEnabled() async {
    // TODO:
    // Check whether GPS/location service is enabled.

    return true;
  }

  Future<String> getFormattedAddress(
      double latitude,
      double longitude,
      ) async {
    // TODO:
    // Replace with reverse geocoding implementation.

    return 'Lat: $latitude, Lng: $longitude';
  }
}