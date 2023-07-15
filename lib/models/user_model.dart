import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser({
    this.id = '',
    required this.firstName,
    required this.lastName,
    required this.communityCodes,
    this.blockedUsers = const [],
    this.profilePicUrl = '',
    this.tokens = const [],
    this.businessIds = const [],
  });

  String id, firstName, lastName, profilePicUrl;
  List<String> blockedUsers, communityCodes, tokens, businessIds;

  @override
  String toString() {
    return 'Comment(\n firstName: $firstName\n lastName: $lastName\n blockedUsers: $blockedUsers\n)';
  }
}

AppUser userFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;

  return AppUser(
    id: snapshot.id,
    firstName: data['firstName'],
    lastName: data['lastName'],
    profilePicUrl: data['profilePicUrl'] ?? '',
    blockedUsers: data['blockedUsers']?.cast<String>() ?? [],
    communityCodes: data['communityCodes']?.cast<String>() ?? [],
    tokens: data['tokens']?.cast<String>() ?? [],
    businessIds: data['businessIds']?.cast<String>() ?? [],
  );
}

Map<String, Object> userToFirestore(AppUser user, SetOptions? options) {
  return {
    'firstName': user.firstName,
    'lastName': user.lastName,
    'communityCodes': user.communityCodes,
  };
}
