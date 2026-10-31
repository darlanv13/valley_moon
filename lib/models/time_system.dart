import 'package:flutter/foundation.dart';

/// The ancient Lunar Cycle of Valley Moon including the rare Blood Moon event.
enum MoonPhase {
  newMoon('Lua Nova', '🌙', 'A noite é densa. Ervas mágicas sussurram nas sombras.'),
  waxingMoon('Lua Crescente', '🌓', 'A seiva sobe forte nas plantações.'),
  fullMoon('Lua Cheia', '🌕', 'Luz mística ilumina a floresta. Minérios e flores cintilam.'),
  waningMoon('Lua Minguante', '🌗', 'Tempo de colher sementes e descansar as terras.'),
  bloodMoon('Lua de Sangue', '🔴', 'Névoa rubra desperta a magia ancestral. Colheitas míticas florescem!');

  final String label;
  final String icon;
  final String lore;

  const MoonPhase(this.label, this.icon, this.lore);
}

/// The 4 rustic seasons of Valley Moon (28 days each).
enum Season {
  spring('Primavera', '🌸'),
  summer('Verão', '☀️'),
  autumn('Outono', '🍂'),
  winter('Inverno', '❄️');

  final String label;
  final String icon;

  const Season(this.label, this.icon);
}

/// Weather conditions.
enum WeatherType {
  sunny('Ensolarado', '☀️'),
  rain('Chuva Fértil', '🌧️'),
  fog('Cinza Silenciosa', '🌫️'),
  autumnLeaves('Vento Místico', '🍃');

  final String label;
  final String icon;

  const WeatherType(this.label, this.icon);
}

/// Crops including standard rustic crops and nocturnal lunar plants.
enum CropType {
  turnip(
    name: 'Nabo Rústico',
    icon: '🥕',
    growthDays: 4,
    isMagical: false,
    sellPrice: 35,
    spriteRow: 0,
  ),
  wheat(
    name: 'Trigo Comum',
    icon: '🌾',
    growthDays: 5,
    isMagical: false,
    sellPrice: 50,
    spriteRow: 1,
  ),
  screamRoot(
    name: 'Raiz-Gritante',
    icon: '🔮',
    growthDays: 5,
    isMagical: true,
    sellPrice: 160,
    spriteRow: 2,
  ),
  dewBlossom(
    name: 'Flor-de-Orvalho',
    icon: '💠',
    growthDays: 6,
    isMagical: true,
    sellPrice: 220,
    spriteRow: 3,
  ),
  goldenWheat(
    name: 'Trigo-Dourado',
    icon: '✨',
    growthDays: 7,
    isMagical: true,
    sellPrice: 350,
    spriteRow: 4,
  );

  final String name;
  final String icon;
  final int growthDays;
  final bool isMagical;
  final int sellPrice;
  final int spriteRow;

  const CropType({
    required this.name,
    required this.icon,
    required this.growthDays,
    required this.isMagical,
    required this.sellPrice,
    required this.spriteRow,
  });
}

/// Active hand tool, seed pouch or earth magic totem.
enum FarmerTool {
  hands('Mãos', '✋'),
  hoe('Enxada', '⛏️'),
  wateringCan('Regador', '💧'),
  sickle('Foice', '🌾'),
  axe('Machado', '🪓'),
  pickaxe('Picareta', '⚒️'),
  sword('Espada', '⚔️'),
  fishingRod('Vara de Pescar', '🎣'),
  brush('Escova de Carinho', '🧹'),
  seedsTurnip('Semente Nabo', '🌱'),
  seedsWheat('Semente Trigo', '🌰'),
  seedsScreamRoot('Semente Raiz-Gritante', '🔮'),
  seedsDewBlossom('Semente Flor-de-Orvalho', '💠'),
  seedsGoldenWheat('Semente Trigo-Dourado', '✨'),
  placeScarecrow('Espantalho Vivo', '🧙'),
  placeRainTotem('Totem de Chuva', '🗿');

  final String label;
  final String icon;

  const FarmerTool(this.label, this.icon);

  bool get isSeed =>
      this == seedsTurnip ||
      this == seedsWheat ||
      this == seedsScreamRoot ||
      this == seedsDewBlossom ||
      this == seedsGoldenWheat;

  CropType? get cropType {
    switch (this) {
      case seedsTurnip: return CropType.turnip;
      case seedsWheat: return CropType.wheat;
      case seedsScreamRoot: return CropType.screamRoot;
      case seedsDewBlossom: return CropType.dewBlossom;
      case seedsGoldenWheat: return CropType.goldenWheat;
      default: return null;
    }
  }
}

