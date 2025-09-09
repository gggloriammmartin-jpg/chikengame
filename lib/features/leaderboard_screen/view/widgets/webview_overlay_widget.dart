import 'package:flutter/material.dart';

class WebViewOverlayWidget extends StatelessWidget {
  final bool isCustomUrl;
  final bool canGoBack;
  final VoidCallback onBackPressed;
  final VoidCallback onClosePressed;

  const WebViewOverlayWidget({
    super.key,
    required this.isCustomUrl,
    required this.canGoBack,
    required this.onBackPressed,
    required this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Кнопка "Назад" (стрелка назад)
          Container(
            decoration: BoxDecoration(
              color: isCustomUrl 
                  ? Colors.grey[800]!.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: onBackPressed,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          
          // Заголовок "Leaderboard" - показываем только для дефолтного лидерборда
          if (!isCustomUrl)
            const Text(
              'LEADERBOARD',
              style: TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.white70,
                  ),
                ],
              ),
            )
          else
            const SizedBox(width: 100), // Заглушка для центрирования кнопок
          
          // Кнопка "Закрыть" (крестик)
          Container(
            decoration: BoxDecoration(
              color: isCustomUrl 
                  ? Colors.grey[800]!.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: onClosePressed,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
