import 'dart:math';
import 'package:chiken_odyssey/game_screen/models/block_type.dart';
import 'package:chiken_odyssey/game_screen/models/bonus_data.dart';
import 'package:chiken_odyssey/game_screen/models/obstacle_data.dart';
import 'package:chiken_odyssey/game_screen/models/platform_data.dart';
import 'package:chiken_odyssey/features/leaderboard_screen/data/services/leaderboard_service.dart';
import 'package:flutter/material.dart';
import 'package:chiken_odyssey/game_screen/widgets/chicken_widget.dart';
import 'package:chiken_odyssey/game_screen/widgets/game_over_screen.dart';
import 'package:chiken_odyssey/game_screen/widgets/pause_screen.dart';
import 'package:chiken_odyssey/game_screen/widgets/game_objects_layer.dart';
import 'package:chiken_odyssey/game_screen/widgets/game_effects_layer.dart';
import 'package:chiken_odyssey/game_screen/widgets/debug_layer.dart';


class GameWorld extends StatefulWidget {
  final VoidCallback? onBackToMenu;
  final Function(bool isPaused)? onPauseStateChanged;
  final VoidCallback? onGameDataChanged;
  final VoidCallback? onScoreSaved;

  const GameWorld({
    super.key, 
    this.onBackToMenu, 
    this.onPauseStateChanged,
    this.onGameDataChanged,
    this.onScoreSaved,
  });

  @override
  State<GameWorld> createState() => GameWorldState();
}

class GameWorldState extends State<GameWorld> with TickerProviderStateMixin {
  // Константы
  static const double wallOffset = 30.0; // Отступ для стенок
  static const double chickenSize = 95.0;
  static const double chickenCollisionWidth =
      20.0; // Ширина хитбокса для коллизий
  static const double chickenCollisionHeight =
      95.0; // Высота хитбокса для коллизий
  static const double platformWidth = 100.0;
  static const double platformHeight = 20.0;
  static const double jumpHeight =
      215.0; // Максимальная высота прыжка (увеличено)
  static const double levelHeight =
      200.0; // Высота между уровнями (увеличено для большей сложности)
  static const double maxJumpDistance =
      150.0; // Максимальное расстояние для прыжка

  // Константы для препятствий
  static const double fallingRockSize = 40.0;
  static const double fallingRockSpeed = 2.0; // Скорость падения камней
  static const double spearWidth = 60.0; // Ширина копья
  static const double spearHeight = 8.0; // Высота копья
  static const double spearSpeed = 4.0; // Скорость выстрела копья (уменьшена)
  static const double pendulumSpeed = 3.5; // Скорость маятникового копья (уменьшена)
  static const double pendulumRange = 200.0; // Диапазон движения маятника
  static const double obstacleSpawnChance =
      0.5; // 50% шанс появления препятствия на уровне

  // Генератор случайных чисел
  late Random _random;

  // Переменные для создания паттернов
  int _currentPatternLength = 0;
  int _currentPatternZone = -1;

  // Курица
  double chickenX = 0.0; // Будет установлено в initState
  double chickenY = 300.0;
  double chickenVelocityY = 0.0;
  ChickenState chickenState = ChickenState.idle;
  bool isFacingRight = true;

  // Размеры экрана
  double screenWidth = 400.0; // Значение по умолчанию
  double screenHeight = 800.0; // Значение по умолчанию

  // Игровые переменные
  int score = 0;
  int lives = 3;
  bool hasShield = false;
  double currentLevel = 0.0; // Текущий уровень (Y координата)
  bool isGameOver = false; // Состояние Game Over
  bool isPaused = false; // Состояние паузы
  
  // Состояние сохранения счета
  bool isSavingScore = false;
  bool scoreSaved = false;
  String? saveError;

  // Камера
  double cameraY = 0.0; // Позиция камеры

  // Трескающиеся платформы
  Map<String, int> crackingPlatforms = {}; // platformId -> timeLeft

  // Платформы, бонусы и препятствия
  List<PlatformData> platforms = [];
  List<BonusData> bonuses = [];
  List<ObstacleData> obstacles = [];

  // Кэшированные списки для видимых объектов (оптимизация производительности)
  List<PlatformData> _visiblePlatforms = [];
  List<BonusData> _visibleBonuses = [];
  List<ObstacleData> _visibleObstacles = [];
  bool _cacheNeedsUpdate = true;

