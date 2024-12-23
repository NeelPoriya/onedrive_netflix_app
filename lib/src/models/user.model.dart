class User {
  late String id;
  late String email;
  late String name;
  late DateTime createdAt;
  late DateTime updatedAt;
  late DateTime lastLogin;
  late bool isAdmin;
  late UserStatus status;

  User();

  User.withDetails(
      {required this.email,
      required this.name,
      required this.createdAt,
      required this.updatedAt,
      required this.lastLogin,
      required this.isAdmin,
      required this.status});

  User.fromMap(Map<dynamic, dynamic> map, this.id) {
    email = map['email'];
    name = map['name'];
    createdAt = DateTime.parse(map['createdAt']);
    updatedAt = DateTime.parse(map['updatedAt']);
    lastLogin = DateTime.parse(map['lastLogin']);
    isAdmin = map['isAdmin'];
    status = UserStatus.values.firstWhere(
        (element) => element.toString().split('.').last == map['status']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['name'] = name;
    data['createdAt'] = createdAt.toIso8601String();
    data['updatedAt'] = updatedAt.toIso8601String();
    data['lastLogin'] = lastLogin.toIso8601String();
    data['isAdmin'] = isAdmin;
    data['status'] = status.toString().split('.').last;
    return data;
  }

  bool isValid() {
    return id.isNotEmpty && email.isNotEmpty && name.isNotEmpty;
  }
}

enum UserStatus { pending, requested, approved, rejected, created }
