// ignore_for_file: avoid_print
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:our_ummah/actions/post_actions/create_post_action.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:test/test.dart';

void main() {
  group('adds a post to a collection:', () {
    test('adds a text post to a collection', () async {
      final instance = FakeFirebaseFirestore();
      final collection = instance.collection('Posts').withConverter(
            fromFirestore: postFromFirestore,
            toFirestore: postToFirestore,
          );
      await createPost(
        'title',
        'description',
        PostType.text,
        'tag',
        null,
        '',
        false,
        'userId',
        null,
        collection,
      );

      final snapshot = await collection.get();
      final newPost = snapshot.docs.first.data();
      final expectedPost = TextPost(
        type: PostType.text,
        createdBy: 'userId',
        description: 'description',
        tags: ['tag'],
        timestamp: newPost.timestamp, // would never match otherwise
        title: 'title',
        isAd: false,
      );

      print(expectedPost.toString());
      print(newPost.toString());
      expect(newPost.toString(), expectedPost.toString());
    });

    test('adds an image post to a collection', () async {
      final instance = FakeFirebaseFirestore();
      final collection = instance.collection('Posts').withConverter(
            fromFirestore: postFromFirestore,
            toFirestore: postToFirestore,
          );
      await createPost(
        '',
        'description',
        PostType.image,
        'tag',
        null, // cant test image storage without fake firebase storage
        '',
        false,
        'userId',
        null,
        collection,
      );

      final snapshot = await collection.get();
      final newPost = snapshot.docs.first.data();
      final expectedPost = ImagePost(
        type: PostType.image,
        createdBy: 'userId',
        description: 'description',
        tags: ['tag'],
        timestamp: newPost.timestamp, // would never match otherwise
        imageUrl: '', isAd: false,
      );

      print(expectedPost.toString());
      print(newPost.toString());
      expect(newPost.toString(), expectedPost.toString());
    });
  });
}
