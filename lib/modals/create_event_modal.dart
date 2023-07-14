import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:our_ummah/actions/event_actions/create_event_action.dart';
import 'package:our_ummah/actions/event_actions/edit_event_action.dart';
import 'package:our_ummah/actions/pick_image_action.dart';
import 'package:our_ummah/actions/send_notification.dart';
import 'package:our_ummah/components/text_form_field_components.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:provider/provider.dart';
import 'package:our_ummah/models/user_model.dart';

class CreateEventModal extends StatefulWidget {
  const CreateEventModal({Key? key, this.post, this.users}) : super(key: key);
  final EventPost? post;
  final List<AppUser>? users;

  @override
  State<CreateEventModal> createState() => _CreateEventModalState();
}

class _CreateEventModalState extends State<CreateEventModal>
    with RestorationMixin {
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
  bool isEdit = false;
  bool isInvalidImage = false;
  final List<String> _selectedTags = [];

  @override
  String? get restorationId => 'main';
  RestorableDateTime _selectedDate =
      RestorableDateTime(DateTime.now().add(const Duration(days: 1)));
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime.now(),
          lastDate: DateTime(2024),
        );
      },
    );
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
        ));
      });
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  @override
  void initState() {
    if (widget.post != null) {
      isEdit = true;
      titleController.text = widget.post!.title;
      descriptionController.text = widget.post!.description;
      addressController.text = widget.post!.location;
      _selectedDate = RestorableDateTime(DateTime.fromMillisecondsSinceEpoch(
        widget.post!.date.millisecondsSinceEpoch,
      ));
      priceDropdownValue = widget.post!.price;
      audienceDropdownValue = widget.post!.audience;
      _selectedTags.addAll(widget.post!.tags);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

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
                      // TODO: Add image picker functionality
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 10),
                      //   child: Stack(
                      //     alignment: Alignment.bottomCenter,
                      //     children: [
                      //       IconButton(
                      //         iconSize: 250,
                      //         padding: const EdgeInsets.all(0),
                      //         onPressed: () async {
                      //           final imageTemp = await pickImage(
                      //             (() => ScaffoldMessenger.of(context)
                      //                     .showSnackBar(
                      //                   const SnackBar(
                      //                     content: Text(
                      //                       'Failed to get image',
                      //                     ),
                      //                   ),
                      //                 )),
                      //           );
                      //           setState(() {
                      //             image = imageTemp;
                      //           });
                      //         },
                      //         icon: const Icon(Icons.image),
                      //         color: isInvalidImage ? Colors.red : null,
                      //       ),
                      //       if (isInvalidImage)
                      //         const Text(
                      //           'Image cannot be empty',
                      //           style: TextStyle(
                      //             color: Colors.red,
                      //           ),
                      //         ),
                      //     ],
                      //   ),
                      // ),
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
                      OutlinedButton(
                        onPressed: () {
                          _restorableDatePickerRouteFuture.present();
                        },
                        child: Text(
                          DateFormat.yMMMMd('en_US')
                              .format(_selectedDate.value),
                        ),
                      ),
                      Row(children: [
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
                      ])
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    children: [
                      ...eventOptionsList.map((value) {
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
                                      color: value.values.first,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(value.keys.first)
                                ],
                              ),
                              selectedColor:
                                  value.values.first.withOpacity(0.5),
                              selected:
                                  _selectedTags.contains(value.keys.first),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTags.add(value.keys.first);
                                  } else {
                                    _selectedTags.remove(value.keys.first);
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
                            // if (image == null && !isEdit) {
                            //   setState(() {
                            //     isInvalidImage = true;
                            //   });

                            //   return;
                            // } else if (isInvalidImage) {
                            //   setState(() {
                            //     isInvalidImage = false;
                            //   });
                            // }
                            isEdit
                                ? editEvent(
                                    titleController.text,
                                    descriptionController.text,
                                    PostType.event,
                                    _selectedTags,
                                    audienceDropdownValue,
                                    priceDropdownValue,
                                    _selectedDate.value,
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
                                    userId,
                                    audienceDropdownValue,
                                    priceDropdownValue,
                                    _selectedDate.value,
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
