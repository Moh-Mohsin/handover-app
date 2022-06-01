import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handover/data/model/map_info.dart';
import 'package:handover/live_tracking/cubit/live_tracking_cubit.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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

  static const _profileImageSize = 100.0;

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
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocBuilder<LiveTrackingCubit, LiveTrackingState>(
        builder: (context, state) {
          if (state is LiveTrackingCurrentState) {
            return SlidingUpPanel(
                header: SizedBox(
                  width: screenSize.width,
                  child: Center(
                    child: Container(
                      height: _profileImageSize,
                      width: _profileImageSize,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            state.handover.user.profilePictureUrl,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                panel: Padding(
                  padding: const EdgeInsets.only(top: _profileImageSize / 2),
                  child: Container(
                    child: Center(
                      child: Text(
                          '${state.handover.handoverStatus}\n ${state.handover.pickupTime}\n ${state.handover.deliveryTime}'),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
                boxShadow: const [],
                color: Colors.transparent,
                body: _mapWidget(state.mapInfo));
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
            mapInfo.pickupGeoFence.center.latitude,
            mapInfo.pickupGeoFence.center.longitude,
          ),
          zoom: 14.4746,
        ),
        circles: {
          ..._buildThreeCircles(
            tag: 'pickup',
            center: mapInfo.pickupGeoFence.center,
            l1RadiusMeters: 10,
            l1Color: Colors.blue[900]!,
            l2RadiusMeters: mapInfo.pickupGeoFence.reachedRadiusInMeters,
            l2Color: Colors.blue,
            l3RadiusMeters: mapInfo.pickupGeoFence.nearRadiusInMeters,
            l3Color: Colors.blue[300]!,
          ),
          ..._buildThreeCircles(
            tag: 'delivery',
            center: mapInfo.deliveryGeoFence.center,
            l1RadiusMeters: 10,
            l1Color: Colors.yellow[900]!,
            l2RadiusMeters: mapInfo.deliveryGeoFence.reachedRadiusInMeters,
            l2Color: Colors.yellow,
            l3RadiusMeters: mapInfo.deliveryGeoFence.nearRadiusInMeters,
            l3Color: Colors.yellow[300]!,
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  Set<Circle> _buildThreeCircles({
    required String tag,
    required LatLng center,
    required double l1RadiusMeters,
    required Color l1Color,
    required double l2RadiusMeters,
    required Color l2Color,
    required double l3RadiusMeters,
    required Color l3Color,
  }) {
    return {
      Circle(
        circleId: CircleId('$tag-near'),
        center: center,
        radius: l3RadiusMeters,
        fillColor: l3Color,
        strokeColor: l3Color,
      ),
      Circle(
        circleId: CircleId('$tag-reached'),
        center: center,
        radius: l2RadiusMeters,
        fillColor: l2Color,
        strokeColor: l2Color,
      ),
      Circle(
        circleId: CircleId('$tag-center'),
        center: center,
        radius: l1RadiusMeters,
        fillColor: l1Color,
        strokeColor: l1Color,
      ),
    };
  }
}
