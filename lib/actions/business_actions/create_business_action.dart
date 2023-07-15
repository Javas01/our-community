import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:our_ummah/models/business_model.dart';

Future<void> createBusiness(
  String title,
  String tagline,
  String address,
  List<String> tags,
  File? image,
  String communityCode,
  String userId,
  void Function(Object)? onError,
) async {
  final businesses = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Businesses')
      .withConverter(
        fromFirestore: businessFromFirestore,
        toFirestore: businessToFirestore,
      );
  try {
    final newBusiness = Business(
      title: title,
      tagline: tagline,
      address: address,
      tags: tags,
      createdBy: userId,
    );
    final businessDocRef = await businesses.add(newBusiness);
    print(businessDocRef.id);
    if (image != null) {
      await FirebaseStorage.instance
          .ref('businessPics')
          .child(businessDocRef.id)
          .putFile(image);

      final businessLogoUrl = await FirebaseStorage.instance
          .ref('businessPics')
          .child(businessDocRef.id)
          .getDownloadURL();

      businessDocRef.update({'businessLogoUrl': businessLogoUrl});
    }
  } catch (e) {
    // ignore: avoid_print
    onError != null ? onError(e) : print(e);
  }
}
