import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/inventory_system.dart';

/// Rustic Dialog for the Wood-Fired Kitchen Stove (Cozinha à Lenha).
class KitchenDialog extends StatefulWidget {
  final ValleyMoonGame game;
  final VoidCallback onClose;

  const KitchenDialog({
    super.key,
    required this.game,
    required this.onClose,
  });

  @override
  State<KitchenDialog> createState() => _KitchenDialogState();
}

class _KitchenDialogState extends State<KitchenDialog> {
  late Recipe _selectedRecipe;
  String? _statusMessage;

  final List<Recipe> _cookingRecipes = Recipe.allRecipes
      .where((r) => r.id.startsWith('rec_food_'))
      .toList();

  @override
  void initState() {
    super.initState();
    if (_cookingRecipes.isNotEmpty) {
      _selectedRecipe = _cookingRecipes.first;
    }
    widget.game.playSFX(GameConstants.sfxWoodClick);
  }

  void _cookRecipe() {
    final inv = widget.game.inventory;
    if (!inv.hasIngredients(_selectedRecipe.ingredients)) {
      widget.game.playSFX(GameConstants.sfxWoodClick);
      setState(() {
        _statusMessage = 'Ingredientes insuficientes no inventário!';
      });
      return;
    }

    final success = inv.craft(_selectedRecipe);
    if (success) {
      widget.game.playSFX(GameConstants.sfxCookingSizzle);
      setState(() {
        _statusMessage = 'Você preparou ${_selectedRecipe.result.name} com perfeição! 🍲';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasKitchen = widget.game.family.cabinLevel.hasKitchen;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: Container(
        width: 540,
        height: 440,
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
                  const Text('🍳', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'FOGÃO À LENHA DA CABANA',
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

            // Content
            Expanded(
              child: hasKitchen
                  ? Row(
                      children: [
                        // Recipe list sidebar
                        Container(
                          width: 200,
                          decoration: const BoxDecoration(
                            color: Color(0xFF221811),
                            border: Border(
                              right: BorderSide(color: Color(0xFF5A3C20), width: 2),
                            ),
                          ),
                          child: ListView.builder(
                            itemCount: _cookingRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _cookingRecipes[index];
                              final isSelected = recipe.id == _selectedRecipe.id;
                              final canCook = widget.game.inventory.hasIngredients(recipe.ingredients);

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedRecipe = recipe;
                                    _statusMessage = null;
                                  });
                                  widget.game.playSFX(GameConstants.sfxWoodClick);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  color: isSelected ? const Color(0xFF5A3C20) : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Text(recipe.icon, style: const TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          recipe.name,
                                          style: TextStyle(
                                            fontFamily: GameConstants.fontPixel,
                                            fontSize: 8,
                                            color: canCook
                                                ? (isSelected ? Colors.white : const Color(0xFFE8C88B))
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Recipe details & cooking action
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(_selectedRecipe.result.icon, style: const TextStyle(fontSize: 32)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedRecipe.result.name,
                                            style: const TextStyle(
                                              fontFamily: GameConstants.fontPixel,
                                              fontSize: 10,
                                              color: Color(0xFFFFD54F),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '+${_selectedRecipe.result.energyRestore.toInt()} Energia  |  +${_selectedRecipe.result.healthRestore.toInt()} HP',
                                            style: const TextStyle(
                                              color: Color(0xFF81C784),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedRecipe.description,
                                  style: const TextStyle(
                                    color: Color(0xFFD7CCC8),
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'INGREDIENTES NECESSÁRIOS:',
                                  style: TextStyle(
                                    fontFamily: GameConstants.fontPixel,
                                    fontSize: 8,
                                    color: Color(0xFFE8C88B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._selectedRecipe.ingredients.entries.map((entry) {
                                  final have = widget.game.inventory.countOf(entry.key);
                                  final need = entry.value;
                                  final ok = have >= need;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Icon(
                                          ok ? Icons.check_circle : Icons.cancel,
                                          size: 14,
                                          color: ok ? const Color(0xFF81C784) : const Color(0xFFE57373),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Item (${entry.key}): $have / $need',
                                          style: TextStyle(
                                            fontFamily: GameConstants.fontPixel,
                                            fontSize: 8,
                                            color: ok ? Colors.white : Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
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
                                    onPressed: _cookRecipe,
                                    child: const Text(
                                      'COZINHAR NO FOGÃO À LENHA 🔥',
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
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('🔒🪵', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 12),
                          Text(
                            'COZINHA À LENHA TRANCADA',
                            style: TextStyle(
                              fontFamily: GameConstants.fontPixel,
                              color: Color(0xFFFFD54F),
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Visite a carpintaria na vila para expandir a cabana (Nível 1) e construir seu fogão!',
                            style: TextStyle(color: Color(0xFFD7CCC8), fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
}
