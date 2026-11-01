import 'dart:math';
import 'package:flutter/foundation.dart';
import 'inventory_system.dart';
import 'npc_dialogue_system.dart';
import 'time_system.dart';

/// The 3 cabin upgrade tiers.
enum CabinLevel {
  level0(
    name: 'Cabana Rústica Inicial',
    description: 'Aconchegante, com lareira e cama de solteiro de palha.',
    goldCost: 0,
    woodCost: 0,
    stoneCost: 0,
    hasKitchen: false,
    hasDoubleBed: false,
    hasNursery: false,
  ),
  level1(
    name: 'Cabana Nível 1 (Cozinha à Lenha)',
    description: 'Espaçosa, com fogão à lenha e bancada rústica para cozinhar receitas.',
    goldCost: 2000,
    woodCost: 100,
    stoneCost: 50,
    hasKitchen: true,
    hasDoubleBed: false,
    hasNursery: false,
  ),
  level2(
    name: 'Cabana Nível 2 (Quarto de Casal)',
    description: 'Adiciona quarto com cama de cedro nobre. Habilita o Casamento com candidatos.',
    goldCost: 5000,
    woodCost: 150,
    stoneCost: 80,
    hasKitchen: true,
    hasDoubleBed: true,
    hasNursery: false,
  ),
  level3(
    name: 'Cabana Nível 3 (Berçário Encantado)',
    description: 'Adiciona berçário com berço de vime e baú de brinquedos. Permite ter até 2 filhos.',
    goldCost: 8000,
    woodCost: 200,
    stoneCost: 100,
    hasKitchen: true,
    hasDoubleBed: true,
    hasNursery: true,
  );

  final String name;
  final String description;
  final int goldCost;
  final int woodCost;
  final int stoneCost;
  final bool hasKitchen;
  final bool hasDoubleBed;
  final bool hasNursery;

  const CabinLevel({
    required this.name,
    required this.description,
    required this.goldCost,
    required this.woodCost,
    required this.stoneCost,
    required this.hasKitchen,
    required this.hasDoubleBed,
    required this.hasNursery,
  });

  CabinLevel? get nextLevel {
    switch (this) {
      case CabinLevel.level0:
        return CabinLevel.level1;
      case CabinLevel.level1:
        return CabinLevel.level2;
      case CabinLevel.level2:
        return CabinLevel.level3;
      case CabinLevel.level3:
        return null;
    }
  }
}

/// Life stages of a child in Valley Moon.
enum ChildStage {
  baby(
    title: 'Bebê de Berço',
    description: 'Descansa no berço de vime. Ri quando ganha carinho e ouve canções de ninar.',
  ),
  toddler(
    title: 'Criança Pequena',
    description: 'Corre pelo pátio da fazenda, colhe flores e brinca com o chocalho de madeira.',
  );

  final String title;
  final String description;

  const ChildStage({
    required this.title,
    required this.description,
  });
}

/// A child of the player and spouse.
class ChildData {
  final String id;
  String name;
  final bool isBoy;
  ChildStage stage;
  int daysOld;
  int affection;
  bool interactedToday;

  ChildData({
    required this.id,
    required this.name,
    required this.isBoy,
    this.stage = ChildStage.baby,
    this.daysOld = 0,
    this.affection = 50,
    this.interactedToday = false,
  });

  int get hearts => (affection / 100).clamp(0, 10).toInt();

  void advanceDay() {
    daysOld++;
    interactedToday = false;
    // After 14 days, baby grows into walking toddler!
    if (daysOld >= 14 && stage == ChildStage.baby) {
      stage = ChildStage.toddler;
    }
  }

  bool playWithChild() {
    if (interactedToday) return false;
    interactedToday = true;
    affection = (affection + 30).clamp(0, 1000);
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isBoy': isBoy,
      'stage': stage.index,
      'daysOld': daysOld,
      'affection': affection,
      'interactedToday': interactedToday,
    };
  }

  factory ChildData.fromJson(Map<String, dynamic> json) {
    final sIdx = json['stage'] as int? ?? 0;
    return ChildData(
      id: json['id'] as String? ?? 'child_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Selene',
      isBoy: json['isBoy'] as bool? ?? false,
      stage: ChildStage.values[sIdx.clamp(0, ChildStage.values.length - 1)],
      daysOld: json['daysOld'] as int? ?? 0,
      affection: json['affection'] as int? ?? 50,
      interactedToday: json['interactedToday'] as bool? ?? false,
    );
  }
}

