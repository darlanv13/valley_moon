import 'package:flutter_test/flutter_test.dart';
import 'package:valley_moon/game/valley_moon_game.dart';
import 'package:valley_moon/models/artisan_system.dart';
import 'package:valley_moon/models/cabin_and_family_system.dart';
import 'package:valley_moon/models/inventory_system.dart';
import 'package:valley_moon/models/npc_dialogue_system.dart';
import 'package:valley_moon/models/save_system.dart';
import 'package:valley_moon/models/time_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Valley Moon - Etapa 8: Expansão da Cabana, Casamento, Filhos e Maquinário Rústico', () {
    late CabinAndFamilyManager family;
    late ArtisanManager artisan;
    late InventoryState inventory;
    late RelationshipManager relationships;
    late GameState gameState;

    setUp(() {
      family = CabinAndFamilyManager();
      artisan = ArtisanManager();
      inventory = InventoryState();
      relationships = RelationshipManager();
      gameState = GameState();
    });

    test('Cabin Upgrades: Level 0 -> Level 1 (Kitchen) -> Level 2 (Marriage) -> Level 3 (Nursery)', () {
      expect(family.cabinLevel, CabinLevel.level0);
      expect(family.cabinLevel.hasKitchen, isFalse);
      expect(family.cabinLevel.hasDoubleBed, isFalse);
      expect(family.cabinLevel.hasNursery, isFalse);
      expect(family.canMarry, isFalse);
      expect(family.canHaveChildren, isFalse);

      // Give resources for Level 1: 2000g, 100 wood, 50 stone
      gameState.coins = 2500;
      inventory.addItem(GameItem.wood, count: 100);
      inventory.addItem(GameItem.stone, count: 50);

      expect(family.canUpgradeCabin(gameState, inventory), isTrue);
      final upgradedToL1 = family.purchaseCabinUpgrade(gameState, inventory);
      expect(upgradedToL1, isTrue);
      expect(family.cabinLevel, CabinLevel.level1);
      expect(family.cabinLevel.hasKitchen, isTrue);
      expect(gameState.coins, 500);

      // Upgrade to Level 2: 5000g, 150 wood, 80 stone
      gameState.coins = 6000;
      inventory.addItem(GameItem.wood, count: 150);
      inventory.addItem(GameItem.stone, count: 80);

      final upgradedToL2 = family.purchaseCabinUpgrade(gameState, inventory);
      expect(upgradedToL2, isTrue);
      expect(family.cabinLevel, CabinLevel.level2);
      expect(family.cabinLevel.hasDoubleBed, isTrue);
      expect(family.canMarry, isTrue);

      // Upgrade to Level 3: 8000g, 200 wood, 100 stone
      gameState.coins = 8500;
      inventory.addItem(GameItem.wood, count: 200);
      inventory.addItem(GameItem.stone, count: 100);

      final upgradedToL3 = family.purchaseCabinUpgrade(gameState, inventory);
      expect(upgradedToL3, isTrue);
      expect(family.cabinLevel, CabinLevel.level3);
      expect(family.cabinLevel.hasNursery, isTrue);
      expect(family.cabinLevel.nextLevel, isNull);
    });

    test('Marriage: Requires Level 2 Cabin, 10 Hearts and Moonflower Amulet', () {
      final helenaRel = relationships.relationships[NpcId.helena]!;

      // 1. Level 0 cabin: Cannot marry
      family.cabinLevel = CabinLevel.level0;
      inventory.addItem(GameItem.moonflowerAmulet, count: 1);
      helenaRel.addPoints(2500); // 10 hearts
      expect(helenaRel.hearts, 10);
      expect(family.marryNpc(NpcId.helena, relationships, gameState, inventory), isFalse);

      // 2. Level 2 cabin but without amulet: Cannot marry
      family.cabinLevel = CabinLevel.level2;
      inventory.consumeIngredients({'gift_moonflower_amulet': 1});
      expect(family.marryNpc(NpcId.helena, relationships, gameState, inventory), isFalse);

      // 3. Level 2 cabin + 10 hearts + Moonflower Amulet: Success!
      inventory.addItem(GameItem.moonflowerAmulet, count: 1);
      final married = family.marryNpc(NpcId.helena, relationships, gameState, inventory);
      expect(married, isTrue);
      expect(family.isMarried, isTrue);
      expect(family.spouseId, NpcId.helena);
      expect(helenaRel.status, RelationshipStatus.married);
      expect(inventory.countOf('gift_moonflower_amulet'), 0); // Consumed
    });

    test('Spouse Morning Chores, Daily Exclusive Gifts, and Affection', () {
      family.cabinLevel = CabinLevel.level2;
      inventory.addItem(GameItem.moonflowerAmulet, count: 1);
      relationships.relationships[NpcId.kael]!.addPoints(2500);
      family.marryNpc(NpcId.kael, relationships, gameState, inventory);

      bool cropsWateredCalled = false;
      bool animalsFedCalled = false;

      // Execute multiple morning routines to verify chore rolls
      for (int i = 0; i < 10; i++) {
        family.executeMorningRoutine(
          onWaterCrops: (count) => cropsWateredCalled = true,
          onFeedAnimals: () => animalsFedCalled = true,
        );
      }
      expect(cropsWateredCalled || animalsFedCalled, isTrue);

      // Daily spouse gift from Kael (metals / bronze)
      final gift = family.claimDailySpouseGift(inventory);
      expect(gift, isNotNull);
      expect([
        GameItem.runicBronzeIngot.id,
        GameItem.ironBar.id,
        GameItem.copperBar.id,
      ], contains(gift!.id));
      expect(inventory.countOf(gift.id), greaterThan(0));

      // Cannot claim twice in the same day
      expect(family.claimDailySpouseGift(inventory), isNull);

      // Kiss spouse (test points increase)
      relationships.relationships[NpcId.kael]!.friendshipPoints = 2000;
      final pointsBefore = relationships.relationships[NpcId.kael]!.friendshipPoints;
      final kissed = family.kissSpouse(relationships);
      expect(kissed, isTrue);
      expect(relationships.relationships[NpcId.kael]!.friendshipPoints, pointsBefore + 25);
    });

    test('Children: Nursery requirement, baby in crib, and growth to walking toddler', () {
      family.cabinLevel = CabinLevel.level2; // No nursery yet
      family.spouseId = NpcId.iris;
      expect(family.canHaveChildren, isFalse);

      // Upgrade to Level 3
      family.cabinLevel = CabinLevel.level3;
      expect(family.canHaveChildren, isTrue);

      // Adopt 1st child: Baby girl
      final child1 = family.haveOrAdoptChild('Selene', false);
      expect(child1, isNotNull);
      expect(child1!.name, 'Selene');
      expect(child1.isBoy, isFalse);
      expect(child1.stage, ChildStage.baby);
      expect(child1.daysOld, 0);

      // Play with baby (crib rocking)
      expect(child1.playWithChild(), isTrue);
      expect(child1.interactedToday, isTrue);
      expect(child1.playWithChild(), isFalse); // Already played today

      // Advance 14 days -> Baby grows into toddler!
      for (int day = 0; day < 14; day++) {
        child1.advanceDay();
      }
      expect(child1.daysOld, 14);
      expect(child1.stage, ChildStage.toddler);

      // Adopt 2nd child: Toddler boy
      final child2 = family.haveOrAdoptChild('Luan', true);
      expect(child2, isNotNull);
      expect(family.children.length, 2);

      // Cannot exceed 2 children
      expect(family.canHaveChildren, isFalse);
      expect(family.haveOrAdoptChild('Sol', true), isNull);
    });

    test('Artisan Machinery: Loom, Oak Cask, Runic Furnace, and Preserves Jar', () {
      expect(artisan.machines.length, 4);

      final loom = artisan.machines.firstWhere((m) => m.type == ArtisanMachineType.loom);
      final cask = artisan.machines.firstWhere((m) => m.type == ArtisanMachineType.oakCask);
      final furnace = artisan.machines.firstWhere((m) => m.type == ArtisanMachineType.runicFurnace);
      final jar = artisan.machines.firstWhere((m) => m.type == ArtisanMachineType.preservesJar);

      // 1. Loom: Wool -> Fine Yarn
      inventory.addItem(GameItem.wool, count: 1);
      final loomInserted = artisan.tryInsertItem(loom, inventory, GameItem.wool.id);
      expect(loomInserted, isTrue);
      expect(loom.isProcessing, isTrue);
      expect(loom.isReady, isFalse);
      expect(loom.resultItem?.id, GameItem.fineYarn.id);

      // Advance 4 hours -> Fine Yarn ready!
      artisan.advanceHours(4.0);
      expect(loom.isReady, isTrue);
      final harvestedYarn = artisan.tryHarvest(loom, inventory);
      expect(harvestedYarn?.id, GameItem.fineYarn.id);
      expect(inventory.countOf(GameItem.fineYarn.id), 1);

      // 2. Oak Cask: Milk -> Cured Cheese
      inventory.addItem(GameItem.milk, count: 1);
      artisan.tryInsertItem(cask, inventory, GameItem.milk.id);
      artisan.advanceHours(6.0);
      expect(cask.isReady, isTrue);
      final harvestedCheese = artisan.tryHarvest(cask, inventory);
      expect(harvestedCheese?.id, GameItem.curedCheese.id);

      // 3. Runic Furnace: Copper Ore (x2) + Iron Ore (x2) -> Runic Bronze Ingot
      inventory.addItem(GameItem.copperOre, count: 2);
      inventory.addItem(GameItem.ironOre, count: 2);
      final furnaceInserted = artisan.tryInsertItem(furnace, inventory, GameItem.copperOre.id, GameItem.ironOre.id);
      expect(furnaceInserted, isTrue);
      artisan.advanceHours(5.0);
      expect(furnace.isReady, isTrue);
      final harvestedBronze = artisan.tryHarvest(furnace, inventory);
      expect(harvestedBronze?.id, GameItem.runicBronzeIngot.id);

      // 4. Preserves Jar: Truffle -> Truffle Oil
      inventory.addItem(GameItem.truffle, count: 1);
      artisan.tryInsertItem(jar, inventory, GameItem.truffle.id);
      artisan.advanceHours(5.0);
      expect(jar.isReady, isTrue);
      final harvestedOil = artisan.tryHarvest(jar, inventory);
      expect(harvestedOil?.id, GameItem.truffleOil.id);
    });

    test('Wood-Fired Stove Cooking: Prepares dishes and consumes farm crops', () {
      final turnipStewRecipe = Recipe.allRecipes.firstWhere((r) => r.id == 'rec_food_turnip_stew');
      final goldenLoafRecipe = Recipe.allRecipes.firstWhere((r) => r.id == 'rec_food_golden_loaf');

      // Turnip Stew requires 2 turnips and 1 wood
      inventory.addItem(GameItem.turnip, count: 2);
      inventory.addItem(GameItem.wood, count: 1);

      expect(inventory.hasIngredients(turnipStewRecipe.ingredients), isTrue);
      final cooked = inventory.craft(turnipStewRecipe);
      expect(cooked, isTrue);
      expect(inventory.countOf(GameItem.turnipStew.id), 1);
      expect(GameItem.turnipStew.energyRestore, 45.0);
      expect(GameItem.turnipStew.healthRestore, 25.0);

      // Golden Loaf requires 2 wheat and 1 milk
      inventory.addItem(GameItem.wheat, count: 2);
      inventory.addItem(GameItem.milk, count: 1);
      expect(inventory.craft(goldenLoafRecipe), isTrue);
      expect(inventory.countOf(GameItem.goldenLoaf.id), 1);
      expect(GameItem.goldenLoaf.energyRestore, 60.0);
    });

    test('SaveManager: Persists and Restores Cabin Level, Spouse, Children, and Artisan Machines', () async {
      await SaveManager.initialize();
      final game = ValleyMoonGame();

      // Configure Stage 8 state
      game.family.cabinLevel = CabinLevel.level3;
      game.family.spouseId = NpcId.maya;
      game.family.marriageDay = 12;
      game.family.haveOrAdoptChild('Aura', false);
      game.artisan.machines[0].startProcessing('produce_wool', count: 1);

      // Save
      final saved = await SaveManager.saveGame(game);
      expect(saved, isTrue);

      // Create new game instance and restore
      final loadedGame = ValleyMoonGame();
      final loaded = await SaveManager.loadGame(loadedGame);
      expect(loaded, isTrue);

      expect(loadedGame.family.cabinLevel, CabinLevel.level3);
      expect(loadedGame.family.spouseId, NpcId.maya);
      expect(loadedGame.family.marriageDay, 12);
      expect(loadedGame.family.children.length, 1);
      expect(loadedGame.family.children.first.name, 'Aura');
      expect(loadedGame.artisan.machines[0].isProcessing, isTrue);
    });
  });
}
