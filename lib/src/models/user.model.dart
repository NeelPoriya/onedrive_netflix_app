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

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    lastLogin = DateTime.parse(json['lastLogin']);
    isAdmin = json['isAdmin'];
    status = UserStatus.values
        .firstWhere((e) => e.toString() == 'UserStatus.${json['status']}');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
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
