class Folder {
  late String id;
  late String name;
  late String accountId;

  Folder();

  Folder.fromMap(String key, Map<dynamic, dynamic> values) {
    id = key;
    name = values['name'];
    accountId = values['accountId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['accountId'] = accountId;
    return data;
  }

  bool isValid() {
    return id.isNotEmpty && name.isNotEmpty && accountId.isNotEmpty;
  }
}
