import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:our_ummah/components/EventCard/event_card_component.dart';
import 'package:our_ummah/components/ImageCard/image_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/components/TextCard/text_card_component.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/components/tag_filter_component.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:provider/provider.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({
    Key? key,
    required this.sortValue,
    required this.users,
    required this.businesses,
  }) : super(key: key);
  final String sortValue;
  final List<AppUser> users;
  final List<Business> businesses;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final currUserId = FirebaseAuth.instance.currentUser!.uid;
  String _selectedTag = '';
  Position? _pos;
  Map<String, Location> _businessLocations = {};

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

  @override
  void initState() {
    _determinePosition();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final postsStream = FirebaseFirestore.instance
        .collection('Communities')
        .doc(Provider.of<Community>(context, listen: false).id)
        .collection('Posts')
        .withConverter(
          fromFirestore: postFromFirestore,
          toFirestore: postToFirestore,
        )
        .snapshots();
    final currUser = widget.users.firstWhere((user) => user.id == currUserId);
    return StreamBuilder<QuerySnapshot<Post>>(
      stream: postsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Failed to load posts');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        List<Post> posts =
            snapshot.data!.docs.map((postDoc) => postDoc.data()).toList();

        // filter posts by blockedUsers
        final notBlockedPosts = posts
            .where((post) => !currUser.blockedUsers.contains(post.createdBy));

        // filter posts by selected tag filter
        var filteredPosts = notBlockedPosts.where((post) {
          if (_selectedTag.isEmpty) return true;

          return post.tags.contains(_selectedTag);
        }).toList();

        // filter posts by end date
        filteredPosts = filteredPosts.where((post) {
          if (post.type != PostType.event) return true;

          final eventPost = post as EventPost;
          final eventEndDate = eventPost.endDate;

          return eventEndDate.isAfter(DateTime.now());
        }).toList();

        // filter out posts older than 30 days
        filteredPosts = filteredPosts.where((post) {
          final postDate = DateTime.fromMicrosecondsSinceEpoch(
              post.timestamp.microsecondsSinceEpoch);
          final thirtyDaysAgo =
              DateTime.now().subtract(const Duration(days: 30));

          return postDate.isAfter(thirtyDaysAgo);
        }).toList();

        // sort posts by vote count (in ascending order)
        filteredPosts.sort((a, b) {
          if (widget.sortValue == 'Upvotes') {
            int aVoteCount = a.upVotes.length - a.downVotes.length;
            int bVoteCount = b.upVotes.length - b.downVotes.length;

            return aVoteCount.compareTo(bVoteCount);
          } else {
            return a.timestamp.compareTo(b.timestamp);
          }
        });

        return ListView(children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 35,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: (Provider.of<Community>(context, listen: false).id !=
                            'Lwdm-2023'
                        ? tagOptionsList
                        : conferenceTagOptionsList)
                    .map<Widget>(
                      (tag) => TagFilter(
                        name: tag.keys.first,
                        color: tag.values.first,
                        selectedTag: _selectedTag,
                        selectTagFilter: selectTagFilter,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          ...filteredPosts.reversed.map((post) {
            if (post is EventPost) getLocationFromAddress(post.location);

            // get post creator user object
            final PostCreator postCreator = post.isAd
                ? () {
                    final business = widget.businesses
                        .firstWhere((e) => e.id == post.createdBy);
                    return PostCreator(
                      name: business.title,
                      picUrl: business.businessLogoUrl,
                      id: business.id,
                    );
                  }()
                : () {
                    final user =
                        widget.users.firstWhere((e) => e.id == post.createdBy);
                    return PostCreator(
                      name: '${user.firstName} ${user.lastName}',
                      picUrl: user.profilePicUrl,
                      id: user.id,
                    );
                  }();

            switch (post.type) {
              case PostType.text:
                return TextCardComponent(
                  users: widget.users,
                  post: post as TextPost,
                  postCreator: postCreator,
                  businesses: widget.businesses,
                );
              case PostType.image:
                return ImageCardComponent(
                  users: widget.users,
                  post: post as ImagePost,
                  postCreator: postCreator,
                  businesses: widget.businesses,
                );
              case PostType.event:
                return EventCardComponent(
                  users: widget.users,
                  post: post as EventPost,
                  postCreator: postCreator,
                  businesses: widget.businesses,
                  distanceFromUser: getDistanceFromPost(post),
                );
            }
          }).toList()
        ]);
      },
    );
  }

  void selectTagFilter(String tagName) {
    setState(() {
      _selectedTag = _selectedTag == tagName ? '' : tagName;
    });
  }

  double getDistanceFromPost(EventPost event) => (Geolocator.distanceBetween(
            _pos?.latitude ?? 0,
            _pos?.longitude ?? 0,
            _businessLocations[event.location]?.latitude ?? 0,
            _businessLocations[event.location]?.longitude ?? 0,
          ) /
          1609.344)
      .ceilToDouble();
}
