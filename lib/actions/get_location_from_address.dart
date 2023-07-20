import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';

void getLocationFromAddress(
  Map<String, Location> locationsMap,
  String address,
  Function(Map<String, Location>) setState,
) async {
  if (address == '') return;

  try {
    if (locationsMap[address] != null) return;
    List<Location> locations = await locationFromAddress(address);

    setState({
      ...locationsMap,
      address: locations.first,
    });
  } catch (e) {
    debugPrint(e.toString());
  }
}
