import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handover/data/location_provider.dart';
import 'package:handover/data/model/handover.dart';
import 'package:handover/data/model/handover_status.dart';
import 'package:handover/data/model/map_info.dart';
import 'package:handover/data/model/step_data.dart';
import 'package:handover/data/model/user.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';

part 'live_tracking_state.dart';

class LiveTrackingCubit extends Cubit<LiveTrackingState> {
  final LocationProvider _locationProvider;
  LiveTrackingCubit({required LocationProvider locationProvider})
      : _locationProvider = locationProvider,
        super(LiveTrackingInitial());
  Handover _handover = Handover(
    user: User(
      name: 'Mohamed Abdalmohsin',
      profilePictureUrl:
          'https://i.picsum.photos/id/431/200/300.jpg?hmac=aUpIWBq8svIaK2ruTnNG-BZuvcDsK9Mr9PuJuYAYEQ0',
    ),
    handoverStatus: HandoverStatus.onRoute,
  );

  final reachedRadiusInMeters = 50.0;
  final nearRadiusInMeters = 180.0;

  StreamSubscription<LatLng>? locListner;

  start() {
    locListner = _locationProvider.locationStream().listen((loc) {
      final pickupLoc = _locationProvider.pickUpLocation;
      final deliveryLoc = _locationProvider.deliveryLocation;

      _updateHandoverStatus(loc, pickupLoc, deliveryLoc);

      final mapInfo = MapInfo(
        currentLocation: loc,
        pickupGeoFence: CircularGeoFence(
          center: pickupLoc,
          reachedRadiusInMeters: reachedRadiusInMeters,
          nearRadiusInMeters: nearRadiusInMeters,
        ),
        deliveryGeoFence: CircularGeoFence(
          center: deliveryLoc,
          reachedRadiusInMeters: reachedRadiusInMeters,
          nearRadiusInMeters: nearRadiusInMeters,
        ),
      );
      // print('emit LiveTrackingCurrentState');
      emit(LiveTrackingCurrentState(
          mapInfo: mapInfo,
          handover: _handover,
          stepsData: _getStepData(
            _handover.handoverStatus,
          )));
    }, onDone: () {
      if (_handover.handoverStatus == HandoverStatus.delivered &&
          state is LiveTrackingCurrentState) {
        _handover = _handover.copyWith(handoverStatus: HandoverStatus.finished);
        emit((state as LiveTrackingCurrentState).copyWith(handover: _handover));
      }
    });
  }

  void onDispose() {
    locListner?.cancel();
  }

  _updateHandoverStatus(LatLng loc, LatLng pickupLoc, LatLng deliveryLoc) {
    final distanceFromPickup = Geolocator.distanceBetween(
        loc.latitude, loc.longitude, pickupLoc.latitude, pickupLoc.longitude);
    final distanceFromDelivery = Geolocator.distanceBetween(loc.latitude,
        loc.longitude, deliveryLoc.latitude, deliveryLoc.longitude);

    var handoverStatus = _handover.handoverStatus;

    if (distanceFromPickup < nearRadiusInMeters &&
        handoverStatus.value < HandoverStatus.nearPickup.value) {
      handoverStatus = HandoverStatus.nearPickup;
    } else if (distanceFromPickup < reachedRadiusInMeters &&
        handoverStatus.value < HandoverStatus.pickedUp.value) {
      handoverStatus = HandoverStatus.pickedUp;
      if (_handover.pickupTime == null) {
        _handover = _handover.copyWith(pickupTime: DateTime.now());
      }
    } else if (distanceFromDelivery < nearRadiusInMeters &&
        handoverStatus.value < HandoverStatus.nearDelivery.value) {
      handoverStatus = HandoverStatus.nearDelivery;
    } else if (distanceFromDelivery < reachedRadiusInMeters &&
        handoverStatus.value < HandoverStatus.delivered.value) {
      handoverStatus = HandoverStatus.delivered;
      if (_handover.deliveryTime == null) {
        _handover = _handover.copyWith(deliveryTime: DateTime.now());
      }
    }
    _handover = _handover.copyWith(handoverStatus: handoverStatus);
  }

  Map<HandoverStatus, String> stepsMap = {
    HandoverStatus.onRoute: "On the way",
    HandoverStatus.nearPickup: "Near Pickup",
    HandoverStatus.pickedUp: "Pickup Delivery",
    HandoverStatus.nearDelivery: "Near Delivery destination",
    HandoverStatus.delivered: "Delivered package",
  };
  StepsData _getStepData(HandoverStatus handoverStatus) {
    return StepsData(
        titles: stepsMap.values.toList(),
        currentStepIndex: stepsMap.keys.toList().indexOf(handoverStatus));
  }
}
