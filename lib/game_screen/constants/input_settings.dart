/// Настройки управления игрой
class InputSettings {
  // Настройки для жестов
  static const double panThreshold = 2.0; // Порог для срабатывания движения (очень чувствительно)
  static const int panCooldownMs = 10; // Минимальное время между движениями (очень отзывчиво)
  
  // Настройки для прыжков
  static const double jumpVelocityThreshold = 5.0; // Максимальная скорость для прыжка (строго 0 - только на платформе)
  
  // Настройки движения
  static const double moveStep = 6.0; // Шаг движения курицы (базовый шаг)
  
  // Скорость на земле (нормальная ходьба)
  static const double moveSpeedGround = 6.0; // Постоянная скорость при ходьбе (уменьшена)
  static const double moveDecelerationGround = 0.4; // Замедление при остановке (увеличено)
  
  // Скорость в воздухе (в прыжке)
  static const double moveSpeedAir = 8; // Постоянная скорость в прыжке (уменьшена)
  static const double moveDecelerationAir = 0.2; // Замедление в прыжке (увеличено)
  
  // Настройки для отладки
  static const bool enableDebugLogs = true; // Включить отладочные логи
}
