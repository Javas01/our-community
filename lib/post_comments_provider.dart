import 'package:flutter/material.dart';

class PostCommentsModel extends ChangeNotifier {
  final expandedCardKey = GlobalKey<ScaffoldState>();
  bool _isReply = false;
  String _parentCommentCreator = '';
  String _parentCommentText = '';
  List<String> _parentCommentReplies = [];
  String _parentCommentId = '';
  FocusNode commentFocusNode = FocusNode();

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

  void reset() {
    _isReply = false;
    _parentCommentCreator = '';
    _parentCommentText = '';
    _parentCommentReplies = [];
    _parentCommentId = '';
    notifyListeners();
  }

  bool get isReply => _isReply;
  String get parentCommentCreator => _parentCommentCreator;
  String get parentCommentText => _parentCommentText;
  List<String> get parentCommentReplies => _parentCommentReplies;
  String get parentCommentId => _parentCommentId;
}
