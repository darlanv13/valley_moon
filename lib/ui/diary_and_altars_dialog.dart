import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/story_system.dart';
import '../models/time_system.dart';

/// Modal dialog for Grandfather's Diary and the Four Seasonal Altars.
class DiaryAndAltarsDialog extends StatefulWidget {
  final ValleyMoonGame game;
  final VoidCallback onClose;

  const DiaryAndAltarsDialog({
    super.key,
    required this.game,
    required this.onClose,
  });

  @override
  State<DiaryAndAltarsDialog> createState() => _DiaryAndAltarsDialogState();
}

class _DiaryAndAltarsDialogState extends State<DiaryAndAltarsDialog> {
  int _currentTab = 0; // 0 = Diário do Avô, 1 = Altares das Estações
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    ValleyMoonAudioManager().playSFX('bag_open.ogg');
  }

  void _close() {
    ValleyMoonAudioManager().playSFX('bag_close.ogg');
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.game.story,
      builder: (context, _) {
        final story = widget.game.story;

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
                  // Top Header
                  _buildHeader(),

                  // Content Body
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: _currentTab == 0
                          ? _buildDiaryTab(story)
                          : _buildAltarsTab(story),
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
          _buildTabButton('📖 Diário do Avô', 0),
          const SizedBox(width: 8),
          _buildTabButton('⛩️ Altares das Estações', 1),
          const Spacer(),
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
          color: isSelected ? GameConstants.parchmentLight : GameConstants.rusticWoodDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? GameConstants.moonstoneGlow : GameConstants.parchmentDark.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: GameConstants.fontPixel,
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? GameConstants.rusticWoodDark : GameConstants.parchmentDark,
          ),
        ),
      ),
    );
  }

  // --- TAB 1: DIÁRIO DO AVÔ ---
  Widget _buildDiaryTab(StoryManager story) {
    final page = story.diaryPages[_selectedPageIndex];

    return Row(
      children: [
        // Page list / Index on left
        Container(
          width: 150,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GameConstants.rusticWood),
          ),
          child: ListView.builder(
            itemCount: story.diaryPages.length,
            itemBuilder: (context, i) {
              final p = story.diaryPages[i];
              final isSel = _selectedPageIndex == i;

              return ListTile(
                dense: true,
                selected: isSel,
                selectedTileColor: const Color(0xFFE8D5B5),
                leading: Text(p.isUnlocked ? '📜' : '🔒', style: const TextStyle(fontSize: 14)),
                title: Text(
                  p.isUnlocked ? p.title : 'Página Rasgada $i',
                  style: TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 7,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: p.isUnlocked ? GameConstants.rusticWoodDark : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  setState(() {
                    _selectedPageIndex = i;
                  });
                  ValleyMoonAudioManager().playSFX('wood_click.ogg');
                },
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        // Page Content on right
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.brown[300]!),
            ),
            child: page.isUnlocked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            page.title,
                            style: const TextStyle(
                              fontFamily: GameConstants.fontPixel,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: GameConstants.rusticWoodDark,
                            ),
                          ),
                          Text(
                            page.dateNote,
                            style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.brown),
                          ),
                        ],
                      ),
                      const Divider(color: GameConstants.rusticWood, thickness: 1),
                      const SizedBox(height: 6),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            page.lore,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF5E5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green[600]!),
                        ),
                        child: Row(
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Receitas Reveladas: ${page.unlockedRecipe}',
                                style: TextStyle(
                                  fontFamily: GameConstants.fontPixel,
                                  fontSize: 7,
                                  color: Colors.green[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🔒', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text(
                          'Página Rasgada do Diário',
                          style: TextStyle(
                            fontFamily: GameConstants.fontPixel,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fortaleça laços com os moradores ou ofereça tributos aos Quatro Altares para recuperar esta página.',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: ALTARES DAS ESTAÇÕES ---
  Widget _buildAltarsTab(StoryManager story) {
    return ListView(
      children: Season.values.map((season) {
        final altar = story.altars[season]!;
        final canOffer = !altar.isRestored &&
            widget.game.inventory.hasIngredients(altar.requiredOfferings);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: altar.isRestored ? const Color(0xFFE8F5E9) : Colors.white60,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: altar.isRestored ? Colors.green[800]! : GameConstants.rusticWood,
              width: altar.isRestored ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(season.icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          altar.name,
                          style: const TextStyle(
                            fontFamily: GameConstants.fontPixel,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: GameConstants.rusticWoodDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (altar.isRestored)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green[800],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'RESTAURADO ✨',
                              style: TextStyle(
                                fontFamily: GameConstants.fontPixel,
                                fontSize: 6,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(altar.description, style: const TextStyle(fontSize: 9, color: Colors.black54)),
                    const SizedBox(height: 4),

                    // Offerings checklist
                    if (!altar.isRestored)
                      Wrap(
                        spacing: 8,
                        children: altar.requiredOfferings.entries.map((e) {
                          final current = widget.game.inventory.getItemCount(e.key);
                          final hasEnough = current >= e.value;

                          return Text(
                            '• ${_getItemName(e.key)}: $current/${e.value}',
                            style: TextStyle(
                              fontFamily: GameConstants.fontPixel,
                              fontSize: 7,
                              color: hasEnough ? Colors.green[800] : Colors.red[800],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        'Bênção Espiritual Ativa: ${altar.blessingName} (${altar.blessingDescription})',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green[900]),
                      ),
                  ],
                ),
              ),

              if (!altar.isRestored)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canOffer ? Colors.green[800] : Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onPressed: canOffer
                      ? () {
                          story.offerToAltar(season, widget.game.inventory);
                          ValleyMoonAudioManager().playSFX('chime.ogg');
                          setState(() {});
                        }
                      : null,
                  child: const Text(
                    'Ofertar 🕊️',
                    style: TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 7.5,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getItemName(String id) {
    switch (id) {
      case 'crop_turnip': return 'Nabo';
      case 'crop_wheat': return 'Trigo';
      case 'crop_scream_root': return 'Raiz-Gritante';
      case 'crop_dew_blossom': return 'Flor-de-Orvalho';
      case 'crop_golden_wheat': return 'Trigo-Dourado';
      case 'mat_wood': return 'Madeira';
      case 'mat_stone': return 'Pedra';
      case 'pot_vigor': return 'Elixir Vigor';
      case 'pot_health': return 'Poção Cura';
      case 'pot_lamp_oil': return 'Óleo Élfico';
      case 'craft_scarecrow': return 'Espantalho';
      case 'craft_rain_totem': return 'Totem Chuva';
      default: return id;
    }
  }
}

