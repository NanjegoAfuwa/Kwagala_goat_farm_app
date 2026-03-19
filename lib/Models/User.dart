class FarmUser {
  final String id;
  final String name;
  final String email;
  final String role;

  FarmUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  factory FarmUser.fromMap(Map<String, dynamic> map) {
    return FarmUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
    );
  }
}