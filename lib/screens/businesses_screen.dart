import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/actions/get_distance_from_post.dart';
import 'package:our_ummah/actions/get_location_from_address.dart';
import 'package:our_ummah/components/business_listing.dart';
import 'package:our_ummah/components/tag_filter_component.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/user_model.dart';
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
  String _searchTerm = '';
  final focusNode = FocusNode();
  Position? _pos;
  Map<String, Location> _businessLocations = {};

  Future<void> _determinePosition() async {
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _pos = pos;
    });
  }

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
                      selectTagFilter: (tagName) {
                        setState(() {
                          _selectedTag = _selectedTag == tagName ? '' : tagName;
                        });
                      },
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
                  businesses.sort((a, b) {
                    if (_pos == null) return 0;
                    if (_businessLocations[a.address] == null) return 0;
                    if (_businessLocations[b.address] == null) return 0;

                    return getDistanceFromPost(
                      a.address,
                      _businessLocations,
                      _pos,
                    ).compareTo(
                      getDistanceFromPost(
                        b.address,
                        _businessLocations,
                        _pos,
                      ),
                    );
                  });
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
                      getLocationFromAddress(
                        _businessLocations,
                        business.address,
                        (locations) {
                          setState(() {
                            _businessLocations = locations;
                          });
                        },
                      );
                      return BusinessListing(
                        business: business,
                        businesses: businesses,
                        users: widget.users,
                        community: widget.community,
                        distance: getDistanceFromPost(
                          business.address,
                          _businessLocations,
                          _pos,
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
}
