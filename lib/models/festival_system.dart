import 'dart:math';
import 'package:flutter/foundation.dart';
import 'animal_system.dart';
import 'inventory_system.dart';
import 'time_system.dart';

/// The 4 seasonal festivals of Valley Moon.
enum FestivalType {
  firstSeed(
    id: 'festival_first_seed',
    name: 'Festival da Primeira Semente',
    icon: '🌱🐷',
    season: Season.spring,
    day: 13,
    description: 'Celebração do plantio de primavera na praça da vila. Conta com a tradicional Corrida de Porcos e mercadores de sementes estelares.',
  ),
  fireBoats(
    id: 'festival_fire_boats',
    name: 'Noite dos Barcos de Fogo',
    icon: '🏮🛶',
    season: Season.summer,
    day: 28,
    description: 'Na última noite de verão, barcos iluminados com lamparinas de papel flutuam no lago. Peixes luminescentes sobem à superfície atraídos pela luz.',
  ),
  hiddenHarvest(
    id: 'festival_hidden_harvest',
    name: 'Banquete da Colheita Oculta',
    icon: '🍲🎃',
    season: Season.autumn,
    day: 16,
    description: 'O grande caldeirão comunitário da vila é aceso. O ingrediente ofertado pelo fazendeiro concede uma bênção mágica para toda a estação.',
  ),
  forgeTournament(
    id: 'festival_forge_tournament',
    name: 'Torneio da Forja e da Espada',
    icon: '⚔️🛡️',
    season: Season.winter,
    day: 20,
    description: 'Grande arena de combate rústico organizada por Kael na praça da vila coberta de neve para testar lâminas forjadas e a bravura dos moradores.',
  );

  final String id;
  final String name;
  final String icon;
  final Season season;
  final int day;
  final String description;

  const FestivalType({
    required this.id,
    required this.name,
    required this.icon,
    required this.season,
    required this.day,
    required this.description,
  });

  static FestivalType? forDate(Season season, int day) {
    for (final f in values) {
      if (f.season == season && f.day == day) return f;
    }
    return null;
  }
}

/// Active seasonal blessing obtained from the Hidden Harvest cauldron.
class HarvestBuff {
  final String name;
  final String description;
  final String icon;
  final double energyMultiplier;
  final double speedMultiplier;
  final int defenseBonus;

  const HarvestBuff({
    required this.name,
    required this.description,
    required this.icon,
    this.energyMultiplier = 1.0,
    this.speedMultiplier = 1.0,
    this.defenseBonus = 0,
  });

  static const HarvestBuff goldenBlessing = HarvestBuff(
    name: 'Bênção do Trigo Dourado',
    description: 'Regeneração rápida de Vigor e +15% de velocidade de trabalho.',
    icon: '✨🌾',
    energyMultiplier: 1.3,
    speedMultiplier: 1.15,
  );

  static const HarvestBuff moonDewBlessing = HarvestBuff(
    name: 'Bênção do Orvalho Lunar',
    description: 'Aura celeste: +4 Defesa contra monstros e colheitas regadas duram mais.',
    icon: '💠🌙',
    defenseBonus: 4,
    speedMultiplier: 1.10,
  );

  static const HarvestBuff rusticVitality = HarvestBuff(
    name: 'Vitalidade da Terra',
    description: 'Sabor campestre reconfortante: +20% de energia máxima.',
    icon: '🥕🍲',
    energyMultiplier: 1.2,
  );
}

/// Central manager for seasonal festivals, activities, and buffs.
class FestivalManager extends ChangeNotifier {
  final Set<String> attendedFestivals = {};
  HarvestBuff? activeHarvestBuff;
  final Random _rng = Random();

  bool isFestivalDay(Season season, int day) {
    return FestivalType.forDate(season, day) != null;
  }

  FestivalType? getActiveFestival(Season season, int day) {
    return FestivalType.forDate(season, day);
  }

