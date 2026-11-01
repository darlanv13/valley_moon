import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/festival_system.dart';
import '../models/inventory_system.dart';

/// Interactive UI Modal for the 4 Seasonal Festivals of Valley Moon.
class FestivalDialog extends StatefulWidget {
  final ValleyMoonGame game;
  final FestivalType festival;
  final VoidCallback onClose;

  const FestivalDialog({
    super.key,
    required this.game,
    required this.festival,
    required this.onClose,
  });

  @override
  State<FestivalDialog> createState() => _FestivalDialogState();
}

class _FestivalDialogState extends State<FestivalDialog> {
  String? _resultBanner;
  String? _selectedIngredientId;

  @override
  void initState() {
    super.initState();
    widget.game.playBGM(GameConstants.bgmFestival);
    widget.game.playSFX(GameConstants.sfxVictory);
  }

  void _onParticipate() {
    final fest = widget.festival;
    final fManager = widget.game.festivals;

    switch (fest) {
      case FestivalType.firstSeed:
        final res = fManager.runPigRace(
          animals: widget.game.animals,
          inventory: widget.game.inventory,
          gameState: widget.game.gameState,
        );
        final place = res['placement'] as int;
        final gold = res['prizeGold'] as int;
        final seed = res['rewardSeed'] as GameItem;
        widget.game.playSFX(GameConstants.sfxCoins);
        setState(() {
          _resultBanner = '🏆 $placeº Lugar na Corrida! Ganhou 🪙 $gold Ouro e 3x ${seed.name}!';
        });
        break;

      case FestivalType.fireBoats:
        final res = fManager.launchFireBoat(
          inventory: widget.game.inventory,
          gameState: widget.game.gameState,
        );
        final fish = res['rewardFish'] as GameItem;
        widget.game.playSFX(GameConstants.sfxSplash);
        setState(() {
          _resultBanner = '🏮 Barco lançado sob as estrelas! Um ${fish.name} subiu à superfície!';
        });
        break;

      case FestivalType.hiddenHarvest:
        if (_selectedIngredientId == null) {
          setState(() {
            _resultBanner = '⚠️ Selecione um ingrediente para ofertar!';
          });
          return;
        }
        final buff = fManager.contributeToCauldron(
          ingredientId: _selectedIngredientId!,
          inventory: widget.game.inventory,
          gameState: widget.game.gameState,
        );
        widget.game.playSFX(GameConstants.sfxPurify);
        setState(() {
          _resultBanner = '✨ O caldeirão borbulhou! Bênção obtida: ${buff.name} (${buff.description})';
        });
        break;

      case FestivalType.forgeTournament:
        final res = fManager.competeInTournament(
          combatStats: widget.game.combat,
          gameState: widget.game.gameState,
          inventory: widget.game.inventory,
        );
        final won = res['roundsWon'] as int;
        final champ = res['isChampion'] as bool;
        final gold = res['prizeGold'] as int;
        widget.game.playSFX(champ ? GameConstants.sfxVictory : GameConstants.sfxSwordHit);
        setState(() {
          if (champ) {
            _resultBanner = '🥇 CAMPEÃO DO TORNEIO! 3/3 Rodadas vencidas! Prêmio: 🪙 $gold Ouro e 50x Madeira Nobre!';
          } else {
            _resultBanner = '⚔️ Lutou bravamente! $won/3 Rodadas vencidas. Prêmio: 🪙 $gold Ouro!';
          }
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fest = widget.festival;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 540,
          height: 330,
          decoration: BoxDecoration(
            color: GameConstants.parchmentLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GameConstants.rusticWood, width: 4),
            boxShadow: const [
              BoxShadow(color: Colors.black87, offset: Offset(4, 4), blurRadius: 8),
            ],
          ),
          child: Column(
            children: [
              // 1. Header Bar
              _buildHeader(fest),

              // 2. Main Content Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // Festival Description
                      Text(
                        fest.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: GameConstants.fontPixel,
                          fontSize: 8,
                          color: GameConstants.rusticWoodDark,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Event Specific Content
                      Expanded(
                        child: _buildEventSpecificArea(fest),
                      ),

                      const SizedBox(height: 6),

                      // Result Banner
                      if (_resultBanner != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: GameConstants.rusticWoodDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _resultBanner!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: GameConstants.fontPixel,
                              fontSize: 7,
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Participation Action Button
                      GestureDetector(
                        onTap: _onParticipate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: GameConstants.rusticWood,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, offset: Offset(1, 2), blurRadius: 4),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(fest.icon, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Text(
                                _getActionLabel(fest),
                                style: const TextStyle(
                                  fontFamily: GameConstants.fontPixel,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: GameConstants.parchmentLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(FestivalType fest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: GameConstants.rusticWood,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Text(fest.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fest.name.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: GameConstants.parchmentLight,
                  ),
                ),
                Text(
                  '${fest.season.label} • Dia ${fest.day}',
                  style: const TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 7,
                    color: Color(0xFFDCC8A0),
                  ),
                ),
              ],
            ),
          ),
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
              child: const Icon(Icons.close, size: 14, color: GameConstants.parchmentLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSpecificArea(FestivalType fest) {
    switch (fest) {
      case FestivalType.firstSeed:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🐷 🏁 🐷 🏁 🐷', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              const Text(
                'Os porcos do vale estão alinhados no portão de carvalho!\nPorcos bem alimentados e acariciados concedem bônus de velocidade.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, color: Colors.black87),
              ),
            ],
          ),
        );

      case FestivalType.fireBoats:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏮 🛶 🌊 🏮 🛶', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              const Text(
                'Escreva seu desejo e lance um barco de madeira com lamparina.\nA luz atrai peixes místicos lendários das profundezas do lago!',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, color: Colors.black87),
              ),
            ],
          ),
        );

