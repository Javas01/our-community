import 'dart:convert';
import 'package:flutter/material.dart';
import 'expanded_card_component.dart';
import 'preview_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ImageCardComponent extends StatefulWidget {
  const ImageCardComponent({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
    required this.postId,
    required this.upVotes,
    required this.downVotes,
    required this.firstName,
    required this.lastName,
    required this.tags,
    required this.creatorId,
    required this.resetValueNotifier,
  }) : super(key: key);

  final String image,
      title,
      description,
      postId,
      firstName,
      lastName,
      creatorId;
  final List<dynamic> upVotes, downVotes, tags;
  final ValueNotifier<bool> resetValueNotifier;

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

    showMenu(
      context: context,
      items: [
        PopupMenuItem(
          value: 1,
          onTap: isCreator ? deletePost : flagPost,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: isCreator
                ? const [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    )
                  ]
                : const [
                    Icon(
                      Icons.flag,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Flag',
                    )
                  ],
          ),
        )
      ],
      position: RelativeRect.fromRect(
        _tapPosition! & context.size!, // smaller rect, the touch area
        Offset.zero & overlay.size, // Bigger rect, the entire screen
      ),
    );

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
                firstName: widget.firstName,
                lastName: widget.lastName,
                tags: widget.tags,
                isSelected: dataKey == _selectedPostKey ? true : false,
              ),
            ),
    );
  }

  void deletePost() {
    const snackBar = SnackBar(content: Text('Post deleted'));

    FirebaseFirestore.instance
        .collection('Communities')
        .doc('ATLMasjid')
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
    final response = await http.post(url,
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
        }));
    print(response.body);

    const snackBar = SnackBar(
      content: Text(
          'Thank you, we received your report and will make a decision after reviewing'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
