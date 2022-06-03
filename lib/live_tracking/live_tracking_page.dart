import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handover/data/model/handover_status.dart';
import 'package:handover/data/model/map_info.dart';
import 'package:handover/live_tracking/cubit/live_tracking_cubit.dart';
import 'package:handover/live_tracking/widget/custom_stepper.dart';
import 'package:handover/tools/notification_helper.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:intl/intl.dart';

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
    const horizontalPaddingValue = 45.0;
    const padding = EdgeInsets.symmetric(horizontal: horizontalPaddingValue);

    final formatter = DateFormat('hh:mm');
    final textStyle = Theme.of(context).textTheme.bodyText1!;

    return Scaffold(
      body: BlocConsumer<LiveTrackingCubit, LiveTrackingState>(
        listenWhen: (previous, current) {
          return current is LiveTrackingCurrentState &&
              (previous is LiveTrackingInitial ||
                  (previous is LiveTrackingCurrentState &&
                      current.handover.handoverStatus !=
                          previous.handover.handoverStatus));
        },
        listener: (context, state) {
          _showNotification(
              (state as LiveTrackingCurrentState).handover.handoverStatus);
        },
        builder: (context, state) {
          if (state is LiveTrackingCurrentState) {
            return SlidingUpPanel(
                minHeight: screenSize.height / 3,
                parallaxEnabled: true,
                parallaxOffset: 0.7,
                header: SizedBox(
                  width: screenSize.width,
                  child: Center(
                    child: Column(
                      children: [
                        Container(
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
                        const SizedBox(height: 16),
                        Text(
                          state.handover.user.name,
                          style: textStyle,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                panel: Padding(
                  padding: const EdgeInsets.only(top: _profileImageSize / 2),
                  child: Container(
                    padding:
                        const EdgeInsets.only(top: _profileImageSize * 1.25),
                    child: Center(
                      child: Builder(builder: (context) {
                        if (state.handover.handoverStatus ==
                            HandoverStatus.finished) {
                          return Column(
                            children: [
                              Container(
                                width: screenSize.width,
                                padding: padding,
                                child: RatingBar.builder(
                                  initialRating: 0,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.blue,
                                  ),
                                  unratedColor: Colors.white,
                                  wrapAlignment: WrapAlignment.spaceBetween,
                                  glow: false,
                                  onRatingUpdate: (rating) {
                                    print(rating);
                                  },
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: padding,
                                child: Row(
                                  children: [
                                    Text(
                                      'Pickup Time',
                                      style: textStyle,
                                    ),
                                    const Spacer(),
                                    Text(
                                      state.handover.pickupTime != null
                                          ? formatter.format(
                                              state.handover.pickupTime!)
                                          : 'unknown',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: padding,
                                child: Row(
                                  children: [
                                    Text(
                                      'Delivery Time',
                                      style: textStyle,
                                    ),
                                    const Spacer(),
                                    Text(
                                      state.handover.deliveryTime != null
                                          ? formatter.format(
                                              state.handover.deliveryTime!)
                                          : 'unknown',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              Container(
                                padding: padding,
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Total',
                                  style: textStyle,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Container(
                                padding: padding.copyWith(right: 0),
                                child: Row(
                                  children: [
                                    Text(
                                      '\$30.00',
                                      style: textStyle.copyWith(fontSize: 20),
                                    ),
                                    const Spacer(),
                                    Container(
                                      height: 40,
                                      width: screenSize.width * .55,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Submit',
                                            style: textStyle,
                                          ),
                                          const SizedBox(width: 40),
                                          const Icon(Icons.arrow_right_alt),
                                          const SizedBox(width: 20),
                                        ],
                                      ),
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            bottomLeft: Radius.circular(30),
                                          )),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: screenSize.height / 20,
                              ),
                            ],
                          );
                        } else {
                          return CustomStepper(steps: [
                            CustomStep('this is a step'),
                            CustomStep('this is a step'),
                            CustomStep('this is a step'),
                            CustomStep('this is a step'),
                          ], currentStepIndex: 2);
                        }
                      }),
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xfffbaf03),
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
            l1Color: Colors.cyan[900]!,
            l2RadiusMeters: mapInfo.pickupGeoFence.reachedRadiusInMeters,
            l2Color: Colors.cyan,
            l3RadiusMeters: mapInfo.pickupGeoFence.nearRadiusInMeters,
            l3Color: Colors.cyan[300]!,
          ),
          ..._buildThreeCircles(
            tag: 'delivery',
            center: mapInfo.deliveryGeoFence.center,
            l1RadiusMeters: 10,
            l1Color: Colors.blue[900]!,
            l2RadiusMeters: mapInfo.deliveryGeoFence.reachedRadiusInMeters,
            l2Color: Colors.blue,
            l3RadiusMeters: mapInfo.deliveryGeoFence.nearRadiusInMeters,
            l3Color: Colors.blue[300]!,
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

  void _showNotification(HandoverStatus handoverStatus) {
    NotificationHelper().showNotification(
        'Delivery update', 'new status: ${handoverStatus.name}');
  }
}
