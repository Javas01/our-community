import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  Community({
    this.id = '',
    required this.name,
  });

  String id, name;

  @override
  String toString() {
    return 'Community(\n id: $id\n name: $name\n)';
  }
}

Community communityFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;

  return Community(
    id: snapshot.id,
    name: data['name'],
  );
}

Map<String, Object> communityToFirestore(
    Community community, SetOptions? options) {
  return {
    'name': community.name,
  };
}
