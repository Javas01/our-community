import 'package:flutter/material.dart';
import 'package:our_community/actions/flag_content_action.dart';
import 'package:our_community/components/create_post_component.dart';
import 'package:our_community/models/post_model.dart';
import 'package:our_community/models/user_model.dart';
import 'package:our_community/components/expanded_card_component.dart';
import 'package:our_community/components/preview_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_community/config.dart' show communityCode;

class ImageCardComponent extends StatefulWidget {
  const ImageCardComponent({
    Key? key,
    required this.resetValueNotifier,
    required this.postCreator,
    required this.post,
  }) : super(key: key);

  final Post post;
  final ValueNotifier<bool> resetValueNotifier;
  final AppUser postCreator;

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
    final isCreator = userId == widget.post.createdBy;
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
              tags: widget.post.tags,
              title: widget.post.title,
              description: widget.post.description,
              postId: widget.post.id,
              isEdit: true,
            );
          }),
        );
      } else if (value == 1) {
        flagContent(
          userEmail,
          userId,
          widget.post.id,
          null,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Thank you, we received your report and will make a decision after reviewing',
                ),
              ),
            );
          },
        );
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
              description: widget.post.description,
              title: widget.post.title,
              setExpanded: setExpanded,
              postId: widget.post.id,
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
                itemKey: dataKey,
                post: widget.post,
                postCreator: widget.postCreator,
                isSelected: dataKey == _selectedPostKey ? true : false,
                isCreator: userId == widget.post.createdBy,
              ),
            ),
    );
  }

  void deletePost() async {
    const snackBar = SnackBar(content: Text('Post deleted'));
    try {
      await FirebaseFirestore.instance
          .collection('Communities')
          .doc(communityCode)
          .collection('Posts')
          .doc(widget.post.id)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      Future.error('Error deleting post $e');
    }
  }
}
