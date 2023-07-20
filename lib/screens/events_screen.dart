import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:our_ummah/components/dropdown_filter_component.dart';
import 'package:our_ummah/components/events_calendar_component.dart';
import 'package:our_ummah/components/events_list_component.dart';
import 'package:our_ummah/constants/filters.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:provider/provider.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({
    super.key,
    required this.users,
    required this.businesses,
    required this.sortValue,
  });

  final List<AppUser> users;
  final List<Business> businesses;
  final String sortValue;

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  Audience? _audienceFilter;
  Price? _priceFilter;
  double? _distanceFilter;
  String? _categoryFilter;
  Position? _pos;

  Future<void> _determinePosition() async {
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _pos = pos;
    });
  }

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final eventsStream = FirebaseFirestore.instance
        .collection('Communities')
        .doc(Provider.of<Community>(context, listen: false).id)
        .collection('Posts')
        .where('type', isEqualTo: 'event')
        .withConverter(
          fromFirestore: postFromFirestore,
          toFirestore: postToFirestore,
        )
        .snapshots();
    return Column(
      children: [
        widget.sortValue == 'Calendar'
            ? Container()
            : Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...eventFilters.map((e) {
                        final filter = () {
                          switch (e.title) {
                            case 'Audience':
                              return _audienceFilter != null
                                  ? _audienceFilter!.name
                                  : null;
                            case 'Distance':
                              return _distanceFilter != null
                                  ? _distanceFilter!.toInt().toString()
                                  : null;
                            case 'Price':
                              return _priceFilter != null
                                  ? _priceFilter!.name
                                  : null;
                            case 'Category':
                              return _categoryFilter;
                          }
                        }();
                        return DropdownFilter(
                          filter: e,
                          value: filter,
                          onChanged: (value) {
                            switch (e.title) {
                              case 'Audience':
                                setState(() {
                                  _audienceFilter = value != null
                                      ? Audience.values.firstWhere(
                                          (audience) => audience.name == value,
                                        )
                                      : null;
                                });
                                break;
                              case 'Distance':
                                setState(() {
                                  _distanceFilter = double.tryParse(value!);
                                });
                                break;
                              case 'Price':
                                setState(() {
                                  _priceFilter = value != null
                                      ? Price.values.firstWhere(
                                          (price) => price.name == value,
                                        )
                                      : null;
                                });
                                break;
                              case 'Category':
                                setState(() {
                                  _categoryFilter = value;
                                });
                                break;
                            }
                          },
                        );
                      }).toList(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          child: IconButton.filledTonal(
                            onPressed: (_audienceFilter == null &&
                                    _priceFilter == null &&
                                    _distanceFilter == null &&
                                    _categoryFilter == null)
                                ? null
                                : () {
                                    setState(() {
                                      _audienceFilter = null;
                                      _priceFilter = null;
                                      _distanceFilter = null;
                                      _categoryFilter = null;
                                    });
                                  },
                            icon: const Icon(Icons.clear_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        StreamBuilder<QuerySnapshot<Post>>(
          stream: eventsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Failed to load posts');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            List<EventPost> posts = snapshot.data!.docs
                .map((postDoc) => postDoc.data())
                .toList()
                .cast<EventPost>();

            // sort posts by vote count (in ascending order)
            posts.sort((a, b) {
              int aVoteCount = a.upVotes.length - a.downVotes.length;
              int bVoteCount = b.upVotes.length - b.downVotes.length;

              return bVoteCount.compareTo(aVoteCount);
            });

            return widget.sortValue == 'List'
                ? EventsList(
                    posts: posts,
                    audienceFilter: _audienceFilter,
                    priceFilter: _priceFilter,
                    categoryFilter: _categoryFilter,
                    distanceFilter: _distanceFilter,
                    users: widget.users,
                    businesses: widget.businesses,
                    currPosition: _pos,
                  )
                : EventsCalendar(
                    posts: posts,
                    users: widget.users,
                    businesses: widget.businesses,
                    currPosition: _pos,
                  );
          },
        ),
      ],
    );
  }
}
