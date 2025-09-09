import 'package:chiken_odyssey/game_screen/models/bonus_data.dart';
import 'package:chiken_odyssey/game_screen/models/obstacle_data.dart';
import 'package:chiken_odyssey/game_screen/models/platform_data.dart';
import 'package:equatable/equatable.dart';
import 'package:chiken_odyssey/game_screen/widgets/chicken_widget.dart';

// Базовый класс для всех состояний игры
abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

// Начальное состояние
class GameInitial extends GameState {
  const GameInitial();
}

// Состояние загрузки
class GameLoading extends GameState {
  const GameLoading();
}

// Основное игровое состояние
class GameRunning extends GameState {
  // Игровые данные
  final int score;
  final int lives;
  final bool hasShield;
  final bool isPaused;
  final bool isGameOver;
  
  // Состояние сохранения счета
  final bool isSavingScore;
  final bool scoreSaved;
  final String? saveError;
  
  // Позиция курицы
  final double chickenX;
  final double chickenY;
  final double chickenVelocityY;
  final double chickenVelocityX; // Горизонтальная скорость для плавного движения
  final ChickenState chickenState;
  final bool isFacingRight;
  
  // Камера
  final double cameraY;
  final double currentLevel;
  
  // Размеры экрана
  final double screenWidth;
  final double screenHeight;
  
  // Игровые объекты
  final List<PlatformData> platforms;
  final List<BonusData> bonuses;
  final List<ObstacleData> obstacles;
  final Map<String, int> crackingPlatforms;
  
  // Кэшированные видимые объекты
  final List<PlatformData> visiblePlatforms;
  final List<BonusData> visibleBonuses;
  final List<ObstacleData> visibleObstacles;
  
  // Анимации
  final bool isBonusCollecting;
  final double bonusCollectX;
  final double bonusCollectY;
  final BonusType collectingBonusType;
  final double shieldAnimationValue;
  final double shieldAppearAnimationValue;

  const GameRunning({
    required this.score,
    required this.lives,
    required this.hasShield,
    required this.isPaused,
    required this.isGameOver,
    required this.isSavingScore,
    required this.scoreSaved,
    this.saveError,
    required this.chickenX,
    required this.chickenY,
    required this.chickenVelocityY,
    required this.chickenVelocityX,
    required this.chickenState,
    required this.isFacingRight,
    required this.cameraY,
    required this.currentLevel,
    required this.screenWidth,
    required this.screenHeight,
    required this.platforms,
    required this.bonuses,
    required this.obstacles,
    required this.crackingPlatforms,
    required this.visiblePlatforms,
    required this.visibleBonuses,
    required this.visibleObstacles,
    required this.isBonusCollecting,
    required this.bonusCollectX,
    required this.bonusCollectY,
    required this.collectingBonusType,
    required this.shieldAnimationValue,
    required this.shieldAppearAnimationValue,
  });

  GameRunning copyWith({
    int? score,
    int? lives,
    bool? hasShield,
    bool? isPaused,
    bool? isGameOver,
    bool? isSavingScore,
    bool? scoreSaved,
    String? saveError,
    double? chickenX,
    double? chickenY,
    double? chickenVelocityY,
    double? chickenVelocityX,
    ChickenState? chickenState,
    bool? isFacingRight,
    double? cameraY,
    double? currentLevel,
    double? screenWidth,
    double? screenHeight,
    List<PlatformData>? platforms,
    List<BonusData>? bonuses,
    List<ObstacleData>? obstacles,
    Map<String, int>? crackingPlatforms,
    List<PlatformData>? visiblePlatforms,
    List<BonusData>? visibleBonuses,
    List<ObstacleData>? visibleObstacles,
    bool? isBonusCollecting,
    double? bonusCollectX,
    double? bonusCollectY,
    BonusType? collectingBonusType,
    double? shieldAnimationValue,
    double? shieldAppearAnimationValue,
  }) {
    return GameRunning(
      score: score ?? this.score,
      lives: lives ?? this.lives,
      hasShield: hasShield ?? this.hasShield,
      isPaused: isPaused ?? this.isPaused,
      isGameOver: isGameOver ?? this.isGameOver,
      isSavingScore: isSavingScore ?? this.isSavingScore,
      scoreSaved: scoreSaved ?? this.scoreSaved,
      saveError: saveError ?? this.saveError,
      chickenX: chickenX ?? this.chickenX,
      chickenY: chickenY ?? this.chickenY,
      chickenVelocityY: chickenVelocityY ?? this.chickenVelocityY,
      chickenVelocityX: chickenVelocityX ?? this.chickenVelocityX,
      chickenState: chickenState ?? this.chickenState,
      isFacingRight: isFacingRight ?? this.isFacingRight,
      cameraY: cameraY ?? this.cameraY,
      currentLevel: currentLevel ?? this.currentLevel,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      platforms: platforms ?? this.platforms,
      bonuses: bonuses ?? this.bonuses,
      obstacles: obstacles ?? this.obstacles,
      crackingPlatforms: crackingPlatforms ?? this.crackingPlatforms,
      visiblePlatforms: visiblePlatforms ?? this.visiblePlatforms,
      visibleBonuses: visibleBonuses ?? this.visibleBonuses,
      visibleObstacles: visibleObstacles ?? this.visibleObstacles,
      isBonusCollecting: isBonusCollecting ?? this.isBonusCollecting,
      bonusCollectX: bonusCollectX ?? this.bonusCollectX,
      bonusCollectY: bonusCollectY ?? this.bonusCollectY,
      collectingBonusType: collectingBonusType ?? this.collectingBonusType,
      shieldAnimationValue: shieldAnimationValue ?? this.shieldAnimationValue,
      shieldAppearAnimationValue: shieldAppearAnimationValue ?? this.shieldAppearAnimationValue,
    );
  }

  @override
  List<Object?> get props => [
    score,
    lives,
    hasShield,
    isPaused,
    isGameOver,
    isSavingScore,
    scoreSaved,
    saveError,
    chickenX,
    chickenY,
    chickenVelocityY,
    chickenVelocityX,
    chickenState,
    isFacingRight,
    cameraY,
    currentLevel,
    screenWidth,
    screenHeight,
    platforms,
    bonuses,
    obstacles,
    crackingPlatforms,
    visiblePlatforms,
    visibleBonuses,
    visibleObstacles,
    isBonusCollecting,
    bonusCollectX,
    bonusCollectY,
    collectingBonusType,
    shieldAnimationValue,
    shieldAppearAnimationValue,
  ];
}
