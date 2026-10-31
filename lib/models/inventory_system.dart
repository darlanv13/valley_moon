import 'package:flutter/foundation.dart';
import 'time_system.dart';

enum ItemCategory {
  tool,
  seed,
  material,
  consumable,
  craftable,
  potion,
}

/// Represents an item definition in Valley Moon.
class GameItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final ItemCategory category;
  final int sellPrice;
  final double energyRestore;
  final double healthRestore;
  final FarmerTool? associatedTool;

  const GameItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.sellPrice = 10,
    this.energyRestore = 0.0,
    this.healthRestore = 0.0,
    this.associatedTool,
  });

  // Pre-defined Registry of Items
  static const GameItem hoe = GameItem(
    id: 'tool_hoe',
    name: 'Enxada de Ferro',
    description: 'Enxada forjada pelo ferreiro da vila. Ara a terra para o plantio.',
    icon: '⛏️',
    category: ItemCategory.tool,
    associatedTool: FarmerTool.hoe,
  );

  static const GameItem wateringCan = GameItem(
    id: 'tool_water',
    name: 'Regador de Madeira',
    description: 'Regador rústico com bocal de cobre para nutrir a terra.',
    icon: '💧',
    category: ItemCategory.tool,
    associatedTool: FarmerTool.wateringCan,
  );

  static const GameItem sickle = GameItem(
    id: 'tool_sickle',
    name: 'Foice Curva',
    description: 'Corta mato alto e colhe feixes de trigo dourado.',
    icon: '🌾',
    category: ItemCategory.tool,
    associatedTool: FarmerTool.sickle,
  );

  static const GameItem axe = GameItem(
    id: 'tool_axe',
    name: 'Machado do Lenhador',
    description: 'Machado pesado de aço e freixo para rachar lenha e tocos.',
    icon: '🪓',
    category: ItemCategory.tool,
    associatedTool: FarmerTool.axe,
  );

  static const GameItem pickaxe = GameItem(
    id: 'tool_pickaxe',
    name: 'Picareta Mineral',
    description: 'Picareta de ferro duro para britar pedras e minérios.',
    icon: '⚒️',
    category: ItemCategory.tool,
    associatedTool: FarmerTool.pickaxe,
  );

  static const GameItem sword = GameItem(
    id: 'tool_sword',
    name: 'Espada de Ferro',
    description: 'Lâmina rústica herdada do avô para afastar feras da floresta.',
    icon: '⚔️',
    category: ItemCategory.tool,
    associatedTool: FarmerTool.sword,
  );

  // Materials
  static const GameItem wood = GameItem(
    id: 'mat_wood',
    name: 'Madeira de Carvalho',
    description: 'Troncos nobres cortados na floresta da fazenda.',
    icon: '🪵',
    category: ItemCategory.material,
    sellPrice: 5,
  );

  static const GameItem stone = GameItem(
    id: 'mat_stone',
    name: 'Pedra Bruta',
    description: 'Bloco de rocha colhido no campo para construções.',
    icon: '🪨',
    category: ItemCategory.material,
    sellPrice: 4,
  );

  // Crops
  static const GameItem turnip = GameItem(
    id: 'crop_turnip',
    name: 'Nabo Rústico',
    description: 'Raiz fresca e crocante, excelente para sopas campestres.',
    icon: '🥕',
    category: ItemCategory.consumable,
    sellPrice: 35,
    energyRestore: 15.0,
  );

  static const GameItem wheat = GameItem(
    id: 'crop_wheat',
    name: 'Trigo da Roça',
    description: 'Grãos secos de trigo prontos para farinha no moinho de pedra.',
    icon: '🌾',
    category: ItemCategory.material,
    sellPrice: 50,
  );

  static const GameItem screamRoot = GameItem(
    id: 'crop_scream_root',
    name: 'Raiz-Gritante',
    description: 'Mandrágora mística que sussurra encantamentos noturnos.',
    icon: '🔮',
    category: ItemCategory.material,
    sellPrice: 160,
  );

  static const GameItem dewBlossom = GameItem(
    id: 'crop_dew_blossom',
    name: 'Flor-de-Orvalho',
    description: 'Pétalas bioluminescentes que destilam lágrimas da lua.',
    icon: '💠',
    category: ItemCategory.material,
    sellPrice: 220,
  );

  static const GameItem goldenWheat = GameItem(
    id: 'crop_golden_wheat',
    name: 'Trigo-Dourado',
    description: 'Espigas raras que brilham sob a luz do luar.',
    icon: '✨',
    category: ItemCategory.material,
    sellPrice: 350,
  );

  // Seeds
  static const GameItem seedsTurnip = GameItem(
    id: 'seed_turnip',
    name: 'Semente de Nabo',
    description: 'Bolsa de sementes comuns para solo arado.',
    icon: '🌱',
    category: ItemCategory.seed,
    associatedTool: FarmerTool.seedsTurnip,
  );

  static const GameItem seedsWheat = GameItem(
    id: 'seed_wheat',
    name: 'Semente de Trigo',
    description: 'Grãos selecionados para plantio na primavera e verão.',
    icon: '🌰',
    category: ItemCategory.seed,
    associatedTool: FarmerTool.seedsWheat,
  );

  static const GameItem seedsScreamRoot = GameItem(
    id: 'seed_scream_root',
    name: 'Semente de Raiz-Gritante',
    description: 'Sementes arcanas: germinam apenas à noite ou sob Lua Cheia.',
    icon: '🔮',
    category: ItemCategory.seed,
    associatedTool: FarmerTool.seedsScreamRoot,
  );

  static const GameItem seedsDewBlossom = GameItem(
    id: 'seed_dew_blossom',
    name: 'Semente de Flor-de-Orvalho',
    description: 'Gemas azuis que demandam orvalho puro da madrugada.',
    icon: '💠',
    category: ItemCategory.seed,
    associatedTool: FarmerTool.seedsDewBlossom,
  );

  static const GameItem seedsGoldenWheat = GameItem(
    id: 'seed_golden_wheat',
    name: 'Semente de Trigo-Dourado',
    description: 'Raridade estelar colhida durante o alinhamento da Lua de Sangue.',
    icon: '✨',
    category: ItemCategory.seed,
    associatedTool: FarmerTool.seedsGoldenWheat,
  );

  // Alchemy Potions
  static const GameItem healthPotion = GameItem(
    id: 'pot_health',
    name: 'Poção de Cura da Floresta',
    description: 'Infusão revigorante de ervas e Raiz-Gritante. Restaura 50 HP.',
    icon: '🧪',
    category: ItemCategory.potion,
    sellPrice: 120,
    healthRestore: 50.0,
  );

  static const GameItem vigorElixir = GameItem(
    id: 'pot_vigor',
    name: 'Elixir de Vigor Lunar',
    description: 'Destilado de Flor-de-Orvalho. Restaura 70 pontos de Energia.',
    icon: '🍶',
    category: ItemCategory.potion,
    sellPrice: 150,
    energyRestore: 70.0,
  );

  static const GameItem moonBait = GameItem(
    id: 'pot_moon_bait',
    name: 'Isca Encantada da Lua',
    description: 'Isca rúnica que atrai peixes noturnos raros nos lagos.',
    icon: '🪱',
    category: ItemCategory.potion,
    sellPrice: 80,
  );

  static const GameItem lampOil = GameItem(
    id: 'pot_lamp_oil',
    name: 'Óleo de Lamparina Élfica',
    description: 'Óleo alquímico que dobra o raio de visão na escuridão por 1 dia.',
    icon: '🪔',
    category: ItemCategory.potion,
    sellPrice: 180,
  );

  // Earth Magic & Farm Craftables
  static const GameItem woodFence = GameItem(
    id: 'craft_fence',
    name: 'Cerca de Madeira',
    description: 'Cerca rústica de estacas de freixo para delimitar canteiros.',
    icon: '🪵',
    category: ItemCategory.craftable,
  );

  static const GameItem woodChest = GameItem(
    id: 'craft_chest',
    name: 'Baú Rústico do Avô',
    description: 'Baú de madeira reforçada com ferragens para guardar itens.',
    icon: '📦',
    category: ItemCategory.craftable,
  );

  static const GameItem scarecrow = GameItem(
    id: 'craft_scarecrow',
    name: 'Espantalho Vivo',
    description: 'Totem de palha e runas: protege raio de 5x5 contra pragas e corvos.',
    icon: '🧙',
    category: ItemCategory.craftable,
    associatedTool: FarmerTool.placeScarecrow,
  );

  static const GameItem rainTotem = GameItem(
    id: 'craft_rain_totem',
    name: 'Totem de Chuva Rúnico',
    description: 'Monólito entalhado: rega automaticamente área de 3x3 todas as manhãs.',
    icon: '🗿',
    category: ItemCategory.craftable,
    associatedTool: FarmerTool.placeRainTotem,
  );
}

