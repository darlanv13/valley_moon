import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/save_system.dart';

/// Pixel Art Title Screen for Valley Moon:
/// - Luminous Full Moon backdrop & rustic logo
/// - Novo Jogo (New Game)
/// - Continuar (Load Save from Hive)
/// - Configurações & Controles (Audio & Keybindings)
class TitleScreenOverlay extends StatefulWidget {
  final ValleyMoonGame game;
  final VoidCallback onStartGame;

  const TitleScreenOverlay({
    super.key,
    required this.game,
    required this.onStartGame,
  });

  @override
  State<TitleScreenOverlay> createState() => _TitleScreenOverlayState();
}

class _TitleScreenOverlayState extends State<TitleScreenOverlay> {
  bool _showSettings = false;
  bool _hasSave = false;

  @override
  void initState() {
    super.initState();
    _checkSave();
    widget.game.playBGM(GameConstants.bgmVillage);
  }

  void _checkSave() {
    setState(() {
      _hasSave = SaveManager.hasSaveGame();
    });
  }

  void _onNewGame() {
    widget.game.playSFX(GameConstants.sfxWoodClick);
    widget.onStartGame();
  }

  Future<void> _onContinue() async {
    widget.game.playSFX(GameConstants.sfxWoodClick);
    final success = await SaveManager.loadGame(widget.game);
    if (success) {
      widget.game.playSFX(GameConstants.sfxVictory);
    }
    widget.onStartGame();
  }

  void _toggleSettings() {
    widget.game.playSFX(GameConstants.sfxWoodClick);
    setState(() {
      _showSettings = !_showSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF140F0A),
      child: Stack(
        children: [
          // 1. Ambient Starry Night Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    Color(0xFF283A4A),
                    Color(0xFF141A24),
                    Color(0xFF0A0B10),
                  ],
                ),
              ),
            ),
          ),

          // 2. Center Content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Full Moon & Valley Moon Pixel Art Logo
                  Image.asset(
                    'assets/images/ui/title_logo.png',
                    width: 260,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'VALLEY MOON',
                    style: TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'O Segredo da Roça Mística & As Fases do Luar',
                    style: TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 7,
                      color: Color(0xFFDCC8A0),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (!_showSettings) ...[
                    // NOVO JOGO
                    _buildMenuButton(
                      label: 'NOVO JOGO',
                      icon: '🌱',
                      onTap: _onNewGame,
                    ),

                    const SizedBox(height: 8),

                    // CONTINUAR (Save Game)
                    _buildMenuButton(
                      label: _hasSave ? 'CONTINUAR FAZENDA' : 'SEM REGISTRO',
                      icon: '📖',
                      isEnabled: _hasSave,
                      onTap: _hasSave ? _onContinue : null,
                    ),

                    const SizedBox(height: 8),

                    // CONFIGURAÇÕES & CONTROLES
                    _buildMenuButton(
                      label: 'CONFIGURAÇÕES & GUIA',
                      icon: '⚙️',
                      onTap: _toggleSettings,
                    ),
                  ] else ...[
                    _buildSettingsPanel(),
                  ],

                  const SizedBox(height: 16),

                  const Text(
                    'Versão 1.0.0 • Antigravity 2D Pixel RPG • Feito em Flutter & Flame',
                    style: TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 6,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required String icon,
    required VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? GameConstants.rusticWood : Colors.grey[800],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isEnabled ? Colors.amber : Colors.black45,
            width: 2,
          ),
          boxShadow: isEnabled
              ? const [
                  BoxShadow(color: Colors.black54, offset: Offset(2, 3), blurRadius: 4),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: GameConstants.fontPixel,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: isEnabled ? GameConstants.parchmentLight : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameConstants.parchmentLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GameConstants.rusticWood, width: 3),
      ),
      child: Column(
        children: [
          const Text(
            'CONTROLES & CONFIGURAÇÕES',
            style: TextStyle(
              fontFamily: GameConstants.fontPixel,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: GameConstants.rusticWoodDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Movimento: W, A, S, D ou Joystick Touch\n'
            '• Usar Ferramenta / Atacar: E ou Botão USAR\n'
            '• Esquiva (Dash): Espaço ou Botão DASH\n'
            '• Mochila / Inventário: Tecla I ou B\n'
            '• Diário do Avô & Altares: Tecla J\n'
            '• Forja & Bigorna de Kael: Tecla K\n'
            '• Pescar no Rio / Lago: Tecla F\n'
            '• Salvar Jogo: Durma na cama da fazenda',
            style: TextStyle(
              fontFamily: GameConstants.fontPixel,
              fontSize: 6,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Áudio: ${widget.game.audioEnabled ? "LIGADO 🔊" : "MUDO 🔇"}',
                style: const TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 7,
                  color: GameConstants.rusticWoodDark,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.game.audioEnabled = !widget.game.audioEnabled;
                    if (!widget.game.audioEnabled) {
                      widget.game.audioManager.stop();
                    } else {
                      widget.game.playBGM(GameConstants.bgmVillage);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: GameConstants.rusticWood,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ALTERNAR',
                    style: TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _toggleSettings,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: GameConstants.rusticWoodDark,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VOLTAR',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 7,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

