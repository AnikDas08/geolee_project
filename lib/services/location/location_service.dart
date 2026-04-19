import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<void> inti() async {
    final bool isEnabled = await checkLocationEnabled();
    if (isEnabled) {
      locationPermission();
    }
  }

  static Future<bool> checkLocationEnabled() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (kDebugMode) {
      print(serviceEnabled);
    }
    return serviceEnabled;
  }

  static Future<bool> locationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (kDebugMode) {
      print(permission);
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (kDebugMode) {
        print(permission);
      }
      if (permission == LocationPermission.denied) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      bool isEnabled = await Geolocator.isLocationServiceEnabled();

      if (!isEnabled) {
        await Geolocator.openLocationSettings();
        isEnabled = await Geolocator.isLocationServiceEnabled();
        if (!isEnabled) return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return null;
      }

      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 15));
      } catch (e) {
        print("Primary location failed: $e");
        final lastPosition = await Geolocator.getLastKnownPosition();
        return lastPosition;
      }
    } catch (e) {
      print("LocationService Error: $e");
      return null;
    }
  }


  static Future<List> addressToCoordinate(String address) async {
    try {
      bool isEnabled = await checkLocationEnabled();
      if (!isEnabled) {
        isEnabled = await Geolocator.openLocationSettings();
      }
      if (isEnabled) {
        final bool isPermission = await locationPermission();
        if (isPermission) {
          final List<Location> locations = await locationFromAddress(address);
          if (kDebugMode) {
            print(locations.first.longitude);
          }
          return locations;
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List> coordinateToAddress({
    required double lat,
    required double long,
  }) async {
    try {
      bool isEnabled = await checkLocationEnabled();
      if (!isEnabled) {
        isEnabled = await Geolocator.openLocationSettings();
      }
      if (isEnabled) {
        final bool isPermission = await locationPermission();
        if (isPermission) {
          final List<Placemark> placeMarks = await placemarkFromCoordinates(
            lat,
            long,
          );
          print(placeMarks.first.street);
          print(placeMarks.first.country);
          print(placeMarks.first.administrativeArea);
          print(placeMarks.first.subLocality);
          print(placeMarks.first.isoCountryCode);
          print(placeMarks);
          return placeMarks;
        }
      }
      //

      return [];
    } catch (e) {
      return [];
    }
  }
}
