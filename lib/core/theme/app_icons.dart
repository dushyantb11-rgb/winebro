import 'package:flutter/material.dart';

abstract final class AppIcons {

  static String drinkImage(String group) => switch (group) {
    'Wine' => 'assets/images/drinks/red_wine.jpg',
    'Whisky' => 'assets/images/drinks/whisky.jpg',
    'Spirits' => 'assets/images/drinks/cocktails.jpg',
    'Beer' => 'assets/images/drinks/beer.jpg',
    _ => 'assets/images/drinks/cocktails.jpg',
  };

  static const wine = Icons.wine_bar;
  static const whisky = Icons.local_bar;
  static const spirits = Icons.liquor;
  static const beer = Icons.sports_bar;
  static const cocktails = Icons.local_drink;

  static IconData forDrinkGroup(String group) => switch (group) {
    'Wine' => wine,
    'Whisky' => whisky,
    'Spirits' => spirits,
    'Beer' => beer,
    _ => cocktails,
  };

  static const brosPick = Icons.emoji_events;
  static const broTip = Icons.lightbulb_outline;

  static const statTastings = Icons.wine_bar;
  static const statStreak = Icons.local_fire_department;
  static const statBadges = Icons.military_tech;
  static const statScans = Icons.photo_camera;
  static const statPairings = Icons.handshake;
  static const statChallenges = Icons.track_changes;

  static const journalEntry = Icons.wine_bar;
}

