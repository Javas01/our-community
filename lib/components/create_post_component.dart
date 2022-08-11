import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_community/components/tag_component.dart';
import 'package:our_community/components/text_form_field_components.dart';
import '../constants/tag_options.dart';

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({
    Key? key,
  }) : super(key: key);

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

  final CollectionReference posts = FirebaseFirestore.instance
      .collection('Communities')
      .doc('ATLMasjid')
      .collection('Posts');

  String? typeDropdownValue = 'Text';
  String? tagDropdownValue = 'Other';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Container(
        constraints: const BoxConstraints(minHeight: 500),
        color: Colors.lightBlueAccent,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create New Post",
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
                    maxLength: 50,
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
                            createPost(
                              titleController.text,
                              descriptionController.text,
                              typeDropdownValue ?? '',
                              tagDropdownValue ?? '',
                              context,
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

  Future<void> createPost(String title, String description, String type,
      String tag, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      return posts
          .add({
            'title': title,
            'description': description,
            'createdBy': {
              'firstName': firstName,
              'lastName': lastName,
              'id': userId
            },
            'type': type,
            'tags': tag.isNotEmpty ? [tag] : null,
            'timestamp': FieldValue.serverTimestamp(),
          })
          .then((value) => Navigator.pop(context))
          .catchError((error) => print("Failed to create post: $error"));
    } else {
      return Future.error('Invalid post');
    }
  }
}
