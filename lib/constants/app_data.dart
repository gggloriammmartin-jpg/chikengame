import 'package:chiken_odyssey/features/leaderboard_screen/view/leaderboard_webview_screen.dart';
import 'package:chiken_odyssey/features/menu_screen/models/menu_model.dart';
import 'package:chiken_odyssey/features/settings_screen/view/settings_screen.dart';
import 'package:chiken_odyssey/game_screen/view/game_screen.dart';
import 'package:flutter/material.dart';

class AppData {
  static final List<MenuCardModel> menuList = [
    MenuCardModel(
      title: 'Start',
      screenBuilder: (context) => GameScreen(
        onBackToMenu: () {
          Navigator.of(context).pop();
        },
      ),
      // screenBuilder: (context) => const SetNickScreen(),
    ),
    MenuCardModel(
      title: 'Leaderboard',
      screenBuilder: (context) => const LeaderboardWebViewScreen(showWelcome: false),
    ),
    MenuCardModel(
      title: 'Settings',
      screenBuilder: (context) => const SettingsScreen(),
    ),
  ];

  static const String privacyLink = '';
}
