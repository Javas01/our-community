import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({Key? key, this.post, this.users}) : super(key: key);
  final Post? post;
  final List<AppUser>? users;

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final _formKey = GlobalKey<FormState>();
  final firstName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[0];
  final lastName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[1];
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? image;
  PostType typeDropdownValue = PostType.text;
  String tagDropdownValue = 'Other';
  bool isEdit = false;
  bool isInvalidImage = false;

  @override
  void initState() {
    if (widget.post != null) {
      isEdit = true;
      typeDropdownValue = widget.post!.type;
      tagDropdownValue = widget.post!.tags.first;
      titleController.text = widget.post!.type == PostType.text
          ? (widget.post as TextPost).title
          : '';
      descriptionController.text = widget.post!.description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isEvent = tagDropdownValue == 'Events';

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
                  isEdit ? 'Edit Post' : 'Create New Post',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 5),
                    DropdownButton<PostType>(
                      disabledHint:
                          isEdit ? Text(widget.post!.type.name) : null,
                      borderRadius: BorderRadius.circular(15),
                      hint: const Text('Type'),
                      value: typeDropdownValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      onChanged: (newValue) {
                        setState(() {
                          typeDropdownValue = newValue!;
                        });
                      },
                      items: isEdit
                          ? null // items null disables dropdown button
                          : PostType.values.map((value) {
                              return DropdownMenuItem<PostType>(
                                value: value,
                                child: Text(value.name),
                              );
                            }).toList(),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      borderRadius: BorderRadius.circular(15),
                      hint: const Text('Tag'),
                      value: tagDropdownValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      onChanged: (String? newValue) {
                        setState(() {
                          tagDropdownValue = newValue!;
                        });
                      },
                      items:
                          (Provider.of<Community>(context, listen: false).id !=
                                      'Lwdm-2023'
                                  ? tagOptionsList
                                  : conferenceTagOptionsList)
                              .map((value) {
                        return DropdownMenuItem<String>(
                          value: value.keys.first,
                          child: Row(
                            children: [
                              Tag(
                                color: value.values.first,
                                title: '',
                                dontExpand: true,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(value.keys.first),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                typeDropdownValue == PostType.text
                    ? Column(
                        children: [
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
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: FormInputField(
                              maxLength: 500,
                              icon: const Icon(Icons.description_rounded),
                              controller: descriptionController,
                              isLast: true,
                              hintText: 'Description',
                              keyboardType: TextInputType.multiline,
                              maxLines: 8,
                              minLines: 8,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
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
                                        color:
                                            isInvalidImage ? Colors.red : null,
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
                                          (widget.post as ImagePost).imageUrl,
                                          height: 300,
                                        ),
                                ),
                          FormInputField(
                            maxLength: 50,
                            icon: const Icon(Icons.description_rounded),
                            hintText: 'Caption',
                            controller: descriptionController,
                            isLast: true,
                            maxLines: 1,
                            validator: (_) => null,
                          ),
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
                                  descriptionController.text,
                                  typeDropdownValue,
                                  tagDropdownValue,
                                  image,
                                  context,
                                  widget.post!.id,
                                )
                              : createPost(
                                  titleController.text,
                                  descriptionController.text,
                                  typeDropdownValue,
                                  tagDropdownValue,
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
            ),
          ),
        ),
      ),
    );
  }
}
