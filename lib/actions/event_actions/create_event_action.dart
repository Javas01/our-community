import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/models/post_model.dart';

Future<void> createEvent(
  String title,
  String description,
  String location,
  List<String> tags,
  File? image,
  String communityCode,
  String userId,
  String audience,
  String price,
  DateTime date,
  void Function(Object)? onError,
) async {
  try {
    final events = FirebaseFirestore.instance
        .collection('Communities')
        .doc(communityCode)
        .collection('Posts')
        .withConverter(
          fromFirestore: postFromFirestore,
          toFirestore: postToFirestore,
        );
    final newEvent = EventPost(
      createdBy: userId,
      description: description,
      tags: tags,
      timestamp: Timestamp.now(),
      title: title,
      location: location,
      audience: audience,
      price: price,
      date: date,
      imageUrl: '',
    );
    final eventDocRef = await events.add(newEvent);
    print(eventDocRef.id);
    // if (image != null) {
    //   await FirebaseStorage.instance
    //       .ref('BusinessPics')
    //       .child(eventDocRef.id)
    //       .putFile(image);

    //   final imageUrl = await FirebaseStorage.instance
    //       .ref('BusinessPics')
    //       .child(eventDocRef.id)
    //       .getDownloadURL();

    //   eventDocRef.update({'imageUrl': imageUrl});
    // }
  } catch (e) {
    // ignore: avoid_print
    onError != null ? onError(e) : print(e);
  }
}