      case FestivalType.hiddenHarvest:
        final inv = widget.game.inventory;
        // Collect candidate crops/items from player's inventory
        final candidates = [
          {'id': 'crop_golden_wheat', 'name': 'Trigo Dourado (Bênção Dourada)', 'icon': '✨🌾'},
          {'id': 'crop_dew_blossom', 'name': 'Flor-de-Orvalho (Orvalho Lunar)', 'icon': '💠🌙'},
          {'id': 'crop_turnip', 'name': 'Nabo da Roça (Vitalidade da Terra)', 'icon': '🥕'},
          {'id': 'mat_wood', 'name': 'Lenha de Carvalho (Básico)', 'icon': '🪵'},
        ];

        return Column(
          children: [
            const Text(
              'Escolha seu ingrediente para ofertar ao Caldeirão Comunitário:',
              style: TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, fontWeight: FontWeight.bold, color: GameConstants.rusticWoodDark),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, idx) {
                  final cand = candidates[idx];
                  final id = cand['id']!;
                  final count = inv.countOf(id);
                  final isSelected = _selectedIngredientId == id;

                  return GestureDetector(
                    onTap: count > 0 ? () => setState(() => _selectedIngredientId = id) : null,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFDCC8A0) : (count > 0 ? const Color(0xFFEFE8D6) : const Color(0xFFD0C6B0)),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isSelected ? Colors.amber[900]! : Colors.black26),
                      ),
                      child: Row(
                        children: [
                          Text(cand['icon']!, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              cand['name']!,
                              style: const TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, color: Colors.black87),
                            ),
                          ),
                          Text(
                            'Na mochila: $count',
                            style: TextStyle(
                              fontFamily: GameConstants.fontPixel,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              color: count > 0 ? Colors.green[900] : Colors.red[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case FestivalType.forgeTournament:
        final combat = widget.game.combat;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚔️ 🛡️ 🏆 🛡️ ⚔️', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(
                'Seu Poder de Ataque: ${combat.calculateMeleeDamage()} • Defesa: ${combat.equipment.totalDefense}',
                style: const TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 8, fontWeight: FontWeight.bold, color: GameConstants.rusticWoodDark),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lute na arena de neve contra sombras e bonecos de treino da guarda.\nTrês vitórias consecutivas consagram o Campeão da Vila!',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, color: Colors.black87),
              ),
            ],
          ),
        );
    }
  }

  String _getActionLabel(FestivalType fest) {
    switch (fest) {
      case FestivalType.firstSeed:
        return 'CORRER COM OS PORCOS';
      case FestivalType.fireBoats:
        return 'LANÇAR BARCO DE FOGO';
      case FestivalType.hiddenHarvest:
        return 'OFERTAR AO CALDEIRÃO';
      case FestivalType.forgeTournament:
        return 'LUTAR NO TORNEIO';
    }
  }
}
