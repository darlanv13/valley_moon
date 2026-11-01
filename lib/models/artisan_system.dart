import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'inventory_system.dart';

/// The 4 types of rustic artisan machinery in Valley Moon.
enum ArtisanMachineType {
  loom(
    name: 'Tear de Madeira',
    description: 'Transforma lãs em fios finos e tecidos celestes.',
    icon: '🧵',
    sfx: 'loom_spin.ogg',
  ),
  oakCask(
    name: 'Barril de Carvalho',
    description: 'Envelhece leite em queijos curados e elixires em vinhos.',
    icon: '🪵',
    sfx: 'barrel_bubble.ogg',
  ),
  runicFurnace(
    name: 'Fornalha Rúnica',
    description: 'Funde ligas metálicas duplas e amálgamas estelares.',
    icon: '🔥',
    sfx: 'forge_anvil.ogg',
  ),
  preservesJar(
    name: 'Pote de Conservas',
    description: 'Prepara picles crocantes, geleias e azeites nobres de trufa.',
    icon: '🏺',
    sfx: 'barrel_bubble.ogg',
  );

  final String name;
  final String description;
  final String icon;
  final String sfx;

  const ArtisanMachineType({
    required this.name,
    required this.description,
    required this.icon,
    required this.sfx,
  });
}

/// A recipe specifically processed by an artisan machine.
class ArtisanRecipe {
  final ArtisanMachineType machineType;
  final String inputItemId;
  final int inputCount;
  final String? secondInputId;
  final int secondInputCount;
  final GameItem outputItem;
  final int outputCount;
  final double durationHours;

  const ArtisanRecipe({
    required this.machineType,
    required this.inputItemId,
    this.inputCount = 1,
    this.secondInputId,
    this.secondInputCount = 1,
    required this.outputItem,
    this.outputCount = 1,
    required this.durationHours,
  });

  static const List<ArtisanRecipe> allArtisanRecipes = [
    // --- Loom (Tear de Madeira) ---
    ArtisanRecipe(
      machineType: ArtisanMachineType.loom,
      inputItemId: 'produce_wool',
      outputItem: GameItem.fineYarn,
      durationHours: 4.0,
    ),
    ArtisanRecipe(
      machineType: ArtisanMachineType.loom,
      inputItemId: 'produce_floating_wool',
      outputItem: GameItem.celestialCloth,
      durationHours: 6.0,
    ),

    // --- Oak Cask (Barril de Carvalho) ---
    ArtisanRecipe(
      machineType: ArtisanMachineType.oakCask,
      inputItemId: 'produce_milk',
      outputItem: GameItem.curedCheese,
      durationHours: 6.0,
    ),
    ArtisanRecipe(
      machineType: ArtisanMachineType.oakCask,
      inputItemId: 'produce_amber_egg',
      outputItem: GameItem.mysticGoldenCheese,
      durationHours: 8.0,
    ),
    ArtisanRecipe(
      machineType: ArtisanMachineType.oakCask,
      inputItemId: 'crop_dew_blossom',
      outputItem: GameItem.lunarWine,
      durationHours: 8.0,
    ),

    // --- Runic Furnace (Fornalha Rúnica) ---
    ArtisanRecipe(
      machineType: ArtisanMachineType.runicFurnace,
      inputItemId: 'ore_copper',
      inputCount: 2,
      secondInputId: 'ore_iron',
      secondInputCount: 2,
      outputItem: GameItem.runicBronzeIngot,
      durationHours: 5.0,
    ),
    ArtisanRecipe(
      machineType: ArtisanMachineType.runicFurnace,
      inputItemId: 'ore_gold',
      inputCount: 2,
      secondInputId: 'gem_lunar_crystal',
      secondInputCount: 1,
      outputItem: GameItem.astralAmalgam,
      durationHours: 7.0,
    ),

    // --- Preserves Jar (Pote de Conservas) ---
    ArtisanRecipe(
      machineType: ArtisanMachineType.preservesJar,
      inputItemId: 'produce_truffle',
      outputItem: GameItem.truffleOil,
      durationHours: 5.0,
    ),
    ArtisanRecipe(
      machineType: ArtisanMachineType.preservesJar,
      inputItemId: 'crop_turnip',
      outputItem: GameItem.pickledTurnip,
      durationHours: 3.0,
    ),
    ArtisanRecipe(
      machineType: ArtisanMachineType.preservesJar,
      inputItemId: 'crop_golden_wheat',
      outputItem: GameItem.mysticJam,
      durationHours: 4.0,
    ),
    ArtisanRecipe(
      machineType: ArtisanMachineType.preservesJar,
      inputItemId: 'crop_wheat',
      outputItem: GameItem.mysticJam,
      durationHours: 4.0,
    ),
  ];

