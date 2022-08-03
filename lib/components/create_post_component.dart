import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostModal extends StatelessWidget {
  CreatePostModal({
    Key? key,
  }) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  CollectionReference posts = FirebaseFirestore.instance.collection('Posts');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      color: Colors.redAccent,
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
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        hintText: 'Title',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
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
                          createPost(titleController.text,
                              descriptionController.text, context);
                        },
                        child: const Text('Submit'))
                  ],
                )
              ],
            )),
      ),
    );
  }

  Future<void> createPost(
      String title, String description, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      return posts
          .add({
            'title': title,
            'description': description,
          })
          .then((value) => Navigator.pop(context))
          .catchError((error) => print("Failed to create post: $error"));
    } else {
      return Future.error('Invalid post');
    }
  }
}