  // Анимация
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Анимация для эффекта щита
  late AnimationController _shieldAnimationController;
  late Animation<double> _shieldAnimation;

  // Анимация появления щита
  late AnimationController _shieldAppearController;
  late Animation<double> _shieldAppearAnimation;

  // Анимация сбора бонусов
  late AnimationController _bonusCollectController;
  late Animation<double> _bonusCollectAnimation;
  bool _isBonusCollecting = false;
  double _bonusCollectX = 0.0;
  double _bonusCollectY = 0.0;
  BonusType _collectingBonusType = BonusType.goldenEgg;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _initializeAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    if (platforms.isEmpty) {
      _generateInitialPlatforms();
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 16,
      ), // ~60 FPS для плавной анимации
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _animation.addListener(() {
      _updateGame();
    });

    _animationController.repeat();

    // Инициализируем анимацию щита
    _shieldAnimationController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ), // 2 секунды на цикл (медленнее)
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
      duration: const Duration(milliseconds: 800), // 0.8 секунды на появление
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
      duration: const Duration(milliseconds: 1000), // 1 секунда
      vsync: this,
    );
    _bonusCollectAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bonusCollectController, curve: Curves.easeOut),
    );
  }

  void _generateInitialPlatforms() {
    platforms.clear();
    bonuses.clear();
    obstacles.clear();

    // Сбрасываем паттерны
    _currentPatternLength = 0;
    _currentPatternZone = -1;

    // Генерируем только стартовую платформу
    final startY = screenHeight - 100; // Начинаем снизу экрана

    // Создаем только одну стартовую платформу в центре
    platforms.add(
      PlatformData(
        id: 'start_platform',
        x:
            wallOffset +
            (screenWidth - 2 * wallOffset - platformWidth) / 2, // Центр экрана
        y: startY,
        type: BlockType.normal,
      ),
    );

    // Ставим курицу на стартовую платформу
    final startPlatform = platforms.first;
    chickenX = startPlatform.x + (platformWidth - chickenSize) / 2;
    chickenY = startPlatform.y - chickenSize;
    chickenVelocityY = 0;
    currentLevel = startPlatform.y;
    cameraY = chickenY - screenHeight / 2; // Камера центрируется на курице

    // Инициализация завершена

    print('Generated ${platforms.length} initial platforms');
  }

  void _generateLevel(int levelIndex) {
    // Этот метод теперь используется для генерации новых платформ выше курицы
    final levelY =
        platforms.first.y -
        levelHeight; // Генерируем ВЫШЕ самой верхней платформы
    _generateLevelAtYAndInsert(levelIndex, levelY);
  }

  void _generateLevelAtYAndInsert(int levelIndex, double levelY) {
    final gameAreaWidth = screenWidth - 2 * wallOffset - platformWidth;

    // Генерируем платформу в доступной зоне
    double platformX;
    if (platforms.isEmpty) {
      platformX = wallOffset + gameAreaWidth / 2;
    } else {
      // Следующие платформы случайно по всей ширине экрана
      final minX = wallOffset;
      final maxX = screenWidth - wallOffset - platformWidth;

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
          _currentPatternLength =
              _random.nextInt(3) + 1; // 1-3 дополнительные платформы
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
          platformX =
              minX + _random.nextDouble() * 20; // Очень близко к левому краю
        } else {
          platformX =
              maxX - _random.nextDouble() * 20; // Очень близко к правому краю
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
    platforms.insert(
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
    if (levelIndex > 2 && _random.nextInt(8) == 0) {
      // 12.5% шанс, начиная с 3-й платформы
      _generateBonus(platformX, levelY - 30);
    }

    // Иногда добавляем препятствие
    _generateObstacle(levelY);

    // Инвалидируем кэш при добавлении новых объектов
    _cacheNeedsUpdate = true;
  }

  void _generateBonus(double platformX, double platformY) {
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

    bonuses.add(
      BonusData(
        x: platformX + (platformWidth - 30) / 2, // Центрируем над платформой
        y: platformY,
        type: bonusType,
      ),
    );
  }

  void _generateObstacle(double levelY) {
    // Генерируем препятствие только если курица поднялась достаточно высоко
    // Проверяем по текущей позиции курицы относительно стартовой позиции
    final startY = screenHeight - 100 - chickenSize; // Стартовая позиция курицы
    final currentChickenHeight =
        startY - chickenY; // На сколько поднялась курица

    if (currentChickenHeight < 800)
      return; // Первые 800 пикселей подъема без препятствий

    // Проверяем шанс появления препятствия
    if (_random.nextDouble() > obstacleSpawnChance) return;

    // Проверяем, что курица еще не достигла этого уровня
    if (chickenY > levelY - 200)
      return; // Курица еще не близко к уровню (должна быть ниже)

    // Выбираем тип препятствия (33% каждый тип)
    final obstacleTypeInt = _random.nextInt(3);
    final obstacleType = obstacleTypeInt == 0
        ? ObstacleType.fallingRock
        : obstacleTypeInt == 1
        ? ObstacleType.spearTrap
        : ObstacleType.pendulumSpear;

    if (obstacleType == ObstacleType.fallingRock) {
      // Генерируем падающий камень
      final gameAreaWidth = screenWidth - 2 * wallOffset - fallingRockSize;
      final obstacleX = wallOffset + _random.nextDouble() * gameAreaWidth;

      // Камень появляется выше экрана и падает вниз
      final spawnY =
          levelY -
          300 -
          _random.nextDouble() * 200; // 300-500 пикселей выше уровня

      obstacles.add(
        ObstacleData(
          id: 'falling_rock_${obstacles.length}_${levelY}',
          x: obstacleX,
          y: spawnY,
          type: ObstacleType.fallingRock,
          velocityY:
              fallingRockSpeed + _random.nextDouble() * 1.0, // Скорость 3.0-4.0
          isActive: true,
        ),
      );

      print(
        'Generated falling rock at height: ${currentChickenHeight.toInt()}px',
      );
    } else if (obstacleType == ObstacleType.spearTrap) {
      // Генерируем ловушку с копьем
      final isLeftWall = _random.nextBool(); // С какой стены выстреливает
      final spearX = isLeftWall
          ? wallOffset - 60
          : screenWidth - wallOffset; // Позиция за стеной
      // Копье появляется на уровне платформы, куда курица скоро придет
      final spearY = levelY - 20;

      obstacles.add(
        ObstacleData(
          id: 'spear_trap_${obstacles.length}_${levelY}',
          x: spearX,
          y: spearY,
          type: ObstacleType.spearTrap,
          velocityX: isLeftWall ? spearSpeed : -spearSpeed, // Скорость выстрела
          isActive: false, // Начинаем неактивной
          activationTimer: 30, // 0.5 секунды до активации (быстрее)
        ),
      );

      print(
        'Generated spear trap at chicken level: ${currentChickenHeight.toInt()}px',
      );
    } else if (obstacleType == ObstacleType.pendulumSpear) {
      // Генерируем маятниковое копье
      final spearY = levelY - 20; // На уровне платформы
      final startX =
          wallOffset + (screenWidth - 2 * wallOffset) / 2; // Начинаем в центре
      final direction = _random.nextBool() ? 1.0 : -1.0; // Направление движения

      obstacles.add(
        ObstacleData(
          id: 'pendulum_spear_${obstacles.length}_${levelY}',
          x: startX,
          y: spearY,
          type: ObstacleType.pendulumSpear,
          velocityX: pendulumSpeed,
          isActive: true, // Сразу активное
          startX: startX,
          direction: direction,
        ),
      );

      print(
        'Generated pendulum spear at chicken level: ${currentChickenHeight.toInt()}px',
      );
    }
  }

  void _updateGame() {
    if (isPaused || isGameOver)
      return; // Не обновляем игру если она на паузе или завершена

    // Обновляем физику курицы
    _updateChickenPhysics();

    // Обновляем камеру (следует за курицей)
    _updateCamera();

    // Обновляем платформы (движение, трескание)
    _updatePlatforms();

    // Обновляем препятствия
    _updateObstacles();

    // Проверяем коллизии с платформами
    _checkPlatformCollisions();

    // Проверяем коллизии с бонусами
    _checkBonusCollisions();

    // Проверяем коллизии с препятствиями
    _checkObstacleCollisions();

    // Генерируем новые платформы если нужно
    _generateNewPlatforms();

    // Проверяем падение курицы
    _checkFall();

    // Обновляем кэш видимых объектов
    _updateVisibleObjectsCache();

    // Вызываем setState только один раз в конце
    setState(() {});
    
    // Уведомляем GameScreen об изменении данных
    widget.onGameDataChanged?.call();
  }

  void _updateVisibleObjectsCache() {
    if (!_cacheNeedsUpdate) return;

    final cameraTop = cameraY - 100;
    final cameraBottom = cameraY + screenHeight + 100;

    // Кэшируем видимые платформы
    _visiblePlatforms = platforms.where((platform) {
      return platform.y >= cameraTop && platform.y <= cameraBottom;
    }).toList();

    // Кэшируем видимые бонусы
    _visibleBonuses = bonuses.where((bonus) {
      return !bonus.isCollected && 
             bonus.y >= cameraTop && 
             bonus.y <= cameraBottom;
    }).toList();

    // Кэшируем видимые препятствия
    _visibleObstacles = obstacles.where((obstacle) {
      return obstacle.isActive && 
             obstacle.y >= cameraTop && 
             obstacle.y <= cameraBottom;
    }).toList();

    _cacheNeedsUpdate = false;
  }

  void _updateChickenPhysics() {
    // Гравитация
    chickenVelocityY +=
        0.5; // Уменьшаем гравитацию для более плавного прыжка
    chickenY += chickenVelocityY;

    // Обновляем состояние курицы
    if (chickenVelocityY > 0) {
      chickenState = isFacingRight
          ? ChickenState.fallingRight
          : ChickenState.falling;
    } else if (chickenVelocityY < 0) {
      chickenState = isFacingRight ? ChickenState.jumpRight : ChickenState.jump;
    } else {
      chickenState = isFacingRight ? ChickenState.idleRight : ChickenState.idle;
    }
  }

  void _updateCamera() {
    // Камера следует за курицей, но только вверх
    final targetCameraY = chickenY - screenHeight / 2;
    if (targetCameraY < cameraY) {
      cameraY = targetCameraY; // Камера движется только вверх
      _cacheNeedsUpdate = true; // Инвалидируем кэш при движении камеры
    }
  }

  void _checkPlatformCollisions() {
    for (int i = 0; i < platforms.length; i++) {
      final platform = platforms[i];

      // Проверяем, не исчезла ли уже платформа (только для трескающихся)
      if (platform.type == BlockType.cracking &&
          crackingPlatforms.containsKey(platform.id) &&
          crackingPlatforms[platform.id]! <= 0) {
        continue; // Пропускаем исчезнувшие трескающиеся платформы
      }

      if (_isChickenOnPlatform(platform)) {
        chickenVelocityY = 0;
        chickenY = platform.y - chickenSize; // Размер курицы
        chickenState = isFacingRight
            ? ChickenState.idleRight
            : ChickenState.idle;

        // Обновляем текущий уровень и начисляем очки за подъем
        if (platform.y < currentLevel) {
          final heightGained = (currentLevel - platform.y).round();
          score += (heightGained / 10)
              .round(); // Очки за высоту подъема (в 10 раз меньше)
          currentLevel = platform.y;
          
          // Уведомляем об изменении данных при начислении очков
          widget.onGameDataChanged?.call();
        }

        // Если это трескающаяся платформа, начинаем отсчет
        if (platform.type == BlockType.cracking &&
            !crackingPlatforms.containsKey(platform.id)) {
          crackingPlatforms[platform.id] = 30; // 0.5 секунды при 60 FPS
          print('Platform started cracking: ${platform.id}');
        }

        break;
      }
    }
  }

  bool _isChickenOnPlatform(PlatformData platform) {
    // Центрируем хитбокс коллизий относительно курицы
    double collisionX = chickenX + (chickenSize - chickenCollisionWidth) / 2;
    double collisionY = chickenY + (chickenSize - chickenCollisionHeight) / 2;

    // Проверяем, что хитбокс курицы находится над платформой по X
    bool horizontalOverlap =
        collisionX + chickenCollisionWidth > platform.x &&
        collisionX < platform.x + platformWidth;

    // Проверяем, что хитбокс курицы падает и находится на уровне платформы по Y
    bool verticalOverlap =
        collisionY + chickenCollisionHeight >= platform.y &&
        collisionY + chickenCollisionHeight <= platform.y + platformHeight;

    // Курица должна падать (velocityY > 0)
    bool isFalling = chickenVelocityY > 0;

    return horizontalOverlap && verticalOverlap && isFalling;
  }

  void _updatePlatforms() {
    bool platformsChanged = false;

    // Обновляем двигающиеся платформы
    for (int i = 0; i < platforms.length; i++) {
      final platform = platforms[i];
      if (platform.type == BlockType.moving) {
        double newX =
            platform.x + (platform.moveDirection * platform.moveSpeed);

        // Проверяем границы
        if (newX < wallOffset) {
          newX = wallOffset;
          platforms[i] = PlatformData(
            id: platform.id,
            x: newX,
            y: platform.y,
            type: platform.type,
            moveDirection: 1.0, // Меняем направление
            moveSpeed: platform.moveSpeed,
          );
          platformsChanged = true;
        } else if (newX > screenWidth - wallOffset - platformWidth) {
          newX = screenWidth - wallOffset - platformWidth;
          platforms[i] = PlatformData(
            id: platform.id,
            x: newX,
            y: platform.y,
            type: platform.type,
            moveDirection: -1.0, // Меняем направление
            moveSpeed: platform.moveSpeed,
          );
          platformsChanged = true;
        } else {
          platforms[i] = PlatformData(
            id: platform.id,
            x: newX,
            y: platform.y,
            type: platform.type,
            moveDirection: platform.moveDirection,
            moveSpeed: platform.moveSpeed,
          );
          platformsChanged = true;
        }
      }
    }

    // Обновляем трескающиеся платформы
    final platformsToRemove = <String>[];
    crackingPlatforms.forEach((platformId, timeLeft) {
      if (timeLeft <= 0) {
        // Платформа исчезает
        platformsToRemove.add(platformId);
        print('Platform destroyed: $platformId');
        platformsChanged = true;
      } else {
        crackingPlatforms[platformId] = timeLeft - 1;
      }
    });

    // Удаляем исчезнувшие платформы (только трескающиеся)
    if (platformsToRemove.isNotEmpty) {
      for (final platformId in platformsToRemove) {
        platforms.removeWhere(
          (platform) =>
              platform.id == platformId && platform.type == BlockType.cracking,
        );
        crackingPlatforms.remove(platformId);
      }
    }

    if (platformsChanged) {
      _cacheNeedsUpdate = true;
    }
  }

  void _updateObstacles() {
    bool obstaclesChanged = false;

    // Обновляем препятствия
    for (int i = 0; i < obstacles.length; i++) {
      final obstacle = obstacles[i];

      if (obstacle.type == ObstacleType.fallingRock && obstacle.isActive) {
        // Обновляем позицию падающего камня
        final newY = obstacle.y + obstacle.velocityY;
        obstacles[i] = obstacle.copyWith(y: newY);
        obstaclesChanged = true;
      } else if (obstacle.type == ObstacleType.spearTrap) {
        // Обновляем ловушку с копьем
        if (!obstacle.isActive && obstacle.activationTimer > 0) {
          // Отсчитываем время до активации
          obstacles[i] = obstacle.copyWith(
            activationTimer: obstacle.activationTimer - 1,
          );
          obstaclesChanged = true;
        } else if (!obstacle.isActive && obstacle.activationTimer <= 0) {
          // Активируем копье
          obstacles[i] = obstacle.copyWith(isActive: true);
          obstaclesChanged = true;
        } else if (obstacle.isActive) {
          // Двигаем активное копье
          final newX = obstacle.x + obstacle.velocityX;
          obstacles[i] = obstacle.copyWith(x: newX);
          obstaclesChanged = true;
        }
      } else if (obstacle.type == ObstacleType.pendulumSpear &&
          obstacle.isActive) {
        // Обновляем маятниковое копье
        final newX = obstacle.x + (obstacle.velocityX * obstacle.direction);

        // Проверяем, достигли ли границ диапазона
        if (newX <= obstacle.startX - pendulumRange ||
            newX >= obstacle.startX + pendulumRange) {
          // Меняем направление
          obstacles[i] = obstacle.copyWith(
            x: newX,
            direction: -obstacle.direction,
          );
        } else {
          obstacles[i] = obstacle.copyWith(x: newX);
        }
        obstaclesChanged = true;
      }
    }

    // Удаляем препятствия, которые ушли за экран
    final initialLength = obstacles.length;
    obstacles.removeWhere((obstacle) {
      if (obstacle.type == ObstacleType.fallingRock) {
        return obstacle.y > chickenY + screenHeight + 200;
      } else if (obstacle.type == ObstacleType.spearTrap) {
        // Копья исчезают только когда полностью ушли за экран
        return obstacle.x < -200 || obstacle.x > screenWidth + 200;
      } else if (obstacle.type == ObstacleType.pendulumSpear) {
        // Маятниковые копья исчезают только когда курица ушла далеко вверх
        return obstacle.y < chickenY - screenHeight - 200;
      }
      return false;
    });

    if (obstacles.length != initialLength) {
      obstaclesChanged = true;
    }

    if (obstaclesChanged) {
      _cacheNeedsUpdate = true;
    }
  }

  void _checkBonusCollisions() {
    for (int i = 0; i < bonuses.length; i++) {
      final bonus = bonuses[i];
      if (!bonus.isCollected) {
        // Проверяем коллизию с курицей
        if (_isChickenOnBonus(bonus)) {
          _collectBonus(bonus, i);
        }
      }
    }
  }

  bool _isChickenOnBonus(BonusData bonus) {
    return chickenX + chickenSize > bonus.x &&
        chickenX < bonus.x + 30 &&
        chickenY + chickenSize > bonus.y &&
        chickenY < bonus.y + 30;
  }

  void _collectBonus(BonusData bonus, int index) {
    bonuses[index] = BonusData(
      x: bonus.x,
      y: bonus.y,
      type: bonus.type,
      isCollected: true,
    );

    // Инвалидируем кэш при изменении бонусов
    _cacheNeedsUpdate = true;

    // Запускаем анимацию сбора для всех бонусов
    _bonusCollectX = bonus.x;
    _bonusCollectY = bonus.y;
    _collectingBonusType = bonus.type;
    _isBonusCollecting = true;

    print('Setting collecting bonus type to: ${bonus.type}');

    try {
      _bonusCollectController.reset();
      _bonusCollectController.forward().then((_) {
        _isBonusCollecting = false;
      });
    } catch (e) {
      _isBonusCollecting = false;
    }

    switch (bonus.type) {
      case BonusType.goldenEgg:
        score += 50;
        break;
      case BonusType.shield:
        hasShield = true;
        _shieldAppearController.forward().then((_) {
          // После завершения анимации появления запускаем пульсацию
          _shieldAnimationController.repeat(reverse: true);
        });
        break;
      case BonusType.life:
        lives++;
        break;
    }
    
    // Уведомляем об изменении данных сразу после сбора бонуса
    widget.onGameDataChanged?.call();
  }



  void _checkObstacleCollisions() {
    for (int i = 0; i < obstacles.length; i++) {
      final obstacle = obstacles[i];
      if (!obstacle.isActive) continue;

      // Проверяем коллизию с курицей
      if (_isChickenHitByObstacle(obstacle)) {
        _handleObstacleHit(obstacle, i);
      }
    }
  }

  bool _isChickenHitByObstacle(ObstacleData obstacle) {
    // Центрируем хитбокс коллизий относительно курицы
    double collisionX = chickenX + (chickenSize - chickenCollisionWidth) / 2;
    double collisionY = chickenY + (chickenSize - chickenCollisionHeight) / 2;

    // Проверяем коллизию с падающим камнем
    if (obstacle.type == ObstacleType.fallingRock) {
      return collisionX + chickenCollisionWidth > obstacle.x &&
          collisionX < obstacle.x + fallingRockSize &&
          collisionY + chickenCollisionHeight > obstacle.y &&
          collisionY < obstacle.y + fallingRockSize;
    }

    // Проверяем коллизию с копьем
    if ((obstacle.type == ObstacleType.spearTrap ||
            obstacle.type == ObstacleType.pendulumSpear) &&
        obstacle.isActive) {
      return collisionX + chickenCollisionWidth > obstacle.x &&
          collisionX < obstacle.x + spearWidth &&
          collisionY + chickenCollisionHeight > obstacle.y &&
          collisionY < obstacle.y + spearHeight;
    }

    return false;
  }

  void _handleObstacleHit(ObstacleData obstacle, int index) {
    if (hasShield) {
      // Щит защищает от одного удара
      hasShield = false;
      _shieldAnimationController.stop(); // Останавливаем пульсацию
      _shieldAppearController.reset(); // Сбрасываем анимацию появления
      // Деактивируем препятствие
      obstacles[index] = obstacle.copyWith(isActive: false);
      
      // Уведомляем об изменении данных при потере щита
      widget.onGameDataChanged?.call();
    } else {
      // Теряем жизнь
      lives--;
      if (lives <= 0) {
        _gameOver();
      } else {
        // Деактивируем препятствие после попадания
        obstacles[index] = obstacle.copyWith(isActive: false);
      }
      
      // Уведомляем об изменении данных при потере жизни
      widget.onGameDataChanged?.call();
    }
  }

  void _checkFall() {
    // Game Over когда курица падает слишком далеко вниз
    if (chickenY > cameraY + screenHeight + 100) {
      _gameOver();
    }
  }

  void _gameOver() async {
    // Останавливаем игру
    _animationController.stop();
    setState(() {
      isGameOver = true;
      isSavingScore = true;
      scoreSaved = false;
      saveError = null;
    });
    
    print('Game Over! Final score: $score');
    
    // Сохраняем счет в Firebase
    if (score > 0) {
      try {
        print('Attempting to save score to Firebase...');
        final leaderboardService = LeaderboardService();
        final user = await leaderboardService.getCurrentUser();
        print('Current user: ${user?.nickname}');
        
        if (user?.nickname != null) {
          print('Updating player score: ${user!.nickname} -> $score');
          final success = await leaderboardService.updatePlayerScore(user.nickname, score);
          print('Score update result: $success');
          
          setState(() {
            isSavingScore = false;
            scoreSaved = success;
            if (!success) {
              saveError = 'Failed to save score';
            }
          });
          
          // Уведомляем о сохранении счета
          if (success) {
            widget.onScoreSaved?.call();
          }
        } else {
          print('No user nickname found, cannot save score');
          setState(() {
            isSavingScore = false;
            saveError = 'No user nickname found';
          });
        }
      } catch (e) {
        print('Error saving score to Firebase: $e');
        setState(() {
          isSavingScore = false;
          saveError = 'Error: $e';
        });
      }
    } else {
      print('Score is 0, not saving to Firebase');
      setState(() {
        isSavingScore = false;
        scoreSaved = true; // Считаем успешным, если счет 0
      });
    }
  }

  void restartGame() {
    setState(() {
      isGameOver = false;
      isPaused = false;
      score = 0;
      lives = 3;
      hasShield = false;
      currentLevel = 0.0;
      cameraY = 0.0;
      isSavingScore = false;
      scoreSaved = false;
      saveError = null;
      crackingPlatforms.clear();
      platforms.clear();
      bonuses.clear();
      obstacles.clear();
      // Очищаем кэш
      _visiblePlatforms.clear();
      _visibleBonuses.clear();
      _visibleObstacles.clear();
      _cacheNeedsUpdate = true;
    });

    // Уведомляем GameScreen об изменении состояния паузы
    widget.onPauseStateChanged?.call(false);

    // Перегенерируем платформы
    _generateInitialPlatforms();

    // Запускаем анимацию заново
    _animationController.repeat();
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });

    // Уведомляем GameScreen об изменении состояния паузы
    widget.onPauseStateChanged?.call(isPaused);

    if (isPaused) {
      _animationController.stop();
    } else {
      _animationController.repeat();
    }
  }

  void _generateNewPlatforms() {
    bool objectsRemoved = false;

    // Удаляем платформы, бонусы и препятствия, которые ушли за экран (вниз)
    final initialPlatformsLength = platforms.length;
    final initialBonusesLength = bonuses.length;
    final initialObstaclesLength = obstacles.length;

    platforms.removeWhere((platform) => platform.y > chickenY + 500);
    bonuses.removeWhere((bonus) => bonus.y > chickenY + 500);
    obstacles.removeWhere((obstacle) => obstacle.y > chickenY + 500);

    if (platforms.length != initialPlatformsLength ||
        bonuses.length != initialBonusesLength ||
        obstacles.length != initialObstaclesLength) {
      objectsRemoved = true;
    }

    // Бесконечно добавляем новые уровни ВЫШЕ курицы
    // Проверяем, есть ли достаточно платформ выше курицы
    var platformsAboveChicken = platforms
        .where((p) => p.y < chickenY - levelHeight * 2)
        .length;

    // Если платформ выше курицы меньше 3, генерируем одну новую
    if (platformsAboveChicken < 3) {
      final nextLevelIndex = platforms.length;
      _generateLevel(nextLevelIndex);
      objectsRemoved = true;
    }

    if (objectsRemoved) {
      _cacheNeedsUpdate = true;
    }
  }

  void jump() {
    if (chickenVelocityY == 0) {
      // Рассчитываем скорость для заданной высоты прыжка
      // h = jumpHeight, g = 0.8, v = sqrt(2 * 0.8 * jumpHeight)
      final gravity = 0.5;
      final jumpVelocity = -sqrt(2 * gravity * jumpHeight);
      chickenVelocityY = jumpVelocity;
    }
  }

  void moveLeft() {
    if (chickenX > wallOffset) {
      chickenX -=
          12.0; // Увеличиваем скорость движения для доступа к разбросанным платформам
      isFacingRight = false;
    }
  }

  void moveRight() {
    if (chickenX < screenWidth - wallOffset - chickenSize) {
      chickenX +=
          12.0; // Увеличиваем скорость движения для доступа к разбросанным платформам
      isFacingRight = true;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              width: wallOffset,
              height: screenHeight,
              color: Colors.brown.withOpacity(0.8),
            ),
          ),

          // Правая стенка
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: wallOffset,
              height: screenHeight,
              color: Colors.brown.withOpacity(0.8),
            ),
          ),

          // Игровые объекты (платформы, бонусы, препятствия) - используем кэшированные списки
          GameObjectsLayer(
            platforms: _visiblePlatforms,
            bonuses: _visibleBonuses,
            obstacles: _visibleObstacles,
            crackingPlatforms: crackingPlatforms,
            cameraY: cameraY,
          ),

          // Курица (с учетом камеры)
          ChickenWidget(
            state: chickenState,
            x: chickenX,
            y: chickenY - cameraY,
          ),

          // Эффекты (щит, анимация сбора бонусов)
          GameEffectsLayer(
            hasShield: hasShield,
            chickenX: chickenX,
            chickenY: chickenY,
            cameraY: cameraY,
            chickenSize: chickenSize,
            shieldAnimation: _shieldAnimation,
            shieldAppearAnimation: _shieldAppearAnimation,
            isBonusCollecting: _isBonusCollecting,
            bonusCollectX: _bonusCollectX,
            bonusCollectY: _bonusCollectY,
            bonusCollectAnimation: _bonusCollectAnimation,
            collectingBonusType: _collectingBonusType,
          ),

          // Хитбокс для отладки (можно убрать)
          DebugLayer(
            chickenX: chickenX,
            chickenY: chickenY,
            cameraY: cameraY,
            chickenSize: chickenSize,
            chickenCollisionWidth: chickenCollisionWidth,
            chickenCollisionHeight: chickenCollisionHeight,
          ),

          // Экран паузы
          if (isPaused && !isGameOver)
            PauseScreen(
              onResume: togglePause,
              onBackToMenu:
                  widget.onBackToMenu ??
                  () {
                    // Возвращаемся в главное меню
                    Navigator.of(context).pop();
                  },
            ),

          // Game Over экран
          if (isGameOver)
            GameOverScreen(
              finalScore: score,
              onRestart: restartGame,
              onBackToMenu:
                  widget.onBackToMenu ??
                  () {
                    // Возвращаемся в главное меню
                    Navigator.of(context).pop();
                  },
              isSavingScore: isSavingScore,
              scoreSaved: scoreSaved,
              saveError: saveError,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shieldAnimationController.dispose();
    _shieldAppearController.dispose();
    try {
      _bonusCollectController.dispose();
    } catch (e) {
      // Контроллер не был инициализирован
    }
    super.dispose();
  }
}




