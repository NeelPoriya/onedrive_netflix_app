class Account {
  late String id;
  late String email;
  late String name;

  Account();

  Account.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['name'] = name;
    return data;
  }

  Account.fromMap(String key, Map<dynamic, dynamic> data) {
    id = key;
    email = data['email'];
    name = data['name'];
  }
}
