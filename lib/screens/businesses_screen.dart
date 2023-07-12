import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/components/tag_filter_component.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:provider/provider.dart';

class BusinessesScreen extends StatefulWidget {
  const BusinessesScreen({
    super.key,
    required this.users,
    required this.community,
  });

  final List<AppUser> users;
  final Community community;

  @override
  State<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends State<BusinessesScreen> {
  bool isActive = false;
  String _selectedTag = '';
  late final Future<QuerySnapshot<Business>> _businessesFuture;

  @override
  void initState() {
    _businessesFuture = FirebaseFirestore.instance
        .collection('Communities')
        .doc(widget.community.id)
        .collection('Businesses')
        .withConverter(
          fromFirestore: businessFromFirestore,
          toFirestore: businessToFirestore,
        )
        .get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(_businessesFuture.toString());
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
                    trailing: [const Icon(Icons.search)],
                    shadowColor: MaterialStateProperty.all(Colors.white10),
                    elevation: MaterialStateProperty.all(16),
                    side: MaterialStateProperty.all(
                      BorderSide(color: Colors.grey[300]!),
                    ),
                    onTap: () => setState(() => isActive = !isActive),
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
        FutureBuilder<QuerySnapshot<Business>>(
            future: _businessesFuture,
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

              // filter posts by selected tag filter
              var filteredBusinesses = businesses.where((post) {
                if (_selectedTag.isEmpty) return true;

                return post.tags.contains(_selectedTag);
              }).toList();

              // sort posts by rating (in ascending order)
              filteredBusinesses.sort((a, b) => b.rating.compareTo(a.rating));

              return Expanded(
                child: ListView(
                  children: [
                    ...filteredBusinesses.map((business) {
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide()),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Image(
                                image: NetworkImage(
                                    'https://www.nicepng.com/png/detail/226-2262947_dunkin-donuts-dunkin-donuts-logo-transparent.png'),
                                // height: 100,
                                width: 100,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(business.title),
                                    Row(
                                      // mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ...business.tags.map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: businessOptionsList
                                                  .firstWhere((option) =>
                                                      option.keys.first == tag)
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
                                    Text(business.tagline),
                                    const Text('Open 24 hours'),
                                    Text(
                                        '1.7 mi - ${business.address}'), // get distance by location
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ...List.generate(5, (index) {
                                          return Icon(
                                            index < business.rating
                                                ? Icons.thumb_up_sharp
                                                : Icons.thumb_up_alt_outlined,
                                          );
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // const Column(
                              //   children: [Icon(Icons.phone), Icon(Icons.web_asset)],
                              // )
                            ],
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
