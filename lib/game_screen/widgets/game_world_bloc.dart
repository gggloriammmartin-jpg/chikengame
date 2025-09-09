import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chiken_odyssey/game_screen/bloc/game_bloc.dart';
import 'package:chiken_odyssey/game_screen/bloc/game_event.dart';
import 'package:chiken_odyssey/game_screen/bloc/game_state.dart';
import 'package:chiken_odyssey/game_screen/widgets/chicken_widget.dart';
import 'package:chiken_odyssey/game_screen/widgets/game_over_screen.dart';
import 'package:chiken_odyssey/game_screen/widgets/pause_screen.dart';
import 'package:chiken_odyssey/game_screen/widgets/game_objects_layer.dart';
import 'package:chiken_odyssey/game_screen/widgets/game_effects_layer.dart';


class GameWorldBloc extends StatefulWidget {
  final VoidCallback? onBackToMenu;
  final Function(bool isPaused)? onPauseStateChanged;
  final VoidCallback? onGameDataChanged;
  final VoidCallback? onScoreSaved;

  const GameWorldBloc({
    super.key, 
    this.onBackToMenu, 
    this.onPauseStateChanged,
    this.onGameDataChanged,
    this.onScoreSaved,
  });

  @override
  State<GameWorldBloc> createState() => _GameWorldBlocState();
}

class _GameWorldBlocState extends State<GameWorldBloc> with TickerProviderStateMixin {
  // Анимация для эффекта щита
  late AnimationController _shieldAnimationController;
  late Animation<double> _shieldAnimation;

  // Анимация появления щита
  late AnimationController _shieldAppearController;
  late Animation<double> _shieldAppearAnimation;

  // Анимация сбора бонусов
  late AnimationController _bonusCollectController;
  late Animation<double> _bonusCollectAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenSize = MediaQuery.of(context).size;
    
    // Инициализируем игру с размерами экрана
    final currentState = context.read<GameBloc>().state;
    if (currentState is GameInitial) {
      // Инициализируем игру
      context.read<GameBloc>().add(GameInitialized(
        screenWidth: screenSize.width,
        screenHeight: screenSize.height,
      ));
      
      // Автоматически запускаем игру после инициализации
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<GameBloc>().add(const GameStarted());
        }
      });
    } else if (currentState is GameRunning && currentState.isPaused) {
      // Если игра уже запущена, но находится на паузе, сбрасываем паузу
      // Это происходит когда возвращаемся из меню
      context.read<GameBloc>().add(const GameResumed());
    }
  }

  void _initializeAnimations() {
    // Инициализируем анимацию щита
    _shieldAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shieldAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _shieldAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Инициализируем анимацию появления щита
    _shieldAppearController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shieldAppearAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shieldAppearController,
        curve: Curves.elasticOut,
      ),
    );

    // Инициализируем анимацию сбора бонусов
    _bonusCollectController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _bonusCollectAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bonusCollectController, curve: Curves.easeOut),
    );
  }

  void _restartGame() {
    context.read<GameBloc>().add(const GameRestarted());
  }

  void _resetGame() {
    context.read<GameBloc>().add(const GameReset());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        if (state is GameInitial) {
          // Если игра в начальном состоянии, инициализируем её
          final screenSize = MediaQuery.of(context).size;
          context.read<GameBloc>().add(GameInitialized(
            screenWidth: screenSize.width,
            screenHeight: screenSize.height,
          ));
          
          // Автоматически запускаем игру после инициализации
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              context.read<GameBloc>().add(const GameStarted());
            }
          });
        } else if (state is GameRunning) {
          // Уведомляем родительский виджет об изменении данных
          widget.onGameDataChanged?.call();
          
          // Уведомляем об изменении состояния паузы
          widget.onPauseStateChanged?.call(state.isPaused);
          
          // Управляем анимациями щита
          if (state.hasShield && !_shieldAppearController.isAnimating) {
            _shieldAppearController.forward().then((_) {
              _shieldAnimationController.repeat(reverse: true);
            });
          } else if (!state.hasShield) {
            _shieldAnimationController.stop();
            _shieldAppearController.reset();
          }
          
          // Управляем анимацией сбора бонуса
          if (state.isBonusCollecting && !_bonusCollectController.isAnimating) {
            _bonusCollectController.reset();
            _bonusCollectController.forward().then((_) {
              // После завершения анимации сбрасываем флаг
              if (mounted) {
                context.read<GameBloc>().add(const BonusCollectAnimationFinished());
              }
            });
          }
        }
      },
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is GameRunning) {
            return _buildGameContent(state);
          }
          
          return const Center(
            child: Text('Game not initialized'),
          );
        },
      ),
    );
  }

  Widget _buildGameContent(GameRunning state) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Левая стенка
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: GameBloc.wallOffset,
                height: state.screenHeight,
                color: Colors.brown.withOpacity(0.8),
              ),
            ),

            // Правая стенка
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: GameBloc.wallOffset,
                height: state.screenHeight,
                color: Colors.brown.withOpacity(0.8),
              ),
            ),

            // Игровые объекты
            GameObjectsLayer(
              platforms: state.visiblePlatforms,
              bonuses: state.visibleBonuses,
              obstacles: state.visibleObstacles,
              crackingPlatforms: state.crackingPlatforms,
              cameraY: state.cameraY,
            ),

            // Курица
            ChickenWidget(
              state: state.chickenState,
              x: state.chickenX,
              y: state.chickenY - state.cameraY,
            ),

            // Эффекты
            GameEffectsLayer(
              hasShield: state.hasShield,
              chickenX: state.chickenX,
              chickenY: state.chickenY,
              cameraY: state.cameraY,
              chickenSize: GameBloc.chickenSize,
              shieldAnimation: _shieldAnimation,
              shieldAppearAnimation: _shieldAppearAnimation,
              isBonusCollecting: state.isBonusCollecting,
              bonusCollectX: state.bonusCollectX,
              bonusCollectY: state.bonusCollectY,
              bonusCollectAnimation: _bonusCollectAnimation,
              collectingBonusType: state.collectingBonusType,
            ),


            // Экран паузы
            if (state.isPaused && !state.isGameOver)
              PauseScreen(
                onResume: () {
                  context.read<GameBloc>().add(const GameResumed());
                },
                onBackToMenu: () {
                  _resetGame(); // Сбрасываем игру перед выходом в меню
                  widget.onBackToMenu?.call();
                },
              ),

            // Game Over экран
            if (state.isGameOver)
              GameOverScreen(
                finalScore: state.score,
                onRestart: _restartGame,
                onBackToMenu: () {
                  _resetGame(); // Сбрасываем игру перед выходом в меню
                  widget.onBackToMenu?.call();
                },
                isSavingScore: state.isSavingScore,
                scoreSaved: state.scoreSaved,
                saveError: state.saveError,
              ),
          ],
        ),
      );
  }

  @override
  void dispose() {
    _shieldAnimationController.dispose();
    _shieldAppearController.dispose();
    _bonusCollectController.dispose();
    super.dispose();
  }
}
