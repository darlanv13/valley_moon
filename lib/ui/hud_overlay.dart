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
                top: 10,
                left: 10,
                child: _buildPlayerStats(state),
              ),

              // 2. Top-Right: Lunar Phase, Season, Weather & Clock
              Positioned(
                top: 10,
                right: 10,
                child: _buildLunarClock(state),
              ),

              // 3. Bottom-Center: Rustic Wooden Scrollable Hotbar
              Positioned(
                bottom: 12,
                left: 70,
                right: 80,
                child: Center(
                  child: _buildToolHotbar(state),
                ),
              ),

              // 4. Bottom-Right: Action Button (Touch)
              Positioned(
                bottom: 16,
                right: 12,
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
          _buildStatBar(
            label: 'HP',
            icon: Icons.favorite,
            iconColor: GameConstants.healthRed,
            value: state.health,
            maxValue: state.maxHealth,
            barColor: GameConstants.healthRed,
          ),
          const SizedBox(height: 4),
          _buildStatBar(
            label: 'EN',
            icon: Icons.bolt,
            iconColor: Colors.amber[800]!,
            value: state.energy,
            maxValue: state.maxEnergy,
            barColor: GameConstants.energyGreen,
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(
                '${state.coins} Ouro',
                style: const TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 9,
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
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 5),
        Container(
          width: 85,
          height: 10,
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
            blurRadius: 5,
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
              Text(state.moonPhase.icon, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 5),
              Text(
                state.moonPhase.label,
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isBlood ? const Color(0xFF8B0000) : GameConstants.rusticWoodDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // Season & Weather
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.weather.icon, style: const TextStyle(fontSize: 12)),
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
          const SizedBox(height: 3),

          // Clock & Advance Day Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$hourStr:$minuteStr',
                style: const TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.rusticWoodDark,
                ),
              ),
              const SizedBox(width: 8),
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
                      fontSize: 7,
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

  Widget _buildToolHotbar(GameState state) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: GameConstants.rusticWood,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameConstants.parchmentDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? GameConstants.parchmentLight
                      : GameConstants.rusticWoodDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? GameConstants.moonstoneGlow
                        : GameConstants.parchmentDark.withValues(alpha: 0.5),
                    width: isSelected ? 2.5 : 1.2,
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
                child: Center(
                  child: Text(
                    tool.icon,
                    style: TextStyle(fontSize: isSelected ? 18 : 15),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButton(GameState state) {
    return GestureDetector(
      onTap: () {
        game.player.performAction(state.selectedTool);
      },
      child: Container(
        width: 56,
        height: 56,
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
                style: const TextStyle(fontSize: 18),
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
