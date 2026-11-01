import 'package:flutter/foundation.dart';
import 'time_system.dart';

enum ItemCategory {
  tool,
  seed,
  material,
  consumable,
  craftable,
  potion,
  fish,
  equipment,
  ore,
}

enum EquipmentSlot { weapon, boots, ring }

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
  final int attackDamage;
  final int defense;
  final EquipmentSlot? equipmentSlot;
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
    this.attackDamage = 0,
    this.defense = 0,
    this.equipmentSlot,
    this.associatedTool,
  });

  // Pre-defined Registry of Items
  static const GameItem hoe = GameItem(
    id: 'tool_hoe',
    name: 'Enxada de Ferro',
    description:
        'Enxada forjada pelo ferreiro da vila. Ara a terra para o plantio.',
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
    description:
        'Lâmina rústica herdada do avô para afastar feras da floresta.',
    icon: '⚔️',
    category: ItemCategory.tool,
    associatedTool: FarmerTool.sword,
    attackDamage: 8,
  );

  static const GameItem fishingRod = GameItem(
    id: 'tool_rod',
    name: 'Vara de Pescar de Bambu',
    description:
        'Vara rústica com carretel de madeira e linha de seda do vale.',
    icon: '🎣',
    category: ItemCategory.tool,
    associatedTool: FarmerTool.fishingRod,
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
    description:
        'Grãos secos de trigo prontos para farinha no moinho de pedra.',
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
    description:
        'Raridade estelar colhida durante o alinhamento da Lua de Sangue.',
    icon: '✨',
    category: ItemCategory.seed,
    associatedTool: FarmerTool.seedsGoldenWheat,
  );

  // Alchemy Potions
  static const GameItem healthPotion = GameItem(
    id: 'pot_health',
    name: 'Poção de Cura da Floresta',
    description:
        'Infusão revigorante de ervas e Raiz-Gritante. Restaura 50 HP.',
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
    description:
        'Óleo alquímico que dobra o raio de visão na escuridão por 1 dia.',
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
    description:
        'Totem de palha e runas: protege raio de 5x5 contra pragas e corvos.',
    icon: '🧙',
    category: ItemCategory.craftable,
    associatedTool: FarmerTool.placeScarecrow,
  );

  static const GameItem rainTotem = GameItem(
    id: 'craft_rain_totem',
    name: 'Totem de Chuva Rúnico',
    description:
        'Monólito entalhado: rega automaticamente área de 3x3 todas as manhãs.',
    icon: '🗿',
    category: ItemCategory.craftable,
    associatedTool: FarmerTool.placeRainTotem,
  );

  // Animal Produce
  static const GameItem egg = GameItem(
    id: 'produce_egg',
    name: 'Ovo Caipira',
    description: 'Ovo fresco colhido de galinhas bem cuidadas.',
    icon: '🥚',
    category: ItemCategory.consumable,
    sellPrice: 40,
    energyRestore: 15.0,
  );

  static const GameItem milk = GameItem(
    id: 'produce_milk',
    name: 'Leite Fresco',
    description: 'Leite cremoso ordenhado ao amanhecer.',
    icon: '🥛',
    category: ItemCategory.consumable,
    sellPrice: 75,
    energyRestore: 25.0,
  );

  static const GameItem wool = GameItem(
    id: 'produce_wool',
    name: 'Lã Macia',
    description: 'Fardo de lã macia tosquiada com carinho.',
    icon: '🧶',
    category: ItemCategory.material,
    sellPrice: 90,
  );

  static const GameItem truffle = GameItem(
    id: 'produce_truffle',
    name: 'Trufa da Floresta',
    description: 'Fungo aromático desenterrado por porcos em solo fértil.',
    icon: '🍄',
    category: ItemCategory.consumable,
    sellPrice: 150,
    energyRestore: 30.0,
  );

  // Mystical Animal Produce
  static const GameItem amberEgg = GameItem(
    id: 'produce_amber_egg',
    name: 'Ovo de Âmbar Místico',
    description:
        'Ovo translúcido reluzente com calor solar puro da Galinha de Âmbar.',
    icon: '✨🥚',
    category: ItemCategory.consumable,
    sellPrice: 280,
    energyRestore: 50.0,
  );

  static const GameItem vitalDew = GameItem(
    id: 'produce_vital_dew',
    name: 'Orvalho Vital do Musgo',
    description: 'Gota etérea colhida do Bezerro-Musgo. Restaura 80 HP.',
    icon: '🌿💧',
    category: ItemCategory.potion,
    sellPrice: 320,
    healthRestore: 80.0,
  );

  static const GameItem floatingWool = GameItem(
    id: 'produce_floating_wool',
    name: 'Lã Flutuante Celeste',
    description: 'Lã levitante como brisa azulada da Ovelha-Nuvem.',
    icon: '☁️🧶',
    category: ItemCategory.material,
    sellPrice: 350,
  );

  // Fish Species
  static const GameItem brookTrout = GameItem(
    id: 'fish_brook_trout',
    name: 'Truta do Riacho',
    description:
        'Peixe ágil com manchas douradas e cobreadas que habita águas límpidas.',
    icon: '🐟',
    category: ItemCategory.fish,
    sellPrice: 65,
    energyRestore: 20.0,
  );

  static const GameItem pondTilapia = GameItem(
    id: 'fish_pond_tilapia',
    name: 'Tilápia da Lagoa',
    description: 'Peixe de escamas azuladas que nada em lagos serenos.',
    icon: '🐠',
    category: ItemCategory.fish,
    sellPrice: 75,
    energyRestore: 22.0,
  );

  static const GameItem pierCatfish = GameItem(
    id: 'fish_pier_catfish',
    name: 'Bagre do Píer',
    description: 'Peixe corpulento de bigodes longos encontrado perto do píer.',
    icon: '🐡',
    category: ItemCategory.fish,
    sellPrice: 95,
    energyRestore: 28.0,
  );

  static const GameItem nightEel = GameItem(
    id: 'fish_night_eel',
    name: 'Enguia Noturna',
    description: 'Enguia escura como a noite com barbatana amarela elétrica.',
    icon: '🐍',
    category: ItemCategory.fish,
    sellPrice: 140,
    energyRestore: 35.0,
  );

  // Legendary Fish Species
  static const GameItem phantomCatfish = GameItem(
    id: 'fish_phantom_catfish',
    name: 'Bagre-Fantasma [Lendário]',
    description:
        'Lenda das cavernas: peixe translúcido que só morde em noites de neblina.',
    icon: '👻🐟',
    category: ItemCategory.fish,
    sellPrice: 600,
    energyRestore: 80.0,
    healthRestore: 50.0,
  );

  static const GameItem astralCarp = GameItem(
    id: 'fish_astral_carp',
    name: 'Carpa Astral [Lendária]',
    description: 'Guardiã cósmica do lago da floresta sob a luz da Lua Cheia.',
    icon: '⭐🐟',
    category: ItemCategory.fish,
    sellPrice: 750,
    energyRestore: 100.0,
    healthRestore: 70.0,
  );

  static const GameItem moonlightSalmon = GameItem(
    id: 'fish_moonlight_salmon',
    name: 'Salmão do Luar [Lendário]',
    description: 'Salmão prateado que sobe as correntes sob o luar sereno.',
    icon: '🌙🐟',
    category: ItemCategory.fish,
    sellPrice: 850,
    energyRestore: 90.0,
    healthRestore: 60.0,
  );

  static const GameItem goldenSunfish = GameItem(
    id: 'fish_golden_sunfish',
    name: 'Peixe-Sol Dourado [Lendário]',
    description:
        'Criatura solar rara vista apenas em dias límpidos e quentes no píer.',
    icon: '☀️🐟',
    category: ItemCategory.fish,
    sellPrice: 1000,
    energyRestore: 120.0,
    healthRestore: 90.0,
  );

  // Mining Ores & Gems
  static const GameItem copperOre = GameItem(
    id: 'ore_copper',
    name: 'Minério de Cobre',
    description:
        'Nódulo avermelhado de cobre extraído das galerias superiores.',
    icon: '🟤',
    category: ItemCategory.ore,
    sellPrice: 15,
  );

  static const GameItem ironOre = GameItem(
    id: 'ore_iron',
    name: 'Minério de Ferro',
    description: 'Bloco denso de ferro das profundezas rochosas da mina.',
    icon: '⚪',
    category: ItemCategory.ore,
    sellPrice: 30,
  );

  static const GameItem silverOre = GameItem(
    id: 'ore_silver',
    name: 'Minério de Prata',
    description: 'Pepitas reluzentes de prata das fendas ancestrais.',
    icon: '🔘',
    category: ItemCategory.ore,
    sellPrice: 60,
  );

  static const GameItem goldOre = GameItem(
    id: 'ore_gold',
    name: 'Minério de Ouro',
    description: 'Minério brilhante extraído perto das câmaras de magma.',
    icon: '🟡',
    category: ItemCategory.ore,
    sellPrice: 100,
  );

  static const GameItem lunarCrystal = GameItem(
    id: 'gem_lunar_crystal',
    name: 'Cristal Lunar Puro',
    description: 'Gema bioluminescente rara que pulsa com a energia da Lua.',
    icon: '💎',
    category: ItemCategory.ore,
    sellPrice: 250,
  );

  static const List<GameItem> allOres = [
    copperOre,
    ironOre,
    silverOre,
    goldOre,
    lunarCrystal,
  ];

  static const GameItem caveGeode = GameItem(
    id: 'mat_geode',
    name: 'Geodo da Caverna',
    description:
        'Rocha esférica que esconde minérios preciosos em seu interior.',
    icon: '🪨',
    category: ItemCategory.material,
    sellPrice: 50,
  );

  // Refined Metal Bars (Kael's Forge)
  static const GameItem copperBar = GameItem(
    id: 'bar_copper',
    name: 'Barra de Cobre',
    description:
        'Lingote fundido de cobre para forjar ferramentas resistentes.',
    icon: '🧱',
    category: ItemCategory.material,
    sellPrice: 80,
  );

  static const GameItem ironBar = GameItem(
    id: 'bar_iron',
    name: 'Barra de Ferro',
    description: 'Barra forjada de ferro maciço para armas e reforços.',
    icon: '⛓️',
    category: ItemCategory.material,
    sellPrice: 150,
  );

  static const GameItem silverBar = GameItem(
    id: 'bar_silver',
    name: 'Barra de Prata',
    description:
        'Lingote puro de prata com propriedades místicas de purificação.',
    icon: '🪙',
    category: ItemCategory.material,
    sellPrice: 280,
  );

  static const GameItem goldBar = GameItem(
    id: 'bar_gold',
    name: 'Barra de Ouro',
    description: 'Barra reluzente de ouro nobre para obras de mestre.',
    icon: '🏆',
    category: ItemCategory.material,
    sellPrice: 450,
  );

  static const GameItem lunarIngot = GameItem(
    id: 'bar_lunar',
    name: 'Lingote Lunar Puro',
    description: 'Fusão sagrada de ouro, cristal lunar e lágrimas da noite.',
    icon: '✨🧱',
    category: ItemCategory.material,
    sellPrice: 900,
  );

  // Action RPG Weapons
  static const GameItem copperBlade = GameItem(
    id: 'weapon_copper_blade',
    name: 'Lâmina de Cobre',
    description:
        'Espada ágil forjada por Kael. Desfere cortes rápidos na caverna.',
    icon: '🗡️',
    category: ItemCategory.equipment,
    equipmentSlot: EquipmentSlot.weapon,
    attackDamage: 12,
    sellPrice: 180,
  );

  static const GameItem ironClaymore = GameItem(
    id: 'weapon_iron_claymore',
    name: 'Espadão de Ferro da Guarda',
    description:
        'Lâmina pesada com alto poder de corte e forte repulsão (*knockback*).',
    icon: '⚔️',
    category: ItemCategory.equipment,
    equipmentSlot: EquipmentSlot.weapon,
    attackDamage: 22,
    sellPrice: 380,
  );

  static const GameItem lunarCrescentBlade = GameItem(
    id: 'weapon_lunar_sword',
    name: 'Lâmina do Luar Carmesim',
    description:
        'Espada lendária forjada com cristal lunar. Dano massivo no escuro.',
    icon: '🌙⚔️',
    category: ItemCategory.equipment,
    equipmentSlot: EquipmentSlot.weapon,
    attackDamage: 45,
    sellPrice: 1200,
  );

  static const GameItem runicStaff = GameItem(
    id: 'weapon_runic_staff',
    name: 'Cajado de Runas Ancestrais',
    description:
        'Cajado entalhado que dispara projéteis de magia rúnica à distância.',
    icon: '🪄',
    category: ItemCategory.equipment,
    equipmentSlot: EquipmentSlot.weapon,
    attackDamage: 36,
    sellPrice: 950,
  );

  // Boots & Armor
  static const GameItem leatherBoots = GameItem(
    id: 'boots_leather',
    name: 'Botas de Couro Rústico',
    description:
        'Botas confortáveis. +2 Defesa e +10% de velocidade de movimento.',
    icon: '🥾',
    category: ItemCategory.equipment,
    equipmentSlot: EquipmentSlot.boots,
    defense: 2,
    sellPrice: 120,
  );

  static const GameItem minerBoots = GameItem(
    id: 'boots_miner',
    name: 'Botas de Ferro do Minerador',
    description:
        'Botas reforçadas. +5 Defesa e imunidade à lentidão de lama e lava.',
    icon: '👢',
    category: ItemCategory.equipment,
    equipmentSlot: EquipmentSlot.boots,
    defense: 5,
    sellPrice: 350,
  );

  static const GameItem featherBoots = GameItem(
    id: 'boots_feather',
    name: 'Botas de Pluma Celeste',
    description:
        'Tecidas com Lã Flutuante. +25% de velocidade e recarga rápida do Dash.',
    icon: '🪶🥾',
    category: ItemCategory.equipment,
    equipmentSlot: EquipmentSlot.boots,
    defense: 3,
    sellPrice: 600,
  );

  // Runic Rings
  static const GameItem vigorRing = GameItem(
    id: 'ring_vigor',
    name: 'Anel de Vigor da Terra',
    description:
        'Entalhado com runas verdes. +30 de Energia Máxima e regeneração.',
    icon: '💍',
    category: ItemCategory.equipment,
    equipmentSlot: EquipmentSlot.ring,
    defense: 1,
    sellPrice: 250,
  );

  static const GameItem moonflowerRing = GameItem(
    id: 'ring_moonflower',
    name: 'Anel da Flor Lunar',
    description:
        'Brilha nas profundezas da mina. +20 de Vida Máxima e +15% de Dano.',
    icon: '💠💍',
    category: ItemCategory.equipment,
    equipmentSlot: EquipmentSlot.ring,
    attackDamage: 4,
    defense: 2,
    sellPrice: 450,
  );

  static const GameItem thornsRing = GameItem(
    id: 'ring_thorns',
    name: 'Anel de Espinhos da Floresta',
    description:
        'Espinhos protetores que refletem 30% do dano sofrido de volta aos monstros.',
    icon: '🌿💍',
    category: ItemCategory.equipment,
    equipmentSlot: EquipmentSlot.ring,
    defense: 3,
    sellPrice: 500,
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
      description:
          'Cozinhe Raiz-Gritante e seiva de madeira para sanar feridas.',
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
    backpack[8] = ItemStack(item: GameItem.fishingRod, count: 1);
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

  int countOf(String itemId) {
    int total = 0;
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
