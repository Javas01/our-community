import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:our_ummah/actions/event_actions/create_event_action.dart';
import 'package:our_ummah/actions/event_actions/edit_event_action.dart';
import 'package:our_ummah/actions/send_notification.dart';
import 'package:our_ummah/components/text_form_field_components.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:provider/provider.dart';
import 'package:our_ummah/models/user_model.dart';

class CreateEventModal extends StatefulWidget {
  const CreateEventModal({
    Key? key,
    this.post,
    this.users,
    this.businesses,
  }) : super(key: key);
  final EventPost? post;
  final List<AppUser>? users;
  final List<Business>? businesses;

  @override
  State<CreateEventModal> createState() => _CreateEventModalState();
}

class _CreateEventModalState extends State<CreateEventModal> {
  final _formKey = GlobalKey<FormState>();
  final firstName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[0];
  final lastName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[1];
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  File? image;
  String priceDropdownValue = 'Free';
  String audienceDropdownValue = 'All';
  String? businessDropdownValue;
  bool isEdit = false;
  bool isInvalidImage = false;
  final List<String> _selectedTags = [];
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();

  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));

  @override
  void initState() {
    if (widget.post != null) {
      isEdit = true;
      titleController.text = widget.post!.title;
      descriptionController.text = widget.post!.description;
      addressController.text = widget.post!.location;
      _startDate = DateTime.fromMillisecondsSinceEpoch(
        widget.post!.startDate.millisecondsSinceEpoch,
      );

      startTime = TimeOfDay.fromDateTime(_startDate);
      _endDate = DateTime.fromMillisecondsSinceEpoch(
        widget.post!.endDate.millisecondsSinceEpoch,
      );

      endTime = TimeOfDay.fromDateTime(_endDate);
      priceDropdownValue = widget.post!.price;
      audienceDropdownValue = widget.post!.audience;
      _selectedTags.addAll(widget.post!.tags);
      businessDropdownValue = widget.post!.isAd ? widget.post!.createdBy : null;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userBusinesses = widget.businesses!
        .where((element) =>
            element.createdBy == FirebaseAuth.instance.currentUser!.uid)
        .toList();
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Container(
        constraints: const BoxConstraints(minHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEdit ? 'Edit Event' : 'Add New Event',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        hint: const Text('Post as business'),
                        items: userBusinesses
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.title),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            businessDropdownValue = value;
                          });
                        },
                        value: businessDropdownValue,
                      ),
                      const SizedBox(height: 10),
                      FormInputField(
                        maxLength: 30,
                        icon: const Icon(Icons.title_outlined),
                        hintText: 'Title',
                        controller: titleController,
                        isLast: false,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: FormInputField(
                          maxLength: 100,
                          icon: const Icon(Icons.description_rounded),
                          controller: descriptionController,
                          isLast: true,
                          hintText: 'Description',
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: FormInputField(
                          maxLength: 100,
                          icon: const Icon(Icons.description_rounded),
                          controller: addressController,
                          isLast: true,
                          hintText: 'Location',
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                      Row(
                        children: [
                          const Text('Start Date: '),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () {
                              showDatePicker(
                                context: context,
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                initialDate:
                                    DateTime.fromMillisecondsSinceEpoch(
                                  _startDate.millisecondsSinceEpoch,
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2024),
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    _startDate = value;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Selected: ${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                        ),
                                      ),
                                    );
                                  });
                                }
                              });
                            },
                            child: Text(
                              DateFormat.yMMMMd('en_US').format(_startDate),
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                              child: Text(startTime.format(context)),
                              onPressed: () async {
                                final TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: startTime,
                                  initialEntryMode: TimePickerEntryMode.dial,
                                  orientation: Orientation.portrait,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    // We just wrap these environmental changes around the
                                    // child in this builder so that we can apply the
                                    // options selected above. In regular usage, this is
                                    // rarely necessary, because the default values are
                                    // usually used as-is.
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.padded,
                                      ),
                                      child: MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: false,
                                        ),
                                        child: child!,
                                      ),
                                    );
                                  },
                                );
                                if (time != null) {
                                  setState(() {
                                    startTime = time;

                                    _startDate = DateTime(
                                      _startDate.year,
                                      _startDate.month,
                                      _startDate.day,
                                      startTime.hour,
                                      startTime.minute,
                                    );
                                  });
                                }
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('End Date: '),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () {
                              showDatePicker(
                                context: context,
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                initialDate:
                                    DateTime.fromMillisecondsSinceEpoch(
                                  _endDate.millisecondsSinceEpoch,
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2024),
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    _endDate = value;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Selected: ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                                        ),
                                      ),
                                    );
                                  });
                                }
                              });
                            },
                            child: Text(
                              DateFormat.yMMMMd('en_US').format(_endDate),
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            child: Text(endTime.format(context)),
                            onPressed: () async {
                              final TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                                initialEntryMode: TimePickerEntryMode.dial,
                                orientation: Orientation.portrait,
                                builder: (BuildContext context, Widget? child) {
                                  // We just wrap these environmental changes around the
                                  // child in this builder so that we can apply the
                                  // options selected above. In regular usage, this is
                                  // rarely necessary, because the default values are
                                  // usually used as-is.
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.padded,
                                    ),
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        alwaysUse24HourFormat: false,
                                      ),
                                      child: child!,
                                    ),
                                  );
                                },
                              );
                              if (time != null) {
                                setState(() {
                                  endTime = time;
                                  _endDate = DateTime(
                                    _endDate.year,
                                    _endDate.month,
                                    _endDate.day,
                                    endTime.hour,
                                    endTime.minute,
                                  );
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: audienceDropdownValue,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.lightBlue),
                            underline: Container(
                              height: 2,
                              color: Colors.lightBlueAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                audienceDropdownValue = newValue!;
                              });
                            },
                            items: <String>[
                              'All',
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
                          ),
                          const Spacer(),
                          DropdownButton<String>(
                            value: priceDropdownValue,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.lightBlue),
                            underline: Container(
                              height: 2,
                              color: Colors.lightBlueAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                priceDropdownValue = newValue!;
                              });
                            },
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
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    children: [
                      ...eventOptionsList.map((option) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
                          child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: option.values.first,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(option.keys.first)
                                ],
                              ),
                              selectedColor:
                                  option.values.first.withOpacity(0.5),
                              selected:
                                  _selectedTags.contains(option.keys.first),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTags.add(option.keys.first);
                                  } else {
                                    _selectedTags.remove(option.keys.first);
                                  }
                                });
                              }),
                        );
                      }).toList()
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel')),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            isEdit
                                ? editEvent(
                                    titleController.text,
                                    descriptionController.text,
                                    PostType.event,
                                    _selectedTags,
                                    audienceDropdownValue,
                                    priceDropdownValue,
                                    _startDate,
                                    _endDate,
                                    addressController.text,
                                    image,
                                    context,
                                    widget.post!.id,
                                  )
                                : createEvent(
                                    titleController.text,
                                    descriptionController.text,
                                    addressController.text,
                                    _selectedTags,
                                    image,
                                    Provider.of<Community>(
                                      context,
                                      listen: false,
                                    ).id,
                                    businessDropdownValue != null
                                        ? true
                                        : false,
                                    businessDropdownValue != null
                                        ? businessDropdownValue!
                                        : userId,
                                    audienceDropdownValue,
                                    priceDropdownValue,
                                    _startDate,
                                    _endDate,
                                    (e) => ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to create post: $e',
                                        ),
                                      ),
                                    ),
                                  );
                            Navigator.pop(context);
                            sendNotification(
                              titleController.text,
                              widget.users
                                      ?.map((e) => e.tokens.map((e) => e))
                                      .expand((element) => element)
                                      .toList() ??
                                  [],
                            );
                          }
                        },
                        child: const Text('Submit'),
                      )
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}