/// A stack of items in an inventory slot.
class ItemStack {
  final GameItem item;
  int count;

  ItemStack({required this.item, this.count = 1});
}

/// Crafting and Alchemy Recipe.
class Recipe {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Map<String, int> ingredients; // Item ID -> Required quantity
  final GameItem result;
  final int resultCount;
  final bool isAlchemy; // True = Caldeirão de Ferro; False = Crafting Rústico

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.ingredients,
    required this.result,
    this.resultCount = 1,
    this.isAlchemy = false,
  });

  // Predefined Recipes
  static const List<Recipe> allRecipes = [
    // --- Crafting Rústico ---
    Recipe(
      id: 'rec_fence',
      name: 'Cerca de Madeira (x4)',
      description: 'Entalhe estacas pontiagudas de carvalho.',
      icon: '🪵',
      ingredients: {'mat_wood': 2},
      result: GameItem.woodFence,
      resultCount: 4,
      isAlchemy: false,
    ),
    Recipe(
      id: 'rec_chest',
      name: 'Baú Rústico de Madeira',
      description: 'Caixa robusta de tábuas e rebites de pedra.',
      icon: '📦',
      ingredients: {'mat_wood': 20, 'mat_stone': 8},
      result: GameItem.woodChest,
      resultCount: 1,
      isAlchemy: false,
    ),
    Recipe(
      id: 'rec_scarecrow',
      name: 'Espantalho Vivo',
      description: 'Construa um guardião rúnico com olhos de âmbar.',
      icon: '🧙',
      ingredients: {'mat_wood': 15, 'crop_turnip': 2},
      result: GameItem.scarecrow,
      resultCount: 1,
      isAlchemy: false,
    ),
    Recipe(
      id: 'rec_rain_totem',
      name: 'Totem de Chuva',
      description: 'Monólito entalhado com glifos de água e madeira.',
      icon: '🗿',
      ingredients: {'mat_stone': 25, 'mat_wood': 10},
      result: GameItem.rainTotem,
      resultCount: 1,
      isAlchemy: false,
    ),

    // --- Caldeirão de Alquimia de Ferro ---
    Recipe(
      id: 'rec_pot_health',
      name: 'Poção de Cura da Floresta',
      description: 'Cozinhe Raiz-Gritante e seiva de madeira para sanar feridas.',
      icon: '🧪',
      ingredients: {'crop_scream_root': 1, 'mat_wood': 2},
      result: GameItem.healthPotion,
      resultCount: 1,
      isAlchemy: true,
    ),
    Recipe(
      id: 'rec_pot_vigor',
      name: 'Elixir de Vigor Lunar',
      description: 'Misture pétalas de Flor-de-Orvalho e raiz de Nabo.',
      icon: '🍶',
      ingredients: {'crop_dew_blossom': 1, 'crop_turnip': 1},
      result: GameItem.vigorElixir,
      resultCount: 1,
      isAlchemy: true,
    ),
    Recipe(
      id: 'rec_pot_bait',
      name: 'Isca Encantada da Lua (x5)',
      description: 'Moa grãos de Trigo-Dourado e Raiz-Gritante.',
      icon: '🪱',
      ingredients: {'crop_golden_wheat': 1, 'crop_scream_root': 1},
      result: GameItem.moonBait,
      resultCount: 5,
      isAlchemy: true,
    ),
    Recipe(
      id: 'rec_pot_oil',
      name: 'Óleo de Lamparina Élfica',
      description: 'Destile Flor-de-Orvalho em pó de pedra polida.',
      icon: '🪔',
      ingredients: {'crop_dew_blossom': 1, 'mat_stone': 2},
      result: GameItem.lampOil,
      resultCount: 1,
      isAlchemy: true,
    ),
  ];
}

