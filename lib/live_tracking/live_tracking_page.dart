import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  StreamSubscription<LiveTrackingState>? _stateSub;

  static const _profileImageSize = 100.0;

  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<LiveTrackingCubit>(context);
    bloc.start();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    BlocProvider.of<LiveTrackingCubit>(context).onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const horizontalPaddingValue = 45.0;
    const padding = EdgeInsets.symmetric(horizontal: horizontalPaddingValue);

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
                maxHeight: max(screenSize.height * 0.66, 400),
                parallaxEnabled: true,
                parallaxOffset: 0.7,
                header: _buildUserWidget(screenSize, state, textStyle),
                panel: Padding(
                  padding: const EdgeInsets.only(top: _profileImageSize / 2),
                  child: Container(
                    padding:
                        const EdgeInsets.only(top: _profileImageSize * 1.2),
                    child: Center(
                      child: Builder(builder: (context) {
                        if (state.handover.handoverStatus ==
                            HandoverStatus.finished) {
                          // this shows up when the handover/delivery is finished
                          return _buildSummeryWidget(
                              screenSize, padding, textStyle, state);
                        } else {
                          // a ccustom stepper widget that highlights finished steps
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 30),
                            child: CustomStepper(
                                steps: state.stepsData.titles
                                    .map((title) => CustomStep(title))
                                    .toList(),
                                currentStepIndex:
                                    state.stepsData.currentStepIndex,
                                textStyle: textStyle),
                          );
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

  /// user profile picture and name
  SizedBox _buildUserWidget(
      Size screenSize, LiveTrackingCurrentState state, TextStyle textStyle) {
    return SizedBox(
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
    );
  }

  /// shows rating and handover summery
  Column _buildSummeryWidget(Size screenSize, EdgeInsets padding,
      TextStyle textStyle, LiveTrackingCurrentState state) {
    final formatter = DateFormat('hh:mm');
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
            onRatingUpdate: (rating) {},
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
                    ? formatter.format(state.handover.pickupTime!)
                    : 'unknown',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
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
                    ? formatter.format(state.handover.deliveryTime!)
                    : 'unknown',
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
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
              InkWell(
                onTap: () {
                  Fluttertoast.showToast(msg: 'Submit!');
                },
                child: Container(
                  height: 40,
                  width: min(screenSize.width * .55, 250),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: max(screenSize.height / 20, 30),
        ),
      ],
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
            l3Color: Colors.cyan[300]!.withAlpha(100),
          ),
          ..._buildThreeCircles(
            tag: 'delivery',
            center: mapInfo.deliveryGeoFence.center,
            l1RadiusMeters: 10,
            l1Color: Colors.blue[900]!,
            l2RadiusMeters: mapInfo.deliveryGeoFence.reachedRadiusInMeters,
            l2Color: Colors.blue,
            l3RadiusMeters: mapInfo.deliveryGeoFence.nearRadiusInMeters,
            l3Color: Colors.blue[300]!.withAlpha(100),
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
          strokeWidth: 0),
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
