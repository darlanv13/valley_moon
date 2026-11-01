import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';

/// Modal cutscene displaying the Act III Climax resolution:
/// The Tree of Light blooms, Grandfather is freed from the amber, and the Silent Ash dissolves.
class Act3VictoryDialog extends StatelessWidget {
  final ValleyMoonGame game;
  final VoidCallback onClose;

  const Act3VictoryDialog({
    super.key,
    required this.game,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 580,
          height: 340,
          decoration: BoxDecoration(
            color: GameConstants.parchmentLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber, width: 4),
            boxShadow: const [
              BoxShadow(color: Colors.amberAccent, blurRadius: 16, spreadRadius: 2),
              BoxShadow(color: Colors.black87, offset: Offset(4, 4), blurRadius: 8),
            ],
          ),
          child: Column(
            children: [
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: GameConstants.rusticWood,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  '🌟 ATO III CONCLUÍDO: O DESPERTAR DO LUAR 🌟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
              ),

              // Dialogue Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Grandfather Portrait Frame
                      Container(
                        width: 90,
                        height: 110,
                        decoration: BoxDecoration(
                          color: GameConstants.parchmentDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: GameConstants.rusticWood, width: 3),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('👴', style: TextStyle(fontSize: 40)),
                            SizedBox(height: 4),
                            Text(
                              'O AVÔ',
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

                      const SizedBox(width: 14),

                      // Grandfather's Dialogue and Lore
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"Você conseguiu, minha criança..."',
                              style: TextStyle(
                                fontFamily: GameConstants.fontPixel,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B2500),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '“Você não apenas empunhou a espada contra as feras, mas compreendeu o verdadeiro segredo de Valley Moon: a terra não se conquista pela força, mas cura-se pelo amor ao solo e ao ciclo lunar.\n\n'
                              'A Árvore de Luz dissipou a Cinza Silenciosa para sempre. O Guardião da Montanha agora descansa em paz, e nosso vale volta a florescer sob o olhar benévolo da Lua.\n\n'
                              'Vamos voltar para casa juntos. A Caverna Infinita agora está aberta para suas próximas jornadas lendárias!”',
                              style: TextStyle(
                                fontFamily: GameConstants.fontPixel,
                                fontSize: 7,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Rewards & Dismiss Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: GameConstants.rusticWoodDark,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('🏆', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'Desbloqueado: A Caverna Infinita & Paz do Vale',
                          style: TextStyle(
                            fontFamily: GameConstants.fontPixel,
                            fontSize: 7,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        game.playSFX(GameConstants.sfxVictory);
                        game.gameState.addCoins(5000);
                        onClose();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: GameConstants.rusticWood,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.amber, width: 1.5),
                        ),
                        child: const Text(
                          'VOLTAR À FAZENDA COM O AVÔ',
                          style: TextStyle(
                            fontFamily: GameConstants.fontPixel,
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: GameConstants.parchmentLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

