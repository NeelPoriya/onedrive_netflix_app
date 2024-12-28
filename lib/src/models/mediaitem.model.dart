class MediaItem {
  late String id;
  late String title;

  // Onedrive properties
  late String onedriveFolderId;
  late String onedriveItemId;
  late String webUrl;
  late String siteId;

  // Tmdb properties
  late List<String> genre;
  late bool adult;
  late int budget;
  late String backdropImage;
  late String imdbId;
  late double popularityId;
  late String posterImage;
  late DateTime releaseDate;
  late int revenue;
  late String status;
  late String tmdbId;
  late String type;
  late double voteAverage;
  late int voteCount;
  late bool isFound;

  // Custom properties
  late String folderId;

  MediaItem();

  MediaItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    title = json['title'] ?? '';
    onedriveFolderId = json['onedriveFolderId'] ?? '';
    onedriveItemId = json['onedriveItemId'] ?? '';
    webUrl = json['webUrl'] ?? '';
    siteId = json['siteId'] ?? '';
    genre =
        (json['genre'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    adult = json['adult'] ?? false;
    budget = json['budget'] ?? 0;
    backdropImage = json['backdropImage'] ?? '';
    imdbId = json['imdbId'] ?? '';
    popularityId = (json['popularityId'] as num?)?.toDouble() ?? 0.0;
    posterImage = json['posterImage'] ?? '';
    releaseDate = json['releaseDate'] != null
        ? DateTime.parse(json['releaseDate'])
        : DateTime.now();
    revenue = json['revenue'] ?? 0;
    status = json['status'] ?? '';
    tmdbId = json['tmdbId'] ?? '';
    type = json['type'] ?? '';
    voteAverage = (json['voteAverage'] as num?)?.toDouble() ?? 0.0;
    voteCount = json['voteCount'] ?? 0;
    folderId = json['folderId'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['onedriveFolderId'] = onedriveFolderId;
    data['onedriveItemId'] = onedriveItemId;
    data['webUrl'] = webUrl;
    data['siteId'] = siteId;
    data['genre'] = genre;
    data['adult'] = adult;
    data['budget'] = budget;
    data['backdropImage'] = backdropImage;
    data['imdbId'] = imdbId;
    data['popularityId'] = popularityId;
    data['posterImage'] = posterImage;
    data['releaseDate'] = releaseDate.toIso8601String();
    data['revenue'] = revenue;
    data['status'] = status;
    data['tmdbId'] = tmdbId;
    data['type'] = type;
    data['voteAverage'] = voteAverage;
    data['voteCount'] = voteCount;
    data['folderId'] = folderId;
    return data;
  }

  MediaItem.fromMap(this.id, Map<dynamic, dynamic> data) {
    title = data['title'] ?? '';
    onedriveFolderId = data['onedriveFolderId'] ?? '';
    onedriveItemId = data['onedriveItemId'] ?? '';
    webUrl = data['webUrl'] ?? '';
    siteId = data['siteId'] ?? '';
    genre =
        (data['genre'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    adult = data['adult'] ?? false;
    budget = data['budget'] ?? 0;

    backdropImage = data['backdropImage'] ?? '';

    imdbId = data['imdbId'] ?? '';
    popularityId = (data['popularityId'] as num?)?.toDouble() ?? 0.0;

    posterImage = data['posterImage'] ?? '';

    releaseDate = data['releaseDate'] != null && data['releaseDate'] != ''
        ? DateTime.parse(data['releaseDate'])
        : DateTime.now();

    revenue = data['revenue'] ?? 0;
    status = data['status'] ?? '';
    tmdbId = data['tmdbId'] ?? '';
    type = data['type'] ?? '';
    voteAverage = (data['voteAverage'] as num?)?.toDouble() ?? 0.0;
    voteCount = data['voteCount'] ?? 0;
    folderId = data['folderId'] ?? '';
  }
}
