import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handover/data/model/map_info.dart';
import 'package:handover/live_tracking/cubit/live_tracking_cubit.dart';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({Key? key}) : super(key: key);

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  StreamSubscription<LiveTrackingState>? _stateSub;

  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<LiveTrackingCubit>(context);
    bloc.start();
    _controller.future.then((controller) {
      _stateSub = bloc.stream.listen((event) {
        if (mounted) {
          // _controller.
        }
      });
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LiveTrackingCubit, LiveTrackingState>(
        builder: (context, state) {
          if (state is LiveTrackingCurrentState) {
            return _mapWidget(state.mapInfo);
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _mapWidget(MapInfo mapInfo) {
    return Animarker(
      mapId: _controller.future.then<int>((value) => value.mapId),
      duration: const Duration(milliseconds: 800),
      useRotation: false,
      markers: {
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: mapInfo.currentLocation,
        )
      },
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            mapInfo.startGeoFence.center.latitude,
            mapInfo.startGeoFence.center.longitude,
          ),
          zoom: 14.4746,
        ),
        circles: {
          Circle(
            circleId: const CircleId('startGeoFence'),
            center: mapInfo.startGeoFence.center,
            radius: mapInfo.startGeoFence.radiusInMeters,
            fillColor: Colors.blue[200]!,
            strokeColor: Colors.blue[200]!,
          ),
          Circle(
            circleId: const CircleId('startDot'),
            center: mapInfo.startGeoFence.center,
            radius: 5,
            fillColor: Colors.blue,
            strokeColor: Colors.blue,
          ),
          Circle(
            circleId: const CircleId('endGeoFence'),
            center: mapInfo.endGeoFence.center,
            radius: mapInfo.endGeoFence.radiusInMeters,
            fillColor: Colors.yellow[200]!,
            strokeColor: Colors.yellow[200]!,
          ),
          Circle(
            circleId: const CircleId('endDot'),
            center: mapInfo.endGeoFence.center,
            radius: 5,
            fillColor: Colors.yellow[900]!,
            strokeColor: Colors.yellow[900]!,
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
