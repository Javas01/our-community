import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/actions/open_map_action.dart';
import 'package:our_ummah/actions/show_popup_menu_action.dart';
import 'package:our_ummah/components/static_tag_component.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/modals/business_rating_modal.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/review_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessListing extends StatefulWidget {
  const BusinessListing({
    super.key,
    required this.business,
    required this.businesses,
    required this.users,
    required this.community,
    required this.distance,
  });

  final Business business;
  final List<Business> businesses;
  final List<AppUser> users;
  final Community community;
  final double distance;

  @override
  State<BusinessListing> createState() => _BusinessListingState();
}

class _BusinessListingState extends State<BusinessListing> {
  final dataKey = GlobalKey();
  bool isActive = false;
  Offset? _tapPosition;
  GlobalKey? _selectedPostKey;
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        setState(() {
          _selectedPostKey = dataKey;
        });
        await showPopupMenu(
          context,
          widget.business,
          _tapPosition!,
          null,
          widget.businesses,
        );
        setState(() {
          _selectedPostKey = null;
        });
      },
      onTapDown: _storePosition,
      child: Card(
        elevation: dataKey == _selectedPostKey ? 20 : 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image(
                  image: NetworkImage(
                    widget.business.businessLogoUrl.isNotEmpty
                        ? widget.business.businessLogoUrl
                        : 'https://via.placeholder.com/150',
                  ),
                  width: 125,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    children: [
                      Text(
                        widget.business.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ...widget.business.tags.map((tag) {
                            return StaticTag(
                              title: tag,
                              color: businessOptionsList
                                  .firstWhere(
                                      (option) => option.keys.first == tag)
                                  .values
                                  .first,
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.business.tagline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${widget.distance} mi - ${widget.business.address}',
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
                              .doc(widget.business.id)
                              .collection('Reviews')
                              .withConverter(
                                fromFirestore: reviewFromFirestore,
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
                            List<Review> reviews = snapshot.data!.docs
                                .map((reviewDoc) => reviewDoc.data())
                                .toList();

                            Review? userReview = reviews
                                    .map((e) => e.createdBy)
                                    .contains(
                                      FirebaseAuth.instance.currentUser!.uid,
                                    )
                                ? reviews.firstWhere(
                                    (review) =>
                                        review.createdBy ==
                                        FirebaseAuth.instance.currentUser!.uid,
                                  )
                                : null;
                            if (reviews.isEmpty) {
                              return GestureDetector(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (context) => BusinessRatingModal(
                                    business: widget.business,
                                    community: widget.community,
                                    user: widget.users.firstWhere(
                                      (user) =>
                                          user.id ==
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
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
                                  builder: (context) => BusinessRatingModal(
                                    business: widget.business,
                                    community: widget.community,
                                    user: widget.users.firstWhere(
                                      (user) =>
                                          user.id ==
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                    ),
                                    review: userReview,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...List.generate(5, (index) {
                                      return Icon(
                                        index < widget.business.rating
                                            ? Icons.thumb_up_sharp
                                            : Icons.thumb_up_alt_outlined,
                                        color: userReview != null
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
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () async {
                      final call =
                          Uri.parse('tel:+1${widget.business.phoneNumber}');
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
                      openMap(widget.business.address);
                    },
                    icon: const Icon(Icons.directions),
                  ),
                  IconButton(
                    onPressed: () async {
                      final url = Uri.parse(
                        'https://www.google.com/search?q=${widget.business.title}',
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
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}
