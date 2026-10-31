import 'dart:math';
import 'package:flutter/foundation.dart';
import 'inventory_system.dart';
import 'story_system.dart';

enum MineBiome {
  stoneGalleries('Galerias de Pedra', '⛏️', 1, 49),
  undergroundGate('O Portão Subterrâneo', '🚪', 50, 50),
  ancientRifts('Fendas Ancestrais & Magma', '🌋', 51, 99),
  earthCore('O Coração da Terra', '✨', 100, 100);

  final String displayName;
  final String icon;
  final int minFloor;
  final int maxFloor;

  const MineBiome(this.displayName, this.icon, this.minFloor, this.maxFloor);

  static MineBiome forFloor(int floor) {
    if (floor == 50) return undergroundGate;
    if (floor >= 100) return earthCore;
    if (floor >= 51) return ancientRifts;
    return stoneGalleries;
  }
}

class PlayerEquipment {
  GameItem? weapon = GameItem.sword;
  GameItem? boots = GameItem.leatherBoots;
  GameItem? ring1 = GameItem.vigorRing;
  GameItem? ring2;

  int get totalAttackDamage {
    int dmg = weapon?.attackDamage ?? 8;
    dmg += ring1?.attackDamage ?? 0;
    dmg += ring2?.attackDamage ?? 0;
    return dmg;
  }

  int get totalDefense {
    int def = boots?.defense ?? 0;
    def += ring1?.defense ?? 0;
    def += ring2?.defense ?? 0;
    return def;
  }

  double get speedMultiplier {
    if (boots?.id == 'boots_feather') return 1.25;
    if (boots?.id == 'boots_leather') return 1.10;
    return 1.0;
  }
}

class PlayerCombatStats extends ChangeNotifier {
  int level = 1;
  int currentXp = 0;
  int strength = 6;
  int endurance = 6;
  int magicAttunement = 6;

  final PlayerEquipment equipment = PlayerEquipment();

  int get xpForNextLevel => level * 100;

  bool addXp(int amount) {
    currentXp += amount;
    bool leveledUp = false;
    while (currentXp >= xpForNextLevel) {
      currentXp -= xpForNextLevel;
      level += 1;
      strength += 2;
      endurance += 2;
      magicAttunement += 2;
      leveledUp = true;
    }
    notifyListeners();
    return leveledUp;
  }

  int calculateMeleeDamage() {
    return strength * 2 + equipment.totalAttackDamage;
  }

  int calculateMagicDamage() {
    return magicAttunement * 3 + (equipment.weapon?.id == 'weapon_runic_staff' ? 25 : 5);
  }
}

class MonsterData {
  final String id;
  final String name;
  final String icon;
  final String spriteAsset;
  final double frameWidth;
  final double frameHeight;
  final int maxHealth;
  final int attackDamage;
  final double speed;
  final int defense;
  final int xpReward;
  final Map<String, double> lootTable; // Item ID -> Drop chance

  const MonsterData({
    required this.id,
    required this.name,
    required this.icon,
    required this.spriteAsset,
    required this.frameWidth,
    required this.frameHeight,
    required this.maxHealth,
    required this.attackDamage,
    required this.speed,
    required this.defense,
    required this.xpReward,
    required this.lootTable,
  });

