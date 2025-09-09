import 'package:chiken_odyssey/features/global/widgets/custom_eleavated_button.dart';
import 'package:chiken_odyssey/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:chiken_odyssey/theme/app_colors.dart';

class GameOverScreen extends StatelessWidget {
  final int finalScore;
  final VoidCallback onRestart;
  final VoidCallback onBackToMenu;
  final bool isSavingScore;
  final bool scoreSaved;
  final String? saveError;

  const GameOverScreen({
    super.key,
    required this.finalScore,
    required this.onRestart,
    required this.onBackToMenu,
    this.isSavingScore = false,
    this.scoreSaved = false,
    this.saveError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.gameOverAlertColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorderColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Game Over заголовок
              Text('Game Over', style: AppStyles.poppins47s700w),

              // Панель с итоговым счетом
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 29),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.grey151Color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Score',
                        style: AppStyles.poppins24s400w,
                      ),
                      const SizedBox(height: 0),
                      Text('$finalScore', style: AppStyles.poppins47s700w),
                    ],
                  ),
                ),
              ),
              // Кнопки
              Row(
                children: [
                  // Кнопка Restart
                  Expanded(
                    flex: 4,
                    child: CustomElevatedButton(
                      text: 'Restart',
                      onPressed: onRestart,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 6,
                    child: CustomElevatedButton(
                      text: 'Back to menu',
                      color: AppColors.grey184Color,
                      onPressed: onBackToMenu,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
