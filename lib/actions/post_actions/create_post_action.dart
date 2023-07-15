import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:our_ummah/models/post_model.dart';

Future<void> createPost(
  String title,
  String description,
  PostType type,
  String tag,
  File? image,
  String communityCode,
  bool isAd,
  String userId,
  void Function(Object)? onError, [
  CollectionReference<Post>? testCollection,
]) async {
  final posts = testCollection ??
      FirebaseFirestore.instance
          .collection('Communities')
          .doc(communityCode)
          .collection('Posts')
          .withConverter(
            fromFirestore: postFromFirestore,
            toFirestore: postToFirestore,
          );
  try {
    final newPost = type == PostType.image
        ? ImagePost(
            isAd: isAd,
            createdBy: userId,
            description: description,
            tags: [tag],
            type: type,
            timestamp: Timestamp.now(),
            imageUrl: '',
          )
        : TextPost(
            isAd: isAd,
            createdBy: userId,
            description: description,
            tags: [tag],
            type: type,
            timestamp: Timestamp.now(),
            title: title,
          );
    final postDocRef = await posts.add(newPost);
    if (image != null) {
      await FirebaseStorage.instance
          .ref('postPics')
          .child(postDocRef.id)
          .putFile(image);

      final imageUrl = await FirebaseStorage.instance
          .ref('postPics')
          .child(postDocRef.id)
          .getDownloadURL();

      postDocRef.update({'imageUrl': imageUrl});
    }
  } catch (e) {
    // ignore: avoid_print
    onError != null ? onError(e) : print(e);
  }
}
