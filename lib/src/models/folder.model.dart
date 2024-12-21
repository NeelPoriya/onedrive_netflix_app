class Folder {
  late String id;
  late String name;
  late String accountId;

  Folder();

  Folder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    accountId = json['accountId'];
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
