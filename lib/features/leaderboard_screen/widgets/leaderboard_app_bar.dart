import 'package:chiken_odyssey/features/global/widgets/animated_tap.dart';
import 'package:chiken_odyssey/theme/app_colors.dart';
import 'package:chiken_odyssey/theme/app_styles.dart';
import 'package:flutter/material.dart';

class LeaderboardAppBar extends StatelessWidget {
  const LeaderboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            AnimatedTap(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(Icons.arrow_back_ios, size: 35),
              ),
            ),
            Text('Leaderboard', style: AppStyles.poppins32s500w.copyWith(color: AppColors.blackColor)),
          ],
        ),
      ),
    );
  }
}
