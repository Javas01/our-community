import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  Post({
    required this.id,
    required this.createdBy,
    required this.description,
    required this.title,
    required this.tags,
    required this.timestamp,
    required this.type,
    required this.upVotes,
    required this.downVotes,
    this.lastEdited,
  });

  String id, createdBy, description, title, type;
  List<String> tags, upVotes, downVotes;
  Timestamp timestamp;
  Timestamp? lastEdited;
}

Post postFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;

  return Post(
    id: snapshot.id,
    createdBy: data['createdBy'],
    description: data['description'],
    title: data['title'],
    tags: data['tags'].cast<String>(),
    timestamp: data['timestamp'],
    type: data['type'],
    upVotes: data['upVotes']?.cast<String>() ?? [],
    downVotes: data['downVotes']?.cast<String>() ?? [],
    lastEdited: data['lastEdited'],
  );
}

Map<String, Object> postToFirestore(Post post, SetOptions? options) {
  return {
    'createdBy': {post.createdBy},
    'description': {post.description},
    'title': {post.title},
    'tags': {post.tags},
    'timestamp': {post.timestamp},
    'type': {post.type},
    'upVotes': {post.upVotes},
    'downVotes': {post.downVotes},
  };
}
