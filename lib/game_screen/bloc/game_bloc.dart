import 'dart:math';
import 'dart:async';
import 'package:chiken_odyssey/game_screen/models/block_type.dart';
import 'package:chiken_odyssey/game_screen/models/bonus_data.dart';
import 'package:chiken_odyssey/game_screen/models/obstacle_data.dart';
import 'package:chiken_odyssey/game_screen/models/platform_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chiken_odyssey/game_screen/bloc/game_event.dart';
import 'package:chiken_odyssey/game_screen/bloc/game_state.dart';
import 'package:chiken_odyssey/game_screen/widgets/chicken_widget.dart';
import 'package:chiken_odyssey/game_screen/constants/input_settings.dart';
import 'package:chiken_odyssey/features/leaderboard_screen/data/services/leaderboard_service.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  // Константы (перенесены из GameWorld)
  static const double wallOffset = 30.0;
  static const double chickenSize = 95.0;
  static const double chickenCollisionWidth = 20.0;
  static const double chickenCollisionHeight = 95.0;
  static const double platformWidth = 100.0;
  static const double platformHeight = 20.0;
  static const double jumpHeight = 215.0;
  static const double levelHeight = 200.0;
  static const double maxJumpDistance = 150.0;
  static const double fallingRockSize = 40.0;
  static const double fallingRockSpeed = 2.0;
  static const double spearWidth = 60.0;
  static const double spearHeight = 8.0;
  static const double spearSpeed = 6.0;
  static const double pendulumSpeed = 5.0;
  static const double pendulumRange = 200.0;
  static const double obstacleSpawnChance = 0.8; // Увеличиваем шанс для тестирования

  // Генератор случайных чисел
  late Random _random;

  // Переменные для создания паттернов
  int _currentPatternLength = 0;
  int _currentPatternZone = -1;

  // Таймер для игрового цикла
  Timer? _gameTimer;

  // Анимационные таймеры
  Timer? _shieldAnimationTimer;
  Timer? _shieldAppearTimer;
  
  // Флаг для отслеживания сохранения счета
  bool _scoreSaved = false;

  GameBloc() : super(const GameInitial()) {
    _random = Random();
    
    // Регистрируем обработчики событий
    on<GameInitialized>(_onGameInitialized);
    on<GameStarted>(_onGameStarted);
    on<GamePaused>(_onGamePaused);
    on<GameResumed>(_onGameResumed);
    on<GameRestarted>(_onGameRestarted);
    on<GameReset>(_onGameReset);
    on<GameOver>(_onGameOver);
    on<ScoreSaved>(_onScoreSaved);
    on<ChickenJumped>(_onChickenJumped);
    on<ChickenMovedLeft>(_onChickenMovedLeft);
    on<ChickenMovedRight>(_onChickenMovedRight);
    on<GameUpdated>(_onGameUpdated);
    on<BonusCollectAnimationFinished>(_onBonusCollectAnimationFinished);
  }

  void _onGameInitialized(GameInitialized event, Emitter<GameState> emit) {
    emit(const GameLoading());
    
    // Создаем начальное состояние игры
    final initialState = _createInitialGameState(
      event.screenWidth,
      event.screenHeight,
    );
    
    emit(initialState);
    
    // Запускаем игровой цикл
    _startGameTimer();
  }

  void _onGameStarted(GameStarted event, Emitter<GameState> emit) {
    if (state is GameRunning) {
      final currentState = state as GameRunning;
      // Принудительно сбрасываем паузу при запуске игры
      emit(currentState.copyWith(isPaused: false));
      _startGameTimer();
    } else if (state is GameInitial) {
      // Если игра еще не инициализирована, запускаем её
      _startGameTimer();
    }
  }

  void _onGamePaused(GamePaused event, Emitter<GameState> emit) {
    if (state is GameRunning) {
      final currentState = state as GameRunning;
      emit(currentState.copyWith(isPaused: true));
      _stopGameTimer();
    }
  }

  void _onGameResumed(GameResumed event, Emitter<GameState> emit) {
    if (state is GameRunning) {
      final currentState = state as GameRunning;
      emit(currentState.copyWith(isPaused: false));
      _startGameTimer();
    }
  }

  void _onGameRestarted(GameRestarted event, Emitter<GameState> emit) {
    if (state is GameRunning) {
      final currentState = state as GameRunning;
      final newState = _createInitialGameState(
        currentState.screenWidth,
        currentState.screenHeight,
      );
      // Сбрасываем флаг сохранения счета
      _scoreSaved = false;
      emit(newState);
      _startGameTimer();
    }
  }

  void _onGameReset(GameReset event, Emitter<GameState> emit) {
    // Полный сброс игры - возвращаемся в начальное состояние
    _stopGameTimer();
    _scoreSaved = false;
    emit(const GameInitial());
  }

  void _onGameOver(GameOver event, Emitter<GameState> emit) async {
    print('GameOver event received!');
    if (state is GameRunning) {
      final currentState = state as GameRunning;
      print('Current state: isGameOver=${currentState.isGameOver}, score=${currentState.score}');
      
      // Проверяем, не сохраняли ли уже счет
      if (_scoreSaved) {
        print('Score already saved, skipping...');
        return;
      }
      
      print('Processing Game Over...');
      emit(currentState.copyWith(isGameOver: true, isSavingScore: false));
      _stopGameTimer();
      
      // Сохраняем счет в Firebase
      await _saveScoreToFirebase(currentState.score, emit);
    } else {
      print('Game Over event received but state is not GameRunning: ${state.runtimeType}');
    }
  }

  void _onScoreSaved(ScoreSaved event, Emitter<GameState> emit) {
    if (state is GameRunning) {
      final currentState = state as GameRunning;
      emit(currentState.copyWith(scoreSaved: true, isSavingScore: false));
    }
  }

  void _onChickenJumped(ChickenJumped event, Emitter<GameState> emit) {
    if (InputSettings.enableDebugLogs) {
      print('ChickenJumped event received');
    }
    if (state is GameRunning) {
      final currentState = state as GameRunning;
      if (InputSettings.enableDebugLogs) {
        print('Current velocity: ${currentState.chickenVelocityY}, isPaused: ${currentState.isPaused}, isGameOver: ${currentState.isGameOver}');
      }
      
      // Строгое условие для прыжка - курица может прыгать только когда стоит на платформе
      // Проверяем, что курица действительно стоит на платформе (velocityY == 0)
      if (currentState.chickenVelocityY == 0 && !currentState.isPaused && !currentState.isGameOver) {
        // Дополнительная проверка - убеждаемся, что курица действительно на платформе
        final isOnPlatform = _isChickenOnAnyPlatform(currentState);
        if (isOnPlatform) {
          final gravity = 0.5;
          final jumpVelocity = -sqrt(2 * gravity * jumpHeight);
          if (InputSettings.enableDebugLogs) {
            print('✅ Jumping with velocity: $jumpVelocity (on platform)');
          }
          emit(currentState.copyWith(chickenVelocityY: jumpVelocity));
        } else {
          if (InputSettings.enableDebugLogs) {
            print('❌ Jump blocked: not on platform');
          }
        }
      } else {
        if (InputSettings.enableDebugLogs) {
          print('❌ Jump blocked: velocity=${currentState.chickenVelocityY.toStringAsFixed(2)}, paused=${currentState.isPaused}, gameOver=${currentState.isGameOver}');
        }
      }
    } else {
      if (InputSettings.enableDebugLogs) {
        print('❌ Game not running, current state: ${state.runtimeType}');
      }
    }
  }

  void _onChickenMovedLeft(ChickenMovedLeft event, Emitter<GameState> emit) {
    if (state is GameRunning) {
      final currentState = state as GameRunning;
      if (!currentState.isPaused && !currentState.isGameOver) {
        // Определяем, находится ли курица в воздухе
        final bool isInAir = currentState.chickenVelocityY != 0;
        final double moveSpeed = isInAir ? InputSettings.moveSpeedAir : InputSettings.moveSpeedGround;
        
        // Устанавливаем постоянную скорость влево
        final newVelocityX = -moveSpeed;
        emit(currentState.copyWith(
          chickenVelocityX: newVelocityX,
          isFacingRight: false,
        ));
        if (InputSettings.enableDebugLogs) {
          print('✅ Chicken moving left: velocity=${newVelocityX.toStringAsFixed(2)} (${isInAir ? 'AIR' : 'GROUND'})');
        }
      }
    }
  }

  void _onChickenMovedRight(ChickenMovedRight event, Emitter<GameState> emit) {
    if (state is GameRunning) {
      final currentState = state as GameRunning;
      if (!currentState.isPaused && !currentState.isGameOver) {
        // Определяем, находится ли курица в воздухе
        final bool isInAir = currentState.chickenVelocityY != 0;
        final double moveSpeed = isInAir ? InputSettings.moveSpeedAir : InputSettings.moveSpeedGround;
        
        // Устанавливаем постоянную скорость вправо
        final newVelocityX = moveSpeed;
        emit(currentState.copyWith(
          chickenVelocityX: newVelocityX,
          isFacingRight: true,
        ));
        if (InputSettings.enableDebugLogs) {
          print('✅ Chicken moving right: velocity=${newVelocityX.toStringAsFixed(2)} (${isInAir ? 'AIR' : 'GROUND'})');
        }
      }
    }
  }

  void _onGameUpdated(GameUpdated event, Emitter<GameState> emit) {
    if (state is GameRunning) {
      final currentState = state as GameRunning;
      if (!currentState.isPaused && !currentState.isGameOver) {
        final updatedState = _updateGameLogic(currentState);
        emit(updatedState);
      }
    }
  }

  GameRunning _createInitialGameState(double screenWidth, double screenHeight) {
    // Создаем начальную платформу
    final startY = screenHeight - 100;
    final platforms = <PlatformData>[
      PlatformData(
        id: 'start_platform',
        x: wallOffset + (screenWidth - 2 * wallOffset - platformWidth) / 2,
        y: startY,
        type: BlockType.normal,
      ),
    ];

    // Позиция курицы на стартовой платформе
    final startPlatform = platforms.first;
    final chickenX = startPlatform.x + (platformWidth - chickenSize) / 2;
    final chickenY = startPlatform.y - chickenSize;
    final cameraY = chickenY - screenHeight / 2;

    return GameRunning(
      score: 0,
      lives: 3,
      hasShield: false,
      isPaused: false,
      isGameOver: false,
      isSavingScore: false,
      scoreSaved: false,
      saveError: null,
      chickenX: chickenX,
      chickenY: chickenY,
      chickenVelocityY: 0.0,
      chickenVelocityX: 0.0, // Начальная горизонтальная скорость
      chickenState: ChickenState.idle,
      isFacingRight: true,
      cameraY: cameraY,
      currentLevel: startPlatform.y,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      platforms: platforms,
      bonuses: [],
      obstacles: [],
      crackingPlatforms: {},
      visiblePlatforms: platforms,
      visibleBonuses: [],
      visibleObstacles: [],
      isBonusCollecting: false,
      bonusCollectX: 0.0,
      bonusCollectY: 0.0,
      collectingBonusType: BonusType.goldenEgg,
      shieldAnimationValue: 0.3,
      shieldAppearAnimationValue: 0.0,
    );
  }

  GameRunning _updateGameLogic(GameRunning currentState) {
    // Обновляем физику курицы
    final newVelocityY = currentState.chickenVelocityY + 0.5;
    final newChickenY = currentState.chickenY + newVelocityY;
    
    // Обновляем горизонтальную физику (плавное движение с инерцией)
    double newVelocityX = currentState.chickenVelocityX;
    
    // Определяем, находится ли курица в воздухе (прыгает или падает)
    final bool isInAir = currentState.chickenVelocityY != 0;
    
    // Выбираем параметры в зависимости от состояния
    final double deceleration = isInAir ? InputSettings.moveDecelerationAir : InputSettings.moveDecelerationGround;
    
    // Применяем замедление (трение)
    if (newVelocityX.abs() > 0.01) {
      newVelocityX *= (1.0 - deceleration);
      if (newVelocityX.abs() < 0.01) {
        newVelocityX = 0.0; // Останавливаем при очень малой скорости
      }
    }
    
    // Обновляем позицию по X с учетом скорости и границ экрана
    double newChickenX = currentState.chickenX + newVelocityX;
    
    // Проверяем границы экрана и корректируем позицию и скорость
    if (newChickenX < wallOffset) {
      newChickenX = wallOffset;
      newVelocityX = 0.0; // Останавливаем при ударе о стену
    } else if (newChickenX > currentState.screenWidth - wallOffset - chickenSize) {
      newChickenX = currentState.screenWidth - wallOffset - chickenSize;
      newVelocityX = 0.0; // Останавливаем при ударе о стену
    }
    
    // Обновляем состояние курицы
    ChickenState newChickenState;
    if (newVelocityY > 0) {
      newChickenState = currentState.isFacingRight
          ? ChickenState.fallingRight
          : ChickenState.falling;
    } else if (newVelocityY < 0) {
      newChickenState = currentState.isFacingRight
          ? ChickenState.jumpRight
          : ChickenState.jump;
    } else {
      newChickenState = currentState.isFacingRight
          ? ChickenState.idleRight
          : ChickenState.idle;
    }

    // Обновляем камеру
    final targetCameraY = newChickenY - currentState.screenHeight / 2;
    final newCameraY = targetCameraY < currentState.cameraY
        ? targetCameraY
        : currentState.cameraY;

    // Создаем обновленное состояние
    var updatedState = currentState.copyWith(
      chickenX: newChickenX,
      chickenY: newChickenY,
      chickenVelocityX: newVelocityX,
      chickenVelocityY: newVelocityY,
      chickenState: newChickenState,
      cameraY: newCameraY,
    );

    // Обновляем платформы, бонусы, препятствия
    updatedState = _updatePlatforms(updatedState);
    updatedState = _updateBonuses(updatedState);
    updatedState = _updateObstacles(updatedState);

    // Проверяем коллизии
    updatedState = _checkCollisions(updatedState);

    // Генерируем новые объекты
    updatedState = _generateNewObjects(updatedState);

    // Проверяем падение
    if (newChickenY > newCameraY + currentState.screenHeight + 100) {
      print('GAME OVER: Chicken fell! chickenY: $newChickenY, cameraY: $newCameraY, screenHeight: ${currentState.screenHeight}');
      // Сначала запускаем сохранение счета, потом обновляем состояние
      add(const GameOver());
      updatedState = updatedState.copyWith(isGameOver: true);
    }

    // Обновляем кэш видимых объектов
    updatedState = _updateVisibleObjectsCache(updatedState);

    return updatedState;
  }

  GameRunning _updatePlatforms(GameRunning state) {
    bool platformsChanged = false;
    var updatedPlatforms = List<PlatformData>.from(state.platforms);
    var updatedCrackingPlatforms = Map<String, int>.from(state.crackingPlatforms);

    // Обновляем двигающиеся платформы
    for (int i = 0; i < updatedPlatforms.length; i++) {
      final platform = updatedPlatforms[i];
      if (platform.type == BlockType.moving) {
        double newX = platform.x + (platform.moveDirection * platform.moveSpeed);

        // Проверяем границы
        if (newX < wallOffset) {
          newX = wallOffset;
          updatedPlatforms[i] = platform.copyWith(
            x: newX,
            moveDirection: 1.0, // Меняем направление
          );
          platformsChanged = true;
        } else if (newX > state.screenWidth - wallOffset - platformWidth) {
          newX = state.screenWidth - wallOffset - platformWidth;
          updatedPlatforms[i] = platform.copyWith(
            x: newX,
            moveDirection: -1.0, // Меняем направление
          );
          platformsChanged = true;
        } else {
          updatedPlatforms[i] = platform.copyWith(x: newX);
          platformsChanged = true;
        }
      }
    }

    // Обновляем трескающиеся платформы
    final platformsToRemove = <String>[];
    updatedCrackingPlatforms.forEach((platformId, timeLeft) {
      if (timeLeft <= 0) {
        // Платформа исчезает
        platformsToRemove.add(platformId);
        print('Platform destroyed: $platformId');
        platformsChanged = true;
      } else {
        updatedCrackingPlatforms[platformId] = timeLeft - 1;
      }
    });

    // Удаляем исчезнувшие платформы (только трескающиеся)
    if (platformsToRemove.isNotEmpty) {
      for (final platformId in platformsToRemove) {
        updatedPlatforms.removeWhere(
          (platform) => platform.id == platformId && platform.type == BlockType.cracking,
        );
        updatedCrackingPlatforms.remove(platformId);
      }
    }

    if (platformsChanged) {
      return state.copyWith(
        platforms: updatedPlatforms,
        crackingPlatforms: updatedCrackingPlatforms,
      );
    }

    return state;
  }

  GameRunning _updateBonuses(GameRunning state) {
    // Здесь будет логика обновления бонусов
    // Пока возвращаем состояние без изменений
    return state;
  }

  GameRunning _updateObstacles(GameRunning state) {
    bool obstaclesChanged = false;
    var updatedObstacles = List<ObstacleData>.from(state.obstacles);

    // Обновляем препятствия
    for (int i = 0; i < updatedObstacles.length; i++) {
      final obstacle = updatedObstacles[i];

      if (obstacle.type == ObstacleType.fallingRock && obstacle.isActive) {
        // Обновляем позицию падающего камня
        final newY = obstacle.y + obstacle.velocityY;
        updatedObstacles[i] = obstacle.copyWith(y: newY);
        obstaclesChanged = true;
      } else if (obstacle.type == ObstacleType.spearTrap) {
        // Обновляем ловушку с копьем
        if (!obstacle.isActive && obstacle.activationTimer > 0) {
          // Отсчитываем время до активации
          updatedObstacles[i] = obstacle.copyWith(
            activationTimer: obstacle.activationTimer - 1,
          );
          obstaclesChanged = true;
        } else if (!obstacle.isActive && obstacle.activationTimer <= 0) {
          // Активируем копье
          updatedObstacles[i] = obstacle.copyWith(isActive: true);
          obstaclesChanged = true;
        } else if (obstacle.isActive) {
          // Двигаем активное копье
          final newX = obstacle.x + obstacle.velocityX;
          updatedObstacles[i] = obstacle.copyWith(x: newX);
          obstaclesChanged = true;
        }
      } else if (obstacle.type == ObstacleType.pendulumSpear && obstacle.isActive) {
        // Обновляем маятниковое копье
        final newX = obstacle.x + (obstacle.velocityX * obstacle.direction);

        // Проверяем, достигли ли границ диапазона
        if (newX <= obstacle.startX - pendulumRange || newX >= obstacle.startX + pendulumRange) {
          // Меняем направление
          updatedObstacles[i] = obstacle.copyWith(
            x: newX,
            direction: -obstacle.direction,
          );
        } else {
          updatedObstacles[i] = obstacle.copyWith(x: newX);
        }
        obstaclesChanged = true;
      }
    }

    // Удаляем препятствия, которые ушли за экран
    final initialLength = updatedObstacles.length;
    updatedObstacles.removeWhere((obstacle) {
      if (obstacle.type == ObstacleType.fallingRock) {
        return obstacle.y > state.chickenY + state.screenHeight + 200;
      } else if (obstacle.type == ObstacleType.spearTrap) {
        // Копья исчезают только когда полностью ушли за экран
        return obstacle.x < -200 || obstacle.x > state.screenWidth + 200;
      } else if (obstacle.type == ObstacleType.pendulumSpear) {
        // Маятниковые копья исчезают только когда курица ушла далеко вверх
        return obstacle.y < state.chickenY - state.screenHeight - 200;
      }
      return false;
    });

    if (updatedObstacles.length != initialLength) {
      obstaclesChanged = true;
    }

    if (obstaclesChanged) {
      return state.copyWith(obstacles: updatedObstacles);
    }

    return state;
  }

  GameRunning _checkCollisions(GameRunning state) {
    var updatedState = state;
    
    // Проверяем коллизии с платформами
    updatedState = _checkPlatformCollisions(updatedState);
    
    // Проверяем коллизии с бонусами
    updatedState = _checkBonusCollisions(updatedState);
    
    // Проверяем коллизии с препятствиями
    final beforeLives = updatedState.lives;
    updatedState = _checkObstacleCollisions(updatedState);
    if (updatedState.lives != beforeLives) {
      print('Lives changed in _checkCollisions: $beforeLives -> ${updatedState.lives}');
    }
    
    return updatedState;
  }

  GameRunning _checkPlatformCollisions(GameRunning state) {
    var updatedPlatforms = List<PlatformData>.from(state.platforms);
    var updatedCrackingPlatforms = Map<String, int>.from(state.crackingPlatforms);
    var updatedState = state;
    bool stateChanged = false;

    for (int i = 0; i < updatedPlatforms.length; i++) {
      final platform = updatedPlatforms[i];

      // Проверяем, не исчезла ли уже платформа (только для трескающихся)
      if (platform.type == BlockType.cracking &&
          updatedCrackingPlatforms.containsKey(platform.id) &&
          updatedCrackingPlatforms[platform.id]! <= 0) {
        continue; // Пропускаем исчезнувшие трескающиеся платформы
      }

      if (_isChickenOnPlatform(state, platform)) {
        updatedState = updatedState.copyWith(
          chickenVelocityY: 0,
          chickenY: platform.y - chickenSize,
          chickenState: state.isFacingRight ? ChickenState.idleRight : ChickenState.idle,
          // Не сбрасываем горизонтальную скорость при приземлении - курица продолжает скользить
        );
        stateChanged = true;

        // Обновляем текущий уровень и начисляем очки за подъем
        if (platform.y < state.currentLevel) {
          final heightGained = (state.currentLevel - platform.y).round();
          final newScore = state.score + (heightGained / 10).round();
          updatedState = updatedState.copyWith(
            score: newScore,
            currentLevel: platform.y,
          );
        }

        // Если это трескающаяся платформа, начинаем отсчет
        if (platform.type == BlockType.cracking &&
            !updatedCrackingPlatforms.containsKey(platform.id)) {
          updatedCrackingPlatforms[platform.id] = 30; // 0.5 секунды при 60 FPS
          print('Platform started cracking: ${platform.id}');
        }

        break;
      }
    }

    if (stateChanged) {
      updatedState = updatedState.copyWith(
        platforms: updatedPlatforms,
        crackingPlatforms: updatedCrackingPlatforms,
      );
    }

    return updatedState;
  }

  bool _isChickenOnPlatform(GameRunning state, PlatformData platform) {
    // Центрируем хитбокс коллизий относительно курицы
    double collisionX = state.chickenX + (chickenSize - chickenCollisionWidth) / 2;
    double collisionY = state.chickenY + (chickenSize - chickenCollisionHeight) / 2;

    // Проверяем, что хитбокс курицы находится над платформой по X
    bool horizontalOverlap = collisionX + chickenCollisionWidth > platform.x &&
        collisionX < platform.x + platformWidth;

    // Проверяем, что хитбокс курицы падает и находится на уровне платформы по Y
    bool verticalOverlap = collisionY + chickenCollisionHeight >= platform.y &&
        collisionY + chickenCollisionHeight <= platform.y + platformHeight;

    // Курица должна падать (velocityY > 0)
    bool isFalling = state.chickenVelocityY > 0;

    return horizontalOverlap && verticalOverlap && isFalling;
  }

  bool _isChickenOnAnyPlatform(GameRunning state) {
    // Проверяем, стоит ли курица на любой платформе
    for (final platform in state.platforms) {
      // Проверяем, не исчезла ли платформа (только для трескающихся)
      if (platform.type == BlockType.cracking &&
          state.crackingPlatforms.containsKey(platform.id) &&
          state.crackingPlatforms[platform.id]! <= 0) {
        continue; // Пропускаем исчезнувшие трескающиеся платформы
      }

      // Центрируем хитбокс коллизий относительно курицы
      double collisionX = state.chickenX + (chickenSize - chickenCollisionWidth) / 2;
      double collisionY = state.chickenY + (chickenSize - chickenCollisionHeight) / 2;

      // Проверяем, что хитбокс курицы находится над платформой по X
      bool horizontalOverlap = collisionX + chickenCollisionWidth > platform.x &&
          collisionX < platform.x + platformWidth;

      // Проверяем, что хитбокс курицы находится точно на уровне платформы по Y
      // (курица стоит на платформе, а не падает на неё)
      bool verticalOverlap = (collisionY + chickenCollisionHeight - platform.y).abs() < 2.0;

      if (horizontalOverlap && verticalOverlap) {
        return true;
      }
    }
    return false;
  }

  GameRunning _checkBonusCollisions(GameRunning state) {
    var updatedBonuses = List<BonusData>.from(state.bonuses);
    var updatedState = state;
    bool stateChanged = false;

    for (int i = 0; i < updatedBonuses.length; i++) {
      final bonus = updatedBonuses[i];
      if (!bonus.isCollected) {
        // Проверяем коллизию с курицей
        if (_isChickenOnBonus(state, bonus)) {
          updatedBonuses[i] = bonus.copyWith(isCollected: true);
          
          // Запускаем анимацию сбора бонуса
          updatedState = updatedState.copyWith(
            isBonusCollecting: true,
            bonusCollectX: bonus.x,
            bonusCollectY: bonus.y,
            collectingBonusType: bonus.type,
          );
          
          // Обрабатываем эффект бонуса
          switch (bonus.type) {
            case BonusType.goldenEgg:
              updatedState = updatedState.copyWith(score: state.score + 50);
              break;
            case BonusType.shield:
              updatedState = updatedState.copyWith(hasShield: true);
              break;
            case BonusType.life:
              updatedState = updatedState.copyWith(lives: state.lives + 1);
              break;
          }
          
          stateChanged = true;
        }
      }
    }

    if (stateChanged) {
      updatedState = updatedState.copyWith(bonuses: updatedBonuses);
    }

    return updatedState;
  }

  bool _isChickenOnBonus(GameRunning state, BonusData bonus) {
    return state.chickenX + chickenSize > bonus.x &&
        state.chickenX < bonus.x + 30 &&
        state.chickenY + chickenSize > bonus.y &&
        state.chickenY < bonus.y + 30;
  }

  GameRunning _checkObstacleCollisions(GameRunning state) {
    var updatedObstacles = List<ObstacleData>.from(state.obstacles);
    var updatedState = state;
    bool stateChanged = false;

    for (int i = 0; i < updatedObstacles.length; i++) {
      final obstacle = updatedObstacles[i];
      
      // Отладочная информация для копий
      if (obstacle.type == ObstacleType.spearTrap && InputSettings.enableDebugLogs) {
        print('Spear trap: active=${obstacle.isActive}, pos=(${obstacle.x.toStringAsFixed(1)}, ${obstacle.y.toStringAsFixed(1)}), timer=${obstacle.activationTimer}');
      }
      
      if (!obstacle.isActive) continue;

      // Проверяем коллизию с курицей
      if (_isChickenHitByObstacle(state, obstacle)) {
        print('COLLISION DETECTED: ${obstacle.type} at (${obstacle.x}, ${obstacle.y})');
        print('Chicken position: (${state.chickenX}, ${state.chickenY})');
        print('Has shield: ${state.hasShield}, Lives: ${state.lives}');
        
        if (state.hasShield) {
          // Щит защищает от одного удара
          print('Shield absorbed hit!');
          updatedState = updatedState.copyWith(hasShield: false);
          // Деактивируем препятствие
          updatedObstacles[i] = obstacle.copyWith(isActive: false);
        } else {
          // Теряем жизнь
          final newLives = state.lives - 1;
          print('Lives reduced from ${state.lives} to $newLives');
          if (newLives <= 0) {
            print('GAME OVER: Lives exhausted! Lives: $newLives');
            // Сначала запускаем сохранение счета, потом обновляем состояние
            add(const GameOver());
            updatedState = updatedState.copyWith(isGameOver: true);
          } else {
            updatedState = updatedState.copyWith(lives: newLives);
            // Деактивируем препятствие после попадания
            updatedObstacles[i] = obstacle.copyWith(isActive: false);
          }
        }
        stateChanged = true;
      }
    }

    if (stateChanged) {
      updatedState = updatedState.copyWith(obstacles: updatedObstacles);
    }

    return updatedState;
  }

  bool _isChickenHitByObstacle(GameRunning state, ObstacleData obstacle) {
    // Центрируем хитбокс коллизий относительно курицы
    double collisionX = state.chickenX + (chickenSize - chickenCollisionWidth) / 2;
    double collisionY = state.chickenY + (chickenSize - chickenCollisionHeight) / 2;

    // Проверяем коллизию с падающим камнем
    if (obstacle.type == ObstacleType.fallingRock) {
      final isHit = collisionX + chickenCollisionWidth > obstacle.x &&
          collisionX < obstacle.x + fallingRockSize &&
          collisionY + chickenCollisionHeight > obstacle.y &&
          collisionY < obstacle.y + fallingRockSize;
      
      if (isHit) {
        print('Falling rock collision check: chicken($collisionX, $collisionY) vs rock(${obstacle.x}, ${obstacle.y})');
      }
      return isHit;
    }

    // Проверяем коллизию с копьем
    if ((obstacle.type == ObstacleType.spearTrap || obstacle.type == ObstacleType.pendulumSpear) &&
        obstacle.isActive) {
      // Более точная проверка коллизий с копьями
      final isHit = collisionX + chickenCollisionWidth > obstacle.x &&
          collisionX < obstacle.x + spearWidth &&
          collisionY + chickenCollisionHeight > obstacle.y &&
          collisionY < obstacle.y + spearHeight;
      
      if (isHit && InputSettings.enableDebugLogs) {
        print('Spear collision check: chicken($collisionX, $collisionY) vs spear(${obstacle.x}, ${obstacle.y})');
        print('Collision bounds: chicken[${collisionX}-${collisionX + chickenCollisionWidth}] vs spear[${obstacle.x}-${obstacle.x + spearWidth}]');
        print('Y bounds: chicken[${collisionY}-${collisionY + chickenCollisionHeight}] vs spear[${obstacle.y}-${obstacle.y + spearHeight}]');
        print('Spear type: ${obstacle.type}, Active: ${obstacle.isActive}');
      }
      return isHit;
    }

    return false;
  }

  GameRunning _generateNewObjects(GameRunning state) {
    bool objectsRemoved = false;
    var updatedPlatforms = List<PlatformData>.from(state.platforms);
    var updatedBonuses = List<BonusData>.from(state.bonuses);
    var updatedObstacles = List<ObstacleData>.from(state.obstacles);

    // Удаляем платформы, бонусы и препятствия, которые ушли за экран (вниз)
    final initialPlatformsLength = updatedPlatforms.length;
    final initialBonusesLength = updatedBonuses.length;
    final initialObstaclesLength = updatedObstacles.length;

    updatedPlatforms.removeWhere((platform) => platform.y > state.chickenY + 500);
    updatedBonuses.removeWhere((bonus) => bonus.y > state.chickenY + 500);
    updatedObstacles.removeWhere((obstacle) => obstacle.y > state.chickenY + 500);

    if (updatedPlatforms.length != initialPlatformsLength ||
        updatedBonuses.length != initialBonusesLength ||
        updatedObstacles.length != initialObstaclesLength) {
      objectsRemoved = true;
    }

    // Бесконечно добавляем новые уровни ВЫШЕ курицы
    // Проверяем, есть ли достаточно платформ выше курицы
    var platformsAboveChicken = updatedPlatforms
        .where((p) => p.y < state.chickenY - levelHeight * 2)
        .length;

    // Если платформ выше курицы меньше 3, генерируем одну новую
    if (platformsAboveChicken < 3) {
      final nextLevelIndex = updatedPlatforms.length;
      final newLevel = _generateLevelAtYAndInsert(nextLevelIndex, state);
      updatedPlatforms = newLevel.platforms;
      updatedBonuses = newLevel.bonuses;
      updatedObstacles = newLevel.obstacles;
      objectsRemoved = true;
    }

    if (objectsRemoved) {
      return state.copyWith(
        platforms: updatedPlatforms,
        bonuses: updatedBonuses,
        obstacles: updatedObstacles,
      );
    }

    return state;
  }

  GameRunning _generateLevelAtYAndInsert(int levelIndex, GameRunning state) {
    final levelY = state.platforms.first.y - levelHeight; // Генерируем ВЫШЕ самой верхней платформы
    final gameAreaWidth = state.screenWidth - 2 * wallOffset - platformWidth;

    // Генерируем платформу в доступной зоне
    double platformX;
    if (state.platforms.isEmpty) {
      platformX = wallOffset + gameAreaWidth / 2;
    } else {
      // Следующие платформы случайно по всей ширине экрана
      final minX = wallOffset;
      final maxX = state.screenWidth - wallOffset - platformWidth;

      // Используем настоящий случайный генератор
      // Создаем зоны: левая треть, центральная треть, правая треть
      int zone;

      // Создаем паттерны: иногда несколько платформ подряд в одной зоне
      if (_currentPatternLength > 0 && _currentPatternZone != -1) {
        zone = _currentPatternZone;
        _currentPatternLength--;
      } else {
        zone = _random.nextInt(3); // 0, 1, 2

        // Иногда (20% шанс) создаем паттерн из 2-4 платформ в одной зоне
        if (_random.nextInt(5) == 0) {
          _currentPatternLength = _random.nextInt(3) + 1; // 1-3 дополнительные платформы
          _currentPatternZone = zone;
        }
      }
      double zoneStart, zoneEnd;

      switch (zone) {
        case 0: // Левая зона
          zoneStart = minX;
          zoneEnd = minX + (maxX - minX) * 0.33;
          break;
        case 1: // Центральная зона (реже)
          zoneStart = minX + (maxX - minX) * 0.33;
          zoneEnd = minX + (maxX - minX) * 0.66;
          break;
        case 2: // Правая зона
          zoneStart = minX + (maxX - minX) * 0.66;
          zoneEnd = maxX;
          break;
        default:
          zoneStart = minX;
          zoneEnd = maxX;
      }

      // Случайная позиция в выбранной зоне
      platformX = zoneStart + _random.nextDouble() * (zoneEnd - zoneStart);

      // Иногда (10% шанс) делаем платформу в крайней позиции для максимальной сложности
      if (_random.nextInt(10) == 0) {
        if (zone == 0) {
          platformX = minX; // Крайняя левая
        } else if (zone == 2) {
          platformX = maxX; // Крайняя правая
        }
      }

      // Иногда (5% шанс) создаем "сложный прыжок" - платформу очень далеко
      if (_random.nextInt(20) == 0) {
        final extremeZone = _random.nextInt(2); // 0 или 1
        if (extremeZone == 0) {
          platformX = minX + _random.nextDouble() * 20; // Очень близко к левому краю
        } else {
          platformX = maxX - _random.nextDouble() * 20; // Очень близко к правому краю
        }
      }
    }

    // Выбираем тип платформы
    BlockType platformType;
    double moveDirection = 0.0;
    double moveSpeed = 0.0;

    if (levelIndex < 5) {
      platformType = BlockType.normal; // Первые 5 платформ всегда обычные
    } else {
      final randomType = _random.nextInt(10);
      if (randomType < 6) {
        platformType = BlockType.normal;
      } else if (randomType < 8) {
        platformType = BlockType.cracking;
      } else {
        platformType = BlockType.moving;
        moveDirection = _random.nextBool() ? 1.0 : -1.0;
        moveSpeed = 1.2 + _random.nextDouble() * 0.8; // 1.2-2.0
      }
    }

    // Добавляем платформу в НАЧАЛО списка (выше всех)
    var newPlatforms = List<PlatformData>.from(state.platforms);
    newPlatforms.insert(
      0,
      PlatformData(
        id: 'platform_${levelIndex}_${levelY}',
        x: platformX,
        y: levelY,
        type: platformType,
        moveDirection: moveDirection,
        moveSpeed: moveSpeed,
      ),
    );

    // Иногда добавляем бонус
    var newBonuses = List<BonusData>.from(state.bonuses);
    if (levelIndex > 2 && _random.nextInt(8) == 0) {
      // 12.5% шанс, начиная с 3-й платформы
      final bonus = _generateBonus(platformX, levelY - 30);
      newBonuses.add(bonus);
    }

    // Иногда добавляем препятствие на том же уровне, что и платформа
    var newObstacles = List<ObstacleData>.from(state.obstacles);
    print('Generating obstacle for platform level: $levelY');
    final obstacle = _generateObstacle(levelY, state);
    if (obstacle != null) {
      newObstacles.add(obstacle);
      print('Added obstacle: ${obstacle.type} at (${obstacle.x}, ${obstacle.y})');
    }

    return state.copyWith(
      platforms: newPlatforms,
      bonuses: newBonuses,
      obstacles: newObstacles,
    );
  }

  BonusData _generateBonus(double platformX, double platformY) {
    final randomType = _random.nextInt(10);
    BonusType bonusType;

    if (randomType < 7) {
      // 70% шанс золотого яйца
      bonusType = BonusType.goldenEgg;
    } else if (randomType < 9) {
      // 20% шанс щита
      bonusType = BonusType.shield;
    } else {
      // 10% шанс жизни
      bonusType = BonusType.life;
    }

    return BonusData(
      x: platformX + (platformWidth - 30) / 2, // Центрируем над платформой
      y: platformY,
      type: bonusType,
    );
  }

  ObstacleData? _generateObstacle(double levelY, GameRunning state) {
    // Генерируем препятствие только если курица поднялась достаточно высоко
    // Проверяем по текущей позиции курицы относительно стартовой позиции
    final startY = state.screenHeight - 100 - chickenSize; // Стартовая позиция курицы
    final currentChickenHeight = startY - state.chickenY; // На сколько поднялась курица

    print('_generateObstacle called: levelY=$levelY, chickenY=${state.chickenY}, height=$currentChickenHeight, distance=${state.chickenY - levelY}');
    print('Condition check: chickenY - levelY (${state.chickenY - levelY}) < 200 = ${state.chickenY - levelY < 200}');

    // Уменьшаем минимальную высоту для появления препятствий
    if (currentChickenHeight < 400) {
      print('Obstacle generation blocked: height too low ($currentChickenHeight < 400)');
      return null; // Первые 400 пикселей подъема без препятствий
    }

    // Проверяем, что нет препятствий слишком близко к этому уровню
    final nearbyObstacles = state.obstacles.where((obstacle) {
      return (obstacle.y - levelY).abs() < 300; // В пределах 300 пикселей
    }).toList();
    
    if (nearbyObstacles.isNotEmpty) {
      print('Obstacle generation blocked: nearby obstacle exists at level $levelY');
      return null;
    }

    // Проверяем шанс появления препятствия
    final spawnChance = _random.nextDouble();
    if (spawnChance > obstacleSpawnChance) {
      print('Obstacle generation blocked: spawn chance failed ($spawnChance > $obstacleSpawnChance)');
      return null;
    }

    // Проверяем, что курица еще не достигла этого уровня
    // В игре Y координаты отрицательные, поэтому levelY < chickenY означает, что препятствие выше курицы
    // Мы хотим, чтобы препятствие было выше курицы на достаточном расстоянии
    // levelY должен быть меньше chickenY (более отрицательный), и разница должна быть достаточной
    if (state.chickenY - levelY < 200) {
      print('Obstacle generation blocked: chicken too close to level (distance: ${state.chickenY - levelY} < 200)');
      return null; // Курица слишком близко к уровню
    }

    print('Generating obstacle at levelY: $levelY, chickenHeight: $currentChickenHeight, distance: ${state.chickenY - levelY}');

    // Выбираем тип препятствия (33% каждый тип)
    final obstacleTypeInt = _random.nextInt(3);
    final obstacleType = obstacleTypeInt == 0
        ? ObstacleType.fallingRock
        : obstacleTypeInt == 1
        ? ObstacleType.spearTrap
        : ObstacleType.pendulumSpear;

    if (obstacleType == ObstacleType.fallingRock) {
      // Генерируем падающий камень
      final gameAreaWidth = state.screenWidth - 2 * wallOffset - fallingRockSize;
      final obstacleX = wallOffset + _random.nextDouble() * gameAreaWidth;

      // Камень появляется выше экрана и падает вниз
      final spawnY = levelY - 300 - _random.nextDouble() * 200; // 300-500 пикселей выше уровня

      return ObstacleData(
        id: 'falling_rock_${state.obstacles.length}_${levelY}',
        x: obstacleX,
        y: spawnY,
        type: ObstacleType.fallingRock,
        velocityY: fallingRockSpeed + _random.nextDouble() * 1.0, // Скорость 3.0-4.0
        isActive: true,
      );
    } else if (obstacleType == ObstacleType.spearTrap) {
      // Генерируем ловушку с копьем
      final isLeftWall = _random.nextBool(); // С какой стены выстреливает
      final spearX = isLeftWall ? wallOffset - 60 : state.screenWidth - wallOffset; // Позиция за стеной
      // Копье появляется на уровне платформы, куда курица скоро придет
      final spearY = levelY - 20;

      if (InputSettings.enableDebugLogs) {
        print('Generated spear trap: pos=($spearX, $spearY), direction=${isLeftWall ? 'LEFT' : 'RIGHT'}, speed=$spearSpeed');
      }

      return ObstacleData(
        id: 'spear_trap_${state.obstacles.length}_${levelY}',
        x: spearX,
        y: spearY,
        type: ObstacleType.spearTrap,
        velocityX: isLeftWall ? spearSpeed : -spearSpeed, // Скорость выстрела
        isActive: false, // Начинаем неактивной
        activationTimer: 20, // Уменьшаем время активации для более быстрого срабатывания
      );
    } else if (obstacleType == ObstacleType.pendulumSpear) {
      // Генерируем маятниковое копье
      final spearY = levelY - 20; // На уровне платформы
      final startX = wallOffset + (state.screenWidth - 2 * wallOffset) / 2; // Начинаем в центре
      final direction = _random.nextBool() ? 1.0 : -1.0; // Направление движения

      return ObstacleData(
        id: 'pendulum_spear_${state.obstacles.length}_${levelY}',
        x: startX,
        y: spearY,
        type: ObstacleType.pendulumSpear,
        velocityX: pendulumSpeed,
        isActive: true, // Сразу активное
        startX: startX,
        direction: direction,
      );
    }

    return null;
  }

  GameRunning _updateVisibleObjectsCache(GameRunning state) {
    final cameraTop = state.cameraY - 100;
    final cameraBottom = state.cameraY + state.screenHeight + 100;

    final visiblePlatforms = state.platforms.where((platform) {
      return platform.y >= cameraTop && platform.y <= cameraBottom;
    }).toList();

    final visibleBonuses = state.bonuses.where((bonus) {
      return !bonus.isCollected && 
             bonus.y >= cameraTop && 
             bonus.y <= cameraBottom;
    }).toList();

    final visibleObstacles = state.obstacles.where((obstacle) {
      // Показываем все препятствия в области видимости, независимо от их активности
      // Активность влияет только на поведение, но не на видимость
      return obstacle.y >= cameraTop && 
             obstacle.y <= cameraBottom;
    }).toList();

    // Отладочная информация
    if (state.obstacles.isNotEmpty) {
      print('Obstacles: Total=${state.obstacles.length}, Visible=${visibleObstacles.length}');
      if (visibleObstacles.isEmpty) {
        print('Camera: $cameraTop to $cameraBottom');
        print('Obstacles Y positions: ${state.obstacles.map((o) => '${o.type}@${o.y}').toList()}');
      }
    }

    return state.copyWith(
      visiblePlatforms: visiblePlatforms,
      visibleBonuses: visibleBonuses,
      visibleObstacles: visibleObstacles,
    );
  }

  void _startGameTimer() {
    _stopGameTimer();
    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60 FPS
      (_) => add(const GameUpdated()),
    );
  }

  void _stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void _onBonusCollectAnimationFinished(BonusCollectAnimationFinished event, Emitter<GameState> emit) {
    final currentState = state;
    if (currentState is GameRunning) {
      emit(currentState.copyWith(isBonusCollecting: false));
    }
  }

  Future<void> _saveScoreToFirebase(int score, Emitter<GameState> emit) async {
    print('_saveScoreToFirebase called with score: $score');
    
    // Устанавливаем флаг, что начали сохранение
    _scoreSaved = true;
    
    if (score <= 0) {
      print('Score is 0 or negative, not saving');
      if (!emit.isDone && state is GameRunning) {
        emit((state as GameRunning).copyWith(scoreSaved: true));
      }
      return;
    }

    try {
      print('GameBloc: Attempting to save score to Firebase...');
      final leaderboardService = LeaderboardService();
      final user = await leaderboardService.getCurrentUser();
      print('GameBloc: Current user: ${user?.nickname}');
      
      if (user?.nickname != null) {
        print('GameBloc: Updating player score: ${user!.nickname} -> $score');
        final success = await leaderboardService.updatePlayerScore(user.nickname, score);
        print('GameBloc: Score update result: $success');
        
        if (success) {
          print('Score saved successfully!');
          if (!emit.isDone && state is GameRunning) {
            emit((state as GameRunning).copyWith(scoreSaved: true));
          }
          add(const ScoreSaved());
        } else {
          print('Failed to save score - new score not higher than current score');
          // Не показываем ошибку пользователю, просто не обновляем состояние
        }
      } else {
        print('GameBloc: No user nickname found, cannot save score');
        // Не показываем ошибку пользователю, просто не сохраняем счет
      }
    } catch (e) {
      print('GameBloc: Error saving score to Firebase: $e');
      // Не показываем ошибку пользователю, просто не сохраняем счет
    }
  }

  @override
  Future<void> close() {
    _stopGameTimer();
    _shieldAnimationTimer?.cancel();
    _shieldAppearTimer?.cancel();
    return super.close();
  }
}
