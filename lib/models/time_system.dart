import 'package:flutter/foundation.dart';

/// The ancient 4-phase Lunar Cycle of Valley Moon.
enum MoonPhase {
  newMoon('Lua Nova', '🌙', 'A noite é densa. Ervas mágicas sussurram nas sombras.'),
  waxingMoon('Lua Crescente', '🌓', 'A seiva sobe forte nas plantações.'),
  fullMoon('Lua Cheia', '🌕', 'Luz mística ilumina a floresta. Minérios cintilam.'),
  waningMoon('Lua Minguante', '🌗', 'Tempo de colher sementes e descansar as terras.');

  final String label;
  final String icon;
  final String lore;

  const MoonPhase(this.label, this.icon, this.lore);
}

/// Selected active tool for the farmer.
enum FarmerTool {
  hands('Mãos', '✋'),
  hoe('Enxada', '⛏️'),
  wateringCan('Regador', '💧'),
  axe('Machado', '🪓');

  final String label;
  final String icon;

  const FarmerTool(this.label, this.icon);
}

/// In-game time, calendar, energy and health state.
class GameState extends ChangeNotifier {
  // Time and Season
  int day = 1;
  String season = 'Primavera';
  int hour = 6;
  int minute = 0;
  double _secondCounter = 0.0;

  // Lunar Cycle
  MoonPhase moonPhase = MoonPhase.waxingMoon;

  // Player Stats
  double energy = 100.0;
  final double maxEnergy = 100.0;
  double health = 100.0;
  final double maxHealth = 100.0;

  // Inventory & Selected Tool
  FarmerTool selectedTool = FarmerTool.hoe;
  int coins = 250;

  void updateTime(double dt) {
    _secondCounter += dt;
    // Every real second is 1 in-game minute
    if (_secondCounter >= 1.0) {
      _secondCounter -= 1.0;
      minute += 10;
      if (minute >= 60) {
        minute = 0;
        hour += 1;
        if (hour >= 24) {
          hour = 0;
          advanceDay();
        }
      }
      notifyListeners();
    }
  }

  void advanceDay() {
    day += 1;
    // Rotate moon phase every 7 in-game days
    final phaseIndex = ((day - 1) ~/ 7) % MoonPhase.values.length;
    moonPhase = MoonPhase.values[phaseIndex];
    // Replenish energy
    energy = maxEnergy;
    notifyListeners();
  }

  void useEnergy(double amount) {
    energy = (energy - amount).clamp(0.0, maxEnergy);
    notifyListeners();
  }

  void selectTool(FarmerTool tool) {
    selectedTool = tool;
    notifyListeners();
  }
}
