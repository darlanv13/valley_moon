import sys

with open('lib/models/inventory_system.dart', 'r', encoding='utf-8') as f:
    content = f.read()

stage8_items = '''  // --- Stage 8: Artisan Goods ---
  static const GameItem fineYarn = GameItem(
    id: 'artisan_fine_yarn',
    name: 'Fio de Lã Fina',
    description: 'Fio macio fiado no Tear de Madeira a partir de lã de ovelha.',
    icon: '🧵',
    category: ItemCategory.material,
    sellPrice: 180,
  );

  static const GameItem celestialCloth = GameItem(
    id: 'artisan_celestial_cloth',
    name: 'Tecido de Nuvem Celeste',
    description: 'Tecido etéreo e leve fiado a partir de Lã Flutuante.',
    icon: '🪽',
    category: ItemCategory.material,
    sellPrice: 650,
  );

  static const GameItem curedCheese = GameItem(
    id: 'artisan_cured_cheese',
    name: 'Queijo Curado da Fazenda',
    description: 'Queijo rústico artesanal envelhecido em barris de carvalho.',
    icon: '🧀',
    category: ItemCategory.consumable,
    sellPrice: 200,
    energyRestore: 45.0,
    healthRestore: 20.0,
  );

  static const GameItem mysticGoldenCheese = GameItem(
    id: 'artisan_mystic_cheese',
    name: 'Queijo Dourado do Luar',
    description: 'Iguaria celestial maturada com ovos de âmbar e leite fresco.',
    icon: '✨🧀',
    category: ItemCategory.consumable,
    sellPrice: 550,
    energyRestore: 100.0,
    healthRestore: 60.0,
  );

  static const GameItem lunarWine = GameItem(
    id: 'artisan_lunar_wine',
    name: 'Vinho Envelhecido do Luar',
    description: 'Bebida nobre fermentada e envelhecida em barris de carvalho.',
    icon: '🍷',
    category: ItemCategory.potion,
    sellPrice: 420,
    energyRestore: 80.0,
    healthRestore: 40.0,
  );

  static const GameItem mysticJam = GameItem(
    id: 'artisan_mystic_jam',
    name: 'Geleia Mística da Floresta',
    description: 'Compota artesanal conservada em pote de barro cozido.',
    icon: '🍯',
    category: ItemCategory.consumable,
    sellPrice: 160,
    energyRestore: 35.0,
  );

  static const GameItem truffleOil = GameItem(
    id: 'artisan_truffle_oil',
    name: 'Azeite Nobre de Trufa',
    description: 'Óleo aromático prensado e curado com trufas raras.',
    icon: '🫒',
    category: ItemCategory.potion,
    sellPrice: 480,
    energyRestore: 75.0,
    healthRestore: 50.0,
  );

  static const GameItem pickledTurnip = GameItem(
    id: 'artisan_pickles',
    name: 'Picles Rústicos de Nabo',
    description: 'Conservas crocantes preparadas em salmoura de carvalho.',
    icon: '🥒',
    category: ItemCategory.consumable,
    sellPrice: 90,
    energyRestore: 25.0,
  );

  static const GameItem runicBronzeIngot = GameItem(
    id: 'artisan_runic_bronze',
    name: 'Lingote de Bronze Rúnico',
    description: 'Liga metálica resistente forjada na Fornalha Rúnica com cobre e ferro.',
    icon: '🛡️',
    category: ItemCategory.material,
    sellPrice: 320,
  );

  static const GameItem astralAmalgam = GameItem(
    id: 'artisan_astral_amalgam',
    name: 'Amálgama Astral',
    description: 'Fusão sagrada de ouro reluzente e cristal lunar puro.',
    icon: '✨🪙',
    category: ItemCategory.material,
    sellPrice: 1100,
  );

  // --- Stage 8: Cooked Dishes (Wood Stove) ---
  static const GameItem turnipStew = GameItem(
    id: 'food_turnip_stew',
    name: 'Ensopado Rústico de Nabo',
    description: 'Prato quente fumegante feito no fogão à lenha. Restaura 45 Energia e 25 HP.',
    icon: '🍲',
    category: ItemCategory.consumable,
    sellPrice: 110,
    energyRestore: 45.0,
    healthRestore: 25.0,
  );

  static const GameItem goldenLoaf = GameItem(
    id: 'food_golden_loaf',
    name: 'Pão Dourado de Trigo',
    description: 'Pão caseiro fofo assado na brasa com trigo e leite. Restaura 60 Energia e 35 HP.',
    icon: '🍞',
    category: ItemCategory.consumable,
    sellPrice: 180,
    energyRestore: 60.0,
    healthRestore: 35.0,
  );

  static const GameItem moonberryPie = GameItem(
    id: 'food_moonberry_pie',
    name: 'Torta Silvestre do Luar',
    description: 'Torta doce aromática com Flor-de-Orvalho e ovos frescos. Restaura 90 Energia e 60 HP.',
    icon: '🥧',
    category: ItemCategory.consumable,
    sellPrice: 320,
    energyRestore: 90.0,
    healthRestore: 60.0,
  );

  static const GameItem amberOmelette = GameItem(
    id: 'food_amber_omelette',
    name: 'Omelete Solar de Âmbar',
    description: 'Omelete mística com Queijo Curado e Ovo de Âmbar. Restaura 140 Energia e 90 HP.',
    icon: '🍳',
    category: ItemCategory.consumable,
    sellPrice: 480,
    energyRestore: 140.0,
    healthRestore: 90.0,
  );

  // --- Stage 8: Special Items (Romance & Family) ---
  static const GameItem moonflowerAmulet = GameItem(
    id: 'gift_moonflower_amulet',
    name: 'Amuleto da Flor da Lua',
    description: 'Pingente entalhado com pétalas lunares e prata. Usado para propor casamento.',
    icon: '💍✨',
    category: ItemCategory.material,
    sellPrice: 500,
  );

  static const GameItem woodenRattle = GameItem(
    id: 'toy_wooden_rattle',
    name: 'Chocalho de Madeira do Avô',
    description: 'Brinquedo entalhado em carvalho com sementes sonoras para o berço.',
    icon: '🪇',
    category: ItemCategory.material,
    sellPrice: 80,
  );

  // --- Stage 8: Artisan Machinery Items ---
  static const GameItem loom = GameItem(
    id: 'craft_loom',
    name: 'Tear de Madeira',
    description: 'Maquinário de fiação para transformar lã em fios finos e tecidos celestes.',
    icon: '🧵',
    category: ItemCategory.craftable,
  );

  static const GameItem oakCask = GameItem(
    id: 'craft_cask',
    name: 'Barril de Carvalho',
    description: 'Barril rústico para curar queijos nobres e fermentar vinhos envelhecidos.',
    icon: '🪵',
    category: ItemCategory.craftable,
  );

  static const GameItem runicFurnace = GameItem(
    id: 'craft_runic_furnace',
    name: 'Fornalha Rúnica',
    description: 'Fornalha mágica que atinge altíssimas temperaturas para fundir ligas metálicas.',
    icon: '🔥',
    category: ItemCategory.craftable,
  );

  static const GameItem preservesJar = GameItem(
    id: 'craft_preserves_jar',
    name: 'Pote de Conservas de Cerâmica',
    description: 'Recipiente de barro cozido com tampa de cera para picles, geleias e azeites.',
    icon: '🏺',
    category: ItemCategory.craftable,
  );
'''

