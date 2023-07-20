import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

double getDistanceFromPost(
  String address,
  Map<String, Location> locations,
  Position? currPosition,
) =>
    (Geolocator.distanceBetween(
              currPosition?.latitude ?? 0,
              currPosition?.longitude ?? 0,
              locations[address]?.latitude ?? 0,
              locations[address]?.longitude ?? 0,
            ) /
            1609.344)
        .ceilToDouble();