  /// Spring: Pig Racing
  /// Returns placement (1st, 2nd, 3rd) and prize money + seeds.
  Map<String, dynamic> runPigRace({
    required AnimalManager animals,
    required InventoryState inventory,
    required GameState gameState,
  }) {
    // Check if player owns a pig and affection bonus
    int affectionBonus = 0;
    for (final a in animals.animals) {
      if (a.species == AnimalSpecies.pig) {
        affectionBonus = max(affectionBonus, (a.friendship / 200).toInt());
      }
    }

    final roll = _rng.nextInt(100) + affectionBonus * 10;
    int placement;
    int prizeGold;
    GameItem rewardSeed;

    if (roll >= 60) {
      placement = 1;
      prizeGold = 500;
      rewardSeed = GameItem.seedsGoldenWheat;
    } else if (roll >= 30) {
      placement = 2;
      prizeGold = 250;
      rewardSeed = GameItem.seedsDewBlossom;
    } else {
      placement = 3;
      prizeGold = 100;
      rewardSeed = GameItem.seedsScreamRoot;
    }

    gameState.addCoins(prizeGold);
    inventory.addItem(rewardSeed, count: 3);
    attendedFestivals.add(FestivalType.firstSeed.id);
    notifyListeners();

    return {
      'placement': placement,
      'prizeGold': prizeGold,
      'rewardSeed': rewardSeed,
    };
  }

  /// Summer: Floating Fire Boats cutscene & Luminescent Catch
  Map<String, dynamic> launchFireBoat({
    required InventoryState inventory,
    required GameState gameState,
  }) {
    // Blessing of the river: player receives moonlight salmon or astral carp
    final rewardFish = _rng.nextBool()
        ? GameItem.moonlightSalmon
        : GameItem.astralCarp;

    inventory.addItem(rewardFish, count: 1);
    gameState.restoreEnergy(50);
    attendedFestivals.add(FestivalType.fireBoats.id);
    notifyListeners();

    return {
      'message': 'Seu barco de fogo iluminou as correntes do lago!',
      'rewardFish': rewardFish,
    };
  }

  /// Fall: Communal Cauldron offering
  HarvestBuff contributeToCauldron({
    required String ingredientId,
    required InventoryState inventory,
    required GameState gameState,
  }) {
    // Consume 1 unit of the item
    inventory.consumeIngredients({ingredientId: 1});

    HarvestBuff buff;
    if (ingredientId == 'crop_golden_wheat' || ingredientId == 'seed_golden_wheat') {
      buff = HarvestBuff.goldenBlessing;
    } else if (ingredientId == 'crop_dew_blossom' || ingredientId == 'gem_lunar_crystal') {
      buff = HarvestBuff.moonDewBlessing;
    } else {
      buff = HarvestBuff.rusticVitality;
    }

    activeHarvestBuff = buff;
    attendedFestivals.add(FestivalType.hiddenHarvest.id);
    notifyListeners();
    return buff;
  }

  /// Winter: Forge & Sword Tournament
  /// Tests player combat damage & defense against tournament rounds.
  Map<String, dynamic> competeInTournament({
    required dynamic combatStats, // PlayerCombatStats
    required GameState gameState,
    required InventoryState inventory,
  }) {
    final int attack = (combatStats.calculateMeleeDamage() as int?) ?? 20;
    final int def = (combatStats.equipment.totalDefense as int?) ?? 2;

    int roundsWon = 0;
    if (attack >= 15 && def >= 2) roundsWon++;
    if (attack >= 30 && def >= 4) roundsWon++;
    if (attack >= 50 && def >= 6) roundsWon++;

    final isChampion = roundsWon == 3;
    final prizeGold = roundsWon * 400;
    gameState.addCoins(prizeGold);

    if (isChampion) {
      // Award Oak Champion Trophy
      inventory.addItem(GameItem.wood, count: 50);
      gameState.addCoins(1000);
    }

    attendedFestivals.add(FestivalType.forgeTournament.id);
    notifyListeners();

    return {
      'roundsWon': roundsWon,
      'isChampion': isChampion,
      'prizeGold': prizeGold + (isChampion ? 1000 : 0),
    };
  }

  void onNewSeason() {
    // Harvest buff expires when season changes
    activeHarvestBuff = null;
    notifyListeners();
  }
}
