import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/image_source.dart';
import '../../leaderboard_screen/view/leaderboard_webview_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Ждем 10 секунд для показа splash screen
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    // Всегда переходим сначала в WebView лидерборда
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LeaderboardWebViewScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(ImageSource.bgWithChiken, fit: BoxFit.cover),
          ),

          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Image.asset(ImageSource.logo, height: 205),
          ),
        ],
      ),
    );
  }
}
