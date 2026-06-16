/// Named route constants for Jelly Pop.
abstract class AppRoutes {
  static const String splashRoute = '/';
  static const String welcomeRoute = '/welcome';
  static const String mapRoute = '/map';
  static const String gameRoute = '/game/:levelId';
  static const String shopRoute = '/shop';
  static const String eventsRoute = '/events';
  static const String settingsRoute = '/settings';
  static const String dailyRoute = '/daily';

  /// Builds a concrete game route for a level id.
  static String gamePath(int levelId) => '/game/$levelId';
}
