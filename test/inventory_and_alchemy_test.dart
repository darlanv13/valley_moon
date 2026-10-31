import 'package:flutter_test/flutter_test.dart';
import 'package:valley_moon/models/inventory_system.dart';
import 'package:valley_moon/models/time_system.dart';

void main() {
  group('Valley Moon - Etapa 3: Inventário, Crafting e Caldeirão de Alquimia', () {
    test('Hotbar de 10 Slots e Mochila de 24 Slots', () {
      final inv = InventoryState();

      // 10 Hotbar slots
      expect(inv.hotbar.length, 10);
      expect(inv.selectedHotbarIndex, 0);
      expect(inv.selectedHotbarItem?.item.id, 'tool_hoe');

      // Selecting slot 3 (Machado)
      inv.selectHotbarSlot(3);
      expect(inv.selectedHotbarIndex, 3);
      expect(inv.selectedHotbarItem?.item.id, 'tool_axe');

      // 24 Backpack slots
      expect(inv.backpack.length, 24);
      expect(inv.getItemCount('mat_wood'), 30);
      expect(inv.getItemCount('mat_stone'), 20);
    });

    test('Crafting Rústico: Cerca, Baú e Totens', () {
      final inv = InventoryState();

      // Craft Cerca de Madeira: Requer 2 Madeira -> gera 4 Cercas
      final fenceRecipe = Recipe.allRecipes.firstWhere((r) => r.id == 'rec_fence');
      expect(inv.hasIngredients(fenceRecipe.ingredients), isTrue);

      final woodBefore = inv.getItemCount('mat_wood');
      final craftSuccess = inv.craft(fenceRecipe);

      expect(craftSuccess, isTrue);
      expect(inv.getItemCount('mat_wood'), woodBefore - 2);
      expect(inv.getItemCount('craft_fence'), 4);
    });

    test('Caldeirão de Alquimia: Preparo de Poções e Consumo', () {
      final inv = InventoryState();
      final gameState = GameState();

      // Receita Poção de Cura: 1 Raiz-Gritante + 2 Madeira
      final healRecipe = Recipe.allRecipes.firstWhere((r) => r.id == 'rec_pot_health');
      expect(inv.hasIngredients(healRecipe.ingredients), isTrue);

      final brewed = inv.craft(healRecipe);
      expect(brewed, isTrue);
      expect(inv.getItemCount('pot_health'), 1);

      // Simular dano no jogador
      gameState.health = 40.0;
      expect(gameState.health, 40.0);

      // Consumir Poção (+50 HP)
      gameState.heal(GameItem.healthPotion.healthRestore);
      expect(gameState.health, 90.0);

      // Receita Elixir de Vigor: 1 Flor-de-Orvalho + 1 Nabo
      final vigorRecipe = Recipe.allRecipes.firstWhere((r) => r.id == 'rec_pot_vigor');
      expect(inv.hasIngredients(vigorRecipe.ingredients), isTrue);

      final brewedVigor = inv.craft(vigorRecipe);
      expect(brewedVigor, isTrue);
      expect(inv.getItemCount('pot_vigor'), 1);

      // Simular cansaço
      gameState.energy = 20.0;
      gameState.restoreEnergy(GameItem.vigorElixir.energyRestore);
      expect(gameState.energy, 90.0);
    });

    test('Consumo de Ingredientes Alquímicos Fecunda Itens Únicos', () {
      final inv = InventoryState();

      // Isca Encantada: 1 Trigo-Dourado + 1 Raiz-Gritante -> 5 Iscas
      final baitRecipe = Recipe.allRecipes.firstWhere((r) => r.id == 'rec_pot_bait');
      expect(inv.hasIngredients(baitRecipe.ingredients), isTrue);

      final brewedBait = inv.craft(baitRecipe);
      expect(brewedBait, isTrue);
      expect(inv.getItemCount('pot_moon_bait'), 5);
    });
  });
}
