import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_ummah/actions/business_actions/create_business_action.dart';
import 'package:our_ummah/actions/pick_image_action.dart';
import 'package:our_ummah/actions/send_notification.dart';
import 'package:our_ummah/components/tag_component.dart';
import 'package:our_ummah/components/text_form_field_components.dart';
import 'package:our_ummah/actions/post_actions/create_post_action.dart';
import 'package:our_ummah/actions/post_actions/edit_post_action.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:provider/provider.dart';
import 'package:our_ummah/models/user_model.dart';

class CreateBusinessModal extends StatefulWidget {
  const CreateBusinessModal({Key? key, this.post, this.users})
      : super(key: key);
  final Post? post;
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
  File? image;
  PostType typeDropdownValue = PostType.text;
  String tagDropdownValue = 'Other';
  bool isEdit = false;
  bool isInvalidImage = false;
  final List<String> _selectedTags = [];

  @override
  void initState() {
    if (widget.post != null) {
      isEdit = true;
      typeDropdownValue = widget.post!.type;
      tagDropdownValue = widget.post!.tags.first;
      titleController.text = widget.post!.type == PostType.text
          ? (widget.post as TextPost).title
          : '';
      taglineController.text = widget.post!.description;
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
                      Padding(
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
                      ),
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
                          controller: taglineController,
                          isLast: true,
                          hintText: 'Tagline',
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
                          hintText: 'Address',
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          minLines: 1,
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
                            if (typeDropdownValue == PostType.image &&
                                image == null &&
                                !isEdit) {
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
                                ? editPost(
                                    titleController.text,
                                    taglineController.text,
                                    typeDropdownValue,
                                    tagDropdownValue,
                                    image,
                                    context,
                                    widget.post!.id,
                                  )
                                : createBusiness(
                                    titleController.text,
                                    taglineController.text,
                                    addressController.text,
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