# Find end of GameItem class
target_str = "  static const GameItem thornsRing = GameItem(\n    id: 'ring_thorns',\n    name: 'Anel de Espinhos da Floresta',\n    description:\n        'Espinhos protetores que refletem 30% do dano sofrido de volta aos monstros.',\n    icon: '🌿💍',\n    category: ItemCategory.equipment,\n    equipmentSlot: EquipmentSlot.ring,\n    defense: 3,\n    sellPrice: 500,\n  );"

if target_str not in content:
    # Try normalized newlines
    target_str_crlf = target_str.replace('\n', '\r\n')
    if target_str_crlf in content:
        content = content.replace(target_str_crlf, target_str_crlf + '\r\n\r\n' + stage8_items.replace('\n', '\r\n'))
    else:
        print("Error: target_str not found!")
        sys.exit(1)
else:
    content = content.replace(target_str, target_str + '\n\n' + stage8_items)

# Add Stage 8 recipes to Recipe.allRecipes
stage8_recipes = '''    // --- Stage 8: Cozinha à Lenha (Culinária Rústica) ---
    Recipe(
      id: 'rec_food_turnip_stew',
      name: 'Ensopado de Nabo',
      description: 'Ferva 2 Nabos frescos na panela de ferro com lenha de carvalho.',
      icon: '🍲',
      ingredients: {'crop_turnip': 2, 'mat_wood': 1},
      result: GameItem.turnipStew,
      resultCount: 1,
      isAlchemy: false,
    ),
    Recipe(
      id: 'rec_food_golden_loaf',
      name: 'Pão Dourado de Trigo',
      description: 'Asse trigo moído com leite fresco no forno à lenha.',
      icon: '🍞',
      ingredients: {'crop_wheat': 2, 'produce_milk': 1},
      result: GameItem.goldenLoaf,
      resultCount: 1,
      isAlchemy: false,
    ),
    Recipe(
      id: 'rec_food_moonberry_pie',
      name: 'Torta Silvestre do Luar',
      description: 'Torta recheada com pétalas de Flor-de-Orvalho, trigo e ovo.',
      icon: '🥧',
      ingredients: {'crop_dew_blossom': 1, 'crop_wheat': 1, 'produce_egg': 1},
      result: GameItem.moonberryPie,
      resultCount: 1,
      isAlchemy: false,
    ),
    Recipe(
      id: 'rec_food_amber_omelette',
      name: 'Omelete Solar de Âmbar',
      description: 'Omelete divina com Queijo Curado e Ovo de Âmbar.',
      icon: '🍳',
      ingredients: {'produce_amber_egg': 1, 'artisan_cured_cheese': 1},
      result: GameItem.amberOmelette,
      resultCount: 1,
      isAlchemy: false,
    ),

    // --- Stage 8: Maquinário Rústico de Carpintaria ---
    Recipe(
      id: 'rec_craft_loom',
      name: 'Tear de Madeira',
      description: 'Construa um tear rústico com carvalho nobre e pedras polidas.',
      icon: '🧵',
      ingredients: {'mat_wood': 30, 'mat_stone': 15},
      result: GameItem.loom,
      resultCount: 1,
      isAlchemy: false,
    ),
    Recipe(
      id: 'rec_craft_cask',
      name: 'Barril de Carvalho',
      description: 'Monte um barril reforçado com tábuas e tiras de ferro.',
      icon: '🪵',
      ingredients: {'mat_wood': 25, 'bar_iron': 1},
      result: GameItem.oakCask,
      resultCount: 1,
      isAlchemy: false,
    ),
    Recipe(
      id: 'rec_craft_runic_furnace',
      name: 'Fornalha Rúnica',
      description: 'Fornalha de pedra maciça com glifos de fogo e cobre.',
      icon: '🔥',
      ingredients: {'mat_stone': 40, 'bar_copper': 2},
      result: GameItem.runicFurnace,
      resultCount: 1,
      isAlchemy: false,
    ),
    Recipe(
      id: 'rec_craft_preserves_jar',
      name: 'Pote de Conservas de Cerâmica',
      description: 'Pote de barro cozido com vedação de resina de madeira.',
      icon: '🏺',
      ingredients: {'mat_stone': 20, 'mat_wood': 10},
      result: GameItem.preservesJar,
      resultCount: 1,
      isAlchemy: false,
    ),
'''

recipe_target = "    Recipe(\n      id: 'rec_pot_oil',\n      name: 'Óleo de Lamparina Élfica',\n      description: 'Destile Flor-de-Orvalho em pó de pedra polida.',\n      icon: '🪔',\n      ingredients: {'crop_dew_blossom': 1, 'mat_stone': 2},\n      result: GameItem.lampOil,\n      resultCount: 1,\n      isAlchemy: true,\n    ),"

if recipe_target not in content:
    recipe_target_crlf = recipe_target.replace('\n', '\r\n')
    if recipe_target_crlf in content:
        content = content.replace(recipe_target_crlf, recipe_target_crlf + '\r\n' + stage8_recipes.replace('\n', '\r\n'))
    else:
        print("Error: recipe_target not found!")
        sys.exit(1)
else:
    content = content.replace(recipe_target, recipe_target + '\n' + stage8_recipes)

with open('lib/models/inventory_system.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Inventory updated successfully!")
