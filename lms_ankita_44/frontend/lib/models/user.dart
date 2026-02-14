class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String userType;

  // 🔑 password OPTIONAL
  final String? password;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.userType,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      userType: json['userType'] ?? 'STUDENT',
    );
  }

  // used ONLY for register / login
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'userType': userType,
    };
  }
}
