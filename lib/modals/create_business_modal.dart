import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_ummah/actions/business_actions/create_business_action.dart';
import 'package:our_ummah/actions/business_actions/edit_business_action.dart';
import 'package:our_ummah/actions/pick_image_action.dart';
import 'package:our_ummah/actions/send_notification.dart';
import 'package:our_ummah/components/text_form_field_components.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:provider/provider.dart';
import 'package:our_ummah/models/user_model.dart';

class CreateBusinessModal extends StatefulWidget {
  const CreateBusinessModal({Key? key, this.business, this.users})
      : super(key: key);
  final Business? business;
  final List<AppUser>? users;

  @override
  State<CreateBusinessModal> createState() => _CreateBusinessModalState();
}

class _CreateBusinessModalState extends State<CreateBusinessModal> {
  final _formKey = GlobalKey<FormState>();
  final firstName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[0];
  final lastName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[1];
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController taglineController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  File? image;
  bool isEdit = false;
  bool isInvalidImage = false;
  final List<String> _selectedTags = [];

  @override
  void initState() {
    if (widget.business != null) {
      isEdit = true;
      titleController.text = widget.business!.title;
      taglineController.text = widget.business!.tagline;
      addressController.text = widget.business!.address;
      phoneNumberController.text = widget.business!.phoneNumber;
      _selectedTags.addAll(widget.business!.tags);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    isEdit ? 'Edit Business' : 'Add New Business',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      FormInputField(
                        maxLength: 30,
                        icon: const Icon(Icons.title_outlined),
                        hintText: 'Title',
                        controller: titleController,
                        isLast: false,
                      ),
                      const SizedBox(height: 10),
                      FormInputField(
                        maxLength: 100,
                        icon: const Icon(Icons.description_rounded),
                        controller: taglineController,
                        isLast: false,
                        hintText: 'Tagline',
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        minLines: 1,
                      ),
                      const SizedBox(height: 10),
                      FormInputField(
                        maxLength: 100,
                        icon: const Icon(Icons.location_on),
                        controller: addressController,
                        isLast: false,
                        hintText: 'Address',
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        minLines: 1,
                      ),
                      const SizedBox(height: 10),
                      FormInputField(
                        icon: const Icon(Icons.phone),
                        controller: phoneNumberController,
                        isLast: true,
                        maxLength: 10,
                        hintText: 'Phone Number',
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        validator: (p0) {
                          if (p0!.isEmpty) {
                            return 'Phone number cannot be empty';
                          }
                          if (p0.length < 10) {
                            return 'Phone number must be 10 digits';
                          }
                          if (RegExp(r'^[0-9]+$').hasMatch(p0) == false) {
                            return 'Phone number must be digits only';
                          }
                          return null;
                        },
                      ),
                      image == null && !isEdit
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  IconButton(
                                    iconSize: 250,
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () async {
                                      final imageTemp = await pickImage(
                                        (() => ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Failed to get image',
                                                ),
                                              ),
                                            )),
                                      );
                                      setState(() {
                                        image = imageTemp;
                                      });
                                    },
                                    icon: const Icon(Icons.image),
                                    color: isInvalidImage ? Colors.red : null,
                                  ),
                                  if (isInvalidImage)
                                    const Text(
                                      'Image cannot be empty',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: () async {
                                final imageTemp = await pickImage(
                                  (() => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Failed to get image',
                                          ),
                                        ),
                                      )),
                                );
                                setState(() {
                                  image = imageTemp;
                                });
                              },
                              child: image != null
                                  ? Image.file(
                                      image!,
                                      height: 300,
                                    )
                                  : Image.network(
                                      widget.business!.businessLogoUrl,
                                      height: 300,
                                    ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    children: [
                      ...businessOptionsList.map((value) {
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
                            if (image == null && !isEdit) {
                              setState(() {
                                isInvalidImage = true;
                              });

                              return;
                            } else if (isInvalidImage) {
                              setState(() {
                                isInvalidImage = false;
                              });
                            }
                            isEdit
                                ? editBusiness(
                                    titleController.text,
                                    taglineController.text,
                                    addressController.text,
                                    phoneNumberController.text,
                                    _selectedTags,
                                    image,
                                    context,
                                    widget.business!.id,
                                  )
                                : createBusiness(
                                    titleController.text,
                                    taglineController.text,
                                    addressController.text,
                                    phoneNumberController.text,
                                    _selectedTags,
                                    image,
                                    Provider.of<Community>(
                                      context,
                                      listen: false,
                                    ).id,
                                    userId,
                                    (e) => ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to create business: $e',
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
