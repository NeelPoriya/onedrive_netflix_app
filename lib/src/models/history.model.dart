class History {
  late String id;
  late String mediaId_userId;
  late DateTime lastWatchedAt;
  late String onedriveItemId;
  late int timestamp;
  late String userId;

  late DateTime createdAt;
  late DateTime modifiedAt;

  History();

  factory History.fromMap(String key, Map<dynamic, dynamic> values) {
    final history = History();
    history.id = key;
    history.mediaId_userId = values['mediaId_userId'];
    history.lastWatchedAt = DateTime.parse(values['lastWatchedAt']);
    history.onedriveItemId = values['onedriveItemId'];
    history.timestamp = values['timestamp'];
    history.createdAt = DateTime.parse(values['createdAt']);
    history.modifiedAt = DateTime.parse(values['modifiedAt']);
    history.userId = values['userId'];
    return history;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mediaId_userId'] = mediaId_userId;
    data['lastWatchedAt'] = lastWatchedAt.toIso8601String();
    data['onedriveItemId'] = onedriveItemId;
    data['timestamp'] = timestamp;
    data['createdAt'] = createdAt.toIso8601String();
    data['modifiedAt'] = modifiedAt.toIso8601String();
    data['userId'] = userId;
    return data;
  }
}
