import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/inventory_system.dart';
import '../models/time_system.dart';

/// The rustic HUD Overlay: Top status bar and bottom 10-slot hotbar.
class HudOverlay extends StatelessWidget {
  final ValleyMoonGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([game.gameState, game.inventory]),
      builder: (context, _) {
        final state = game.gameState;
        final inv = game.inventory;

        return SafeArea(
          child: Stack(
            children: [
              // 1. Top-Left: Health, Energy/Stamina, Gold & Backpack Button
              Positioned(
                top: 8,
                left: 10,
                child: _buildPlayerStats(state),
              ),

              // 2. Top-Right: Rustic Wooden Clock, Season, Weather & Lunar Phase
              Positioned(
                top: 8,
                right: 10,
                child: _buildLunarClock(state),
              ),

              // 3. Bottom-Center: 10-Slot Quick Hotbar
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildTenSlotHotbar(inv),
                ),
              ),

              // 4. Bottom-Right: Touch Action Button (USAR)
              Positioned(
                bottom: 14,
                right: 14,
                child: _buildActionButton(inv),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerStats(GameState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: GameConstants.parchmentLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GameConstants.rusticWood, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Health Bar
              _buildStatBar(
                label: 'HP',
                icon: Icons.favorite,
                iconColor: GameConstants.healthRed,
                value: state.health,
                maxValue: state.maxHealth,
                barColor: GameConstants.healthRed,
              ),
              const SizedBox(height: 4),

              // Stamina / Vigor Bar
              _buildStatBar(
                label: 'VIGOR',
                icon: Icons.bolt,
                iconColor: Colors.amber[800]!,
                value: state.energy,
                maxValue: state.maxEnergy,
                barColor: GameConstants.energyGreen,
              ),
              const SizedBox(height: 4),

              // Village Gold
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '${state.coins} Ouro',
                    style: const TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: GameConstants.rusticWoodDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Backpack / Inventory Button
        GestureDetector(
          onTap: game.toggleInventory,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: GameConstants.parchmentLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GameConstants.rusticWood, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  offset: Offset(1, 2),
                  blurRadius: 3,
                ),
              ],
            ),
            child: const Center(
              child: Text('🎒', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),

        const SizedBox(width: 6),

        // Grandfather's Diary & Altars Button
        GestureDetector(
          onTap: game.openDiaryAndAltars,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: GameConstants.parchmentLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GameConstants.rusticWood, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  offset: Offset(1, 2),
                  blurRadius: 3,
                ),
              ],
            ),
            child: const Center(
              child: Text('📖', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),

        const SizedBox(width: 6),

        // Quick Fishing Button
        GestureDetector(
          onTap: game.startFishing,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: GameConstants.parchmentLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GameConstants.rusticWood, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  offset: Offset(1, 2),
                  blurRadius: 3,
                ),
              ],
            ),
            child: const Center(
              child: Text('🎣', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBar({
    required String label,
    required IconData icon,
    required Color iconColor,
    required double value,
    required double maxValue,
    required Color barColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 4),
        Container(
          width: 80,
          height: 9,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: GameConstants.rusticWoodDark, width: 1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / maxValue).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLunarClock(GameState state) {
    final minuteStr = state.minute.toString().padLeft(2, '0');
    final hourStr = state.hour.toString().padLeft(2, '0');
    final isBlood = state.moonPhase == MoonPhase.bloodMoon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isBlood ? const Color(0xFFFBE5E5) : GameConstants.parchmentLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBlood ? const Color(0xFF881515) : GameConstants.rusticWood,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: isBlood ? const Color(0x66AA1111) : Colors.black45,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Location & Lunar Phase Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${game.currentLocation.icon} ${game.currentLocation.displayName}',
                style: const TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 7,
                  color: GameConstants.rusticWoodDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(state.moonPhase.icon, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 5),
              Text(
                state.moonPhase.label,
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isBlood ? const Color(0xFF8B0000) : GameConstants.rusticWoodDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          // Season & Weather
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.weather.icon, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                '${state.season.label}, Dia ${state.day}',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 8,
                  color: Colors.brown[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          // Clock & Advance Day Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$hourStr:$minuteStr',
                style: const TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.rusticWoodDark,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  game.gameState.advanceDay();
                  game.playSFX(GameConstants.sfxDoorOpen);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: GameConstants.rusticWood,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Dormir 💤',
                    style: TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 6,
                      color: GameConstants.parchmentLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 10-Slot Quick Hotbar
  Widget _buildTenSlotHotbar(InventoryState inv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: GameConstants.rusticWood,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GameConstants.parchmentDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(10, (index) {
          final stack = inv.hotbar[index];
          final isSelected = inv.selectedHotbarIndex == index;

          return GestureDetector(
            onTap: () {
              inv.selectHotbarSlot(index);
              final item = stack?.item;
              if (item?.associatedTool != null) {
                game.gameState.selectTool(item!.associatedTool!);
              }
              game.playSFX('wood_click.ogg');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected
                    ? GameConstants.parchmentLight
                    : GameConstants.rusticWoodDark,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isSelected
                      ? GameConstants.moonstoneGlow
                      : GameConstants.parchmentDark.withValues(alpha: 0.4),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: GameConstants.moonstoneGlow.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // Number Key Indicator (1 to 0)
                  Positioned(
                    top: 1,
                    left: 2,
                    child: Text(
                      '${(index + 1) % 10}',
                      style: TextStyle(
                        fontFamily: GameConstants.fontPixel,
                        fontSize: 6,
                        color: isSelected ? Colors.brown[900] : Colors.grey[400],
                      ),
                    ),
                  ),

                  // Item Icon
                  if (stack != null)
                    Center(
                      child: Text(
                        stack.item.icon,
                        style: TextStyle(fontSize: isSelected ? 16 : 14),
                      ),
                    ),

                  // Stack Count
                  if (stack != null && stack.count > 1)
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
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionButton(InventoryState inv) {
    final selectedStack = inv.selectedHotbarItem;
    final icon = selectedStack?.item.icon ?? '✋';

    return GestureDetector(
      onTap: () {
        final tool = selectedStack?.item.associatedTool ?? game.gameState.selectedTool;
        game.player.performAction(tool);
      },
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: GameConstants.parchmentLight,
          shape: BoxShape.circle,
          border: Border.all(color: GameConstants.rusticWood, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(2, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const Text(
                'USAR',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.rusticWoodDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
