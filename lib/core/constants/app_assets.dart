import '../../models/candy.dart';

/// Central image asset registry for Jelly Pop.
abstract class AppAssets {
  static const String background = 'assets/images/bg/BG.png';
  static const String splash = 'assets/images/bg/splash.png';

  static const String logo = 'assets/images/mascot/logo_transparent.png';
  static const String mascotSad = logo;

  static const String coin = 'assets/images/ui/coin.png';
  static const String gem = 'assets/images/ui/dimond.png';
  static const String heart = 'assets/images/ui/heart.png';
  static const String starFilled = 'assets/images/ui/star.png';
  static const String starEmpty = 'assets/images/candies/bomb.png';
  static const String openChest = 'assets/images/ui/open reward.png';
  static const String winning = 'assets/images/candies/Reward Chest.png';
  static const String reward = 'assets/images/ui/reward.png';
  static const String locked = 'assets/images/ui/locked.png';
  static const String starterPack =
      'assets/images/candies/Starter Pack Badge.png';

  static const String back = 'assets/images/ui/backbutton.png';
  static const String correct = 'assets/images/ui/correct.png';
  static const String navMap = 'assets/images/ui/map.png';
  static const String navShop = 'assets/images/ui/Shop.png';
  static const String navEvents = 'assets/images/ui/explore.png';
  static const String settings = 'assets/images/ui/Setting.png';
  static const String music = 'assets/images/ui/mucis.png';
  static const String sfx = 'assets/images/ui/Audio.png';
  static const String mute = 'assets/images/ui/mute.png';
  static const String timer = 'assets/images/ui/timer.png';
  static const String team = 'assets/images/ui/Team.png';
  static const String about = 'assets/images/ui/about.png';

  static const String hammerBooster = 'assets/images/candies/Jelly Hammer.png';
  static const String rocketBooster =
      'assets/images/candies/Rocvet Jelly Booster.png';
  static const String colorBombBooster =
      'assets/images/candies/Color Bome Booster.png';

  /// Returns the image asset that matches a candy color.
  static String candyFor(CandyType type) {
    return switch (type) {
      CandyType.red => 'assets/images/candies/Stawberry.png',
      CandyType.blue => 'assets/images/candies/blue drop.png',
      CandyType.green => 'assets/images/candies/leaf.png',
      CandyType.yellow => 'assets/images/candies/Star.png',
      CandyType.purple => 'assets/images/candies/purple jelly.png',
      CandyType.orange => 'assets/images/candies/orange.png',
    };
  }

  /// Returns the board image for normal and special candies.
  static String candyImageFor(Candy candy) {
    return switch (candy.specialType) {
      SpecialType.none => candyFor(candy.type),
      SpecialType.stripedH ||
      SpecialType.stripedV => _glossyCandyFor(candy.type),
      SpecialType.wrapped => 'assets/images/candies/pack candy.png',
      SpecialType.colorBomb => 'assets/images/candies/bomb.png',
    };
  }

  static String _glossyCandyFor(CandyType type) {
    return switch (type) {
      CandyType.red => 'assets/images/candies/glossy stawberry.png',
      CandyType.blue => 'assets/images/candies/glossydrop.png',
      CandyType.green => 'assets/images/candies/glossy leaf.png',
      CandyType.yellow => 'assets/images/candies/Golden star.png',
      CandyType.purple => 'assets/images/candies/purple drop.png',
      CandyType.orange => 'assets/images/candies/Glowing orange.png',
    };
  }
}
