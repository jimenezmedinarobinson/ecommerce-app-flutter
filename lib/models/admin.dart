class Admin {
  final String? id;
  final String username;
  final String email;
  final String? token;

  Admin({
    this.id,
    required this.username,
    required this.email,
    this.token,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] ?? json['_id']?.toString(),
      username: json['username'],
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }
}