  static const List<MonsterData> allMonsters = [
    // 1. Mud Slime
    MonsterData(
      id: 'mob_slime',
      name: 'Slime de Lama',
      icon: '🍮',
      spriteAsset: 'monsters/slime.png',
      frameWidth: 16.0,
      frameHeight: 16.0,
      maxHealth: 30,
      attackDamage: 6,
      speed: 30.0,
      defense: 1,
      xpReward: 15,
      lootTable: {'ore_copper': 0.35, 'mat_wood': 0.40},
    ),

    // 2. Cave Bat
    MonsterData(
      id: 'mob_bat',
      name: 'Morcego das Cavernas',
      icon: '🦇',
      spriteAsset: 'monsters/bat.png',
      frameWidth: 16.0,
      frameHeight: 16.0,
      maxHealth: 22,
      attackDamage: 10,
      speed: 55.0,
      defense: 0,
      xpReward: 20,
      lootTable: {'mat_geode': 0.30},
    ),

    // 3. Armored Beetle
    MonsterData(
      id: 'mob_beetle',
      name: 'Besouro Couraçado',
      icon: '🪲',
      spriteAsset: 'monsters/beetle.png',
      frameWidth: 20.0,
      frameHeight: 20.0,
      maxHealth: 55,
      attackDamage: 14,
      speed: 25.0,
      defense: 5,
      xpReward: 35,
      lootTable: {'ore_iron': 0.45, 'mat_stone': 0.60},
    ),

    // 4. Ancestral Shadow
    MonsterData(
      id: 'mob_shadow',
      name: 'Sombra Ancestral',
      icon: '👤',
      spriteAsset: 'monsters/shadow.png',
      frameWidth: 24.0,
      frameHeight: 24.0,
      maxHealth: 85,
      attackDamage: 24,
      speed: 42.0,
      defense: 7,
      xpReward: 65,
      lootTable: {'ore_silver': 0.40, 'ore_gold': 0.25, 'gem_lunar_crystal': 0.15},
    ),

    // 5. Runic Golem
    MonsterData(
      id: 'mob_golem',
      name: 'Golem de Runas',
      icon: '🗿',
      spriteAsset: 'monsters/golem.png',
      frameWidth: 32.0,
      frameHeight: 32.0,
      maxHealth: 170,
      attackDamage: 38,
      speed: 20.0,
      defense: 14,
      xpReward: 130,
      lootTable: {'ore_gold': 0.60, 'gem_lunar_crystal': 0.40, 'mat_geode': 0.70},
    ),
  ];
}

class MineOreNode {
  final int x;
  final int y;
  final String oreId;
  final int health;
  bool isBroken = false;

  MineOreNode({
    required this.x,
    required this.y,
    required this.oreId,
    this.health = 3,
  });
}

class ProceduralFloor {
  final int floorNumber;
  final MineBiome biome;
  final List<MineOreNode> oreNodes;
  final List<MonsterData> monsters;
  final Point<int> ladderPosition;
  bool ladderRevealed = false;
  bool gateUnlocked = false;

  ProceduralFloor({
    required this.floorNumber,
    required this.biome,
    required this.oreNodes,
    required this.monsters,
    required this.ladderPosition,
    this.ladderRevealed = false,
    this.gateUnlocked = false,
  });
}

class MineFloorManager extends ChangeNotifier {
  int currentFloor = 1;
  int deepestFloorReached = 1;
  ProceduralFloor? activeFloor;

  final Random _rng = Random();

  MineFloorManager() {
    loadFloor(1);
  }

  void loadFloor(int floorNum, {StoryManager? story}) {
    currentFloor = floorNum.clamp(1, 100);
    if (currentFloor > deepestFloorReached) {
      deepestFloorReached = currentFloor;
    }

    final biome = MineBiome.forFloor(currentFloor);
    final ores = <MineOreNode>[];
    final monsters = <MonsterData>[];

    if (currentFloor == 50) {
      // Floor 50: The Underground Gate
      final allAltarsRestored = story?.altars.values.every((a) => a.isRestored) ?? false;
      activeFloor = ProceduralFloor(
        floorNumber: 50,
        biome: MineBiome.undergroundGate,
        oreNodes: [],
        monsters: [],
        ladderPosition: const Point(10, 12),
        ladderRevealed: allAltarsRestored,
        gateUnlocked: allAltarsRestored,
      );
      notifyListeners();
      return;
    }

    // Procedural Ore Generation
    final oreCount = 6 + _rng.nextInt(6);
    for (int i = 0; i < oreCount; i++) {
      final x = 2 + _rng.nextInt(16);
      final y = 2 + _rng.nextInt(10);
      String oreId;
      if (currentFloor < 20) {
        oreId = 'ore_copper';
      } else if (currentFloor < 50) {
        oreId = _rng.nextBool() ? 'ore_iron' : 'ore_copper';
      } else if (currentFloor < 80) {
        oreId = _rng.nextDouble() < 0.3 ? 'gem_lunar_crystal' : (_rng.nextBool() ? 'ore_silver' : 'ore_gold');
      } else {
        oreId = _rng.nextDouble() < 0.45 ? 'gem_lunar_crystal' : 'ore_gold';
      }
      ores.add(MineOreNode(x: x, y: y, oreId: oreId));
    }

    // Procedural Monster Spawning
    final monsterCount = 2 + _rng.nextInt(4);
    for (int i = 0; i < monsterCount; i++) {
      if (currentFloor < 25) {
        monsters.add(_rng.nextBool() ? MonsterData.allMonsters[0] : MonsterData.allMonsters[1]);
      } else if (currentFloor < 50) {
        monsters.add(_rng.nextDouble() < 0.4 ? MonsterData.allMonsters[2] : MonsterData.allMonsters[0]);
      } else if (currentFloor < 80) {
        monsters.add(_rng.nextDouble() < 0.5 ? MonsterData.allMonsters[3] : MonsterData.allMonsters[2]);
      } else {
        monsters.add(_rng.nextDouble() < 0.4 ? MonsterData.allMonsters[4] : MonsterData.allMonsters[3]);
      }
    }

    activeFloor = ProceduralFloor(
      floorNumber: currentFloor,
      biome: biome,
      oreNodes: ores,
      monsters: monsters,
      ladderPosition: Point(1 + _rng.nextInt(18), 1 + _rng.nextInt(12)),
      ladderRevealed: false,
    );
    notifyListeners();
  }

