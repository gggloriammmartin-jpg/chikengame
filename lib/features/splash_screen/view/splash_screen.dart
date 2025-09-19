import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/image_source.dart';
import '../../leaderboard_screen/view/leaderboard_webview_screen.dart';
import '../../settings_screen/bloc/settings_bloc.dart';
import '../../settings_screen/bloc/settings_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAudioSafely();
    _navigateAfterDelay();
  }

  Future<void> _initializeAudioSafely() async {
    try {
      // Безопасная инициализация аудио с задержкой
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.read<SettingsBloc>().add(InitializeMusic());
      }
    } catch (e) {
      print('Failed to initialize audio in splash screen: $e');
      // Продолжаем работу без аудио
    }
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
