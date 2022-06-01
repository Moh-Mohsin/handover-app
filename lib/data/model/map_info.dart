import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapInfo {
  final LatLng currentLocation;
  final CircularGeoFence pickupGeoFence;
  final CircularGeoFence deliveryGeoFence;

  MapInfo({
    required this.currentLocation,
    required this.pickupGeoFence,
    required this.deliveryGeoFence,
  });
}

class CircularGeoFence {
  final LatLng center;
  final double reachedRadiusInMeters;
  final double nearRadiusInMeters;

  CircularGeoFence({
    required this.center,
    required this.reachedRadiusInMeters,
    required this.nearRadiusInMeters,
  });
}
