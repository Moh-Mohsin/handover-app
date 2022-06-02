// TODO: can enhanced Enums be used?

enum HandoverStatus {
  onRoute,
  nearPickup,
  pickedUp,
  nearDelivery,
  delivered,
  finished,
}

extension HandoverStatusExtension on HandoverStatus {
  int get value {
    switch (this) {
      case HandoverStatus.onRoute:
        return 1;
      case HandoverStatus.nearPickup:
        return 2;
      case HandoverStatus.pickedUp:
        return 3;
      case HandoverStatus.nearDelivery:
        return 4;
      case HandoverStatus.delivered:
        return 5;
      case HandoverStatus.finished:
        return 6;
    }
  }
}
