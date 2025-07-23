class User {
  final String uid;
  final String name;
  final String email;
  final String proPicUrl;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.proPicUrl,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': name,
    'email': email,
    'proPic': proPicUrl,
  };

  factory User.fromMap(dynamic map) {
    return User(
      uid: map['uid']?.toString() ?? '',
      name: map['displayName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      proPicUrl: map['proPic']?.toString() ?? '',
    );
  }
}
