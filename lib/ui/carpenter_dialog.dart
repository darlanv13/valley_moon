import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/artisan_system.dart';
import '../models/cabin_and_family_system.dart';
import '../models/inventory_system.dart';

/// Rustic Dialog for Robin's Village Carpentry Shop (House Upgrades & Artisan Machinery).
class CarpenterDialog extends StatefulWidget {
  final ValleyMoonGame game;
  final VoidCallback onClose;

  const CarpenterDialog({
    super.key,
    required this.game,
    required this.onClose,
  });

  @override
  State<CarpenterDialog> createState() => _CarpenterDialogState();
}

class _CarpenterDialogState extends State<CarpenterDialog> {
  int _selectedTab = 0; // 0 = Expansão da Cabana, 1 = Maquinário Rústico
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    widget.game.playSFX(GameConstants.sfxWoodClick);
  }

  void _upgradeCabin() {
    final success = widget.game.family.purchaseCabinUpgrade(
      widget.game.gameState,
      widget.game.inventory,
    );

    if (success) {
      widget.game.playSFX(GameConstants.sfxCarpenterHammer);
      setState(() {
        _statusMessage = 'Cabana aprimorada com sucesso para ${widget.game.family.cabinLevel.name}!';
      });
    } else {
      widget.game.playSFX(GameConstants.sfxWoodClick);
      setState(() {
        _statusMessage = 'Recursos ou ouro insuficientes para esta obra.';
      });
    }
  }

  void _buildMachine(ArtisanMachineType type) {
    // Check Recipe
    Recipe? craftRecipe;
    switch (type) {
      case ArtisanMachineType.loom:
        craftRecipe = Recipe.allRecipes.firstWhere((r) => r.id == 'rec_craft_loom');
        break;
      case ArtisanMachineType.oakCask:
        craftRecipe = Recipe.allRecipes.firstWhere((r) => r.id == 'rec_craft_cask');
        break;
      case ArtisanMachineType.runicFurnace:
        craftRecipe = Recipe.allRecipes.firstWhere((r) => r.id == 'rec_craft_runic_furnace');
        break;
      case ArtisanMachineType.preservesJar:
        craftRecipe = Recipe.allRecipes.firstWhere((r) => r.id == 'rec_craft_preserves_jar');
        break;
    }

    if (widget.game.inventory.hasIngredients(craftRecipe.ingredients)) {
      widget.game.inventory.consumeIngredients(craftRecipe.ingredients);
      widget.game.artisan.addMachine(type);
      widget.game.playSFX(GameConstants.sfxCarpenterHammer);
      setState(() {
        _statusMessage = '${type.name} construído e instalado na fazenda!';
      });
    } else {
      widget.game.playSFX(GameConstants.sfxWoodClick);
      setState(() {
        _statusMessage = 'Materiais insuficientes para construir ${type.name}.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cabin = widget.game.family.cabinLevel;
    final next = cabin.nextLevel;
    final coins = widget.game.gameState.coins;
    final wood = widget.game.inventory.countOf('mat_wood');
    final stone = widget.game.inventory.countOf('mat_stone');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: Container(
        width: 580,
        height: 480,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2219),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF8B5A2B), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1B140E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Text('🪵', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'CARPINTARIA RÚSTICA DA VILA',
                      style: TextStyle(
                        fontFamily: GameConstants.fontPixel,
                        color: Color(0xFFE8C88B),
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFE8C88B), size: 18),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              color: const Color(0xFF38291E),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  _buildTabButton(0, 'Expansão da Cabana 🏡'),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'Maquinário Rústico ⚙️'),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _selectedTab == 0
                    ? _buildCabinTab(cabin, next, coins, wood, stone)
                    : _buildMachinesTab(),
              ),
            ),

            // Status message
            if (_statusMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                color: const Color(0xFF1B140E),
                child: Text(
                  _statusMessage!,
                  style: const TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    color: Color(0xFFFFD54F),
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _statusMessage = null;
        });
        widget.game.playSFX(GameConstants.sfxWoodClick);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5A2B) : const Color(0xFF241A13),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? const Color(0xFFE8C88B) : Colors.black45,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: GameConstants.fontPixel,
            fontSize: 9,
            color: isSelected ? Colors.white : const Color(0xFFB0987A),
          ),
        ),
      ),
    );
  }

  Widget _buildCabinTab(
    CabinLevel current,
    CabinLevel? next,
    int coins,
    int wood,
    int stone,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Level card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B140E),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF5A3C20)),
          ),
          child: Row(
            children: [
              const Text('🏠', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTADO ATUAL: ${current.name.toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: GameConstants.fontPixel,
                        fontSize: 9,
                        color: Color(0xFF81C784),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      current.description,
                      style: const TextStyle(
                        color: Color(0xFFD7CCC8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Next upgrade or Max level
        if (next != null) ...[
          const Text(
            'PRÓXIMO APRIMORAMENTO:',
            style: TextStyle(
              fontFamily: GameConstants.fontPixel,
              fontSize: 9,
              color: Color(0xFFE8C88B),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF221811),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF8B5A2B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    next.name,
                    style: const TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 10,
                      color: Color(0xFFFFD54F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    next.description,
                    style: const TextStyle(
                      color: Color(0xFFECEFF1),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'REQUISITOS DE MATERIAIS:',
                    style: TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 8,
                      color: Color(0xFFE8C88B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildReqBadge(
                        'Ouro',
                        coins,
                        next.goldCost,
                        '🪙',
                      ),
                      const SizedBox(width: 12),
                      _buildReqBadge(
                        'Madeira',
                        wood,
                        next.woodCost,
                        '🪵',
                      ),
                      const SizedBox(width: 12),
                      _buildReqBadge(
                        'Pedra',
                        stone,
                        next.stoneCost,
                        '🪨',
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5A2B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: const BorderSide(color: Color(0xFFE8C88B)),
                        ),
                      ),
                      onPressed: _upgradeCabin,
                      child: const Text(
                        'CONTRATAR OBRA DO CARPINTEIRO 🔨',
                        style: TextStyle(
                          fontFamily: GameConstants.fontPixel,
                          fontSize: 9,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('🏰✨', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 12),
                  Text(
                    'OBRA-PRIMA RÚSTICA CONCLUÍDA!',
                    style: TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      color: Color(0xFFFFD54F),
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sua cabana possui Cozinha à Lenha, Quarto de Casal e Berçário Encantado.',
                    style: TextStyle(color: Color(0xFFD7CCC8), fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReqBadge(String name, int current, int required, String icon) {
    final hasEnough = current >= required;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B140E),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hasEnough ? const Color(0xFF81C784) : const Color(0xFFE57373),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            '$current/$required',
            style: TextStyle(
              fontFamily: GameConstants.fontPixel,
              fontSize: 8,
              color: hasEnough ? const Color(0xFF81C784) : const Color(0xFFE57373),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachinesTab() {
    final machines = ArtisanMachineType.values;
    return ListView.separated(
      itemCount: machines.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final m = machines[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF221811),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF5A3C20)),
          ),
          child: Row(
            children: [
              Text(m.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      style: const TextStyle(
                        fontFamily: GameConstants.fontPixel,
                        fontSize: 9,
                        color: Color(0xFFFFD54F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.description,
                      style: const TextStyle(
                        color: Color(0xFFD7CCC8),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5A2B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Color(0xFFE8C88B)),
                  ),
                ),
                onPressed: () => _buildMachine(m),
                child: const Text(
                  'Construir',
                  style: TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
