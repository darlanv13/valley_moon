import 'dart:math';
import '../components/map_transition.dart';
import 'inventory_system.dart';
import 'time_system.dart';

enum FishBehavior {
  smooth,
  dart,
  sinker,
  floater,
}

class FishData {
  final String id;
  final String name;
  final String icon;
  final GameItem gameItem;
  final double difficulty; // 0.2 (easy) to 1.0 (legendary)
  final FishBehavior behavior;
  final List<GameLocation> allowedLocations;
  final List<WeatherType>? requiredWeather;
  final List<MoonPhase>? requiredMoonPhase;
  final bool nightOnly;
  final bool dayOnly;
  final bool requiresMoonBait;
  final int minSizeCm;
  final int maxSizeCm;
  final bool isLegendary;

  const FishData({
    required this.id,
    required this.name,
    required this.icon,
    required this.gameItem,
    required this.difficulty,
    required this.behavior,
    required this.allowedLocations,
    this.requiredWeather,
    this.requiredMoonPhase,
    this.nightOnly = false,
    this.dayOnly = false,
    this.requiresMoonBait = false,
    required this.minSizeCm,
    required this.maxSizeCm,
    this.isLegendary = false,
  });

  int generateRandomSize(Random rng) {
    return minSizeCm + rng.nextInt(maxSizeCm - minSizeCm + 1);
  }

  // Pre-configured Fish Database
  static const List<FishData> allFishes = [
    // 1. Truta do Riacho
    FishData(
      id: 'fish_brook_trout',
      name: 'Truta do Riacho',
      icon: '🐟',
      gameItem: GameItem.brookTrout,
      difficulty: 0.35,
      behavior: FishBehavior.smooth,
      allowedLocations: [GameLocation.farm, GameLocation.forest],
      minSizeCm: 25,
      maxSizeCm: 50,
    ),

    // 2. Tilápia da Lagoa
    FishData(
      id: 'fish_pond_tilapia',
      name: 'Tilápia da Lagoa',
      icon: '🐠',
      gameItem: GameItem.pondTilapia,
      difficulty: 0.40,
      behavior: FishBehavior.smooth,
      allowedLocations: [GameLocation.farm, GameLocation.forest],
      dayOnly: true,
      minSizeCm: 20,
      maxSizeCm: 45,
    ),

    // 3. Bagre do Píer
    FishData(
      id: 'fish_pier_catfish',
      name: 'Bagre do Píer',
      icon: '🐡',
      gameItem: GameItem.pierCatfish,
      difficulty: 0.50,
      behavior: FishBehavior.sinker,
      allowedLocations: [GameLocation.village],
      minSizeCm: 40,
      maxSizeCm: 80,
    ),

    // 4. Enguia Noturna
    FishData(
      id: 'fish_night_eel',
      name: 'Enguia Noturna',
      icon: '🐍',
      gameItem: GameItem.nightEel,
      difficulty: 0.65,
      behavior: FishBehavior.dart,
      allowedLocations: [GameLocation.farm, GameLocation.forest, GameLocation.village],
      nightOnly: true,
      minSizeCm: 50,
      maxSizeCm: 110,
    ),

    // 5. [LENDÁRIO] Bagre-Fantasma
    FishData(
      id: 'fish_phantom_catfish',
      name: 'Bagre-Fantasma',
      icon: '👻🐟',
      gameItem: GameItem.phantomCatfish,
      difficulty: 0.88,
      behavior: FishBehavior.sinker,
      allowedLocations: [GameLocation.mineEntrance],
      nightOnly: true,
      requiresMoonBait: true,
      minSizeCm: 90,
      maxSizeCm: 160,
      isLegendary: true,
    ),

    // 6. [LENDÁRIO] Carpa Astral
    FishData(
      id: 'fish_astral_carp',
      name: 'Carpa Astral',
      icon: '⭐🐟',
      gameItem: GameItem.astralCarp,
      difficulty: 0.92,
      behavior: FishBehavior.dart,
      allowedLocations: [GameLocation.forest],
      requiredMoonPhase: [MoonPhase.fullMoon, MoonPhase.bloodMoon],
      nightOnly: true,
      requiresMoonBait: true,
      minSizeCm: 70,
      maxSizeCm: 130,
      isLegendary: true,
    ),

    // 7. [LENDÁRIO] Salmão do Luar
    FishData(
      id: 'fish_moonlight_salmon',
      name: 'Salmão do Luar',
      icon: '🌙🐟',
      gameItem: GameItem.moonlightSalmon,
      difficulty: 0.85,
      behavior: FishBehavior.smooth,
      allowedLocations: [GameLocation.farm],
      nightOnly: true,
      minSizeCm: 60,
      maxSizeCm: 120,
      isLegendary: true,
    ),

    // 8. [LENDÁRIO] Peixe-Sol Dourado
    FishData(
      id: 'fish_golden_sunfish',
      name: 'Peixe-Sol Dourado',
      icon: '☀️🐟',
      gameItem: GameItem.goldenSunfish,
      difficulty: 0.90,
      behavior: FishBehavior.floater,
      allowedLocations: [GameLocation.village],
      requiredWeather: [WeatherType.sunny],
      dayOnly: true,
      minSizeCm: 80,
      maxSizeCm: 150,
      isLegendary: true,
    ),
  ];

  /// Roll an eligible fish based on location, environment and bait.
  static FishData rollFish({
    required GameLocation location,
    required GameState state,
    required bool hasMoonBait,
    Random? rng,
  }) {
    final rand = rng ?? Random();
    final eligible = allFishes.where((fish) {
      // 1. Location match
      if (!fish.allowedLocations.contains(location)) return false;

      // 2. Time match
      if (fish.nightOnly && !state.isNight) return false;
      if (fish.dayOnly && state.isNight) return false;

      // 3. Weather match
      if (fish.requiredWeather != null && !fish.requiredWeather!.contains(state.weather)) {
        return false;
      }

      // 4. Moon Phase match
      if (fish.requiredMoonPhase != null && !fish.requiredMoonPhase!.contains(state.moonPhase)) {
        return false;
      }

      // 5. Moon Bait requirement
      if (fish.requiresMoonBait && !hasMoonBait) {
        return false;
      }

      return true;
    }).toList();

    if (eligible.isEmpty) {
      // Fallback to standard Brook Trout
      return allFishes[0];
    }

    // Weight legendary fishes lower (10% chance if eligible)
    final legendaries = eligible.where((f) => f.isLegendary).toList();
    if (legendaries.isNotEmpty && rand.nextDouble() < 0.35) {
      return legendaries[rand.nextInt(legendaries.length)];
    }

    final commons = eligible.where((f) => !f.isLegendary).toList();
    if (commons.isNotEmpty) {
      return commons[rand.nextInt(commons.length)];
    }

    return eligible[rand.nextInt(eligible.length)];
  }
}
