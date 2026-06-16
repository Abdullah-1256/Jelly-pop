/// Shared sizes and timings used across the match-3 game.
abstract class AppSizes {
  static const double screenPadding = 16;
  static const double gap = 10;
  static const double smallGap = 6;
  static const double radius = 22;
  static const double boardRadius = 18;
  static const double buttonHeight = 56;
  static const double glassButtonRadius = 30;
  static const double glassButtonDepth = 8;
  static const double welcomeBlurSigma = 5;
  static const double welcomeButtonWidthFactor = 0.72;
  static const double welcomeLogoWidthFactor = 0.62;
  static const double welcomeButtonBottomFactor = 0.16;
  static const double welcomeSettingsSize = 54;
  static const double welcomeSettingsPadding = 16;
  static const double hudHeight = 88;
  static const int splashDelayMs = 2500;
  static const int swapMs = 200; // Increased for smoother swap animation
  static const int swapAnimMs = 180; // Individual candy swap scale animation
  static const int selectAnimMs =
      140; // Individual candy select scale animation
  static const int popMs = 180;
  static const int fallMinMs = 180;
  static const int fallMaxMs = 350;
  static const int spawnMs = 160;
  static const int scorePopupMs = 800;
  static const int idleHintSeconds = 4;
  static const int baseCandyScore = 60;
  static const double maxComboMultiplier = 4;
}
