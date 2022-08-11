import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post_comments_component.dart';
import 'text_field_components.dart';

class ExpandedCard extends StatefulWidget {
  late Stream<QuerySnapshot> _commentsStream;
  late CollectionReference comments;
  ExpandedCard({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
    required this.setExpanded,
    required this.postId,
  }) : super(key: key) {
    _commentsStream = FirebaseFirestore.instance
        .collection('Communities')
        .doc('ATLMasjid')
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .snapshots();
    comments = FirebaseFirestore.instance
        .collection('Communities')
        .doc('ATLMasjid')
        .collection('Posts')
        .doc(postId)
        .collection('Comments');
  }

  final void Function(bool) setExpanded;
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

  void unFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
    Scrollable.ensureVisible(
      context,
      alignment: 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unFocus,
      child: Card(
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Stack(
          children: [
            Positioned(
              top: -5,
              right: -5,
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => widget.setExpanded(false),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.setExpanded(false);
                    },
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            widget.description,
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 10,
                    thickness: 2,
                  ),
                  PostComments(
                    commentsStream: widget._commentsStream,
                    postId: widget.postId,
                    unFocus: unFocus,
                  ),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                            child: CommentField(
                              commentController: commentController,
                              hintText: 'Reply to post',
                              unFocus: unFocus,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(50, 50),
                            shape: const CircleBorder(),
                          ),
                          onPressed: () {
                            unFocus();
                            addComment(commentController.text);
                          },
                          child: const Icon(
                            Icons.send_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addComment(String text) {
    if (text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cant be empty')),
      );
      return Future.value();
    }
    commentController.text = '';

    return widget.comments.add({
      'text': text,
      'isReply': false,
      'createdBy': {
        'firstName': firstName,
        'lastName': lastName,
        'id': userId,
      },
      'timestamp': FieldValue.serverTimestamp(),
    }).catchError((error) => print("Failed to add comment: $error"));
  }
}
