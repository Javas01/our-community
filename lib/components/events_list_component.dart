import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:our_ummah/actions/get_distance_from_post.dart';
import 'package:our_ummah/actions/get_location_from_address.dart';
import 'package:our_ummah/components/EventCard/event_card_component.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/models/user_model.dart';

class EventsList extends StatefulWidget {
  const EventsList({
    super.key,
    required this.posts,
    required this.users,
    this.audienceFilter,
    this.priceFilter,
    this.categoryFilter,
    this.distanceFilter,
    required this.businesses,
    required this.currPosition,
  });

  final List<EventPost> posts;
  final Audience? audienceFilter;
  final Price? priceFilter;
  final String? categoryFilter;
  final double? distanceFilter;
  final List<AppUser> users;
  final List<Business> businesses;
  final Position? currPosition;

  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  Map<String, Location> _businessLocations = {};

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          ...widget.posts
              .where(
                (post) => widget.audienceFilter != null
                    ? post.audience == widget.audienceFilter
                    : true,
              )
              .where(
                (post) => widget.priceFilter != null
                    ? post.price == widget.priceFilter
                    : true,
              )
              .where(
                (post) => post.endDate.isAfter(DateTime.now()),
              )
              .where(
                (post) => widget.categoryFilter != null
                    ? post.tags.contains(widget.categoryFilter)
                    : true,
              )
              .where(
                (post) => widget.distanceFilter != null
                    ? getDistanceFromPost(
                          post.location,
                          _businessLocations,
                          widget.currPosition,
                        ) <=
                        widget.distanceFilter!
                    : true,
              )
              .map<Widget>((post) {
            getLocationFromAddress(
              _businessLocations,
              post.location,
              (locations) {
                setState(() {
                  _businessLocations = locations;
                });
              },
            );

            final PostCreator postCreator = post.isAd
                ? () {
                    final business = widget.businesses.firstWhere(
                      (e) => e.id == post.createdBy,
                    );
                    return PostCreator(
                      name: business.title,
                      picUrl: business.businessLogoUrl,
                      id: business.id,
                    );
                  }()
                : () {
                    final user = widget.users.firstWhere(
                      (e) => e.id == post.createdBy,
                    );
                    return PostCreator(
                      name: '${user.firstName} ${user.lastName}',
                      picUrl: user.profilePicUrl,
                      id: user.id,
                    );
                  }();

            return EventCardComponent(
              postCreator: postCreator,
              post: post,
              users: widget.users,
              businesses: widget.businesses,
              distanceFromUser: getDistanceFromPost(
                post.location,
                _businessLocations,
                widget.currPosition,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
