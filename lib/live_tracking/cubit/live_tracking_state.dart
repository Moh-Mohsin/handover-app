part of 'live_tracking_cubit.dart';

@immutable
abstract class LiveTrackingState {}

class LiveTrackingInitial extends LiveTrackingState {}

class LiveTrackingCurrentState extends LiveTrackingState {
  final MapInfo mapInfo;
  final Handover handover;

  LiveTrackingCurrentState(
      {required this.mapInfo, required this.handover});
      
  LiveTrackingCurrentState copyWith({
    MapInfo? mapInfo,
    Handover? handover,
  }) {
    return LiveTrackingCurrentState(
      mapInfo: mapInfo ?? this.mapInfo,
      handover: handover ?? this.handover,
    );
  }
}

