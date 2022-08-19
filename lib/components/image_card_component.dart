import 'package:flutter/material.dart';
import 'package:our_community/actions/show_popup_menu_action.dart';
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
