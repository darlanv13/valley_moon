import 'dart:async';
import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/inventory_system.dart';
import '../models/npc_dialogue_system.dart';
import '../models/time_system.dart';

/// Parchment Dialogue Modal with Typewriter effect, Portraits, Choices, and Gifting.
class DialogueDialog extends StatefulWidget {
  final ValleyMoonGame game;
  final NpcId npcId;
  final VoidCallback onClose;

  const DialogueDialog({
    super.key,
    required this.game,
    required this.npcId,
    required this.onClose,
  });

  @override
  State<DialogueDialog> createState() => _DialogueDialogState();
}

class _DialogueDialogState extends State<DialogueDialog> {
  late DialogueNode _currentNode;
  late NpcRelationship _relationship;

  String _displayedText = '';
  Timer? _typewriterTimer;
  int _charIndex = 0;
  bool _isTyping = false;

  String? _choiceFeedback;
  String? _giftFeedback;
  bool _showGiftPicker = false;

  @override
  void initState() {
    super.initState();
    _relationship = widget.game.relationships.getRelationship(widget.npcId);
    _currentNode = NpcDialogueRepository.getGreeting(
      widget.npcId,
      _relationship.hearts,
      widget.game.gameState.moonPhase == MoonPhase.bloodMoon,
      widget.game.gameState.isNight,
    );

    // Initial talk friendship bonus
    if (!_relationship.talkedToday) {
      _relationship.talkedToday = true;
      _relationship.addPoints(20);
      widget.game.story.checkRelationshipUnlocks(_relationship.hearts);
    }

    _startTypewriter(_currentNode.text);
  }