/// Player Inventory State Manager.
class InventoryState extends ChangeNotifier {
  // Hotbar: 10 quick slots (indices 0 to 9)
  final List<ItemStack?> hotbar = List.filled(10, null);

  // Backpack: 24 slots (indices 0 to 23)
  final List<ItemStack?> backpack = List.filled(24, null);

  int selectedHotbarIndex = 0;

  InventoryState() {
    _initializeStarterKit();
  }

  void _initializeStarterKit() {
    // Fill hotbar with initial tools
    hotbar[0] = ItemStack(item: GameItem.hoe);
    hotbar[1] = ItemStack(item: GameItem.wateringCan);
    hotbar[2] = ItemStack(item: GameItem.sickle);
    hotbar[3] = ItemStack(item: GameItem.axe);
    hotbar[4] = ItemStack(item: GameItem.pickaxe);
    hotbar[5] = ItemStack(item: GameItem.sword);
    hotbar[6] = ItemStack(item: GameItem.seedsTurnip, count: 8);
    hotbar[7] = ItemStack(item: GameItem.seedsScreamRoot, count: 4);
    hotbar[8] = ItemStack(item: GameItem.seedsDewBlossom, count: 3);
    hotbar[9] = ItemStack(item: GameItem.scarecrow, count: 1);

    // Starter backpack items
    backpack[0] = ItemStack(item: GameItem.wood, count: 30);
    backpack[1] = ItemStack(item: GameItem.stone, count: 20);
    backpack[2] = ItemStack(item: GameItem.turnip, count: 4);
    backpack[3] = ItemStack(item: GameItem.screamRoot, count: 2);
    backpack[4] = ItemStack(item: GameItem.dewBlossom, count: 2);
    backpack[5] = ItemStack(item: GameItem.goldenWheat, count: 2);
    backpack[6] = ItemStack(item: GameItem.seedsGoldenWheat, count: 2);
    backpack[7] = ItemStack(item: GameItem.rainTotem, count: 1);
  }

