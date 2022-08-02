import 'package:flutter/material.dart';
import 'package:our_community/components/image_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListScreen extends StatelessWidget {
  ListScreen({
    Key? key,
  }) : super(key: key);

  final Stream<QuerySnapshot> _postsStream =
      FirebaseFirestore.instance.collection('Posts').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _postsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          return ImageCardComponent(
            title: data['title'],
            description: data['description'],
            image: 'assets/masjid.jpeg',
          );
        }).toList());
      },
    );
  }
}
