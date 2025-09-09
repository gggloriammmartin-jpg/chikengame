import 'package:chiken_odyssey/features/global/widgets/custom_eleavated_button.dart';
import 'package:flutter/material.dart';
import 'package:chiken_odyssey/theme/app_colors.dart';
import 'package:chiken_odyssey/theme/app_styles.dart';

class PauseScreen extends StatelessWidget {
  final VoidCallback? onResume;
  final VoidCallback? onBackToMenu;

  const PauseScreen({super.key, this.onResume, this.onBackToMenu});

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
              Text('Pause', style: AppStyles.poppins47s700w),

              SizedBox(height: 25),

              // Кнопки
              Row(
                children: [
                  // Кнопка Resume
                  Expanded(
                    flex: 4,
                    child: CustomElevatedButton(
                      text: 'Resume',
                      onPressed: onResume ?? () {},
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 6,
                    child: CustomElevatedButton(
                      text: 'Back to menu',
                      color: AppColors.grey184Color,
                      onPressed: onBackToMenu ?? () {},
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
