import 'package:flutter/foundation.dart';
import 'inventory_system.dart';
import 'time_system.dart';

enum BossBattlePhase {
  phase1Armor('Fase 1: Carapaça Corrompida', '🛡️'),
  phase2Purification('Fase 2: Purificação da Terra', '🌱✨'),
  victory('Vitória: O Despertar do Luar', '🌟');

  final String displayName;
  final String icon;
  const BossBattlePhase(this.displayName, this.icon);
}

/// System managing the climax boss fight on Floor 100.
class Act3BossState extends ChangeNotifier {
  BossBattlePhase phase = BossBattlePhase.phase1Armor;

  // Phase 1: Armor destruction
  final double maxArmor = 500.0;
  double currentArmor = 500.0;

  // Phase 2: Farming under pressure
  bool isSoilTilled = false;
  bool isSeedPlanted = false;
  int waterCycles = 0; // Requires 3 cycles
  static const int requiredWaterCycles = 3;

  // Ending Cutscene & Unlocks
  bool grandfatherFreed = false;
  bool act3Completed = false;
  bool endlessMinesUnlocked = false;

  double get armorPercentage => (currentArmor / maxArmor).clamp(0.0, 1.0);
  double get purificationProgress => (waterCycles / requiredWaterCycles).clamp(0.0, 1.0);

  /// Phase 1: Damage the Boss's stony carapace
  bool applyWeaponDamage(double damage) {
    if (phase != BossBattlePhase.phase1Armor) {
      // Phase 2 is immune to physical damage!
      return false;
    }

    currentArmor = (currentArmor - damage).clamp(0.0, maxArmor);
    if (currentArmor <= 0) {
      // Armor broken! Transition to Phase 2
      phase = BossBattlePhase.phase2Purification;
    }
    notifyListeners();
    return true;
  }

  /// Phase 2 Action 1: Till the sacred arena soil
  bool tillSacredSoil(GameState gameState) {
    if (phase != BossBattlePhase.phase2Purification || isSoilTilled) {
      return false;
    }
    isSoilTilled = true;
    gameState.useEnergy(8);
    notifyListeners();
    return true;
  }

  /// Phase 2 Action 2: Plant the Lunar Light Seed
  bool plantLunarSeed(InventoryState inventory, GameState gameState) {
    if (phase != BossBattlePhase.phase2Purification || !isSoilTilled || isSeedPlanted) {
      return false;
    }
    isSeedPlanted = true;
    gameState.useEnergy(5);
    notifyListeners();
    return true;
  }

  /// Phase 2 Action 3: Water the Lunar Tree of Light (1 of 3 cycles)
  bool waterLunarTree(GameState gameState) {
    if (phase != BossBattlePhase.phase2Purification || !isSeedPlanted || waterCycles >= requiredWaterCycles) {
      return false;
    }

    waterCycles++;
    gameState.useEnergy(12);

    if (waterCycles >= requiredWaterCycles) {
      // 3 cycles complete! Tree of Light purifies the guardian and shatters amber!
      completeAct3();
    } else {
      notifyListeners();
    }
    return true;
  }

  void completeAct3() {
    phase = BossBattlePhase.victory;
    grandfatherFreed = true;
    act3Completed = true;
    endlessMinesUnlocked = true;
    notifyListeners();
  }

  void resetBattle() {
    phase = BossBattlePhase.phase1Armor;
    currentArmor = maxArmor;
    isSoilTilled = false;
    isSeedPlanted = false;
    waterCycles = 0;
    grandfatherFreed = false;
    notifyListeners();
  }
}
