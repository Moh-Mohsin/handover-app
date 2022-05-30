import 'dart:convert';

import 'package:handover/data/model/handover_status.dart';

import 'user.dart';

class Handover {
  final User user;
  final HandoverStatus handoverStatus;

  Handover({
    required this.user,
    required this.handoverStatus,
  });

  Handover copyWith({
    User? user,
    HandoverStatus? handoverStatus,
  }) {
    return Handover(
      user: user ?? this.user,
      handoverStatus: handoverStatus ?? this.handoverStatus,
    );
  }

  @override
  String toString() => 'Handover(user: $user, handoverStatus: $handoverStatus)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Handover &&
      other.user == user &&
      other.handoverStatus == handoverStatus;
  }

  @override
  int get hashCode => user.hashCode ^ handoverStatus.hashCode;
}
