import 'package:chiken_odyssey/features/leaderboard_screen/widgets/leaderboard_app_bar.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          children: [
            LeaderboardAppBar(),
          ],
        ),
      ),
    );
  }
}
