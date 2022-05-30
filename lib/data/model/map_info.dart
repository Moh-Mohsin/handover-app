import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapInfo {
  final LatLng currentLocation;
  final CircularGeoFence startGeoFence;
  final CircularGeoFence endGeoFence;

  MapInfo({
    required this.currentLocation,
    required this.startGeoFence,
    required this.endGeoFence,
  });
}

class CircularGeoFence {
  final LatLng center;
  final double radiusInMeters;

  CircularGeoFence({required this.center, required this.radiusInMeters});
}
