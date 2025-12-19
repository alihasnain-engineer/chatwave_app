class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final DateTime? dateOfBirth;
  final String? displayName;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.dateOfBirth,
    this.displayName,
    this.photoUrl,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      dateOfBirth: data['dateOfBirth']?.toDate(),
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  String get displayNameOrFullName => displayName ?? fullName;
}

