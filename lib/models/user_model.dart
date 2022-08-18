import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.blockedUsers,
    this.profilePicUrl,
  });

  String id, firstName, lastName;
  List<String> blockedUsers;
  String? profilePicUrl;
}

AppUser userFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;

  return AppUser(
    id: snapshot.id,
    firstName: data['firstName'],
    lastName: data['lastName'],
    profilePicUrl: data['profilePicUrl'],
    blockedUsers: data['blockedUsers']?.cast<String>() ?? [],
  );
}

Map<String, Object> userToFirestore(AppUser user, SetOptions? options) {
  return {
    'firstName': {user.firstName},
    'lastName': {user.lastName},
  };
}
