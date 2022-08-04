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

        List<QueryDocumentSnapshot> postDocs = snapshot.data!.docs;

        // sort posts by vote count (in ascending order)
        postDocs.sort((a, b) {
          Map<String, dynamic> aData = a.data()! as Map<String, dynamic>;
          Map<String, dynamic> bData = b.data()! as Map<String, dynamic>;
          List aUpVotes = aData['upVotes'] ?? [];
          List bUpVotes = bData['upVotes'] ?? [];
          List aDownVotes = aData['downVotes'] ?? [];
          List bDownVotes = bData['downVotes'] ?? [];
          int aVoteCount = aUpVotes.length - aDownVotes.length;
          int bVoteCount = bUpVotes.length - bDownVotes.length;

          return aVoteCount.compareTo(bVoteCount);
        });

        return ListView(
            children: postDocs.reversed.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          return ImageCardComponent(
            title: data['title'],
            description: data['description'],
            image: 'assets/masjid.jpeg',
            upVotes: data['upVotes'] ?? [],
            downVotes: data['downVotes'] ?? [],
            firstName: data['createdBy']['firstName'] ?? '',
            lastName: data['createdBy']['lastName'] ?? '',
            tags: data['tags'] ?? [],
            postId: document.id,
          );
        }).toList());
      },
    );
  }
}