/// Core Game State: Time (12 min = 1 day), Seasons, Lunar Cycle, Player Stats.
class GameState extends ChangeNotifier {
  // Calendar & Clock
  int day = 1;
  Season season = Season.spring;
  int hour = 6;
  int minute = 0;
  double _fractionalMinute = 0.0;

  // Day length: 06:00 to 02:00 = 20 in-game hours = 1200 in-game minutes.
  // 12 real minutes = 720 real seconds.
  // Rate: 1200 / 720 = 1.6666... in-game minutes per real second.
  static const double inGameMinutesPerRealSecond = 1200.0 / 720.0;

  // Moon & Weather
  MoonPhase moonPhase = MoonPhase.waxingMoon;
  WeatherType weather = WeatherType.sunny;

  // Player Stats
  double energy = 100.0;
  final double maxEnergy = 100.0;
  double health = 100.0;
  final double maxHealth = 100.0;

  // Inventory & Economy
  FarmerTool selectedTool = FarmerTool.hoe;
  int coins = 300;
  final Map<String, int> inventory = {
    'Madeira': 12,
    'Pedra': 8,
    'Nabo': 0,
    'Raiz-Gritante': 0,
    'Flor-de-Orvalho': 0,
    'Trigo-Dourado': 0,
  };

  // Callback hooks for day-night transitions
  VoidCallback? onNewDayStarted;
  VoidCallback? onPlayerFainted;

  bool get isNight => hour >= 19 || hour < 5;

  void updateTime(double dt) {
    _fractionalMinute += dt * inGameMinutesPerRealSecond;

    if (_fractionalMinute >= 1.0) {
      final addedMinutes = _fractionalMinute.toInt();
      _fractionalMinute -= addedMinutes;
      minute += addedMinutes;

      if (minute >= 60) {
        hour += minute ~/ 60;
        minute %= 60;

        // Exhaustion check at 02:00 AM
        if (hour == 2) {
          hour = 6;
          minute = 0;
          onPlayerFainted?.call();
          advanceDay(exhausted: true);
          return;
        }
      }
      notifyListeners();
    }
  }

  void advanceDay({bool exhausted = false}) {
    day += 1;

    // Check season transition (28 days per season)
    if (day > 28) {
      day = 1;
      final nextSeasonIdx = (season.index + 1) % Season.values.length;
      season = Season.values[nextSeasonIdx];
    }

    // Determine Moon Phase
    // Every 14 days, check for Blood Moon event
    if (day % 14 == 0) {
      moonPhase = MoonPhase.bloodMoon;
    } else {
      final phaseIndex = ((day - 1) ~/ 7) % 4;
      moonPhase = MoonPhase.values[phaseIndex];
    }

    // Determine Weather
    if (moonPhase == MoonPhase.bloodMoon) {
      weather = WeatherType.fog; // The eerie Silent Ash Fog
    } else if (day % 5 == 0) {
      weather = WeatherType.rain;
    } else if (season == Season.autumn && day % 3 == 0) {
      weather = WeatherType.autumnLeaves;
    } else {
      weather = WeatherType.sunny;
    }

    // Replenish Energy (half if exhausted)
    energy = exhausted ? maxEnergy * 0.5 : maxEnergy;

    onNewDayStarted?.call();
    notifyListeners();
  }

  void useEnergy(double amount) {
    energy = (energy - amount).clamp(0.0, maxEnergy);
    notifyListeners();
  }

  void restoreEnergy(double amount) {
    energy = (energy + amount).clamp(0.0, maxEnergy);
    notifyListeners();
  }

  void heal(double amount) {
    health = (health + amount).clamp(0.0, maxHealth);
    notifyListeners();
  }

  void damagePlayer(double amount) {
    health = (health - amount).clamp(0.0, maxHealth);
    if (health <= 0) {
      onPlayerFainted?.call();
      advanceDay(exhausted: true);
    }
    notifyListeners();
  }

  void addCoins(int amount) {
    coins += amount;
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (coins < amount) return false;
    coins -= amount;
    notifyListeners();
    return true;
  }

  void addItem(String item, int count) {
    inventory[item] = (inventory[item] ?? 0) + count;
    notifyListeners();
  }

  void selectTool(FarmerTool tool) {
    selectedTool = tool;
    notifyListeners();
  }
}