  void _startTypewriter(String fullText) {
    _typewriterTimer?.cancel();
    _displayedText = '';
    _charIndex = 0;
    _isTyping = true;

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (_charIndex < fullText.length) {
        _displayedText += fullText[_charIndex];
        _charIndex++;
        // Play subtle murmur periodically
        if (_charIndex % 4 == 0) {
          ValleyMoonAudioManager().playSFX('talk_murmur.ogg', volume: 0.35);
        }
        setState(() {});
      } else {
        _isTyping = false;
        timer.cancel();
        setState(() {});
      }
    });
  }

  void _skipTypewriter() {
    if (_isTyping) {
      _typewriterTimer?.cancel();
      _displayedText = _choiceFeedback ?? _currentNode.text;
      _isTyping = false;
      setState(() {});
    }
  }

  void _selectChoice(DialogueChoice choice) {
    _relationship.addPoints(choice.pointsBonus);
    widget.game.story.checkRelationshipUnlocks(_relationship.hearts);
    ValleyMoonAudioManager().playSFX('wood_click.ogg');

    setState(() {
      _choiceFeedback = choice.response;
    });
    _startTypewriter(choice.response);
  }

  void _giveGift(GameItem item) {
    final inv = widget.game.inventory;
    if (inv.consumeIngredients({item.id: 1})) {
      final reaction = _relationship.evaluateGift(item.id);
      widget.game.relationships.giveGift(widget.npcId, item.id);
      widget.game.story.checkRelationshipUnlocks(_relationship.hearts);

      String reactionText;
      switch (reaction) {
        case GiftReaction.loved:
          reactionText = 'Nossa! Isso é incrível, muito obrigado! Você realmente me conhece bem! ❤️';
          ValleyMoonAudioManager().playSFX('chime.ogg');
          break;
        case GiftReaction.liked:
          reactionText = 'Muito obrigado! Isso me será muito útil na vila.';
          ValleyMoonAudioManager().playSFX('coins.ogg');
          break;
        case GiftReaction.neutral:
          reactionText = 'Obrigado pelo gesto.';
          ValleyMoonAudioManager().playSFX('wood_click.ogg');
          break;
        case GiftReaction.hated:
          reactionText = 'Ugh... Por que você me daria algo assim? Não gostei nem um pouco.';
          ValleyMoonAudioManager().playSFX('wood_click.ogg');
          break;
      }

      setState(() {
        _showGiftPicker = false;
        _giftFeedback = reactionText;
      });
      _startTypewriter(reactionText);
    }
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rel = widget.game.relationships.getRelationship(widget.npcId);

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 540,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GameConstants.parchmentLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GameConstants.rusticWood, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                offset: Offset(3, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar: NPC Name, Hearts, Status Badge & Close
              _buildTopBar(rel),
              const SizedBox(height: 8),

              // Middle: Portrait + Dialogue Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 64x64 Portrait
                  _buildPortrait(),
                  const SizedBox(width: 12),

                  // Dialogue text & choices
                  Expanded(
                    child: GestureDetector(
                      onTap: _skipTypewriter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(minHeight: 55),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.brown[300]!),
                            ),
                            child: Text(
                              _displayedText,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.3,
                                color: GameConstants.rusticWoodDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Branching Choices (if active and finished typing)
                          if (!_isTyping &&
                              _choiceFeedback == null &&
                              _giftFeedback == null &&
                              _currentNode.choices != null)
                            ..._currentNode.choices!.map((c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: GameConstants.rusticWood,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                    onPressed: () => _selectChoice(c),
                                    child: Text(
                                      '• ${c.text}',
                                      style: const TextStyle(
                                        fontFamily: GameConstants.fontPixel,
                                        fontSize: 7.5,
                                        color: GameConstants.parchmentLight,
                                      ),
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Bottom Actions: Gift Button & Romance Options
              _buildActionToolbar(rel),

              // Gift Picker Panel (if open)
              if (_showGiftPicker) _buildGiftPicker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(NpcRelationship rel) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.npcId.displayName,
                  style: const TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: GameConstants.rusticWoodDark,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${widget.npcId.title})',
                  style: const TextStyle(fontSize: 9, color: Colors.brown),
                ),
              ],
            ),
            const SizedBox(height: 3),
            // Hearts meter (0 to 10 hearts)
            Row(
              children: [
                Text(
                  '❤️' * rel.hearts + '🤍' * (10 - rel.hearts),
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(width: 6),
                Text(
                  '${rel.status.icon} ${rel.status.label}',
                  style: TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: rel.status == RelationshipStatus.dating
                        ? Colors.pink[800]
                        : rel.status == RelationshipStatus.married
                            ? Colors.purple[800]
                            : Colors.brown[800],
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: widget.onClose,
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
    );
  }

  Widget _buildPortrait() {
    final expr = _currentNode.expression;
    final portraitPath = 'assets/images/portraits/${widget.npcId.name}_$expr.png';

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GameConstants.rusticWood, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          portraitPath,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Center(
            child: Text(
              widget.npcId.displayName[0],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionToolbar(NpcRelationship rel) {
    return Row(
      children: [
        // Gift Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: rel.giftedToday ? Colors.grey : GameConstants.rusticWood,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
          onPressed: rel.giftedToday
              ? null
              : () {
                  setState(() {
                    _showGiftPicker = !_showGiftPicker;
                  });
                },
          icon: const Text('🎁', style: TextStyle(fontSize: 12)),
          label: Text(
            rel.giftedToday ? 'Presente Entregue Hoje' : 'Dar Presente',
            style: const TextStyle(
              fontFamily: GameConstants.fontPixel,
              fontSize: 7.5,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Romance: Moonflower Amulet (8 hearts)
        if (widget.npcId.isMarriageCandidate &&
            rel.hearts >= 8 &&
            rel.status != RelationshipStatus.dating &&
            rel.status != RelationshipStatus.married)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[800],
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            onPressed: () {
              widget.game.relationships.giveMoonflowerAmulet(widget.npcId);
              ValleyMoonAudioManager().playSFX('chime.ogg');
              _startTypewriter('Você me entregou o Amuleto da Flor Lunar?! Eu aceito namorar você! 💖');
              setState(() {});
            },
            icon: const Text('💖', style: TextStyle(fontSize: 12)),
            label: const Text(
              'Dar Amuleto Lunar',
              style: TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, color: Colors.white),
            ),
          ),

        // Marriage Proposal (10 hearts)
        if (widget.npcId.isMarriageCandidate &&
            rel.hearts >= 10 &&
            rel.status == RelationshipStatus.dating)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[800],
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            onPressed: () {
              widget.game.relationships.proposeMarriage(widget.npcId);
              ValleyMoonAudioManager().playSFX('chime.ogg');
              _startTypewriter('Sim, sim! Eu me caso com você! Vamos cuidar deste vale juntos para sempre! 💍✨');
              setState(() {});
            },
            icon: const Text('💍', style: TextStyle(fontSize: 12)),
            label: const Text(
              'Propor Casamento',
              style: TextStyle(fontFamily: GameConstants.fontPixel, fontSize: 7, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildGiftPicker() {
    final inv = widget.game.inventory;
    final availableItems = [...inv.hotbar, ...inv.backpack]
        .where((s) => s != null && s.count > 0)
        .map((s) => s!.item)
        .toSet()
        .toList();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GameConstants.rusticWood),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escolha um item para presentear:',
            style: TextStyle(
              fontFamily: GameConstants.fontPixel,
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              color: GameConstants.rusticWoodDark,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableItems.map((item) {
                return GestureDetector(
                  onTap: () => _giveGift(item),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: GameConstants.parchmentLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: GameConstants.rusticWood),
                    ),
                    child: Row(
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          item.name,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