  ItemStack? get selectedHotbarItem => hotbar[selectedHotbarIndex];

  void selectHotbarSlot(int index) {
    if (index >= 0 && index < 10) {
      selectedHotbarIndex = index;
      notifyListeners();
    }
  }

  int getItemCount(String itemId) {
    var total = 0;
    for (final slot in [...hotbar, ...backpack]) {
      if (slot != null && slot.item.id == itemId) {
        total += slot.count;
      }
    }
    return total;
  }

  bool hasIngredients(Map<String, int> required) {
    for (final entry in required.entries) {
      if (getItemCount(entry.key) < entry.value) {
        return false;
      }
    }
    return true;
  }

  bool consumeIngredients(Map<String, int> required) {
    if (!hasIngredients(required)) return false;

    for (final entry in required.entries) {
      var remaining = entry.value;

      // Consume from backpack first, then hotbar
      for (final slot in [...backpack, ...hotbar]) {
        if (slot != null && slot.item.id == entry.key) {
          if (slot.count >= remaining) {
            slot.count -= remaining;
            remaining = 0;
            break;
          } else {
            remaining -= slot.count;
            slot.count = 0;
          }
        }
      }

      // Clean up empty slots
      for (var i = 0; i < backpack.length; i++) {
        if (backpack[i]?.count == 0) backpack[i] = null;
      }
      for (var i = 0; i < hotbar.length; i++) {
        if (hotbar[i]?.count == 0) hotbar[i] = null;
      }
    }

    notifyListeners();
    return true;
  }

  bool addItem(GameItem item, {int count = 1}) {
    // 1. Try to stack into existing hotbar slot
    for (final slot in hotbar) {
      if (slot != null && slot.item.id == item.id) {
        slot.count += count;
        notifyListeners();
        return true;
      }
    }

    // 2. Try to stack into existing backpack slot
    for (final slot in backpack) {
      if (slot != null && slot.item.id == item.id) {
        slot.count += count;
        notifyListeners();
        return true;
      }
    }

    // 3. Find first empty hotbar slot
    for (var i = 0; i < hotbar.length; i++) {
      if (hotbar[i] == null) {
        hotbar[i] = ItemStack(item: item, count: count);
        notifyListeners();
        return true;
      }
    }

    // 4. Find first empty backpack slot
    for (var i = 0; i < backpack.length; i++) {
      if (backpack[i] == null) {
        backpack[i] = ItemStack(item: item, count: count);
        notifyListeners();
        return true;
      }
    }

    return false; // Inventory full
  }

  bool craft(Recipe recipe) {
    if (!hasIngredients(recipe.ingredients)) return false;
    if (!consumeIngredients(recipe.ingredients)) return false;

    addItem(recipe.result, count: recipe.resultCount);
    notifyListeners();
    return true;
  }
}