/// Result of morning chore assistance by the spouse.
enum SpouseChoreType {
  wateredCrops,
  fedAnimals,
  repairedFences,
  none,
}

/// Central manager for Cabin Upgrades, Marriage, Spouse Morning Chores and Children.
class CabinAndFamilyManager extends ChangeNotifier {
  CabinLevel cabinLevel = CabinLevel.level0;
  NpcId? spouseId;
  int marriageDay = 0;
  bool kissedToday = false;
  bool receivedGiftToday = false;

  final List<ChildData> children = [];
  final Random _rng = Random();

  SpouseChoreType lastMorningChore = SpouseChoreType.none;
  String? lastSpouseDialogue;

  bool get isMarried => spouseId != null;
  bool get canMarry => cabinLevel.hasDoubleBed;
  bool get canHaveChildren => cabinLevel.hasNursery && isMarried && children.length < 2;

  // --- Cabin Upgrades ---
  bool canUpgradeCabin(GameState gameState, InventoryState inventory) {
    final next = cabinLevel.nextLevel;
    if (next == null) return false;

    if (gameState.coins < next.goldCost) return false;
    if (inventory.countOf('mat_wood') < next.woodCost) return false;
    if (inventory.countOf('mat_stone') < next.stoneCost) return false;

    return true;
  }

  bool purchaseCabinUpgrade(GameState gameState, InventoryState inventory) {
    final next = cabinLevel.nextLevel;
    if (next == null) return false;
    if (!canUpgradeCabin(gameState, inventory)) return false;

    gameState.coins -= next.goldCost;
    inventory.consumeIngredients({
      'mat_wood': next.woodCost,
      'mat_stone': next.stoneCost,
    });

    cabinLevel = next;
    notifyListeners();
    return true;
  }

  // --- Marriage System ---
  bool marryNpc(NpcId candidateId, RelationshipManager relationships, GameState gameState, InventoryState inventory) {
    if (!canMarry) return false;
    if (!candidateId.isMarriageCandidate) return false;

    final rel = relationships.relationships[candidateId];
    if (rel == null || rel.hearts < 10) return false;

    // Check if player has the Moonflower Amulet
    if (inventory.countOf('gift_moonflower_amulet') <= 0) return false;

    // Consume amulet
    inventory.consumeIngredients({'gift_moonflower_amulet': 1});

    spouseId = candidateId;
    marriageDay = gameState.day;
    rel.status = RelationshipStatus.married;
    rel.addPoints(200);

    notifyListeners();
    return true;
  }

  // --- Morning Routine & Chores ---
  SpouseChoreType executeMorningRoutine({
    required Function(int count) onWaterCrops,
    required VoidCallback onFeedAnimals,
  }) {
    if (!isMarried) {
      lastMorningChore = SpouseChoreType.none;
      lastSpouseDialogue = null;
      return SpouseChoreType.none;
    }

    kissedToday = false;
    receivedGiftToday = false;

    // Advance children
    for (final child in children) {
      child.advanceDay();
    }

    // 50% chance to assist with morning chores
    final roll = _rng.nextDouble();
    if (roll < 0.35) {
      // Water crops
      lastMorningChore = SpouseChoreType.wateredCrops;
      onWaterCrops(5);
      lastSpouseDialogue = _getSpouseChoreDialogue(SpouseChoreType.wateredCrops);
    } else if (roll < 0.70) {
      // Feed animals
      lastMorningChore = SpouseChoreType.fedAnimals;
      onFeedAnimals();
      lastSpouseDialogue = _getSpouseChoreDialogue(SpouseChoreType.fedAnimals);
    } else {
      lastMorningChore = SpouseChoreType.none;
      lastSpouseDialogue = _getSpouseChoreDialogue(SpouseChoreType.none);
    }

    notifyListeners();
    return lastMorningChore;
  }

