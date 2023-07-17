import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:our_ummah/components/EventCard/event_card_component.dart';
import 'package:our_ummah/components/tag_filter_component.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:our_ummah/extensions/string_extensions.dart';

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
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String _selectedTag = '';
  Audience? _audienceFilter;
  Price? _priceFilter;
  String? _distanceFilter;
  String? _categoryFilter;

  List<EventPost> _getEventsForDay(DateTime day, List<EventPost> posts) {
    return posts
        .where((element) => isSameDay((element).startDate, day))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.sortValue != 'Calendar') return;

    FirebaseFirestore.instance
        .collection('Communities')
        .doc(Provider.of<Community>(context, listen: false).id)
        .collection('Posts')
        .where('type', isEqualTo: 'event')
        .withConverter(
          fromFirestore: postFromFirestore,
          toFirestore: postToFirestore,
        )
        .get()
        .then((value) {
      if (value.docs.isEmpty) return;
      if (value.docs
          .map((e) => e.data())
          .toList()
          .cast<EventPost>()
          .where(
            (element) => isSameDay(_selectedDay, element.startDate),
          )
          .isEmpty) return;
      setState(() {
        _calendarFormat = CalendarFormat.week;
      });
    });
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
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    scrollDirection: Axis.horizontal,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: _audienceFilter != null
                              ? Colors.blueAccent.withOpacity(0.7)
                              : Colors.blueAccent.withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButton<Audience>(
                            hint: const Text('Audience'),
                            borderRadius: BorderRadius.circular(40),
                            underline: Container(),
                            icon: const Icon(Icons.filter_list),
                            items: Audience.values
                                .map<DropdownMenuItem<Audience>>((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value.name.toTitleCase()),
                              );
                            }).toList(),
                            value: _audienceFilter,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 53, 93, 175),
                              fontSize: 16,
                            ),
                            alignment: AlignmentDirectional.center,
                            onChanged: (value) {
                              setState(() {
                                _audienceFilter = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: _distanceFilter != null
                              ? Colors.greenAccent.withOpacity(0.7)
                              : Colors.greenAccent.withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButton(
                            hint: const Text('Distance'),
                            borderRadius: BorderRadius.circular(40),
                            underline: Container(),
                            icon: const Icon(Icons.filter_list),
                            items: <String>[
                              '5 miles',
                              '10 miles',
                              '15 miles',
                              '30 miles',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: _distanceFilter,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 39, 165, 104),
                              fontSize: 16,
                            ),
                            alignment: AlignmentDirectional.center,
                            onChanged: (value) {
                              setState(() {
                                _distanceFilter = value.toString();
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: _priceFilter != null
                              ? const Color.fromARGB(255, 197, 97, 181)
                                  .withOpacity(0.7)
                              : const Color.fromARGB(255, 230, 149, 210)
                                  .withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButton<Price>(
                            hint: const Text('Price'),
                            borderRadius: BorderRadius.circular(40),
                            underline: Container(),
                            icon: const Icon(Icons.filter_list),
                            items: Price.values
                                .map<DropdownMenuItem<Price>>((value) {
                              return DropdownMenuItem<Price>(
                                value: value,
                                child: Text(value.name.toTitleCase()),
                              );
                            }).toList(),
                            value: _priceFilter,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 184, 92, 163),
                              fontSize: 16,
                            ),
                            alignment: AlignmentDirectional.center,
                            onChanged: (value) {
                              setState(() {
                                _priceFilter = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: _categoryFilter != null
                              ? const Color.fromARGB(255, 187, 81, 225)
                                  .withOpacity(0.7)
                              : const Color.fromARGB(255, 167, 97, 178)
                                  .withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButton(
                            hint: const Text(
                              'Category',
                              style: TextStyle(
                                color: Color.fromARGB(255, 248, 246, 246),
                                fontSize: 16,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(40),
                            underline: Container(),
                            icon: const Icon(Icons.filter_list),
                            items: eventOptionsList
                                .map<DropdownMenuItem<String>>((value) {
                              return DropdownMenuItem<String>(
                                value: value.keys.first,
                                child: Text(value.keys.first),
                              );
                            }).toList(),
                            value: _categoryFilter,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 4, 2, 2),
                              fontSize: 16,
                            ),
                            alignment: AlignmentDirectional.center,
                            onChanged: (value) {
                              setState(() {
                                _categoryFilter = value.toString();
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
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
                      ...eventOptionsList
                          .map<Widget>(
                            (tag) => TagFilter(
                              name: tag.keys.first,
                              color: tag.values.first,
                              selectedTag: _selectedTag,
                              selectTagFilter: selectTagFilter,
                            ),
                          )
                          .toList()
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
                ? Expanded(
                    child: ListView(
                      children: [
                        ...posts
                            .where(
                              (post) => _audienceFilter != null
                                  ? post.audience == _audienceFilter
                                  : true,
                            )
                            .where(
                              (post) => _priceFilter != null
                                  ? post.price == _priceFilter
                                  : true,
                            )
                            .where(
                              (post) => post.startDate.isAfter(DateTime.now()),
                            )
                            .where(
                              (post) => _selectedTag.isNotEmpty
                                  ? post.tags.contains(_selectedTag)
                                  : true,
                            )
                            .where(
                              (post) => _categoryFilter != null
                                  ? post.tags.contains(_categoryFilter)
                                  : true,
                            )
                            // .where((post) => _distanceFilter != null ? post.distance == _distanceFilter : true)
                            .map<Widget>((post) {
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
                          );
                        }).toList(),
                      ],
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        TableCalendar(
                          calendarBuilders: CalendarBuilders(
                            markerBuilder:
                                (context, day, List<EventPost> events) {
                              if (events.isNotEmpty) {
                                return Container(
                                  margin: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color:
                                        eventOptions[events.first.tags.first],
                                    shape: BoxShape.circle,
                                  ),
                                  width: 8.0,
                                  height: 8.0,
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                          calendarStyle: CalendarStyle(
                            selectedDecoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            todayTextStyle: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                            CalendarFormat.week: 'Week',
                          },
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          headerStyle: const HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                          ),
                          // onPageChanged: (focusedDay) {
                          //   _focusedDay = focusedDay;
                          // },
                          onDaySelected: (selectedDay, focusedDay) {
                            if (!isSameDay(_selectedDay, selectedDay)) {
                              final eventsForDay = _getEventsForDay(
                                selectedDay,
                                posts,
                              );
                              setState(() {
                                _focusedDay = focusedDay;
                                _selectedDay = selectedDay;
                                _calendarFormat = eventsForDay.isEmpty
                                    ? CalendarFormat.month
                                    : CalendarFormat.week;
                              });
                            }
                          },
                          calendarFormat: _calendarFormat,
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          eventLoader: (day) {
                            return _getEventsForDay(
                              day,
                              posts,
                            );
                          },
                        ),
                        Flexible(
                          child: Column(
                            children: [
                              const SizedBox(height: 8.0),
                              Text(
                                'Events on ${DateFormat.yMMMd().format(_selectedDay)}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8.0),
                              Expanded(
                                child: ListView(
                                  children: posts
                                      .where((post) => isSameDay(
                                          post.startDate, _selectedDay))
                                      .map((event) {
                                    final PostCreator postCreator = event.isAd
                                        ? () {
                                            final business =
                                                widget.businesses.firstWhere(
                                              (e) => e.id == event.createdBy,
                                            );
                                            return PostCreator(
                                              name: business.title,
                                              picUrl: business.businessLogoUrl,
                                              id: business.id,
                                            );
                                          }()
                                        : () {
                                            final user =
                                                widget.users.firstWhere(
                                              (e) => e.id == event.createdBy,
                                            );
                                            return PostCreator(
                                              name:
                                                  '${user.firstName} ${user.lastName}',
                                              picUrl: user.profilePicUrl,
                                              id: user.id,
                                            );
                                          }();

                                    return EventCardComponent(
                                      postCreator: postCreator,
                                      post: event,
                                      users: widget.users,
                                      businesses: widget.businesses,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ],
    );
  }

  void selectTagFilter(String tagName) {
    setState(() {
      _selectedTag = _selectedTag == tagName ? '' : tagName;
    });
  }
}
