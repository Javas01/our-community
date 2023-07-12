import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { text, image, event }

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

  String imageUrl;

  @override
  String toString() =>
      'ImagePost(\n createdBy: $createdBy\n description: $description\n imageUrl: $imageUrl\n tags: $tags\n type: $type\n hasSeen: $hasSeen\n $timestamp\n)';
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

  String title;

  @override
  String toString() =>
      'TextPost(\n createdBy: $createdBy\n title: $title\n description: $description\n tags: $tags\n type: $type\n hasSeen: $hasSeen\n $timestamp\n)';
}

class EventPost extends Post {
  EventPost({
    super.id,
    required super.createdBy,
    required super.description,
    required super.tags,
    super.type = PostType.event,
    required super.timestamp,
    required this.title,
    required this.location,
    required this.audience,
    required this.price,
    required this.date,
    required this.imageUrl,
    super.hasSeen,
    super.downVotes,
    super.lastEdited,
    super.upVotes,
  });

  String title,
      location,
      audience,
      price,
      imageUrl; // TODO: Make audience and price enum
  DateTime date;

  @override
  String toString() =>
      'TextPost(\n createdBy: $createdBy\n title: $title\n description: $description\n tags: $tags\n type: $type\n hasSeen: $hasSeen\n $timestamp\n)';
}

Post postFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;
  final PostType postType = () {
    switch (data['type'] as String) {
      case 'text':
        return PostType.text;
      case 'image':
        return PostType.image;
      case 'event':
        return PostType.event;
      default:
        return PostType.text;
    }
  }();

  switch (postType) {
    case PostType.text:
      return TextPost(
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
      );
    case PostType.image:
      return ImagePost(
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
    case PostType.event:
      return EventPost(
        id: snapshot.id,
        createdBy: data['createdBy'],
        description: data['description'],
        tags: data['tags']?.cast<String>() ?? [],
        type: postType,
        timestamp: data['timestamp'],
        title: data['title'],
        location: data['location'],
        audience: data['audience'],
        imageUrl: data['imageUrl'] ?? '',
        price: data['price'],
        date: data['date'].toDate(),
        upVotes: data['upVotes']?.cast<String>() ?? [],
        downVotes: data['downVotes']?.cast<String>() ?? [],
        lastEdited: data['lastEdited'],
        hasSeen: data['hasSeen']?.cast<String>() ?? [],
      );
  }
}

Map<String, Object> postToFirestore(Post post, SetOptions? options) {
  switch (post.type) {
    case PostType.text:
      return {
        'createdBy': post.createdBy,
        'title': (post as TextPost).title,
        'description': post.description,
        'tags': post.tags,
        'type': post.type.name,
        'timestamp': post.timestamp,
      };
    case PostType.image:
      return {
        'createdBy': post.createdBy,
        'imageUrl': (post as ImagePost).imageUrl,
        'description': post.description,
        'tags': post.tags,
        'type': post.type.name,
        'timestamp': post.timestamp,
      };
    case PostType.event:
      return {
        'createdBy': post.createdBy,
        'title': (post as EventPost).title,
        'imageUrl': post.imageUrl,
        'description': post.description,
        'location': post.location,
        'audience': post.audience,
        'price': post.price,
        'date': post.date,
        'tags': post.tags,
        'type': post.type.name,
        'timestamp': post.timestamp,
      };
  }
}