  void nextFloor({StoryManager? story}) {
    if (currentFloor == 50) {
      final allAltarsRestored = story?.altars.values.every((a) => a.isRestored) ?? false;
      if (!allAltarsRestored) return; // Gate is locked!
    }
    loadFloor(currentFloor + 1, story: story);
  }

  void previousFloor() {
    if (currentFloor > 1) {
      loadFloor(currentFloor - 1);
    }
  }

  bool breakOreAt(int index, InventoryState inv) {
    if (activeFloor == null || index >= activeFloor!.oreNodes.length) return false;
    final node = activeFloor!.oreNodes[index];
    if (node.isBroken) return false;

    node.isBroken = true;
    final oreItem = GameItem.allOres.firstWhere(
      (o) => o.id == node.oreId,
      orElse: () => GameItem.copperOre,
    );
    inv.addItem(oreItem, count: 1 + _rng.nextInt(2));

    // Chance to reveal ladder (25% per rock)
    if (!activeFloor!.ladderRevealed && _rng.nextDouble() < 0.28) {
      activeFloor!.ladderRevealed = true;
    }

    notifyListeners();
    return true;
  }
}

class ForgeRecipe {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Map<String, int> requiredMaterials;
  final int requiredGold;
  final GameItem resultItem;

  const ForgeRecipe({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredMaterials,
    required this.requiredGold,
    required this.resultItem,
  });

