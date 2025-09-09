import 'package:equatable/equatable.dart';

// Базовый класс для всех игровых событий
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

// События управления игрой
class GameStarted extends GameEvent {
  const GameStarted();
}

class GamePaused extends GameEvent {
  const GamePaused();
}

class GameResumed extends GameEvent {
  const GameResumed();
}

class GameRestarted extends GameEvent {
  const GameRestarted();
}

class GameReset extends GameEvent {
  const GameReset();
}

class GameOver extends GameEvent {
  const GameOver();
}

class ScoreSaved extends GameEvent {
  const ScoreSaved();
}

// События управления курицей
class ChickenJumped extends GameEvent {
  const ChickenJumped();
}

class ChickenMovedLeft extends GameEvent {
  const ChickenMovedLeft();
}

class ChickenMovedRight extends GameEvent {
  const ChickenMovedRight();
}

// События обновления игры (вызывается каждый кадр)
class GameUpdated extends GameEvent {
  const GameUpdated();
}

// События анимации
class BonusCollectAnimationFinished extends GameEvent {
  const BonusCollectAnimationFinished();
}

// События инициализации
class GameInitialized extends GameEvent {
  final double screenWidth;
  final double screenHeight;

  const GameInitialized({
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  List<Object?> get props => [screenWidth, screenHeight];
}
