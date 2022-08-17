import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:our_community/components/create_post_component.dart';
import 'expanded_card_component.dart';
import 'preview_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../config.dart' show communityCode;

class ImageCardComponent extends StatefulWidget {
  const ImageCardComponent({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
    required this.postId,
    required this.upVotes,
    required this.downVotes,
    required this.tags,
    required this.timestamp,
    required this.creatorId,
    required this.resetValueNotifier,
    required this.lastEdited,
    required this.postCreator,
  }) : super(key: key);

  final String image, title, description, postId, creatorId;
  final List<dynamic> upVotes, downVotes, tags;
  final ValueNotifier<bool> resetValueNotifier;
  final Timestamp timestamp;
  final Timestamp? lastEdited;
  final Map postCreator;

  @override
  State<ImageCardComponent> createState() => _ImageCardComponentState();
}

class _ImageCardComponentState extends State<ImageCardComponent> {
  final dataKey = GlobalKey();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  bool _isExpanded = false;
  Offset? _tapPosition;
  GlobalKey? _selectedPostKey;
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Users').snapshots();

  void setExpanded(bool isExpanded) {
    setState(() {
      _isExpanded = isExpanded;
    });
  }

  void _showCustomMenu() {
    final isCreator = userId == widget.creatorId;
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    setState(() {
      _selectedPostKey = dataKey;
    });

    showMenu<int>(
      context: context,
      items: [
        PopupMenuItem(
          value: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: isCreator
                ? const [Icon(Icons.edit), SizedBox(width: 10), Text('Edit')]
                : const [Icon(Icons.flag), SizedBox(width: 10), Text('Flag')],
          ),
        ),
        if (isCreator)
          PopupMenuItem(
            value: 2,
            onTap: deletePost,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                )
              ],
            ),
          )
      ],
      position: RelativeRect.fromRect(
        _tapPosition! & context.size!, // smaller rect, the touch area
        Offset.zero & overlay.size, // Bigger rect, the entire screen
      ),
    ).then((value) {
      if (value == 1 && isCreator) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: ((context) {
            return CreatePostModal(
              tags: widget.tags,
              title: widget.title,
              description: widget.description,
              postId: widget.postId,
              isEdit: true,
            );
          }),
        );
      } else if (value == 1) {
        flagPost();
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _selectedPostKey = null;
      });
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resetValueNotifier.value) {
      setExpanded(false);
    }

    return SizedBox(
      key: dataKey,
      height: _isExpanded ? MediaQuery.of(context).size.height - 200 : null,
      child: _isExpanded
          ? ExpandedCard(
              description: widget.description,
              title: widget.title,
              image: widget.image,
              setExpanded: setExpanded,
              postId: widget.postId,
            )
          : GestureDetector(
              onLongPress: _showCustomMenu,
              onTapDown: _storePosition,
              onTap: () {
                setExpanded(true);
                Future.delayed(const Duration(milliseconds: 50), () {
                  Scrollable.ensureVisible(
                    dataKey.currentContext!,
                    alignment: 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                });
                widget.resetValueNotifier.value = false;
              },
              child: PreviewCard(
                description: widget.description,
                title: widget.title,
                image: widget.image,
                upVotes: widget.upVotes,
                downVotes: widget.downVotes,
                postId: widget.postId,
                itemKey: dataKey,
                postCreator: widget.postCreator,
                tags: widget.tags,
                isSelected: dataKey == _selectedPostKey ? true : false,
                timestamp: widget.timestamp,
                lastEdited: widget.lastEdited,
                creatorId: widget.creatorId,
                isCreator: userId == widget.creatorId,
              ),
            ),
    );
  }

  void deletePost() {
    const snackBar = SnackBar(content: Text('Post deleted'));

    FirebaseFirestore.instance
        .collection('Communities')
        .doc(communityCode)
        .collection('Posts')
        .doc(widget.postId)
        .delete()
        .then(
          (doc) => ScaffoldMessenger.of(context).showSnackBar(snackBar),
          onError: (e) => print("Error deleting post $e"),
        );
  }

  void flagPost() async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    await http
        .post(url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'accessToken': 'RSpCM_xJwri5l9DjMIGAy',
              'service_id': 'service_ydieaun',
              'template_id': 'template_ejdq7ar',
              'user_id': 'zycID_4Z1ijq9fgbW',
              'template_params': {
                'user_email': userEmail,
                'content_type': 'post',
                'user_id': userId,
                'post_id': widget.postId,
                'comment_id': '',
              }
            }))
        .then(
          (_) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Thank you, we received your report and will make a decision after reviewing'),
            ),
          ),
        );
  }
}
