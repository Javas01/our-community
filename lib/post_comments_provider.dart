import 'package:flutter/material.dart';

class PostCommentsModel extends ChangeNotifier {
  final expandedCardKey = GlobalKey<ScaffoldState>();
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();
  bool _isReply = false;
  bool _isEdit = false;
  String _parentCommentCreator = '';
  String _parentCommentText = '';
  List<String> _parentCommentReplies = [];
  String _parentCommentId = '';

  void unFocus() {
    FocusScope.of(expandedCardKey.currentContext!).requestFocus(FocusNode());
    Scrollable.ensureVisible(
      expandedCardKey.currentContext!,
      alignment: 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void reply(
    String parentCommentCreator,
    String parentCommentText,
    List<String> parentCommentReplies,
    String parentCommentId,
  ) {
    _isReply = true;
    _parentCommentCreator = parentCommentCreator;
    _parentCommentText = parentCommentText;
    _parentCommentReplies = parentCommentReplies;
    _parentCommentId = parentCommentId;
    notifyListeners();
  }

  void edit(
    String commentText,
    String commentId,
  ) {
    _isEdit = true;
    _parentCommentId = commentId;
    _parentCommentText = commentText;
    commentController.text = commentText;
    notifyListeners();
  }

  void reset() {
    _isEdit = false;
    _isReply = false;
    _parentCommentCreator = '';
    _parentCommentText = '';
    _parentCommentReplies = [];
    _parentCommentId = '';
    commentController.clear();
    notifyListeners();
  }

  bool get isReply => _isReply;
  bool get isEdit => _isEdit;
  String get parentCommentCreator => _parentCommentCreator;
  String get parentCommentText => _parentCommentText;
  List<String> get parentCommentReplies => _parentCommentReplies;
  String get parentCommentId => _parentCommentId;
}
