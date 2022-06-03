part of 'live_tracking_cubit.dart';

@immutable
abstract class LiveTrackingState {}

class LiveTrackingInitial extends LiveTrackingState {}

class LiveTrackingCurrentState extends LiveTrackingState {
  final MapInfo mapInfo;
  final Handover handover;
  final StepsData stepsData;

  LiveTrackingCurrentState({required this.mapInfo, required this.handover, required this.stepsData});

  LiveTrackingCurrentState copyWith({
    MapInfo? mapInfo,
    Handover? handover,
    StepsData? stepsData,
  }) {
    return LiveTrackingCurrentState(
      mapInfo: mapInfo ?? this.mapInfo,
      handover: handover ?? this.handover,
      stepsData: stepsData ?? this.stepsData,
    );
  }
}
