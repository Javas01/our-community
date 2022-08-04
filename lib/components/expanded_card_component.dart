import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post_comments_component.dart';
import 'text_field_components.dart';

class ExpandedCard extends StatefulWidget {
  late Stream<QuerySnapshot> _commentsStream;
  late CollectionReference comments;
  ExpandedCard(
      {Key? key,
      required this.image,
      required this.title,
      required this.description,
      required this.toggleExpanded,
      required this.postId})
      : super(key: key) {
    _commentsStream = FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .snapshots();
    comments = FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments');
  }

  final VoidCallback toggleExpanded;
  final String image, title, description, postId;

  @override
  State<ExpandedCard> createState() => _ExpandedCardState();
}

class _ExpandedCardState extends State<ExpandedCard> {
  final firstName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[0];
  final lastName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[1];
  final userId = FirebaseAuth.instance.currentUser!.uid;

  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  widget.toggleExpanded();
                },
                child: Column(children: [
                  Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        widget.image,
                        width: 200,
                      )),
                  Text(widget.description),
                ]),
              ),
              const Divider(
                height: 10,
                thickness: 2,
              ),
              PostComments(commentsStream: widget._commentsStream),
              SizedBox(
                height: 50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child:
                            CommentField(commentController: commentController)),
                    const SizedBox(
                      width: 5,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(50, 50),
                            shape: const CircleBorder()),
                        onPressed: () => addComment(commentController.text),
                        child: const Icon(Icons.send_rounded)),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Future<void> addComment(String text) {
    if (text == '') {
      const snackBar = SnackBar(content: Text('Comment cant be empty'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return Future.value();
    }
    commentController.text = '';
    return widget.comments
        .add({
          'text': text,
          'createdBy': {
            'firstName': firstName,
            'lastName': lastName,
            'id': userId,
          },
        })
        .then((value) => print(value))
        .catchError((error) => print("Failed to add comment: $error"));
  }
}
