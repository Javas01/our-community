import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/actions/open_map_action.dart';
import 'package:our_ummah/actions/show_popup_menu_action.dart';
import 'package:our_ummah/components/tag_filter_component.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/modals/business_rating_modal.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/review_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class BusinessesScreen extends StatefulWidget {
  const BusinessesScreen({
    super.key,
    required this.users,
    required this.community,
    required this.sortValue,
  });

  final List<AppUser> users;
  final Community community;
  final String sortValue;

  @override
  State<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends State<BusinessesScreen> {
  final dataKey = GlobalKey();
  bool isActive = false;
  String _selectedTag = '';
  late final Stream<QuerySnapshot<Business>> _businessesStream;
  Offset? _tapPosition;
  // ignore: unused_field
  GlobalKey? _selectedPostKey;
  String _searchTerm = '';
  final focusNode = FocusNode();
  Position? _pos;
  Map<String, Location> _businessLocations = {};

  @override
  void initState() {
    _determinePosition();
    _businessesStream = FirebaseFirestore.instance
        .collection('Communities')
        .doc(widget.community.id)
        .collection('Businesses')
        .withConverter(
          fromFirestore: businessFromFirestore,
          toFirestore: businessToFirestore,
        )
        .snapshots();
    super.initState();
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final pos = await Geolocator.getCurrentPosition();
    debugPrint(pos.toString());
    setState(() {
      _pos = pos;
    });
  }

  Future<void> getLocationFromAddress(String address) async {
    if (address == '') return;
    if (address == 'online only') return;
    List<Location> locations = await locationFromAddress(address);
    if (_businessLocations[address] != null) return;
    setState(() {
      _businessLocations = {
        ..._businessLocations,
        address: locations.first,
      };
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) setState(() => isActive = false);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: isActive ? MediaQuery.of(context).size.width : 150,
                  child: SearchBar(
                    hintText: 'Search',
                    trailing: const [Icon(Icons.search)],
                    shadowColor: MaterialStateProperty.all(Colors.white10),
                    elevation: MaterialStateProperty.all(16),
                    side: MaterialStateProperty.all(
                      BorderSide(color: Colors.grey[300]!),
                    ),
                    onTap: () => setState(() => isActive = !isActive),
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                      });
                    },
                    focusNode: focusNode,
                  ),
                ),
                ...businessOptionsList.map<Widget>(
                  (tag) => Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6.0, 0, 6.0),
                    child: TagFilter(
                      name: tag.keys.first,
                      color: tag.values.first,
                      selectedTag: _selectedTag,
                      selectTagFilter: selectTagFilter,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot<Business>>(
            stream: _businessesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Failed to load businesses');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              List<Business> businesses = snapshot.data!.docs
                  .map((businessDoc) => businessDoc.data())
                  .toList();

              // sort posts by selected sort value
              switch (widget.sortValue) {
                case 'Rating':
                  businesses.sort((a, b) => b.rating.compareTo(a.rating));
                  break;
                case 'Distance':
                  break;
                case 'Alphabetical':
                  businesses.sort((a, b) => a.title.compareTo(b.title));
                  break;
                default:
              }

              // filter posts by selected tag filter
              var filteredBusinesses = businesses.where((post) {
                if (_selectedTag.isEmpty) return true;

                return post.tags.contains(_selectedTag);
              }).toList();

              // filter posts by search term
              filteredBusinesses = filteredBusinesses.where((post) {
                if (_searchTerm.isEmpty) return true;

                return post.title.toLowerCase().contains(_searchTerm);
              }).toList();

              return Expanded(
                child: ListView(
                  children: [
                    ...filteredBusinesses.map((business) {
                      getLocationFromAddress(business.address);
                      return GestureDetector(
                        onLongPress: () async {
                          setState(() {
                            _selectedPostKey = dataKey;
                          });
                          await showPopupMenu(
                            context,
                            business,
                            _tapPosition!,
                            null,
                            businesses,
                          );
                          setState(() {
                            _selectedPostKey = null;
                          });
                        },
                        onTapDown: _storePosition,
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide()),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Image(
                                  image: NetworkImage(
                                    business.businessLogoUrl.isNotEmpty
                                        ? business.businessLogoUrl
                                        : 'https://via.placeholder.com/150',
                                  ),
                                  // height: 100,
                                  width: 100,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(business.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ...business.tags.map((tag) {
                                            return Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: businessOptionsList
                                                    .firstWhere((option) =>
                                                        option.keys.first ==
                                                        tag)
                                                    .values
                                                    .first,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(tag),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        business.tagline,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      // const Text('Open 24 hours'),
                                      // const SizedBox(height: 5),
                                      Text(
                                        '${(Geolocator.distanceBetween(
                                              _pos?.latitude ?? 0,
                                              _pos?.longitude ?? 0,
                                              _businessLocations[
                                                          business.address]
                                                      ?.latitude ??
                                                  0,
                                              _businessLocations[
                                                          business.address]
                                                      ?.longitude ??
                                                  0,
                                            ) / 1609.344).ceilToDouble()} miles - ${business.address}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      StreamBuilder<QuerySnapshot<Review>>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Communities')
                                              .doc(widget.community.id)
                                              .collection('Businesses')
                                              .doc(business.id)
                                              .collection('Reviews')
                                              .withConverter(
                                                fromFirestore:
                                                    reviewFromFirestore,
                                                toFirestore: reviewToFirestore,
                                              )
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Text(
                                                'Failed to load reviews',
                                              );
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            }
                                            List<Review> reviews = snapshot
                                                .data!.docs
                                                .map((reviewDoc) =>
                                                    reviewDoc.data())
                                                .toList();

                                            Review? userReview = reviews
                                                    .map((e) => e.createdBy)
                                                    .contains(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                    )
                                                ? reviews.firstWhere(
                                                    (review) =>
                                                        review.createdBy ==
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                  )
                                                : null;
                                            if (reviews.isEmpty) {
                                              return GestureDetector(
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      BusinessRatingModal(
                                                    business: business,
                                                    community: widget.community,
                                                    user:
                                                        widget.users.firstWhere(
                                                      (user) =>
                                                          user.id ==
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                    ),
                                                    review: null,
                                                  ),
                                                ),
                                                child: const Text('No reviews'),
                                              );
                                            } else {
                                              return GestureDetector(
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      BusinessRatingModal(
                                                    business: business,
                                                    community: widget.community,
                                                    user:
                                                        widget.users.firstWhere(
                                                      (user) =>
                                                          user.id ==
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                    ),
                                                    review: userReview,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ...List.generate(5,
                                                        (index) {
                                                      return Icon(
                                                        index < business.rating
                                                            ? Icons
                                                                .thumb_up_sharp
                                                            : Icons
                                                                .thumb_up_alt_outlined,
                                                        color:
                                                            userReview != null
                                                                ? Colors.blue
                                                                : Colors.grey,
                                                      );
                                                    }),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      '(${reviews.length})',
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          }),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final call = Uri.parse(
                                            'tel:+1${business.phoneNumber}');
                                        if (await canLaunchUrl(call)) {
                                          launchUrl(call);
                                        } else {
                                          throw 'Could not launch $call';
                                        }
                                      },
                                      icon: const Icon(Icons.phone),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        openMap(business.address);
                                      },
                                      icon: const Icon(Icons.directions),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final url = Uri.parse(
                                          'https://www.google.com/search?q=${business.title}',
                                        );
                                        if (await canLaunchUrl(url)) {
                                          launchUrl(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      icon: const Icon(Icons.web_asset),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }),
      ],
    );
  }

  void selectTagFilter(String tagName) {
    setState(() {
      _selectedTag = _selectedTag == tagName ? '' : tagName;
    });
  }
}
