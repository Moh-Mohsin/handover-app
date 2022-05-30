import 'package:bloc/bloc.dart';
import 'package:handover/data/location_provider.dart';
import 'package:handover/data/model/handover.dart';
import 'package:handover/data/model/handover_status.dart';
import 'package:handover/data/model/map_info.dart';
import 'package:handover/data/model/user.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';

part 'live_tracking_state.dart';

class LiveTrackingCubit extends Cubit<LiveTrackingState> {
  final LocationProvider _locationProvider;
  LiveTrackingCubit({required LocationProvider locationProvider})
      : _locationProvider = locationProvider,
        super(LiveTrackingInitial());
  final Handover _handover = Handover(
    user: User(
      name: 'Mohamed Abdalmohsin',
      profilePictureUrl:
          'https://i.picsum.photos/id/431/200/300.jpg?hmac=aUpIWBq8svIaK2ruTnNG-BZuvcDsK9Mr9PuJuYAYEQ0',
    ),
    handoverStatus: HandoverStatus.started,
  );

  start() {
    const radiusInMeters = 100.0;
    final s = _locationProvider.locationStream();

    print('start');
    _locationProvider.locationStream().listen((loc) {
      final startLoc = _locationProvider.startLocation;
      final endLoc = _locationProvider.endLocation;

      final distanceFromStart = Geolocator.distanceBetween(
          loc.latitude, loc.longitude, startLoc.latitude, startLoc.longitude);
      final distanceFromEnd = Geolocator.distanceBetween(
          loc.latitude, loc.longitude, endLoc.latitude, endLoc.longitude);

      var handoverStatus = HandoverStatus.onRoute;
      if (distanceFromStart < radiusInMeters) {
        handoverStatus = HandoverStatus.started;
      } else if (distanceFromEnd < radiusInMeters) {
        handoverStatus = HandoverStatus.delivered;
      }

      final mapInfo = MapInfo(
        currentLocation: loc,
        startGeoFence:
            CircularGeoFence(center: startLoc, radiusInMeters: radiusInMeters),
        endGeoFence:
            CircularGeoFence(center: endLoc, radiusInMeters: radiusInMeters),
      );
      print('emit LiveTrackingCurrentState');
      emit(LiveTrackingCurrentState(
          mapInfo: mapInfo,
          handover: _handover.copyWith(handoverStatus: handoverStatus)));
    });
  }

  @override
  void onChange(Change<LiveTrackingState> change) {
    super.onChange(change);
    // print('new state: ${change.nextState}');
  }
}
