import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_community/components/tag_component.dart';
import 'package:our_community/components/text_form_field_components.dart';
import 'package:our_community/actions/post_actions/create_post_action.dart';
import 'package:our_community/actions/post_actions/edit_post_action.dart';
import 'package:our_community/constants/tag_options.dart';

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({
    Key? key,
    this.tags,
    this.title,
    this.description,
    this.postId,
    required this.isEdit,
  }) : super(key: key);

  final List<dynamic>? tags;
  final String? title, description, postId;
  final bool isEdit;

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

  String typeDropdownValue = 'Text';
  late String tagDropdownValue;

  @override
  void initState() {
    if (widget.isEdit) {
      tagDropdownValue = widget.tags!.first;
      titleController.text = widget.title!;
      descriptionController.text = widget.description!;
    } else {
      tagDropdownValue = 'Other';
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
                    widget.isEdit ? 'Edit Post' : 'Create New Post',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 5),
                      DropdownButton<String>(
                        borderRadius: BorderRadius.circular(15),
                        hint: const Text('Type'),
                        value: typeDropdownValue,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        onChanged: (String? newValue) {
                          setState(() {
                            typeDropdownValue = newValue!;
                          });
                        },
                        items: <String>['Text']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
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
                        items: tagOptionsList
                            .map<DropdownMenuItem<String>>((value) {
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
                      const SizedBox(width: 5),
                    ],
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
                      maxLength: 500,
                      icon: const Icon(Icons.description_outlined),
                      controller: descriptionController,
                      isLast: true,
                      hintText: 'Description',
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      minLines: 8,
                    ),
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
                            widget.isEdit
                                ? editPost(
                                    titleController.text,
                                    descriptionController.text,
                                    typeDropdownValue,
                                    tagDropdownValue,
                                    context,
                                    widget.postId!,
                                    _formKey,
                                    () => Navigator.pop(context),
                                  )
                                : createPost(
                                    titleController.text,
                                    descriptionController.text,
                                    typeDropdownValue,
                                    tagDropdownValue,
                                    context,
                                    userId,
                                    _formKey,
                                    () => Navigator.pop(context),
                                  );
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