  String _getSpouseChoreDialogue(SpouseChoreType chore) {
    switch (chore) {
      case SpouseChoreType.wateredCrops:
        return 'Bom dia, amor! Acordei mais cedo e reguei alguns canteiros de plantio para você poupar seu vigor hoje. 💖';
      case SpouseChoreType.fedAnimals:
        return 'Bom dia, querido(a)! Fui até o celeiro e enchi o cocho de feno de todos os animais. Eles estavam famintos! 🌾';
      case SpouseChoreType.repairedFences:
        return 'Arrumei algumas tábuas da cerca que estavam frouxas pelo vento da noite. Tenha um ótimo dia na fazenda!';
      case SpouseChoreType.none:
        return 'Bom dia! O aroma da floresta e da terra molhada está maravilhoso nesta manhã de Valley Moon. ✨';
    }
  }

  /// Gives the exclusive daily spouse gift to the player.
  GameItem? claimDailySpouseGift(InventoryState inventory) {
    if (!isMarried || receivedGiftToday) return null;

    GameItem gift;
    switch (spouseId) {
      case NpcId.kael:
        // Kael gives forged metal or runic bronze
        final r = _rng.nextInt(3);
        gift = r == 0 ? GameItem.runicBronzeIngot : (r == 1 ? GameItem.ironBar : GameItem.copperBar);
        break;
      case NpcId.helena:
        // Helena gives mystical forest potions
        final r = _rng.nextInt(3);
        gift = r == 0 ? GameItem.vitalDew : (r == 1 ? GameItem.healthPotion : GameItem.vigorElixir);
        break;
      case NpcId.iris:
        // Iris gives warm rustic delicacies
        final r = _rng.nextInt(3);
        gift = r == 0 ? GameItem.turnipStew : (r == 1 ? GameItem.goldenLoaf : GameItem.moonberryPie);
        break;
      case NpcId.maya:
        // Maya gives mystical animal products
        final r = _rng.nextInt(3);
        gift = r == 0 ? GameItem.amberEgg : (r == 1 ? GameItem.floatingWool : GameItem.curedCheese);
        break;
      default:
        gift = GameItem.turnipStew;
        break;
    }

    inventory.addItem(gift);
    receivedGiftToday = true;
    notifyListeners();
    return gift;
  }

  /// Kiss/Hug interaction with spouse.
  bool kissSpouse(RelationshipManager relationships) {
    if (!isMarried || kissedToday) return false;
    kissedToday = true;
    relationships.relationships[spouseId]?.addPoints(25);
    notifyListeners();
    return true;
  }

  // --- Children System ---
  ChildData? haveOrAdoptChild(String name, bool isBoy) {
    if (!canHaveChildren) return null;

    final child = ChildData(
      id: 'child_${DateTime.now().millisecondsSinceEpoch}_${children.length}',
      name: name,
      isBoy: isBoy,
      stage: ChildStage.baby,
      daysOld: 0,
      affection: 80,
    );
    children.add(child);
    notifyListeners();
    return child;
  }

  Map<String, dynamic> toJson() {
    return {
      'cabinLevel': cabinLevel.index,
      'spouseId': spouseId?.name,
      'marriageDay': marriageDay,
      'kissedToday': kissedToday,
      'receivedGiftToday': receivedGiftToday,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }

  void loadFromJson(Map<String, dynamic> json) {
    final cIdx = json['cabinLevel'] as int? ?? 0;
    cabinLevel = CabinLevel.values[cIdx.clamp(0, CabinLevel.values.length - 1)];

    final spName = json['spouseId'] as String?;
    if (spName != null) {
      for (final n in NpcId.values) {
        if (n.name == spName) {
          spouseId = n;
          break;
        }
      }
    } else {
      spouseId = null;
    }

    marriageDay = json['marriageDay'] as int? ?? 0;
    kissedToday = json['kissedToday'] as bool? ?? false;
    receivedGiftToday = json['receivedGiftToday'] as bool? ?? false;

    children.clear();
    final childList = json['children'] as List<dynamic>?;
    if (childList != null) {
      for (final item in childList) {
        if (item is Map<String, dynamic>) {
          children.add(ChildData.fromJson(item));
        }
      }
    }

    notifyListeners();
  }
}
