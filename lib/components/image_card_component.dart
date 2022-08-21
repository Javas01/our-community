import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_community/actions/show_popup_menu_action.dart';
import 'package:our_community/config.dart';
import 'package:our_community/models/post_model.dart';
import 'package:our_community/models/user_model.dart';
import 'package:our_community/components/expanded_card_component.dart';
import 'package:our_community/components/preview_card_component.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    if (!widget.post.hasSeen.contains(userId)) {
      final hasSeen = widget.post.hasSeen;
      hasSeen.add(userId);
      FirebaseFirestore.instance
          .collection('Communities')
          .doc(communityCode)
          .collection('Posts')
          .doc(widget.post.id)
          .withConverter(
            fromFirestore: postFromFirestore,
            toFirestore: postToFirestore,
          )
          .update({'hasSeen': hasSeen});
    }
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
              post: widget.post,
              setExpanded: setExpanded,
            )
          : GestureDetector(
              onLongPress: () async {
                setState(() {
                  _selectedPostKey = dataKey;
                });
                await showPopupMenu(context, widget.post, _tapPosition!);
                setState(() {
                  _selectedPostKey = null;
                });
              },
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
}
