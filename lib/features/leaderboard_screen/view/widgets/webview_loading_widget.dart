import 'package:flutter/material.dart';
import 'package:chiken_odyssey/theme/app_colors.dart';
import 'package:chiken_odyssey/constants/image_source.dart';

class WebViewLoadingWidget extends StatelessWidget {
  final bool isCustomUrl;

  const WebViewLoadingWidget({
    super.key,
    required this.isCustomUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCustomUrl ? Colors.white : const Color(0xFFE8F4FD),
      ),
      child: Stack(
        children: [
          // Фоновое изображение показываем только для дефолтного лидерборда
          if (!isCustomUrl)
            Positioned.fill(
              child: Image.asset(
                ImageSource.bgWithChiken,
                fit: BoxFit.cover,
              ),
            ),
          
          // Простая циркулярка по центру
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: isCustomUrl ? MediaQuery.of(context).padding.top : 0,
              ),
              child: CircularProgressIndicator(
                color: isCustomUrl ? Colors.blue : AppColors.greenColor,
                strokeWidth: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
