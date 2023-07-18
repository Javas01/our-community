import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:our_ummah/actions/show_popup_menu_action.dart';
import 'package:our_ummah/components/EventCard/expanded_event_card.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:our_ummah/components/EventCard/preview_event_card_component.dart';

class EventCardComponent extends StatefulWidget {
  const EventCardComponent({
    Key? key,
    required this.postCreator,
    required this.post,
    required this.users,
    required this.businesses,
    required this.distanceFromUser,
  }) : super(key: key);

  final EventPost post;
  final PostCreator postCreator;
  final List<AppUser> users;
  final List<Business> businesses;
  final double? distanceFromUser;

  @override
  State<EventCardComponent> createState() => _EventCardComponentState();
}

class _EventCardComponentState extends State<EventCardComponent> {
  final dataKey = GlobalKey();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  bool _isExpanded = false;
  Offset? _tapPosition;
  GlobalKey? _selectedPostKey;
  // Position? _userPosition;
  // Location? _businessLocation;

  void setExpanded(bool isExpanded) {
    setState(() {
      _isExpanded = isExpanded;
    });

    if (!widget.post.hasSeen.contains(userId)) {
      final hasSeen = widget.post.hasSeen;
      hasSeen.add(userId);
      FirebaseFirestore.instance
          .collection('Communities')
          .doc(Provider.of<Community>(context, listen: false).id)
          .collection('Posts')
          .doc(widget.post.id)
          .withConverter(
            fromFirestore: postFromFirestore,
            toFirestore: postToFirestore,
          )
          .update({'hasSeen': hasSeen});
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  // /// Determine the current position of the device.
  // ///
  // /// When the location services are not enabled or permissions
  // /// are denied the `Future` will return an error.
  // Future<void> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   final pos = await Geolocator.getCurrentPosition();
  //   debugPrint(pos.toString());
  //   setState(() {
  //     _userPosition = pos;
  //   });
  // }

  // Future<void> _getBusinessLocation(String address) async {
  //   if (address == '') return;
  //   if (address == 'online only') return;
  //   if (address == 'I can\'t see this part on my phone') return;
  //   try {
  //     List<Location> locations = await locationFromAddress(address);
  //     setState(() {
  //       _businessLocation = locations.first;
  //     });
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // @override
  // void initState() {
  //   _determinePosition();
  //   _getBusinessLocation(widget.post.location);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final currUser = widget.users.firstWhere((user) => user.id == userId);

    return SizedBox(
      key: dataKey,
      height: _isExpanded
          ? MediaQuery.of(context).size.height -
              (Scaffold.of(context).appBarMaxHeight! * 2)
          : null,
      child: _isExpanded
          ? ExpandedEventCard(
              users: widget.users,
              post: widget.post,
              setExpanded: setExpanded,
            )
          : GestureDetector(
              onLongPress: () async {
                setState(() {
                  _selectedPostKey = dataKey;
                });
                await showPopupMenu(
                  context,
                  widget.post,
                  _tapPosition!,
                  widget.postCreator,
                  widget.businesses,
                  currUser,
                );
                setState(() {
                  _selectedPostKey = null;
                });
              },
              onTapDown: _storePosition,
              onTap: () {
                setExpanded(true);
                Future.delayed(const Duration(milliseconds: 50), () {
                  Scrollable.ensureVisible(
                    dataKey.currentContext!,
                    alignment: 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                });
              },
              child: PreviewEventCard(
                itemKey: dataKey,
                post: widget.post,
                postCreator: widget.postCreator,
                isSelected: dataKey == _selectedPostKey ? true : false,
                isCreator: userId == widget.post.createdBy,
                distanceFromUser: widget.distanceFromUser,
                // distanceFromUser:
                //     _userPosition != null && _businessLocation != null
                //         ? (Geolocator.distanceBetween(
                //                   _userPosition!.latitude,
                //                   _userPosition!.longitude,
                //                   _businessLocation!.latitude,
                //                   _businessLocation!.longitude,
                //                 ) /
                //                 1609.344)
                //             .ceilToDouble()
                //         : null,
              ),
            ),
    );
  }
}