  static ArtisanRecipe? findRecipe(
    ArtisanMachineType type,
    String primaryItemId, [
    String? secondaryItemId,
  ]) {
    for (final r in allArtisanRecipes) {
      if (r.machineType != type) continue;
      if (r.inputItemId == primaryItemId) {
        if (r.secondInputId != null) {
          if (r.secondInputId == secondaryItemId) return r;
        } else {
          return r;
        }
      } else if (r.secondInputId == primaryItemId && secondaryItemId == r.inputItemId) {
        return r;
      }
    }
    return null;
  }
}

/// An active artisan machine placed on the farm or in the cabin.
class ArtisanMachine {
  final String id;
  final ArtisanMachineType type;
  Vector2 position;

  String? inputItemId;
  int inputCount = 0;
  String? secondInputId;
  int secondInputCount = 0;

  GameItem? resultItem;
  int resultCount = 0;

  double hoursRemaining = 0.0;
  bool isProcessing = false;

  ArtisanMachine({
    required this.id,
    required this.type,
    Vector2? position,
  }) : position = position ?? Vector2.zero();

  bool get isReady => isProcessing && hoursRemaining <= 0.0 && resultItem != null;

  double get progressPercentage {
    if (!isProcessing) return 0.0;
    final recipe = ArtisanRecipe.findRecipe(type, inputItemId ?? '', secondInputId);
    if (recipe == null) return 1.0;
    final total = recipe.durationHours;
    if (total <= 0) return 1.0;
    final done = total - hoursRemaining;
    return (done / total).clamp(0.0, 1.0);
  }

  bool canAccept(String itemId, [String? secondItemId]) {
    if (isProcessing) return false;
    final recipe = ArtisanRecipe.findRecipe(type, itemId, secondItemId);
    return recipe != null;
  }

  bool startProcessing(
    String itemId, {
    int count = 1,
    String? secondItemId,
    int secondCount = 0,
  }) {
    if (isProcessing) return false;
    final recipe = ArtisanRecipe.findRecipe(type, itemId, secondItemId);
    if (recipe == null) return false;

    inputItemId = itemId;
    inputCount = count;
    secondInputId = secondItemId;
    secondInputCount = secondCount;
    resultItem = recipe.outputItem;
    resultCount = recipe.outputCount;
    hoursRemaining = recipe.durationHours;
    isProcessing = true;
    return true;
  }

  GameItem? harvest() {
    if (!isReady || resultItem == null) return null;
    final harvested = resultItem;
    inputItemId = null;
    inputCount = 0;
    secondInputId = null;
    secondInputCount = 0;
    resultItem = null;
    resultCount = 0;
    hoursRemaining = 0.0;
    isProcessing = false;
    return harvested;
  }

  void advanceTime(double hours) {
    if (!isProcessing) return;
    hoursRemaining -= hours;
    if (hoursRemaining < 0) hoursRemaining = 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'x': position.x,
      'y': position.y,
      'inputItemId': inputItemId,
      'inputCount': inputCount,
      'secondInputId': secondInputId,
      'secondInputCount': secondInputCount,
      'resultItemId': resultItem?.id,
      'resultCount': resultCount,
      'hoursRemaining': hoursRemaining,
      'isProcessing': isProcessing,
    };
  }

  factory ArtisanMachine.fromJson(Map<String, dynamic> json) {
    final typeIdx = json['type'] as int? ?? 0;
    final machine = ArtisanMachine(
      id: json['id'] as String? ?? 'machine_${DateTime.now().millisecondsSinceEpoch}',
      type: ArtisanMachineType.values[typeIdx.clamp(0, ArtisanMachineType.values.length - 1)],
      position: Vector2(
        (json['x'] as num?)?.toDouble() ?? 0.0,
        (json['y'] as num?)?.toDouble() ?? 0.0,
      ),
    );

    machine.inputItemId = json['inputItemId'] as String?;
    machine.inputCount = json['inputCount'] as int? ?? 0;
    machine.secondInputId = json['secondInputId'] as String?;
    machine.secondInputCount = json['secondInputCount'] as int? ?? 0;
    machine.resultCount = json['resultCount'] as int? ?? 0;
    machine.hoursRemaining = (json['hoursRemaining'] as num?)?.toDouble() ?? 0.0;
    machine.isProcessing = json['isProcessing'] as bool? ?? false;

    final rId = json['resultItemId'] as String?;
    if (rId != null) {
      for (final r in ArtisanRecipe.allArtisanRecipes) {
        if (r.outputItem.id == rId) {
          machine.resultItem = r.outputItem;
          break;
        }
      }
    }

    return machine;
  }
}

