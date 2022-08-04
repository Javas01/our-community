import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_community/components/tag_component.dart';
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

  final CollectionReference posts =
      FirebaseFirestore.instance.collection('Posts');

  String? typeDropdownValue = 'Image';
  String? tagDropdownValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      color: Colors.lightBlueAccent,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
            key: _formKey,
            child: Column(
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
                      items: <String>['Image']
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
                      items:
                          tagOptionsList.map<DropdownMenuItem<String>>((value) {
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
                TextFormField(
                  controller: titleController,
                  onSaved: (value) {
                    titleController.text = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ('Title cannot be empty');
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.title),
                      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      hintText: 'Title',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 10),
                TextFormField(
                    controller: descriptionController,
                    onSaved: (value) {
                      descriptionController.text = value!;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return ('Description cannot be empty');
                      }
                      return null;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 9,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.description),
                        hintText: 'Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
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
          })
          .then((value) => Navigator.pop(context))
          .catchError((error) => print("Failed to create post: $error"));
    } else {
      return Future.error('Invalid post');
    }
  }
}
