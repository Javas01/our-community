import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_ummah/actions/pick_image_action.dart';
import 'package:our_ummah/components/tag_component.dart';
import 'package:our_ummah/components/text_form_field_components.dart';
import 'package:our_ummah/actions/post_actions/create_post_action.dart';
import 'package:our_ummah/actions/post_actions/edit_post_action.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/models/post_model.dart';

class CreatePostModal extends StatefulWidget {
  CreatePostModal({Key? key, this.post}) : super(key: key);
  Post? post;

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
                        .headline5!
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
                        items: tagOptionsList.map((value) {
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
                                ? IconButton(
                                    iconSize: 250,
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
                            // const SizedBox(height: 10),
                            FormInputField(
                              maxLength: 50,
                              icon: const Icon(Icons.description_rounded),
                              hintText: 'Caption',
                              controller: descriptionController,
                              isLast: true,
                              maxLines: 1,
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
                                      context,
                                      userId,
                                    );
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Submit'))
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}
