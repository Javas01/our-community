import 'package:flutter/material.dart';
import 'expanded_card_component.dart';
import 'preview_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  }) : super(key: key);

  final String image,
      title,
      description,
      postId,
      firstName,
      lastName,
      creatorId;
  final List<dynamic> upVotes, downVotes, tags;

  @override
  State<ImageCardComponent> createState() => _ImageCardComponentState();
}

class _ImageCardComponentState extends State<ImageCardComponent> {
  final dataKey = GlobalKey();

  final userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isExpanded = false;

  void toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Offset? _tapPosition;

  GlobalKey? _selectedPostKey;

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
          onTap: isCreator ? deletePost : null,
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
    return SizedBox(
      key: dataKey,
      height: _isExpanded ? MediaQuery.of(context).size.height - 200 : null,
      child: _isExpanded
          ? ExpandedCard(
              description: widget.description,
              title: widget.title,
              image: widget.image,
              toggleExpanded: toggleExpanded,
              postId: widget.postId,
            )
          : GestureDetector(
              onLongPress: _showCustomMenu,
              onTapDown: _storePosition,
              child: PreviewCard(
                description: widget.description,
                title: widget.title,
                image: widget.image,
                toggleExpanded: toggleExpanded,
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
        .collection('Posts')
        .doc(widget.postId)
        .delete()
        .then(
          (doc) => ScaffoldMessenger.of(context).showSnackBar(snackBar),
          onError: (e) => print("Error deleting post $e"),
        );
  }
}
