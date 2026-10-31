import 'package:flutter_test/flutter_test.dart';
import 'package:valley_moon/models/combat_and_mining_system.dart';
import 'package:valley_moon/models/inventory_system.dart';
import 'package:valley_moon/models/story_system.dart';
import 'package:valley_moon/models/time_system.dart';

void main() {
  group('Valley Moon - Etapa 6: Minas, Combate Action-RPG e Forja', () {
    late PlayerCombatStats combatStats;
    late InventoryState inventory;
    late GameState gameState;
    late StoryManager story;

    setUp(() {
      combatStats = PlayerCombatStats();
      inventory = InventoryState();
      gameState = GameState();
      story = StoryManager();
    });

    test('PlayerCombatStats: Level up, XP progression and attribute scaling', () {
      expect(combatStats.level, equals(1));
      expect(combatStats.strength, equals(6));
      expect(combatStats.endurance, equals(6));
      expect(combatStats.magicAttunement, equals(6));
      expect(combatStats.xpForNextLevel, equals(100));

      // Add 50 XP (no level up)
      final leveled1 = combatStats.addXp(50);
      expect(leveled1, isFalse);
      expect(combatStats.level, equals(1));
      expect(combatStats.currentXp, equals(50));

      // Add 60 XP (crosses 100 XP -> Level 2 with 10 leftover XP)
      final leveled2 = combatStats.addXp(60);
      expect(leveled2, isTrue);
      expect(combatStats.level, equals(2));
      expect(combatStats.currentXp, equals(10));
      expect(combatStats.strength, equals(8));
      expect(combatStats.endurance, equals(8));
      expect(combatStats.magicAttunement, equals(8));
      expect(combatStats.xpForNextLevel, equals(200));
    });

    test('PlayerEquipment: Damage, Defense and Movement Speed modifiers', () {
      final equip = combatStats.equipment;

      // Default loadout
      expect(equip.weapon?.id, equals('tool_sword'));
      expect(equip.boots?.id, equals('boots_leather'));
      expect(equip.ring1?.id, equals('ring_vigor'));
      expect(equip.ring2, isNull);

      // Default attack damage: 8 (iron sword)
      expect(equip.totalAttackDamage, equals(8));
      // Default defense: 2 (leather boots) + 1 (vigor ring) = 3
      expect(equip.totalDefense, equals(3));
      // Leather boots speed multiplier: +10%
      expect(equip.speedMultiplier, closeTo(1.10, 0.01));

      // Equip Lunar Crescent Blade (+45 ATK), Feather Boots (+3 DEF, +25% Speed), and Moonflower Ring (+4 ATK, +2 DEF)
      equip.weapon = GameItem.lunarCrescentBlade;
      equip.boots = GameItem.featherBoots;
      equip.ring2 = GameItem.moonflowerRing;

      expect(equip.totalAttackDamage, equals(49)); // 45 + 4
      expect(equip.totalDefense, equals(6)); // 3 (boots) + 1 (ring1) + 2 (ring2)
      expect(equip.speedMultiplier, closeTo(1.25, 0.01));

      // Melee damage calculation with Strength 6:
      // strength (6) * 2 + equip (49) = 12 + 49 = 61
      expect(combatStats.calculateMeleeDamage(), equals(61));
    });

    test('Runic Staff Magic Projectile Damage', () {
      // Magic damage with normal sword
      combatStats.magicAttunement = 10;
      expect(combatStats.calculateMagicDamage(), equals(35)); // 10*3 + 5

      // Magic damage with Runic Staff equipped
      combatStats.equipment.weapon = GameItem.runicStaff;
      expect(combatStats.calculateMagicDamage(), equals(55)); // 10*3 + 25
    });

    test('MonsterData: Roster statistics and loot table rolls', () {
      expect(MonsterData.allMonsters.length, equals(5));

      final slime = MonsterData.allMonsters[0];
      expect(slime.id, equals('mob_slime'));
      expect(slime.maxHealth, equals(30));
      expect(slime.defense, equals(1));
      expect(slime.xpReward, equals(15));
      expect(slime.lootTable.containsKey('ore_copper'), isTrue);

      final golem = MonsterData.allMonsters[4];
      expect(golem.id, equals('mob_golem'));
      expect(golem.maxHealth, equals(170));
      expect(golem.attackDamage, equals(38));
      expect(golem.defense, equals(14));
      expect(golem.lootTable.containsKey('gem_lunar_crystal'), isTrue);
    });

    test('MineFloorManager: Procedural Generation for Stone Galleries (Floors 1-49)', () {
      final mine = MineFloorManager();
      mine.loadFloor(5, story: story);

      expect(mine.currentFloor, equals(5));
      expect(mine.activeFloor, isNotNull);
      expect(mine.activeFloor!.biome, equals(MineBiome.stoneGalleries));
      expect(mine.activeFloor!.oreNodes.isNotEmpty, isTrue);
      expect(mine.activeFloor!.monsters.isNotEmpty, isTrue);
      expect(mine.activeFloor!.ladderRevealed, isFalse);

      // Breaking an ore node deposits ore in inventory and can reveal ladder
      final initialCopperCount = inventory.countOf('ore_copper');
      final broken = mine.breakOreAt(0, inventory);
      expect(broken, isTrue);
      expect(mine.activeFloor!.oreNodes[0].isBroken, isTrue);
      // Ore count increased
      final newOreTotal = inventory.countOf('ore_copper') + inventory.countOf('ore_iron');
      expect(newOreTotal > initialCopperCount, isTrue);
    });

    test('MineFloorManager: Floor 50 Colossal Gate locks progression until Altars are restored', () {
      final mine = MineFloorManager();
      mine.loadFloor(50, story: story);

      expect(mine.currentFloor, equals(50));
      expect(mine.activeFloor!.biome, equals(MineBiome.undergroundGate));

      // Attempting to advance without restoring 4 Altars fails (stays at Floor 50)
      mine.nextFloor(story: story);
      expect(mine.currentFloor, equals(50));

      // Now restore all 4 Forest Altars in grandfather's questline
      for (final altar in story.altars.values) {
        altar.isRestored = true;
      }

      // Gate unseals! Advancing now reaches Floor 51 (Ancient Rifts)
      mine.nextFloor(story: story);
      expect(mine.currentFloor, equals(51));
      expect(mine.activeFloor!.biome, equals(MineBiome.ancientRifts));
    });

    test('MineFloorManager: Ancient Rifts & Magma (Floors 51-99) spawn rare ores and corrupt beasts', () {
      final mine = MineFloorManager();
      mine.loadFloor(85, story: story);

      expect(mine.currentFloor, equals(85));
      expect(mine.activeFloor!.biome, equals(MineBiome.ancientRifts));

      final oreIds = mine.activeFloor!.oreNodes.map((n) => n.oreId).toSet();
      // Ancient rifts deep floors spawn gold or lunar crystals
      final hasRareOres = oreIds.contains('ore_gold') ||
          oreIds.contains('gem_lunar_crystal');
      expect(hasRareOres, isTrue);

      final monsterIds = mine.activeFloor!.monsters.map((m) => m.id).toSet();
      // Should spawn advanced monsters (Shadows or Golems)
      final hasAdvancedMonsters = monsterIds.contains('mob_shadow') ||
          monsterIds.contains('mob_golem');
      expect(hasAdvancedMonsters, isTrue);
    });

    test('Kael\'s Forge: Smelting Bars consumes raw ores and coins', () {
      final smeltCopper = ForgeRecipe.allForgeRecipes.firstWhere((r) => r.id == 'smelt_copper');
      expect(smeltCopper.requiredGold, equals(20));
      expect(smeltCopper.requiredMaterials, equals({'ore_copper': 5, 'mat_wood': 1}));

      final initialWood = inventory.countOf('mat_wood');

      // Player lacks materials and gold
      gameState.spendCoins(gameState.coins); // 0 gold
      expect(smeltCopper.canCraft(inventory, gameState.coins), isFalse);

      // Add gold and materials
      gameState.addCoins(100);
      inventory.addItem(GameItem.copperOre, count: 5);
      inventory.addItem(GameItem.wood, count: 2);

      expect(smeltCopper.canCraft(inventory, gameState.coins), isTrue);

      // Craft recipe
      final success = smeltCopper.craft(inventory, gameState);
      expect(success, isTrue);
      expect(gameState.coins, equals(80)); // 100 - 20
      expect(inventory.countOf('ore_copper'), equals(0)); // 5 - 5
      expect(inventory.countOf('mat_wood'), equals(initialWood + 1)); // (initial + 2) - 1
      expect(inventory.countOf('bar_copper'), equals(1)); // 1 bar gained
    });

    test('Kael\'s Forge: Forging Lunar Crescent Blade and Runic Staff', () {
      final forgeLunarBlade = ForgeRecipe.allForgeRecipes.firstWhere((r) => r.id == 'forge_lunar_blade');
      final forgeStaff = ForgeRecipe.allForgeRecipes.firstWhere((r) => r.id == 'forge_runic_staff');

      gameState.spendCoins(gameState.coins); // Reset to 0
      gameState.addCoins(3000);
      inventory.addItem(GameItem.lunarIngot, count: 2);
      inventory.addItem(GameItem.dewBlossom, count: 1);

      expect(forgeLunarBlade.canCraft(inventory, gameState.coins), isTrue);
      final forgedSword = forgeLunarBlade.craft(inventory, gameState);
      expect(forgedSword, isTrue);
      expect(inventory.countOf('weapon_lunar_sword'), equals(1));
      expect(gameState.coins, equals(1500)); // 3000 - 1500

      // Forging Runic Staff
      inventory.addItem(GameItem.silverBar, count: 3);
      inventory.addItem(GameItem.lunarCrystal, count: 2);
      expect(forgeStaff.canCraft(inventory, gameState.coins), isTrue);
      final forgedStaff = forgeStaff.craft(inventory, gameState);
      expect(forgedStaff, isTrue);
      expect(inventory.countOf('weapon_runic_staff'), equals(1));
      expect(gameState.coins, equals(500)); // 1500 - 1000
    });
  });
}
