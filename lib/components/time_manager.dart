import 'package:flame/components.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/time_system.dart';

/// Manages game clock progression, Day/Night cycles, and weather ambient audio.
class TimeManagerComponent extends Component
    with HasGameReference<ValleyMoonGame> {
  WeatherType? _previousWeather;
  bool _wasNight = false;

  @override
  void update(double dt) {
    super.update(dt);
    game.gameState.updateTime(dt);

    final isNight = game.gameState.isNight;
    final weather = game.gameState.weather;

    // Check audio changes on weather/day-night transitions
    if (weather != _previousWeather || isNight != _wasNight) {
      _previousWeather = weather;
      _wasNight = isNight;
      _updateAmbientAudio(weather, isNight);
    }
  }

  void _updateAmbientAudio(WeatherType weather, bool isNight) {
    if (!game.audioEnabled) return;

    if (weather == WeatherType.rain) {
      game.playBGM(GameConstants.bgmRain);
    } else if (isNight) {
      game.playBGM(GameConstants.bgmForest);
    } else {
      game.playBGM(GameConstants.bgmVillage);
    }
  }
}
