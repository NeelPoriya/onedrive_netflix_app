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
  late int popularityId;
  late String posterImage;
  late DateTime releaseDate;
  late int revenue;
  late String status;
  late String tmdbId;
  late String type;
  late int voteAverage;
  late int voteCount;

  // Custom properties
  late String folderId;

  MediaItem();

  MediaItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    onedriveFolderId = json['onedriveFolderId'];
    onedriveItemId = json['onedriveItemId'];
    webUrl = json['webUrl'];
    siteId = json['siteId'];
    genre = List<String>.from(json['genre']);
    adult = json['adult'];
    budget = json['budget'];
    backdropImage = json['backdropImage'];
    imdbId = json['imdbId'];
    popularityId = json['popularityId'];
    posterImage = json['posterImage'];
    releaseDate = DateTime.parse(json['releaseDate']);
    revenue = json['revenue'];
    status = json['status'];
    tmdbId = json['tmdbId'];
    type = json['type'];
    voteAverage = json['voteAverage'];
    voteCount = json['voteCount'];
    folderId = json['folderId'];
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
}
