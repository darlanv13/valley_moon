import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/accessibility_settings.dart';

/// Rustic Settings & Accessibility Dialog.
class SettingsDialog extends StatefulWidget {
  final ValleyMoonGame game;
  final VoidCallback onClose;

  const SettingsDialog({
    super.key,
    required this.game,
    required this.onClose,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  void initState() {
    super.initState();
    widget.game.playSFX(GameConstants.sfxWoodClick);
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.game.settings;
    final scale = settings.fontSizeMultiplier;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: Container(
        width: 560,
        height: 480,
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
                  const Text('⚙️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CONFIGURAÇÕES & ACESSIBILIDADE',
                      style: TextStyle(
                        fontFamily: GameConstants.fontPixel,
                        color: const Color(0xFFE8C88B),
                        fontSize: 10 * scale,
                        letterSpacing: 1.1,
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

            // Scrollable Settings Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Font Size Scaling
                  _buildSectionHeader('TAMANHO DO TEXTO & LEGIBILIDADE', scale),
                  _buildToggleRow(
                    icon: '🔍',
                    title: 'Textos Grandes (1.3x)',
                    subtitle: 'Aumenta a escala tipográfica de diálogos e menus.',
                    value: settings.isLargeFont,
                    scale: scale,
                    onChanged: (_) {
                      setState(() {
                        settings.toggleFontSize();
                      });
                      widget.game.playSFX(GameConstants.sfxWoodClick);
                    },
                  ),

                  const SizedBox(height: 12),

                  // 2. Screen Shake (Combat / Damage)
                  _buildSectionHeader('CONFORTO VISUAL & CINETOSE', scale),
                  _buildToggleRow(
                    icon: '📳',
                    title: 'Vibração de Tela (Screen Shake)',
                    subtitle: 'Desative caso sinta enjoo de movimento durante combates.',
                    value: settings.enableScreenShake,
                    scale: scale,
                    onChanged: (_) {
                      setState(() {
                        settings.toggleScreenShake();
                      });
                      widget.game.playSFX(GameConstants.sfxWoodClick);
                    },
                  ),

                  const SizedBox(height: 12),

                  // 3. Colorblindness Filters
                  _buildSectionHeader('FILTRO PARA DALTONISMO', scale),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF221811),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF5A3C20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ColorblindFilterType.values.map((type) {
                            final isSelected = settings.colorFilterType == type;
                            return ChoiceChip(
                              label: Text(
                                type.displayName,
                                style: TextStyle(
                                  fontFamily: GameConstants.fontPixel,
                                  fontSize: 8 * scale,
                                  color: isSelected ? Colors.white : const Color(0xFFB0987A),
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFF8B5A2B),
                              backgroundColor: const Color(0xFF1B140E),
                              onSelected: (_) {
                                setState(() {
                                  settings.setColorFilter(type);
                                });
                                widget.game.playSFX(GameConstants.sfxWoodClick);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          settings.colorFilterType.description,
                          style: TextStyle(
                            color: const Color(0xFFD7CCC8),
                            fontSize: 9 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Auto-Pause on Idle (Casual Mode)
                  _buildSectionHeader('RITMO DE JOGO (MODO CASUAL)', scale),
                  _buildToggleRow(
                    icon: '⏳',
                    title: 'Pausa Automática por Inatividade',
                    subtitle: 'Pausa o relógio do jogo ao ficar 10s parado, sem pressa.',
                    value: settings.enableAutoPauseOnIdle,
                    scale: scale,
                    onChanged: (_) {
                      setState(() {
                        settings.toggleAutoPauseOnIdle();
                      });
                      widget.game.playSFX(GameConstants.sfxWoodClick);
                    },
                  ),

                  const SizedBox(height: 12),

                  // 5. Visual Shaders & Volumetric Lighting
                  _buildSectionHeader('GRÁFICOS & SHADERS GLSL', scale),
                  _buildToggleRow(
                    icon: '🌊',
                    title: 'Shaders de Distorção de Água e Vento',
                    subtitle: 'Ondulação dinâmica de rio, lago e copas de árvores.',
                    value: settings.enableShaders,
                    scale: scale,
                    onChanged: (_) {
                      setState(() {
                        settings.toggleShaders();
                      });
                      widget.game.playSFX(GameConstants.sfxWoodClick);
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildToggleRow(
                    icon: '✨',
                    title: 'Luz Volumétrica & Vaga-lumes',
                    subtitle: 'Cintilação de lamparinas a óleo e enxame de vaga-lumes.',
                    value: settings.enableVolumetricLighting,
                    scale: scale,
                    onChanged: (_) {
                      setState(() {
                        settings.toggleVolumetricLighting();
                      });
                      widget.game.playSFX(GameConstants.sfxWoodClick);
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF1B140E),
              child: SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5A2B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(color: Color(0xFFE8C88B)),
                    ),
                  ),
                  onPressed: widget.onClose,
                  child: Text(
                    'CONCLUIR & VOLTAR AO VALE',
                    style: TextStyle(
                      fontFamily: GameConstants.fontPixel,
                      fontSize: 9 * scale,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double scale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: GameConstants.fontPixel,
          fontSize: 8 * scale,
          color: const Color(0xFFE8C88B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required double scale,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF221811),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF5A3C20)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 8.5 * scale,
                    color: const Color(0xFFFFD54F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFFD7CCC8),
                    fontSize: 8.5 * scale,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF81C784),
            activeTrackColor: const Color(0xFF388E3C),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[800],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
