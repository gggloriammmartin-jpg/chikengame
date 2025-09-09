import 'package:chiken_odyssey/constants/image_source.dart';
import 'package:chiken_odyssey/features/global/widgets/custom_text_field.dart';
import 'package:chiken_odyssey/features/leaderboard_screen/view/leaderboard_webview_screen.dart';
import 'package:chiken_odyssey/features/leaderboard_screen/data/services/leaderboard_service.dart';
import 'package:chiken_odyssey/theme/app_colors.dart';
import 'package:chiken_odyssey/theme/app_styles.dart';
import 'package:flutter/material.dart';

class SetNickScreen extends StatefulWidget {
  const SetNickScreen({super.key});

  @override
  State<SetNickScreen> createState() => _SetNickScreenState();
}

class _SetNickScreenState extends State<SetNickScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _canProceed = false;
  bool _showErrors = false;
  bool _isCheckingNickname = false;
  String _errorMessage = '';
  final LeaderboardService _leaderboardService = LeaderboardService();

  @override
  void initState() {
    super.initState();
    _checkExistingNickname();
  }

  Future<void> _checkExistingNickname() async {
    // Проверяем, есть ли уже сохраненный ник
    final user = await _leaderboardService.getCurrentUser();
    if (user?.nickname != null && user!.nickname.isNotEmpty) {
      // Если ник уже есть, переходим к WebView
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LeaderboardWebViewScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }


  void _onNicknameChanged(String value) {
    setState(() {
      _canProceed = value.length >= 6;
      _showErrors = false;
      _errorMessage = '';
    });
  }

  void _onButtonPressed() async {
    if (_nicknameController.text.length < 6) {
      setState(() {
        _showErrors = true;
        _errorMessage = 'Nickname must be at least 6 characters long';
      });
      return;
    }

    setState(() {
      _isCheckingNickname = true;
      _showErrors = false;
      _errorMessage = '';
    });

    final nickname = _nicknameController.text.trim();
    
    try {
      // Проверяем доступность ника
      print('Checking nickname availability: $nickname');
      final isAvailable = await _leaderboardService.isNicknameAvailable(nickname);
      print('Nickname available: $isAvailable');
      
      if (!mounted) return;
      
      if (isAvailable) {
        // Создаем игрока в Firebase
        final playerCreated = await _leaderboardService.createPlayer(nickname);
        
        if (playerCreated) {
          // Сохраняем ник локально
          await _leaderboardService.setNickname(nickname);
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LeaderboardWebViewScreen(),
              ),
            );
          }
        } else {
          setState(() {
            _showErrors = true;
            _errorMessage = 'Failed to create player. Please try again.';
          });
        }
      } else {
        setState(() {
          _showErrors = true;
          _errorMessage = 'This nickname is already taken. Please choose another one.';
        });
      }
    } catch (e) {
      setState(() {
        _showErrors = true;
        _errorMessage = 'Error checking nickname. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingNickname = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(ImageSource.bgWithChiken, fit: BoxFit.cover),
          ),

          // Центральный контейнер с полем ввода и кнопкой
          Center(
            child: Container(
              width: 332,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set nickname', style: AppStyles.poppins24s500w),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _nicknameController,
                    hintText: 'Enter Nickname...',
                    minLength: 6,
                    onChanged: _onNicknameChanged,
                    showError: _showErrors,
                  ),
                  if (_showErrors && _errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_canProceed && !_isCheckingNickname) ? _onButtonPressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_canProceed && !_isCheckingNickname)
                            ? AppColors.greenColor
                            : AppColors.grey115Color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isCheckingNickname
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _canProceed ? 'Enter game' : 'Enter your nickname',
                              style: AppStyles.poppins16s400w,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
