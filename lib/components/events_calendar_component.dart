import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:our_ummah/actions/get_distance_from_post.dart';
import 'package:our_ummah/actions/get_location_from_address.dart';
import 'package:our_ummah/components/EventCard/event_card_component.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsCalendar extends StatefulWidget {
  const EventsCalendar({
    super.key,
    required this.posts,
    required this.users,
    required this.businesses,
    required this.currPosition,
  });

  final List<EventPost> posts;
  final List<AppUser> users;
  final List<Business> businesses;
  final Position? currPosition;

  @override
  State<EventsCalendar> createState() => _EventsCalendarState();
}

class _EventsCalendarState extends State<EventsCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, Location> _businessLocations = {};

  @override
  void initState() {
    final eventsForDay = getEventsForDay(
      DateTime.now(),
      widget.posts,
    );
    if (eventsForDay.isNotEmpty) {
      _calendarFormat = CalendarFormat.week;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TableCalendar(
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, List<EventPost> events) {
                if (events.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: eventOptions[events.first.tags.first],
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
                final eventsForDay = getEventsForDay(
                  selectedDay,
                  widget.posts,
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
              return getEventsForDay(
                day,
                widget.posts,
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
                    children: widget.posts
                        .where(
                            (post) => isSameDay(post.startDate, _selectedDay))
                        .map((event) {
                      getLocationFromAddress(
                        _businessLocations,
                        event.location,
                        (locations) {
                          setState(() {
                            _businessLocations = locations;
                          });
                        },
                      );

                      final PostCreator postCreator = event.isAd
                          ? () {
                              final business = widget.businesses.firstWhere(
                                (e) => e.id == event.createdBy,
                              );
                              return PostCreator(
                                name: business.title,
                                picUrl: business.businessLogoUrl,
                                id: business.id,
                              );
                            }()
                          : () {
                              final user = widget.users.firstWhere(
                                (e) => e.id == event.createdBy,
                              );
                              return PostCreator(
                                name: '${user.firstName} ${user.lastName}',
                                picUrl: user.profilePicUrl,
                                id: user.id,
                              );
                            }();

                      return EventCardComponent(
                        postCreator: postCreator,
                        post: event,
                        users: widget.users,
                        businesses: widget.businesses,
                        distanceFromUser: getDistanceFromPost(
                          event.location,
                          _businessLocations,
                          widget.currPosition,
                        ),
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
  }

  List<EventPost> getEventsForDay(DateTime day, List<EventPost> posts) {
    return posts
        .where((element) => isSameDay((element).startDate, day))
        .toList();
  }
}