  static const List<ForgeRecipe> allForgeRecipes = [
    // Metal Smelting
    ForgeRecipe(
      id: 'smelt_copper',
      name: 'Fundir Barra de Cobre',
      description: 'Funda 5 minérios de cobre com carvão vegetal.',
      icon: '🧱',
      requiredMaterials: {'ore_copper': 5, 'mat_wood': 1},
      requiredGold: 20,
      resultItem: GameItem.copperBar,
    ),
    ForgeRecipe(
      id: 'smelt_iron',
      name: 'Fundir Barra de Ferro',
      description: 'Funda 5 minérios de ferro no fogo da forja.',
      icon: '⛓️',
      requiredMaterials: {'ore_iron': 5, 'mat_wood': 2},
      requiredGold: 40,
      resultItem: GameItem.ironBar,
    ),
    ForgeRecipe(
      id: 'smelt_silver',
      name: 'Fundir Barra de Prata',
      description: 'Funda 5 pepitas de prata com pó místico.',
      icon: '🪙',
      requiredMaterials: {'ore_silver': 5, 'mat_wood': 2},
      requiredGold: 80,
      resultItem: GameItem.silverBar,
    ),
    ForgeRecipe(
      id: 'smelt_gold',
      name: 'Fundir Barra de Ouro',
      description: 'Funda 5 minérios de ouro em temperatura extrema.',
      icon: '🏆',
      requiredMaterials: {'ore_gold': 5, 'mat_wood': 3},
      requiredGold: 150,
      resultItem: GameItem.goldBar,
    ),
    ForgeRecipe(
      id: 'smelt_lunar',
      name: 'Forjar Lingote Lunar Puro',
      description: 'Alquimia de Kael: funda ouro e cristal lunar puro.',
      icon: '✨🧱',
      requiredMaterials: {'bar_gold': 1, 'gem_lunar_crystal': 1},
      requiredGold: 300,
      resultItem: GameItem.lunarIngot,
    ),

    // Weapon & Tool Upgrades
    ForgeRecipe(
      id: 'forge_copper_blade',
      name: 'Forjar Lâmina de Cobre',
      description: 'Espada rápida com bom fio para as primeiras galerias.',
      icon: '🗡️',
      requiredMaterials: {'bar_copper': 5, 'mat_wood': 2},
      requiredGold: 200,
      resultItem: GameItem.copperBlade,
    ),
    ForgeRecipe(
      id: 'forge_iron_claymore',
      name: 'Forjar Espadão de Ferro',
      description: 'Espadão maciço com dano massivo e forte *knockback*.',
      icon: '⚔️',
      requiredMaterials: {'bar_iron': 8, 'mat_wood': 4},
      requiredGold: 500,
      resultItem: GameItem.ironClaymore,
    ),
    ForgeRecipe(
      id: 'forge_lunar_blade',
      name: 'Forjar Lâmina do Luar Carmesim',
      description: 'A obra-prima de Kael: forjada com lingote lunar e orvalho.',
      icon: '🌙⚔️',
      requiredMaterials: {'bar_lunar': 2, 'crop_dew_blossom': 1},
      requiredGold: 1500,
      resultItem: GameItem.lunarCrescentBlade,
    ),
    ForgeRecipe(
      id: 'forge_runic_staff',
      name: 'Entalhar Cajado de Runas',
      description: 'Cajado de madeira antiga e gemas que dispara projéteis mágicos.',
      icon: '🪄',
      requiredMaterials: {'bar_silver': 3, 'gem_lunar_crystal': 2},
      requiredGold: 1000,
      resultItem: GameItem.runicStaff,
    ),

    // Boots & Armor
    ForgeRecipe(
      id: 'forge_miner_boots',
      name: 'Forjar Botas do Minerador',
      description: 'Botas pesadas com solado de ferro. +5 Defesa e estabilidade.',
      icon: '👢',
      requiredMaterials: {'bar_iron': 4, 'mat_wood': 2},
      requiredGold: 350,
      resultItem: GameItem.minerBoots,
    ),
    ForgeRecipe(
      id: 'forge_feather_boots',
      name: 'Encantar Botas Celestes',
      description: 'Botas leves com Lã Flutuante. +25% de velocidade de movimento.',
      icon: '🪶🥾',
      requiredMaterials: {'produce_floating_wool': 2, 'gem_lunar_crystal': 1},
      requiredGold: 500,
      resultItem: GameItem.featherBoots,
    ),

    // Runic Rings
    ForgeRecipe(
      id: 'forge_moonflower_ring',
      name: 'Forjar Anel da Flor Lunar',
      description: 'Anel místico de prata com pétalas de Flor-de-Orvalho.',
      icon: '💠💍',
      requiredMaterials: {'bar_silver': 2, 'crop_dew_blossom': 2},
      requiredGold: 400,
      resultItem: GameItem.moonflowerRing,
    ),
    ForgeRecipe(
      id: 'forge_thorns_ring',
      name: 'Forjar Anel de Espinhos',
      description: 'Entalhado com ferro e Raiz-Gritante. Reflete 30% do dano.',
      icon: '🌿💍',
      requiredMaterials: {'bar_iron': 3, 'crop_scream_root': 1},
      requiredGold: 450,
      resultItem: GameItem.thornsRing,
    ),
  ];

  bool canCraft(InventoryState inventory, int playerGold) {
    if (playerGold < requiredGold) return false;
    return inventory.hasIngredients(requiredMaterials);
  }

  bool craft(InventoryState inventory, dynamic state) {
    // state is GameState
    final gold = (state.coins as int?) ?? 0;
    if (!canCraft(inventory, gold)) return false;

    state.spendCoins(requiredGold);
    inventory.consumeIngredients(requiredMaterials);
    inventory.addItem(resultItem, count: 1);
    return true;
  }
}
