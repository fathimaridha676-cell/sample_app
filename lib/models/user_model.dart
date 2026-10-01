class UserModel {
  final String id;
  final String name;
  final int age;
  final String email;
  final String phone;
  final String password;
  final String role;
  final bool deleted;
  final bool isBlocked;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.deleted = false,
    this.isBlocked = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    int? age,
    String? email,
    String? phone,
    String? password,
    String? role,
    bool? deleted,
    bool? isBlocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      deleted: deleted ?? this.deleted,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'deleted': deleted,
      'isBlocked': isBlocked,
    };
  }
}
