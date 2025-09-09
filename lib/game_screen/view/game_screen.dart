import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chiken_odyssey/game_screen/widgets/game_background.dart';
import 'package:chiken_odyssey/game_screen/widgets/game_world_bloc.dart';
import 'package:chiken_odyssey/game_screen/bloc/game_bloc.dart';
import 'package:chiken_odyssey/game_screen/bloc/game_state.dart';
import 'package:chiken_odyssey/game_screen/bloc/game_event.dart';
import 'package:chiken_odyssey/features/global/services/audio_manager.dart';
import 'package:chiken_odyssey/game_screen/constants/input_settings.dart';

class GameScreen extends StatefulWidget {
  final VoidCallback? onBackToMenu;
  
  const GameScreen({super.key, this.onBackToMenu});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isPaused = false;
  
  // Данные игры для передачи в GameBackground
  int _currentScore = 0;
  int _currentLives = 3;
  bool _currentHasShield = false;
  
  // Переменные для улучшенного управления
  double _accumulatedPanDelta = 0.0;
  DateTime? _lastPanTime;

  @override
  void initState() {
    super.initState();
    // Сбрасываем состояние паузы при инициализации экрана
    _isPaused = false;
  }

  void _handleTap() {
    if (InputSettings.enableDebugLogs) {
      print('Tap detected in GameScreen');
    }
    // Воспроизводим звук прыжка
    AudioManager.playJumpSound(context);
    context.read<GameBloc>().add(const ChickenJumped());
  }

  void _handlePanUpdate(double deltaX) {
    final now = DateTime.now();
    
    // Накопляем движение
    _accumulatedPanDelta += deltaX;
    
    // Проверяем, прошло ли достаточно времени с последнего движения
    final canMove = _lastPanTime == null || 
        now.difference(_lastPanTime!).inMilliseconds >= InputSettings.panCooldownMs;
    
    // Если накопилось достаточно движения и прошло время, выполняем движение
    if (canMove && _accumulatedPanDelta.abs() >= InputSettings.panThreshold) {
      if (_accumulatedPanDelta > 0) {
        context.read<GameBloc>().add(const ChickenMovedRight());
        if (InputSettings.enableDebugLogs) {
          print('Moved right: accumulated=${_accumulatedPanDelta.toStringAsFixed(2)}');
        }
      } else {
        context.read<GameBloc>().add(const ChickenMovedLeft());
        if (InputSettings.enableDebugLogs) {
          print('Moved left: accumulated=${_accumulatedPanDelta.toStringAsFixed(2)}');
        }
      }
      
      // Сбрасываем накопленное движение и обновляем время
      _accumulatedPanDelta = 0.0;
      _lastPanTime = now;
    }
  }
  
  void _handlePanStart() {
    // Сбрасываем накопленное движение при начале нового жеста
    _accumulatedPanDelta = 0.0;
    _lastPanTime = null;
  }

  void _handlePause() {
    final gameBloc = context.read<GameBloc>();
    final currentState = gameBloc.state;
    if (currentState is GameRunning) {
      if (currentState.isPaused) {
        gameBloc.add(const GameResumed());
      } else {
        gameBloc.add(const GamePaused());
      }
    }
  }

  void _onPauseStateChanged(bool isPaused) {
    setState(() {
      _isPaused = isPaused;
    });
  }

  void _updateGameData() {
    final currentState = context.read<GameBloc>().state;
    if (currentState is GameRunning) {
      setState(() {
        _currentScore = currentState.score;
        _currentLives = currentState.lives;
        _currentHasShield = currentState.hasShield;
      });
    }
  }

  void _onScoreSaved() {
    print('Score saved successfully! Leaderboard should be updated.');
    // Здесь можно добавить дополнительную логику, например:
    // - Показать уведомление
    // - Обновить кэш лидерборда
    // - Отправить аналитику
  }

  void _handleGameEvents(GameRunning state) {
    // Проверяем, есть ли анимация сбора бонуса
    if (state.isBonusCollecting) {
      AudioManager.playBonusSound(context);
    }
    
    // Проверяем окончание игры
    if (state.isGameOver) {
      AudioManager.playGameOverSound(context);
    }
    
    // Проверяем потерю жизни (можно добавить логику для отслеживания изменений)
    // Это требует более сложной логики для отслеживания изменений состояния
  }



  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        if (state is GameRunning) {
          _updateGameData();
          _onPauseStateChanged(state.isPaused);
          
          // Воспроизводим звуки при игровых событиях
          _handleGameEvents(state);
        }
      },
      child: Scaffold(
        body: GameBackground(
          onTap: _handleTap,
          onPanUpdate: _handlePanUpdate,
          onPanStart: _handlePanStart,
          onBack: widget.onBackToMenu,
          onPause: _handlePause,
          isPaused: _isPaused,
          score: _currentScore,
          lives: _currentLives,
          hasShield: _currentHasShield,
          child: GameWorldBloc(
            onBackToMenu: widget.onBackToMenu,
            onPauseStateChanged: _onPauseStateChanged,
            onGameDataChanged: _updateGameData,
            onScoreSaved: _onScoreSaved,
          ),
        ),
      ),
    );
  }
}
