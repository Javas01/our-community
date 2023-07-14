import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/components/EventCard/event_card_component.dart';
import 'package:our_ummah/components/tag_filter_component.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'package:timeago/timeago.dart' as timeago;

class EventScreen extends StatefulWidget {
  const EventScreen({super.key, required this.users, required this.sortValue});

  final List<AppUser> users;
  final String sortValue;

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool isActive = false;
  final dataKey = GlobalKey();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<EventPost> _selectedEvents = [];
  // GlobalKey? _selectedPostKey;
  String _selectedTag = '';
  String? _audienceFilter;
  String? _priceFilter;
  String? _distanceFilter;
  String? _categoryFilter;

  List<EventPost> _getEventsForDay(DateTime day, List<EventPost> posts) {
    return posts
        .where((element) => isSameDay((element as EventPost).date, day))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    print(Provider.of<Community>(context, listen: false).id);
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
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: _audienceFilter != null
                              ? Colors.blueAccent.withOpacity(0.7)
                              : Colors.blueAccent.withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButton(
                            hint: const Text('Audience'),
                            borderRadius: BorderRadius.circular(40),
                            underline: Container(),
                            icon: const Icon(Icons.filter_list),
                            items: <String>[
                              'Everyone',
                              'Teenagers only',
                              'Adults only',
                              'Men only',
                              'Women only',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: _audienceFilter,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            alignment: AlignmentDirectional.center,
                            onChanged: (value) {
                              setState(() {
                                _audienceFilter = value.toString();
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
                              color: Colors.black,
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
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: _priceFilter != null
                              ? Colors.redAccent.withOpacity(0.7)
                              : Colors.redAccent.withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButton(
                            hint: const Text('Price'),
                            borderRadius: BorderRadius.circular(40),
                            underline: Container(),
                            icon: const Icon(Icons.filter_list),
                            items: <String>[
                              'Free',
                              '\$',
                              '\$\$',
                              '\$\$\$',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: _priceFilter,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            alignment: AlignmentDirectional.center,
                            onChanged: (value) {
                              setState(() {
                                _priceFilter = value.toString();
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
                          color: _categoryFilter != null
                              ? Colors.yellowAccent.withOpacity(0.7)
                              : Colors.yellowAccent.withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownButton(
                            hint: const Text('Category'),
                            borderRadius: BorderRadius.circular(40),
                            underline: Container(),
                            icon: const Icon(Icons.filter_list),
                            items: <String>[
                              'Quran',
                              'Recreation',
                              'Meetup',
                              'Other',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: _categoryFilter,
                            style: const TextStyle(
                              color: Colors.black,
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
                                  _distanceFilter == null)
                              ? null
                              : () {
                                  setState(() {
                                    _audienceFilter = null;
                                    _priceFilter = null;
                                    _distanceFilter = null;
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

            return widget.sortValue == 'List'
                ? Expanded(
                    child: ListView(children: [
                      ...posts
                          .where((post) => _audienceFilter != null
                              ? post.audience == _audienceFilter
                              : true)
                          .where((post) => _priceFilter != null
                              ? post.price == _priceFilter
                              : true)
                          .where(
                              (element) => element.date.isAfter(DateTime.now()))
                          .where((element) => _selectedTag.isNotEmpty
                              ? element.tags.contains(_selectedTag)
                              : true)
                          // .where((post) => _distanceFilter != null ? post.distance == _distanceFilter : true)
                          .map<Widget>((post) {
                        final AppUser postCreator = widget.users
                            .firstWhere((e) => e.id == post.createdBy);
                        // final isCreator = userId == post.createdBy;
                        // final String postDate = post.lastEdited == null
                        //     ? 'Posted ${timeago.format(
                        //         DateTime.fromMicrosecondsSinceEpoch(
                        //           post.timestamp.microsecondsSinceEpoch,
                        //         ),
                        //       )}'
                        //     : 'Edited ${timeago.format(
                        //         DateTime.fromMicrosecondsSinceEpoch(
                        //           post.lastEdited!.microsecondsSinceEpoch,
                        //         ),
                        //       )}';

                        return EventCardComponent(
                          postCreator: postCreator,
                          post: post,
                          users: widget.users,
                        );
                      }).toList(),
                    ]),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        TableCalendar(
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
                          onDaySelected: (selectedDay, focusedDay) {
                            // setState(() {
                            //   _selectedDay = selectedDay;
                            //   _focusedDay = focusedDay; // update `_focusedDay` here as well
                            // });
                            if (!isSameDay(_selectedDay, selectedDay)) {
                              setState(() {
                                _focusedDay = focusedDay;
                                _selectedDay = selectedDay;
                                _calendarFormat = CalendarFormat.week;
                                _selectedEvents = _getEventsForDay(
                                    selectedDay, posts as List<EventPost>);
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
                                day, posts as List<EventPost>);
                          },
                        ),
                        Flexible(
                          child: ListView(
                            children: _selectedEvents.map((event) {
                              final AppUser postCreator = widget.users
                                  .firstWhere((e) => e.id == event.createdBy);
                              // final isCreator = userId == event.createdBy;
                              // final String postDate = event.lastEdited == null
                              //     ? 'Posted ${timeago.format(
                              //         DateTime.fromMicrosecondsSinceEpoch(
                              //           event.timestamp.microsecondsSinceEpoch,
                              //         ),
                              //       )}'
                              //     : 'Edited ${timeago.format(
                              //         DateTime.fromMicrosecondsSinceEpoch(
                              //           event.lastEdited!.microsecondsSinceEpoch,
                              //         ),
                              //       )}';

                              return EventCardComponent(
                                postCreator: postCreator,
                                post: event,
                                users: widget.users,
                              );
                            }).toList(),
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
