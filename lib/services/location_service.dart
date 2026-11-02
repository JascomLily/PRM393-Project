import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class AddressResult {
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String? road;
  final String? suburb;
  final String? city;

  AddressResult({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.road,
    this.suburb,
    this.city,
  });
}

class LocationService {
  static Future<AddressResult?> getCurrentAddress() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final lat = position.latitude;
      final lng = position.longitude;

      final reverseResult = await reverseGeocode(lat, lng);
      return reverseResult ??
          AddressResult(
            formattedAddress:
                'Tọa độ (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}), Khu vực TP. Hồ Chí Minh',
            latitude: lat,
            longitude: lng,
            city: 'TP. Hồ Chí Minh',
          );
    } catch (e) {
      debugPrint('[LocationService] getCurrentAddress error: $e');
      return null;
    }
  }

  static Future<AddressResult?> reverseGeocode(double lat, double lng) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&accept-language=vi',
      );

      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'Furni3D-Mobile-App/1.0 (prm393_project)');
      final response = await request.close();

      if (response.statusCode == 200) {
        final bodyString = await response.transform(utf8.decoder).join();
        final data = jsonDecode(bodyString) as Map<String, dynamic>;

        final displayName = data['display_name'] as String?;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final houseNumber = address['house_number'] ?? '';
          final road = address['road'] ?? address['street'] ?? '';
          final suburb = address['suburb'] ?? address['quarter'] ?? address['neighbourhood'] ?? '';
          final district = address['district'] ?? address['city_district'] ?? '';
          final city = address['city'] ?? address['state'] ?? 'TP. Hồ Chí Minh';

          final parts = [
            if (houseNumber.isNotEmpty) houseNumber,
            if (road.isNotEmpty) road,
            if (suburb.isNotEmpty) suburb,
            if (district.isNotEmpty) district,
            if (city.isNotEmpty) city,
          ];

          final formatted = parts.isNotEmpty
              ? parts.join(', ')
              : (displayName ?? 'Tọa độ ($lat, $lng)');

          return AddressResult(
            formattedAddress: formatted,
            latitude: lat,
            longitude: lng,
            road: road,
            suburb: suburb,
            city: city,
          );
        } else if (displayName != null) {
          return AddressResult(
            formattedAddress: displayName,
            latitude: lat,
            longitude: lng,
          );
        }
      }
    } catch (e) {
      debugPrint('[LocationService] reverseGeocode fallback: $e');
    }

    return null;
  }
}
