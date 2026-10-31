import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/combat_and_mining_system.dart';
import '../models/inventory_system.dart';

/// Rustic dialog for Kael's Anvil & Smelting Forge.
class ForgeDialog extends StatefulWidget {
  final ValleyMoonGame game;
  final VoidCallback onClose;

  const ForgeDialog({
    super.key,
    required this.game,
    required this.onClose,
  });

  @override
  State<ForgeDialog> createState() => _ForgeDialogState();
}

class _ForgeDialogState extends State<ForgeDialog> {
  int _selectedCategory = 0; // 0 = Fundição, 1 = Armas, 2 = Armaduras & Anéis
  late ForgeRecipe _selectedRecipe;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _selectedRecipe = _filteredRecipes.first;
    widget.game.playSFX(GameConstants.sfxWoodClick);
  }

  List<ForgeRecipe> get _filteredRecipes {
    switch (_selectedCategory) {
      case 0:
        return ForgeRecipe.allForgeRecipes
            .where((r) => r.id.startsWith('smelt_'))
            .toList();
      case 1:
        return ForgeRecipe.allForgeRecipes
            .where((r) => r.id.startsWith('forge_') && r.resultItem.category == ItemCategory.equipment && r.resultItem.equipmentSlot == EquipmentSlot.weapon)
            .toList();
      case 2:
      default:
        return ForgeRecipe.allForgeRecipes
            .where((r) => r.id.startsWith('forge_') && r.resultItem.category == ItemCategory.equipment && r.resultItem.equipmentSlot != EquipmentSlot.weapon)
            .toList();
    }
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _selectedCategory = index;
      _selectedRecipe = _filteredRecipes.first;
      _statusMessage = null;
    });
    widget.game.playSFX(GameConstants.sfxWoodClick);
  }

  void _forgeCurrentRecipe() {
    final inv = widget.game.inventory;
    final state = widget.game.gameState;

    if (_selectedRecipe.canCraft(inv, state.coins)) {
      final success = _selectedRecipe.craft(inv, state);
      if (success) {
        widget.game.playSFX(GameConstants.sfxForgeAnvil);
        setState(() {
          _statusMessage = '✨ ${_selectedRecipe.resultItem.name} forjado com perfeição!';
        });
      }
    } else {
      setState(() {
        _statusMessage = '❌ Materiais ou moedas insuficientes!';
      });
      widget.game.playSFX(GameConstants.sfxWoodClick);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.game.inventory, widget.game.gameState]),
      builder: (context, _) {
        final inv = widget.game.inventory;
        final state = widget.game.gameState;
        final recipes = _filteredRecipes;
        final canCraft = _selectedRecipe.canCraft(inv, state.coins);

        return Material(
          color: Colors.black54,
          child: Center(
            child: Container(
              width: 580,
              height: 330,
              decoration: BoxDecoration(
                color: GameConstants.parchmentLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameConstants.rusticWood, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black87,
                    offset: Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. Header Bar with Title and Close Button
                  _buildHeader(state),

                  // 2. Category Selector Tabs
                  _buildCategoryTabs(),

                  // 3. Main Content: Recipe List (Left) & Forge Details (Right)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Left: Recipe List
                          Expanded(
                            flex: 5,
                            child: _buildRecipeList(recipes, inv, state.coins),
                          ),

                          const SizedBox(width: 8),

                          // Vertical Wooden Divider
                          Container(
                            width: 3,
                            color: GameConstants.rusticWoodDark,
                          ),

                          const SizedBox(width: 8),

                          // Right: Selected Recipe Details & Action
                          Expanded(
                            flex: 6,
                            child: _buildRecipeDetails(canCraft, inv, state.coins),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Status Message Banner
                  if (_statusMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      color: GameConstants.rusticWoodDark,
                      child: Text(
                        _statusMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: GameConstants.fontPixel,
                          fontSize: 8,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(dynamic state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: GameConstants.rusticWood,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const Text('⚒️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FORJA DE KAEL & FUNDIÇÃO',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.parchmentLight,
                ),
              ),
              Text(
                'Funda minérios, forje lâminas pesadas e armaduras de ferro.',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 7,
                  color: Color(0xFFDCC8A0),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Player's Coins
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: GameConstants.rusticWoodDark,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.amber, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Text(
                  '${state.coins} Ouro',
                  style: const TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              widget.game.playSFX(GameConstants.sfxWoodClick);
              widget.onClose();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: GameConstants.rusticWoodDark,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: GameConstants.parchmentLight, width: 1),
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: GameConstants.parchmentLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      {'title': 'Fundição', 'icon': '🧱'},
      {'title': 'Armas', 'icon': '⚔️'},
      {'title': 'Equipamentos', 'icon': '🛡️'},
    ];

    return Container(
      color: GameConstants.rusticWoodDark,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: List.generate(categories.length, (idx) {
          final isSelected = _selectedCategory == idx;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => _onCategoryChanged(idx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? GameConstants.parchmentLight : GameConstants.rusticWood,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? Colors.amber : Colors.black45,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(categories[idx]['icon']!, style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(
                      categories[idx]['title']!,
                      style: TextStyle(
                        fontFamily: GameConstants.fontPixel,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? GameConstants.rusticWoodDark : GameConstants.parchmentLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecipeList(List<ForgeRecipe> recipes, InventoryState inv, int playerGold) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, idx) {
        final r = recipes[idx];
        final isSelected = r.id == _selectedRecipe.id;
        final craftable = r.canCraft(inv, playerGold);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRecipe = r;
              _statusMessage = null;
            });
            widget.game.playSFX(GameConstants.sfxWoodClick);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFDCC8A0)
                  : (craftable ? const Color(0xFFE8DCC2) : const Color(0xFFC7B693)),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? GameConstants.rusticWoodDark
                    : (craftable ? Colors.green[800]! : Colors.black26),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Text(r.icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.name,
                        style: const TextStyle(
                          fontFamily: GameConstants.fontPixel,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: GameConstants.rusticWoodDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '🪙 ${r.requiredGold} Ouro',
                        style: TextStyle(
                          fontFamily: GameConstants.fontPixel,
                          fontSize: 7,
                          color: playerGold >= r.requiredGold ? Colors.black87 : Colors.red[900],
                        ),
                      ),
                    ],
                  ),
                ),
                if (craftable)
                  const Text('✅', style: TextStyle(fontSize: 10))
                else
                  const Text('🔒', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeDetails(bool canCraft, InventoryState inv, int playerGold) {
    final r = _selectedRecipe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recipe Header (Icon + Name)
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: GameConstants.parchmentDark,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: GameConstants.rusticWood, width: 2),
              ),
              child: Center(
                child: Text(r.icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: const TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: GameConstants.rusticWoodDark,
                    ),
                  ),
                  Text(
                    r.description,
                    style: const TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 7,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Equipment Stats info (if applicable)
        if (r.resultItem.attackDamage > 0 || r.resultItem.defense > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0x334A3319),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                if (r.resultItem.attackDamage > 0) ...[
                  const Text('⚔️ Dano: ', style: TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, fontWeight: FontWeight.bold)),
                  Text('+${r.resultItem.attackDamage}', style: const TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                ],
                if (r.resultItem.defense > 0) ...[
                  const Text('🛡️ Defesa: ', style: TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, fontWeight: FontWeight.bold)),
                  Text('+${r.resultItem.defense}', style: const TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          ),

        const SizedBox(height: 6),

        const Text(
          'MATERIAIS EXIGIDOS:',
          style: TextStyle(
            fontFamily: GameConstants.fontPixel,
            fontSize: 7,
            fontWeight: FontWeight.bold,
            color: GameConstants.rusticWoodDark,
          ),
        ),

        const SizedBox(height: 4),

        // Materials List
        Expanded(
          child: ListView(
            children: r.requiredMaterials.entries.map((entry) {
              final matId = entry.key;
              final requiredQty = entry.value;
              final playerQty = inv.countOf(matId);
              final hasEnough = playerQty >= requiredQty;

              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Icon(
                      hasEnough ? Icons.check_circle : Icons.cancel,
                      size: 10,
                      color: hasEnough ? Colors.green[800] : Colors.red[800],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatMaterialName(matId),
                        style: const TextStyle(
                          fontFamily: GameConstants.fontPixel,
                          fontSize: 7,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '$playerQty / $requiredQty',
                      style: TextStyle(
                        fontFamily: GameConstants.fontPixel,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: hasEnough ? Colors.green[900] : Colors.red[900],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Required Gold Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CUSTO EM OURO:',
              style: TextStyle(
                fontFamily: GameConstants.fontPixel,
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: GameConstants.rusticWoodDark,
              ),
            ),
            Text(
              '🪙 ${r.requiredGold} Ouro',
              style: TextStyle(
                fontFamily: GameConstants.fontPixel,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: playerGold >= r.requiredGold ? Colors.green[900] : Colors.red[900],
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Action Button: Forge on Anvil
        GestureDetector(
          onTap: canCraft ? _forgeCurrentRecipe : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: canCraft ? GameConstants.rusticWood : Colors.grey[600],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: canCraft ? Colors.amber : Colors.black26,
                width: 1.5,
              ),
              boxShadow: canCraft
                  ? const [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(1, 2),
                        blurRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⚒️', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Text(
                  canCraft ? 'FORJAR NA BIGORNA' : 'MATERIAIS INSUFICIENTES',
                  style: TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: canCraft ? GameConstants.parchmentLight : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatMaterialName(String id) {
    switch (id) {
      case 'ore_copper':
        return 'Minério de Cobre';
      case 'ore_iron':
        return 'Minério de Ferro';
      case 'ore_silver':
        return 'Minério de Prata';
      case 'ore_gold':
        return 'Minério de Ouro';
      case 'gem_lunar_crystal':
        return 'Cristal Lunar Puro';
      case 'bar_copper':
        return 'Barra de Cobre';
      case 'bar_iron':
        return 'Barra de Ferro';
      case 'bar_silver':
        return 'Barra de Prata';
      case 'bar_gold':
        return 'Barra de Ouro';
      case 'bar_lunar':
        return 'Lingote Lunar Puro';
      case 'mat_wood':
        return 'Madeira de Carvalho';
      case 'boots_leather':
        return 'Botas de Couro Rústico';
      case 'produce_floating_wool':
        return 'Lã Flutuante Mística';
      case 'crop_dew_blossom':
        return 'Flor-de-Orvalho';
      case 'crop_scream_root':
        return 'Raiz-Gritante';
      default:
        return id;
    }
  }
}