/// Central manager for all rustic artisan machines on the farm.
class ArtisanManager extends ChangeNotifier {
  final List<ArtisanMachine> machines = [];

  ArtisanManager() {
    _initializeDefaultMachines();
  }

  void _initializeDefaultMachines() {
    // Farm starts with 1 of each machine near the cabin and barn
    machines.add(ArtisanMachine(
      id: 'default_loom_1',
      type: ArtisanMachineType.loom,
      position: Vector2(240, 220),
    ));
    machines.add(ArtisanMachine(
      id: 'default_cask_1',
      type: ArtisanMachineType.oakCask,
      position: Vector2(280, 220),
    ));
    machines.add(ArtisanMachine(
      id: 'default_furnace_1',
      type: ArtisanMachineType.runicFurnace,
      position: Vector2(320, 220),
    ));
    machines.add(ArtisanMachine(
      id: 'default_jar_1',
      type: ArtisanMachineType.preservesJar,
      position: Vector2(360, 220),
    ));
  }

  ArtisanMachine addMachine(ArtisanMachineType type, [Vector2? pos]) {
    final newMachine = ArtisanMachine(
      id: 'machine_${DateTime.now().millisecondsSinceEpoch}_${machines.length}',
      type: type,
      position: pos ?? Vector2(200.0 + machines.length * 36.0, 260.0),
    );
    machines.add(newMachine);
    notifyListeners();
    return newMachine;
  }

  void advanceHours(double hours) {
    for (final m in machines) {
      m.advanceTime(hours);
    }
    notifyListeners();
  }

  void onNewDay() {
    // Advances processing by 10 overnight hours
    advanceHours(10.0);
  }

  bool tryInsertItem(
    ArtisanMachine machine,
    InventoryState inventory,
    String primaryItemId, [
    String? secondaryItemId,
  ]) {
    final recipe = ArtisanRecipe.findRecipe(machine.type, primaryItemId, secondaryItemId);
    if (recipe == null) return false;

    // Check primary
    if (inventory.countOf(recipe.inputItemId) < recipe.inputCount) return false;
    // Check secondary if needed
    if (recipe.secondInputId != null) {
      if (inventory.countOf(recipe.secondInputId!) < recipe.secondInputCount) {
        return false;
      }
    }

    // Consume items
    final consumed = <String, int>{
      recipe.inputItemId: recipe.inputCount,
    };
    if (recipe.secondInputId != null) {
      consumed[recipe.secondInputId!] = recipe.secondInputCount;
    }
    inventory.consumeIngredients(consumed);

    // Start machine
    machine.startProcessing(
      recipe.inputItemId,
      count: recipe.inputCount,
      secondItemId: recipe.secondInputId,
      secondCount: recipe.secondInputCount,
    );
    notifyListeners();
    return true;
  }

  GameItem? tryHarvest(ArtisanMachine machine, InventoryState inventory) {
    if (!machine.isReady) return null;
    final item = machine.harvest();
    if (item != null) {
      inventory.addItem(item, count: machine.resultCount > 0 ? machine.resultCount : 1);
      notifyListeners();
    }
    return item;
  }

  List<Map<String, dynamic>> toJsonList() {
    return machines.map((m) => m.toJson()).toList();
  }

  void loadFromJsonList(List<dynamic> jsonList) {
    machines.clear();
    for (final entry in jsonList) {
      if (entry is Map<String, dynamic>) {
        machines.add(ArtisanMachine.fromJson(entry));
      }
    }
    if (machines.isEmpty) {
      _initializeDefaultMachines();
    }
    notifyListeners();
  }
}
