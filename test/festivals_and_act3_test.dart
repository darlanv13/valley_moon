import 'package:flutter_test/flutter_test.dart';
import 'package:valley_moon/game/valley_moon_game.dart';
import 'package:valley_moon/models/act3_boss_system.dart';
import 'package:valley_moon/models/animal_system.dart';
import 'package:valley_moon/models/combat_and_mining_system.dart';
import 'package:valley_moon/models/festival_system.dart';
import 'package:valley_moon/models/inventory_system.dart';
import 'package:valley_moon/models/save_system.dart';
import 'package:valley_moon/models/time_system.dart';

void main() {
  group('Valley Moon - Etapa 7: Festivais, Ato III e Persistência', () {
    late FestivalManager festivals;
    late Act3BossState boss;
    late GameState gameState;
    late InventoryState inventory;
    late AnimalManager animals;
    late PlayerCombatStats combat;

    setUp(() {
      festivals = FestivalManager();
      boss = Act3BossState();
      gameState = GameState();
      inventory = InventoryState();
      animals = AnimalManager();
      combat = PlayerCombatStats();
    });

    test('Festival Calendar: The 4 seasonal festivals trigger on exact days', () {
      expect(festivals.getActiveFestival(Season.spring, 13), equals(FestivalType.firstSeed));
      expect(festivals.getActiveFestival(Season.summer, 28), equals(FestivalType.fireBoats));
      expect(festivals.getActiveFestival(Season.autumn, 16), equals(FestivalType.hiddenHarvest));
      expect(festivals.getActiveFestival(Season.winter, 20), equals(FestivalType.forgeTournament));

      // Non-festival days
      expect(festivals.getActiveFestival(Season.spring, 12), isNull);
      expect(festivals.getActiveFestival(Season.winter, 1), isNull);
    });

    test('Spring Festival: Pig Racing awards prize money and seeds', () {
      final initialCoins = gameState.coins;
      final raceResult = festivals.runPigRace(
        animals: animals,
        inventory: inventory,
        gameState: gameState,
      );

      final placement = raceResult['placement'] as int;
      final prizeGold = raceResult['prizeGold'] as int;
      final rewardSeed = raceResult['rewardSeed'] as GameItem;

      expect(placement >= 1 && placement <= 3, isTrue);
      expect(gameState.coins, equals(initialCoins + prizeGold));
      expect(inventory.countOf(rewardSeed.id) >= 3, isTrue);
      expect(festivals.attendedFestivals.contains(FestivalType.firstSeed.id), isTrue);
    });

    test('Summer Festival: Fire Boats release awards luminescent fish and energy', () {
      gameState.useEnergy(60);
      final energyBefore = gameState.energy;

      final res = festivals.launchFireBoat(
        inventory: inventory,
        gameState: gameState,
      );

      final fish = res['rewardFish'] as GameItem;
      expect(fish.category, equals(ItemCategory.fish));
      expect(inventory.countOf(fish.id) >= 1, isTrue);
      expect(gameState.energy, equals(energyBefore + 50));
      expect(festivals.attendedFestivals.contains(FestivalType.fireBoats.id), isTrue);
    });

    test('Fall Festival: Communal Cauldron offering grants seasonal harvest buff', () {
      // Golden Wheat Offering
      inventory.addItem(GameItem.seedsGoldenWheat, count: 2);
      final buff = festivals.contributeToCauldron(
        ingredientId: 'seed_golden_wheat',
        inventory: inventory,
        gameState: gameState,
      );

      expect(buff.name, equals('Bênção do Trigo Dourado'));
      expect(buff.energyMultiplier, closeTo(1.3, 0.01));
      expect(festivals.activeHarvestBuff, equals(buff));
      expect(festivals.attendedFestivals.contains(FestivalType.hiddenHarvest.id), isTrue);

      // Transition to next season expires the harvest buff
      festivals.onNewSeason();
      expect(festivals.activeHarvestBuff, isNull);
    });

    test('Winter Festival: Forge & Sword Tournament rewards combat prowess', () {
      // Set high combat stats
      combat.strength = 20;
      combat.equipment.weapon = GameItem.lunarCrescentBlade; // +45 ATK
      combat.equipment.boots = GameItem.minerBoots; // +5 DEF
      combat.equipment.ring1 = GameItem.thornsRing; // +3 DEF

      final initialCoins = gameState.coins;
      final res = festivals.competeInTournament(
        combatStats: combat,
        gameState: gameState,
        inventory: inventory,
      );

      final won = res['roundsWon'] as int;
      final isChamp = res['isChampion'] as bool;
      expect(won, equals(3));
      expect(isChamp, isTrue);
      expect(gameState.coins > initialCoins, isTrue);
      expect(festivals.attendedFestivals.contains(FestivalType.forgeTournament.id), isTrue);
    });

    test('Act III Boss Battle: Phase 1 Carapace damage and Phase 2 transition', () {
      expect(boss.phase, equals(BossBattlePhase.phase1Armor));
      expect(boss.currentArmor, equals(500.0));

      // Damage the rocky armor
      final hit1 = boss.applyWeaponDamage(200);
      expect(hit1, isTrue);
      expect(boss.currentArmor, equals(300.0));
      expect(boss.phase, equals(BossBattlePhase.phase1Armor));

      // Break remaining armor
      final hit2 = boss.applyWeaponDamage(350);
      expect(hit2, isTrue);
      expect(boss.currentArmor, equals(0.0));
      expect(boss.phase, equals(BossBattlePhase.phase2Purification));

      // During Phase 2, physical weapons cannot damage the nature core
      final hit3 = boss.applyWeaponDamage(100);
      expect(hit3, isFalse);
    });

    test('Act III Boss Battle: Phase 2 Farming Under Pressure purifies the Guardian', () {
      // Transition to Phase 2
      boss.phase = BossBattlePhase.phase2Purification;

      // 1. Till Sacred Soil
      expect(boss.isSoilTilled, isFalse);
      final tilled = boss.tillSacredSoil(gameState);
      expect(tilled, isTrue);
      expect(boss.isSoilTilled, isTrue);

      // 2. Plant Sacred Lunar Seed
      expect(boss.isSeedPlanted, isFalse);
      final planted = boss.plantLunarSeed(inventory, gameState);
      expect(planted, isTrue);
      expect(boss.isSeedPlanted, isTrue);

      // 3. Water the Tree of Light in 3 cycles
      expect(boss.waterCycles, equals(0));
      boss.waterLunarTree(gameState);
      expect(boss.waterCycles, equals(1));
      expect(boss.phase, equals(BossBattlePhase.phase2Purification));

      boss.waterLunarTree(gameState);
      expect(boss.waterCycles, equals(2));

      // Final cycle triggers victory!
      boss.waterLunarTree(gameState);
      expect(boss.waterCycles, equals(3));
      expect(boss.phase, equals(BossBattlePhase.victory));
      expect(boss.grandfatherFreed, isTrue);
      expect(boss.act3Completed, isTrue);
      expect(boss.endlessMinesUnlocked, isTrue);
    });

    test('SaveManager: Saves full game state and restores accurately', () async {
      final game = ValleyMoonGame();
      game.gameState.day = 16;
      game.gameState.season = Season.autumn;
      game.gameState.coins = 2450;
      game.combat.level = 5;
      game.combat.strength = 14;
      game.mine.currentFloor = 50;
      game.boss.act3Completed = true;
      game.boss.grandfatherFreed = true;
      game.boss.endlessMinesUnlocked = true;
      game.festivals.attendedFestivals.add(FestivalType.hiddenHarvest.id);

      // Save game
      final saved = await SaveManager.saveGame(game);
      expect(saved, isTrue);
      expect(SaveManager.hasSaveGame(), isTrue);

      // Create new game instance and load
      final newGame = ValleyMoonGame();
      final loaded = await SaveManager.loadGame(newGame);
      expect(loaded, isTrue);

      expect(newGame.gameState.day, equals(16));
      expect(newGame.gameState.season, equals(Season.autumn));
      expect(newGame.gameState.coins, equals(2450));
      expect(newGame.combat.level, equals(5));
      expect(newGame.combat.strength, equals(14));
      expect(newGame.mine.currentFloor, equals(50));
      expect(newGame.boss.act3Completed, isTrue);
      expect(newGame.boss.grandfatherFreed, isTrue);
      expect(newGame.boss.endlessMinesUnlocked, isTrue);
      expect(newGame.festivals.attendedFestivals.contains(FestivalType.hiddenHarvest.id), isTrue);

      // Clear save
      await SaveManager.clearSave();
      expect(SaveManager.hasSaveGame(), isFalse);
    });
  });
}

