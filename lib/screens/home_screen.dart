import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/modals/create_business_modal.dart';
import 'package:our_ummah/modals/create_event_modal.dart';
import 'package:our_ummah/modals/create_post_modal.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/screens/businesses_screen.dart';
import 'package:our_ummah/screens/events_screen.dart';
import 'package:our_ummah/screens/settings_screen.dart';
import 'package:our_ummah/screens/list_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _usersStream = FirebaseFirestore.instance
      .collection('Users')
      .withConverter(
        fromFirestore: userFromFirestore,
        toFirestore: userToFirestore,
      )
      .snapshots();
  final _getCommunities = FirebaseFirestore.instance
      .collection('Communities')
      .withConverter(
          fromFirestore: communityFromFirestore,
          toFirestore: communityToFirestore)
      .get();

  TextEditingController communityController = TextEditingController();

  int currentIndex = 0;
  String _listSortValue = 'Recent';
  String _eventsSortValue = 'Calendar';
  String _businessSortValue = 'Rating';
  late List screens;
  Community? selectedCommunity;
  String? _string;

  void loadCommunity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? community = prefs.getString('community');
    String? listSort = prefs.getString('listSortValue');
    String? eventsSort = prefs.getString('eventsSortValue');
    String? businessesSort = prefs.getString('businessesSortValue');
    setState(() {
      _string = community;
      _listSortValue = listSort ?? 'Recent';
      _eventsSortValue = eventsSort ?? 'Calendar';
      _businessSortValue = businessesSort ?? 'Rating';
    });
  }

  Widget getModal(int index, List<AppUser> users, List<Business> businesses) {
    switch (index) {
      case 0:
        return CreatePostModal(users: users, businesses: businesses);
      case 1:
        return CreateEventModal(users: users, businesses: businesses);
      case 3:
        return CreateBusinessModal(users: users);
      default:
        return CreatePostModal(users: users, businesses: businesses);
    }
  }

  void setCommunity() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('community', selectedCommunity!.name);
  }

  void setListSortValue(String sort) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('listSortValue', sort);

    setState(() {
      _listSortValue = sort;
    });
  }

  void setEventsSortValue(String sort) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('eventsSortValue', sort);

    setState(() {
      _eventsSortValue = sort;
    });
  }

  void setBusinessesSortValue(String sort) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('businessesSortValue', sort);

    setState(() {
      _businessSortValue = sort;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCommunity();
  }

  @override
  Widget build(BuildContext context) {
    String sortValue = () {
      switch (currentIndex) {
        case 0:
          return _listSortValue;
        case 1:
          return _eventsSortValue;
        case 2:
          return _businessSortValue;
        default:
          return _listSortValue;
      }
    }();
    return FutureBuilder<QuerySnapshot<Community>>(
      future: _getCommunities,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final communities =
              snapshot.data!.docs.map((doc) => doc.data()).toList();

          return StreamBuilder<QuerySnapshot<AppUser>>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final users = snapshot.data!.docs
                    .map((userDoc) => userDoc.data())
                    .toList();
                final currUser = users.firstWhere((user) =>
                    user.id == FirebaseAuth.instance.currentUser!.uid);
                final userCommunities = communities
                    .where((item) =>
                        currUser.communityCodes.contains(item.id.toLowerCase()))
                    .toList();

                selectedCommunity = selectedCommunity ??
                    userCommunities.firstWhere(
                      (element) => element.name == _string,
                      orElse: () => userCommunities.first,
                    );

                return FutureBuilder<QuerySnapshot<Business>>(
                    future: FirebaseFirestore.instance
                        .collection('Communities')
                        .doc(selectedCommunity!.id)
                        .collection('Businesses')
                        .withConverter(
                          fromFirestore: businessFromFirestore,
                          toFirestore: businessToFirestore,
                        )
                        .get(),
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

                      screens = [
                        ListScreen(
                          sortValue: _listSortValue,
                          users: users,
                          businesses: businesses,
                        ),
                        EventScreen(
                          sortValue: _eventsSortValue,
                          users: users,
                          businesses: businesses,
                        ),
                        // const Scaffold(),
                        BusinessesScreen(
                          sortValue: _businessSortValue,
                          users: users,
                          community: selectedCommunity!,
                        ),
                        SettingsScreen(
                          community: selectedCommunity!,
                        )
                      ];
                      return Provider.value(
                        value: selectedCommunity,
                        child: Scaffold(
                          appBar: AppBar(
                            elevation: 1,
                            title: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                alignment: Alignment.center,
                                underline: null,
                                borderRadius: BorderRadius.circular(15),
                                hint: Text(selectedCommunity!.name),
                                value: selectedCommunity!.id,
                                icon: const Icon(Icons.arrow_drop_down),
                                elevation: 16,
                                onChanged: (newCommunity) {
                                  if (newCommunity == selectedCommunity?.id) {
                                    return;
                                  }
                                  setCommunity();
                                  setState(() {
                                    selectedCommunity =
                                        userCommunities.firstWhere(
                                      (community) =>
                                          community.id == newCommunity,
                                    );
                                  });
                                },
                                items: userCommunities.map((community) {
                                  return DropdownMenuItem<String>(
                                    value: community.id,
                                    child: Text(community.name),
                                  );
                                }).toList(),
                              ),
                            ),
                            leading: IconButton(
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Add a new community'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: communityController,
                                              decoration: const InputDecoration(
                                                hintText:
                                                    'Enter community code',
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final newCommunity =
                                                    communityController.text;
                                                if (newCommunity.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Please enter a community code',
                                                      ),
                                                    ),
                                                  );

                                                  communityController.clear();
                                                  return;
                                                }
                                                if (userCommunities.any(
                                                    (element) =>
                                                        element
                                                            .id
                                                            .toLowerCase() ==
                                                        newCommunity
                                                            .toLowerCase())) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'You are already a member of this community',
                                                      ),
                                                    ),
                                                  );

                                                  communityController.clear();
                                                  return;
                                                }
                                                if (!communities.any(
                                                    (element) =>
                                                        element.id
                                                            .toLowerCase() ==
                                                        newCommunity
                                                            .toLowerCase())) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'This community does not exist',
                                                      ),
                                                    ),
                                                  );

                                                  communityController.clear();
                                                  return;
                                                }

                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(currUser.id)
                                                    .update({
                                                  'communityCodes':
                                                      FieldValue.arrayUnion([
                                                    newCommunity.toLowerCase()
                                                  ])
                                                });

                                                communityController.clear();
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Community added successfully',
                                                    ),
                                                  ),
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Add'),
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              },
                              icon: const Icon(
                                Icons.add_box_rounded,
                                color: Colors.white,
                              ),
                            ),
                            actions: [
                              PopupMenuButton(
                                icon: getMenuIcon(sortValue),
                                initialValue: sortValue,
                                onSelected: (value) {
                                  if (sortValue == value.toString()) return;
                                  switch (currentIndex) {
                                    case 0:
                                      setListSortValue(value.toString());
                                      break;
                                    case 1:
                                      setEventsSortValue(value.toString());
                                      break;
                                    case 2:
                                      setBusinessesSortValue(value.toString());
                                      break;
                                    default:
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  switch (currentIndex) {
                                    case 0:
                                      return <PopupMenuEntry>[
                                        const PopupMenuItem(
                                          value: 'Upvotes',
                                          child: Text('Upvotes'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Recent',
                                          child: Text('Recent'),
                                        ),
                                      ];
                                    case 1:
                                      return <PopupMenuEntry>[
                                        const PopupMenuItem(
                                          value: 'Calendar',
                                          child: Text('Calendar'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'List',
                                          child: Text('List'),
                                        ),
                                      ];
                                    case 2:
                                      return <PopupMenuEntry>[
                                        const PopupMenuItem(
                                          value: 'Alphabetical',
                                          child: Text('Alphabetical'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Rating',
                                          child: Text('Rating'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Distance',
                                          child: Text('Distance'),
                                        ),
                                      ];

                                    default:
                                      return <PopupMenuEntry>[];
                                  }
                                },
                              )
                            ],
                          ),
                          body: Builder(
                            builder: ((context) => screens[currentIndex]),
                          ),
                          floatingActionButton: currentIndex != 3
                              ? PopupMenuButton(
                                  // color: Colors.lightBlueAccent,
                                  icon: const Icon(Icons.add_circle),
                                  iconSize: 35,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        child: TextButton(
                                          onPressed: () {
                                            showModalBottomSheet<void>(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (BuildContext c) {
                                                return Provider.value(
                                                  value: selectedCommunity,
                                                  child: getModal(
                                                    0,
                                                    users,
                                                    businesses,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: const Text("Post"),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: TextButton(
                                          onPressed: () {
                                            showModalBottomSheet<void>(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (BuildContext c) {
                                                return Provider.value(
                                                  value: selectedCommunity,
                                                  child: getModal(
                                                    1,
                                                    users,
                                                    businesses,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: const Text("Event"),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: TextButton(
                                          onPressed: () {
                                            showModalBottomSheet<void>(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (BuildContext c) {
                                                return Provider.value(
                                                  value: selectedCommunity,
                                                  child: getModal(
                                                    3,
                                                    users,
                                                    businesses,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: const Text("Business"),
                                        ),
                                      ),
                                    ];
                                  },
                                )
                              : Container(),
                          bottomNavigationBar: BottomNavigationBar(
                            items: const <BottomNavigationBarItem>[
                              BottomNavigationBarItem(
                                icon: Icon(Icons.list),
                                label: 'List',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.event_outlined),
                                label: 'Events',
                              ),
                              // BottomNavigationBarItem(
                              //   icon: Icon(Icons.add),
                              //   label: 'Create',
                              // ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.business_outlined),
                                label: 'Businesses',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.settings),
                                label: 'Settings',
                              ),
                            ],
                            currentIndex: currentIndex,
                            unselectedItemColor: Colors.black,
                            onTap: (value) {
                              switch (value) {
                                // case 2:
                                //   if (currentIndex == 4) {
                                //     setState(() {
                                //       currentIndex = 0;
                                //     });
                                //   }

                                //   showModalBottomSheet<void>(
                                //     context: context,
                                //     isScrollControlled: true,
                                //     builder: (BuildContext c) {
                                //       return Provider.value(
                                //         value: selectedCommunity,
                                //         child: getModal(
                                //           currentIndex,
                                //           users,
                                //           businesses,
                                //         ),
                                //       );
                                //     },
                                //   );
                                //   break;
                                default:
                                  setState(() {
                                    currentIndex = value;
                                  });
                              }
                            },
                          ),
                        ),
                      );
                    });
              });
        } else {
          return const Text('');
        }
      },
    );
  }
}

getMenuIcon(String sortValue) {
  switch (sortValue) {
    case 'Upvotes':
      return const Icon(Icons.arrow_circle_up_rounded);
    case 'Recent':
      return const Icon(Icons.access_time_rounded);
    case 'Calendar':
      return const Icon(Icons.calendar_today_rounded);
    case 'List':
      return const Icon(Icons.list_rounded);
    case 'Alphabetical':
      return const Icon(Icons.sort_by_alpha_rounded);
    case 'Rating':
      return const Icon(Icons.star_rounded);
    case 'Distance':
      return const Icon(Icons.near_me_rounded);
    default:
      return const Icon(Icons.arrow_circle_up_rounded);
  }
}
