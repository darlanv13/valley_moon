import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/time_system.dart';

/// The rustic HUD Overlay in aged parchment and carved wood.
class HudOverlay extends StatelessWidget {
  final ValleyMoonGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game.gameState,
      builder: (context, _) {
        final state = game.gameState;

        return SafeArea(
          child: Stack(
            children: [
              // 1. Top-Left: Health, Energy & Coin Pouch
              Positioned(
                top: 12,
                left: 12,
                child: _buildPlayerStats(state),
              ),

              // 2. Top-Right: Lunar Phase & Rustic Calendar Clock
              Positioned(
                top: 12,
                right: 12,
                child: _buildLunarClock(state),
              ),

              // 3. Bottom-Center: Rustic Wooden Hotbar (Tools)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildToolHotbar(state),
                ),
              ),

              // 4. Bottom-Right: Action Button (for Mobile/Touch)
              Positioned(
                bottom: 20,
                right: 20,
                child: _buildActionButton(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerStats(GameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          const SizedBox(height: 5),

          // Energy Bar
          _buildStatBar(
            label: 'EN',
            icon: Icons.bolt,
            iconColor: Colors.amber[800]!,
            value: state.energy,
            maxValue: state.maxEnergy,
            barColor: GameConstants.energyGreen,
          ),
          const SizedBox(height: 6),

          // Coin Pouch
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '${state.coins} Ouro',
                style: const TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.rusticWoodDark,
                ),
              ),
            ],
          ),
        ],
      ),
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
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 5),
        Container(
          width: 90,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: GameConstants.rusticWoodDark, width: 1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / maxValue).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(3),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lunar Phase Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.moonPhase.icon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                state.moonPhase.label,
                style: const TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.rusticWoodDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Day & Season
          Text(
            '${state.season}, Dia ${state.day}',
            style: TextStyle(
              fontFamily: GameConstants.fontPixel,
              fontSize: 9,
              color: Colors.brown[800],
            ),
          ),
          const SizedBox(height: 3),

          // Time Clock
          Text(
            '$hourStr:$minuteStr',
            style: const TextStyle(
              fontFamily: GameConstants.fontPixel,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: GameConstants.rusticWoodDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolHotbar(GameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: GameConstants.rusticWood,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameConstants.parchmentDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: FarmerTool.values.map((tool) {
          final isSelected = state.selectedTool == tool;

          return GestureDetector(
            onTap: () {
              game.gameState.selectTool(tool);
              game.playSFX(GameConstants.sfxCoins);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? GameConstants.parchmentLight
                    : GameConstants.rusticWoodDark,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? GameConstants.moonstoneGlow
                      : GameConstants.parchmentDark.withValues(alpha: 0.5),
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: GameConstants.moonstoneGlow.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  tool.icon,
                  style: TextStyle(fontSize: isSelected ? 20 : 18),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(GameState state) {
    return GestureDetector(
      onTap: () {
        game.player.performAction(state.selectedTool);
      },
      child: Container(
        width: 60,
        height: 60,
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
              Text(
                state.selectedTool.icon,
                style: const TextStyle(fontSize: 20),
              ),
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
