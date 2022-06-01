import 'dart:convert';

import 'package:handover/data/model/handover_status.dart';

import 'user.dart';

class Handover {
  final User user;
  final HandoverStatus handoverStatus;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;

  Handover({
    required this.user,
    required this.handoverStatus,
    this.pickupTime,
    this.deliveryTime,
  });

  Handover copyWith({
    User? user,
    HandoverStatus? handoverStatus,
    DateTime? pickupTime,
    DateTime? deliveryTime,
  }) {
    return Handover(
      user: user ?? this.user,
      handoverStatus: handoverStatus ?? this.handoverStatus,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }
}
