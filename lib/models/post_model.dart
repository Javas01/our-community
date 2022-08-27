import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { text, image }

abstract class Post {
  Post({
    this.id = '',
    required this.createdBy,
    required this.description,
    required this.tags,
    required this.type,
    required this.timestamp,
    this.hasSeen = const [],
    this.upVotes = const [],
    this.downVotes = const [],
    this.lastEdited,
  });

  String id, createdBy, description;
  PostType type;
  List<String> tags, upVotes, downVotes, hasSeen;
  Timestamp timestamp;
  Timestamp? lastEdited;

  String get title => '';
  String get imageUrl => '';

  @override
  String toString() {
    return 'Post(\n createdBy: $createdBy\n description: $description\n tags: $tags\n type: $type\n hasSeen: $hasSeen\n $timestamp\n)';
  }
}

class ImagePost extends Post {
  ImagePost({
    super.id,
    required super.createdBy,
    required super.description,
    required super.tags,
    super.type = PostType.image,
    required super.timestamp,
    required this.imageUrl,
    super.hasSeen,
    super.downVotes,
    super.lastEdited,
    super.upVotes,
  });

  @override
  String imageUrl;
}

class TextPost extends Post {
  TextPost({
    super.id,
    required super.createdBy,
    required super.description,
    required super.tags,
    super.type = PostType.text,
    required super.timestamp,
    required this.title,
    super.hasSeen,
    super.downVotes,
    super.lastEdited,
    super.upVotes,
  });

  @override
  String title;
}

Post postFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;
  final PostType postType =
      data['type'] == PostType.text.name ? PostType.text : PostType.image;

  return postType == PostType.text
      ? TextPost(
          id: snapshot.id,
          createdBy: data['createdBy'],
          description: data['description'],
          tags: data['tags'].cast<String>(),
          type: postType,
          timestamp: data['timestamp'],
          title: data['title'],
          upVotes: data['upVotes']?.cast<String>() ?? [],
          downVotes: data['downVotes']?.cast<String>() ?? [],
          lastEdited: data['lastEdited'],
          hasSeen: data['hasSeen']?.cast<String>() ?? [],
        )
      : ImagePost(
          id: snapshot.id,
          createdBy: data['createdBy'],
          description: data['description'],
          tags: data['tags'].cast<String>(),
          type: postType,
          timestamp: data['timestamp'],
          imageUrl: data['imageUrl'],
          upVotes: data['upVotes']?.cast<String>() ?? [],
          downVotes: data['downVotes']?.cast<String>() ?? [],
          lastEdited: data['lastEdited'],
          hasSeen: data['hasSeen']?.cast<String>() ?? [],
        );
}

Map<String, Object> postToFirestore(Post post, SetOptions? options) {
  return post.type == PostType.text
      ? {
          'createdBy': post.createdBy,
          'title': post.title,
          'description': post.description,
          'tags': post.tags,
          'type': post.type.name,
          'timestamp': post.timestamp,
        }
      : {
          'createdBy': post.createdBy,
          'imageUrl': post.imageUrl,
          'description': post.description,
          'tags': post.tags,
          'type': post.type.name,
          'timestamp': post.timestamp,
        };
}
