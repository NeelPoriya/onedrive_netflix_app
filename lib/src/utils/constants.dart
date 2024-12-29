class Constants {
  static final Constants instance = Constants._();

  Constants._();

  static const String homeRoute = '/home';

  static const String loginRoute = '/login';

  static const String searchRoute = '/search';

  static const String listRoute = '/list';

  static const String mediaDetailsRoute = '/media/:mediaId';

  static const String videoPlayerRoute = '/play/:mediaId';

  static const String adminRoute = '/admin';
  static const String accountsRoute = '/admin/accounts';
  static const String foldersRoute = '/admin/folders';
  static const String usersRoute = '/admin/users';

  // tmdb constants
  static const String tmdbImageEndpoint = 'https://image.tmdb.org/t/p/original';
  static const String tmdbImageEndpointW500 = 'https://image.tmdb.org/t/p/w500';
}
