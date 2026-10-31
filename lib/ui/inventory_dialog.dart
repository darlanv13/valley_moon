import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/inventory_system.dart';

/// Full screen Inventory, Crafting, and Alchemy Cauldron in aged leather book style.
class InventoryDialog extends StatefulWidget {
  final ValleyMoonGame game;
  final VoidCallback onClose;

  const InventoryDialog({
    super.key,
    required this.game,
    required this.onClose,
  });

  @override
  State<InventoryDialog> createState() => _InventoryDialogState();
}

class _InventoryDialogState extends State<InventoryDialog> {
  int _currentTab = 0; // 0 = Mochila, 1 = Crafting, 2 = Caldeirão
  ItemStack? _selectedItem;

  @override
  void initState() {
    super.initState();
    ValleyMoonAudioManager().playSFX('bag_open.ogg');
    _selectedItem = widget.game.inventory.backpack.firstWhere(
      (slot) => slot != null,
      orElse: () => widget.game.inventory.hotbar.firstWhere(
        (slot) => slot != null,
        orElse: () => null,
      ),
    );
  }

  void _close() {
    ValleyMoonAudioManager().playSFX('bag_close.ogg');
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.game.inventory,
      builder: (context, _) {
        final inv = widget.game.inventory;

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
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. Header with Leather Tabs and Close Button
                  _buildHeader(),

                  // 2. Main Content Body
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: _currentTab == 0
                          ? _buildBackpackTab(inv)
                          : _currentTab == 1
                              ? _buildCraftingTab(inv)
                              : _buildAlchemyTab(inv),
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

  Widget _buildHeader() {
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
          // Tabs
          _buildTabButton('🎒 Mochila', 0),
          const SizedBox(width: 8),
          _buildTabButton('🔨 Crafting', 1),
          const SizedBox(width: 8),
          _buildTabButton('⚗️ Caldeirão', 2),

          const Spacer(),

          // Village Coins
          Text(
            '🪙 ${widget.game.gameState.coins}',
            style: const TextStyle(
              fontFamily: GameConstants.fontPixel,
              fontSize: 10,
              color: GameConstants.parchmentLight,
            ),
          ),
          const SizedBox(width: 14),

          // Close Button
          GestureDetector(
            onTap: _close,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: GameConstants.healthRed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _currentTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTab = index;
        });
        ValleyMoonAudioManager().playSFX('wood_click.ogg');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? GameConstants.parchmentLight
              : GameConstants.rusticWoodDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? GameConstants.moonstoneGlow
                : GameConstants.parchmentDark.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: GameConstants.fontPixel,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? GameConstants.rusticWoodDark
                : GameConstants.parchmentDark,
          ),
        ),
      ),
    );
  }

  // --- TAB 1: MOCHILA ---
  Widget _buildBackpackTab(InventoryState inv) {
    return Row(
      children: [
        // Left Column: 24 Backpack Slots
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mochila de Couro (24 Slots)',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.rusticWoodDark,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 24,
                  itemBuilder: (context, i) {
                    final stack = inv.backpack[i];
                    return _buildSlotWidget(stack, () {
                      setState(() {
                        _selectedItem = stack;
                      });
                      ValleyMoonAudioManager().playSFX('wood_click.ogg');
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(color: GameConstants.rusticWood, thickness: 1.5, width: 20),

        // Right Column: Item Details & Action
        Expanded(
          flex: 4,
          child: _buildItemInspector(inv),
        ),
      ],
    );
  }

  Widget _buildItemInspector(InventoryState inv) {
    if (_selectedItem == null) {
      return const Center(
        child: Text(
          'Selecione um item para inspecionar',
          style: TextStyle(
            fontFamily: GameConstants.fontPixel,
            fontSize: 8,
            color: Colors.brown,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final item = _selectedItem!.item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          item.icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          item.name,
          style: const TextStyle(
            fontFamily: GameConstants.fontPixel,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: GameConstants.rusticWoodDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          'Quantidade: ${_selectedItem!.count}',
          style: const TextStyle(
            fontFamily: GameConstants.fontPixel,
            fontSize: 8,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white60,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.brown[300]!),
          ),
          child: Text(
            item.description,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black87,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),

        // Action Button: Consume or Equip
        if (item.category == ItemCategory.consumable || item.category == ItemCategory.potion)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GameConstants.energyGreen,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            onPressed: () {
              // Consume item
              if (item.energyRestore > 0) {
                widget.game.gameState.restoreEnergy(item.energyRestore);
              }
              if (item.healthRestore > 0) {
                widget.game.gameState.heal(item.healthRestore);
              }
              _selectedItem!.count -= 1;
              if (_selectedItem!.count <= 0) {
                inv.backpack[inv.backpack.indexOf(_selectedItem)] = null;
                _selectedItem = null;
              }
              ValleyMoonAudioManager().playSFX('potion_drink.ogg');
              setState(() {});
            },
            child: const Text(
              'Consumir / Beber',
              style: TextStyle(
                fontFamily: GameConstants.fontPixel,
                fontSize: 8,
                color: Colors.white,
              ),
            ),
          )
        else if (item.associatedTool != null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GameConstants.rusticWood,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            onPressed: () {
              widget.game.gameState.selectTool(item.associatedTool!);
              ValleyMoonAudioManager().playSFX('wood_click.ogg');
              _close();
            },
            child: const Text(
              'Equipar na Mão',
              style: TextStyle(
                fontFamily: GameConstants.fontPixel,
                fontSize: 8,
                color: GameConstants.parchmentLight,
              ),
            ),
          ),
      ],
    );
  }

  // --- TAB 2: CRAFTING RÚSTICO ---
  Widget _buildCraftingTab(InventoryState inv) {
    final recipes = Recipe.allRecipes.where((r) => !r.isAlchemy).toList();

    return ListView.separated(
      itemCount: recipes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final rec = recipes[i];
        final canCraft = inv.hasIngredients(rec.ingredients);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GameConstants.rusticWood, width: 1.5),
          ),
          child: Row(
            children: [
              Text(rec.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.name,
                      style: const TextStyle(
                        fontFamily: GameConstants.fontPixel,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: GameConstants.rusticWoodDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rec.description,
                      style: const TextStyle(fontSize: 9, color: Colors.black54),
                    ),
                    const SizedBox(height: 3),
                    // Ingredients
                    Row(
                      children: rec.ingredients.entries.map((e) {
                        final available = inv.getItemCount(e.key);
                        final hasEnough = available >= e.value;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${_getItemName(e.key)}: $available/${e.value}',
                            style: TextStyle(
                              fontFamily: GameConstants.fontPixel,
                              fontSize: 7,
                              color: hasEnough ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCraft ? GameConstants.rusticWood : Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                onPressed: canCraft
                    ? () {
                        inv.craft(rec);
                        ValleyMoonAudioManager().playSFX('chop.ogg');
                      }
                    : null,
                child: const Text(
                  'Entalhar',
                  style: TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: CALDEIRÃO DE ALQUIMIA ---
  Widget _buildAlchemyTab(InventoryState inv) {
    final recipes = Recipe.allRecipes.where((r) => r.isAlchemy).toList();

    return Row(
      children: [
        // Cauldron Animation / Visual Illustration
        Container(
          width: 130,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0x332C1D0F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GameConstants.rusticWood),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ui/cauldron.png',
                width: 56,
                height: 56,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              const Text(
                'Caldeirão de Ferro',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.rusticWoodDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Ferva ervas, colheitas lunares e minérios para destilar elixires ancestrais.',
                style: TextStyle(fontSize: 9, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Alchemy Recipes List
        Expanded(
          child: ListView.separated(
            itemCount: recipes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final rec = recipes[i];
              final canBrew = inv.hasIngredients(rec.ingredients);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canBrew ? Colors.purple[800]! : GameConstants.rusticWood,
                    width: canBrew ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(rec.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.name,
                            style: const TextStyle(
                              fontFamily: GameConstants.fontPixel,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: GameConstants.rusticWoodDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: rec.ingredients.entries.map((e) {
                              final available = inv.getItemCount(e.key);
                              final hasEnough = available >= e.value;

                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  '${_getItemName(e.key)}: $available/${e.value}',
                                  style: TextStyle(
                                    fontFamily: GameConstants.fontPixel,
                                    fontSize: 7,
                                    color: hasEnough ? Colors.green[800] : Colors.red[800],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canBrew ? Colors.purple[900] : Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      onPressed: canBrew
                          ? () {
                              inv.craft(rec);
                              ValleyMoonAudioManager().playSFX('cauldron_stir.ogg');
                              ValleyMoonAudioManager().playSFX('cauldron_pot.ogg');
                            }
                          : null,
                      child: const Text(
                        'Ferver 🧪',
                        style: TextStyle(
                          fontFamily: GameConstants.fontPixel,
                          fontSize: 7,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSlotWidget(ItemStack? stack, VoidCallback onTap) {
    final isSelected = _selectedItem == stack && stack != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8D5B5) : const Color(0xFFDCC8A0),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? GameConstants.moonstoneGlow : GameConstants.rusticWood,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            if (stack != null) ...[
              Center(
                child: Text(
                  stack.item.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (stack.count > 1)
                Positioned(
                  bottom: 1,
                  right: 2,
                  child: Text(
                    '${stack.count}',
                    style: const TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _getItemName(String id) {
    switch (id) {
      case 'mat_wood': return 'Madeira';
      case 'mat_stone': return 'Pedra';
      case 'crop_turnip': return 'Nabo';
      case 'crop_scream_root': return 'Raiz-Gritante';
      case 'crop_dew_blossom': return 'Flor-de-Orvalho';
      case 'crop_golden_wheat': return 'Trigo-Dourado';
      default: return id;
    }
  }
}
