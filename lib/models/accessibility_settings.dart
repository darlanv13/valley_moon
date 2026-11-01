import 'package:flutter/material.dart';

/// Supported accessibility color filters.
enum ColorblindFilterType {
  none('Desativado', 'Cores originais do vale sem alterações.'),
  protanopia('Protanopia', 'Ajusta tons avermelhados para melhor distinção de contraste.'),
  deuteranopia('Deuteranopia', 'Ajusta tons esverdeados comuns na vegetação e campos.'),
  tritanopia('Tritanopia', 'Ajusta tons azulados e amarelos para visão facilitada.'),
  highContrast('Alto Contraste', 'Aumenta saturação e contraste para máxima legibilidade.');

  final String displayName;
  final String description;

  const ColorblindFilterType(this.displayName, this.description);

  ColorFilter? get colorFilter {
    switch (this) {
      case ColorblindFilterType.none:
        return null;
      case ColorblindFilterType.protanopia:
        // Protanopia matrix (Red-blind)
        return const ColorFilter.matrix(<double>[
          0.567, 0.433, 0.000, 0, 0,
          0.558, 0.442, 0.000, 0, 0,
          0.000, 0.242, 0.758, 0, 0,
          0,     0,     0,     1, 0,
        ]);
      case ColorblindFilterType.deuteranopia:
        // Deuteranopia matrix (Green-blind)
        return const ColorFilter.matrix(<double>[
          0.625, 0.375, 0.000, 0, 0,
          0.700, 0.300, 0.000, 0, 0,
          0.000, 0.300, 0.700, 0, 0,
          0,     0,     0,     1, 0,
        ]);
      case ColorblindFilterType.tritanopia:
        // Tritanopia matrix (Blue-blind)
        return const ColorFilter.matrix(<double>[
          0.950, 0.050, 0.000, 0, 0,
          0.000, 0.433, 0.567, 0, 0,
          0.000, 0.475, 0.525, 0, 0,
          0,     0,     0,     1, 0,
        ]);
      case ColorblindFilterType.highContrast:
        // High contrast matrix (Contrast boost)
        return const ColorFilter.matrix(<double>[
          1.30, 0.00, 0.00, 0, -25,
          0.00, 1.30, 0.00, 0, -25,
          0.00, 0.00, 1.30, 0, -25,
          0,    0,    0,    1, 0,
        ]);
    }
  }
}

/// Central manager for Valley Moon Accessibility and Quality of Life settings.
class AccessibilitySettings extends ChangeNotifier {
  // 1. Font Size Scaling
  double fontSizeMultiplier = 1.0; // 1.0 = Normal, 1.3 = Textos Grandes

  // 2. Screen Shake
  bool enableScreenShake = true;

  // 3. Colorblind Accessibility Filter
  ColorblindFilterType colorFilterType = ColorblindFilterType.none;

  // 4. Auto-Pause on Idle (Casual Mode)
  bool enableAutoPauseOnIdle = true;
  double idleTimer = 0.0;
  bool isAutoPaused = false;

  // 5. Shader visual effects toggle (performance safety switch)
  bool enableShaders = true;
  bool enableVolumetricLighting = true;

  bool get isLargeFont => fontSizeMultiplier > 1.1;

  void toggleFontSize() {
    fontSizeMultiplier = fontSizeMultiplier > 1.1 ? 1.0 : 1.3;
    notifyListeners();
  }

  void toggleScreenShake() {
    enableScreenShake = !enableScreenShake;
    notifyListeners();
  }

  void setColorFilter(ColorblindFilterType type) {
    colorFilterType = type;
    notifyListeners();
  }

  void toggleAutoPauseOnIdle() {
    enableAutoPauseOnIdle = !enableAutoPauseOnIdle;
    if (!enableAutoPauseOnIdle) {
      isAutoPaused = false;
      idleTimer = 0.0;
    }
    notifyListeners();
  }

  void toggleShaders() {
    enableShaders = !enableShaders;
    notifyListeners();
  }

  void toggleVolumetricLighting() {
    enableVolumetricLighting = !enableVolumetricLighting;
    notifyListeners();
  }

  /// Called whenever player presses any key, taps screen, or moves.
  void registerPlayerActivity() {
    idleTimer = 0.0;
    if (isAutoPaused) {
      isAutoPaused = false;
      notifyListeners();
    }
  }

  /// Updates idle clock timer.
  void updateIdleCheck(double dt) {
    if (!enableAutoPauseOnIdle) return;

    if (!isAutoPaused) {
      idleTimer += dt;
      if (idleTimer >= 10.0) {
        isAutoPaused = true;
        notifyListeners();
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSizeMultiplier': fontSizeMultiplier,
      'enableScreenShake': enableScreenShake,
      'colorFilterType': colorFilterType.index,
      'enableAutoPauseOnIdle': enableAutoPauseOnIdle,
      'enableShaders': enableShaders,
      'enableVolumetricLighting': enableVolumetricLighting,
    };
  }

  void loadFromJson(Map<String, dynamic> json) {
    fontSizeMultiplier = (json['fontSizeMultiplier'] as num?)?.toDouble() ?? 1.0;
    enableScreenShake = json['enableScreenShake'] as bool? ?? true;
    final cIdx = json['colorFilterType'] as int? ?? 0;
    colorFilterType = ColorblindFilterType.values[cIdx.clamp(0, ColorblindFilterType.values.length - 1)];
    enableAutoPauseOnIdle = json['enableAutoPauseOnIdle'] as bool? ?? true;
    enableShaders = json['enableShaders'] as bool? ?? true;
    enableVolumetricLighting = json['enableVolumetricLighting'] as bool? ?? true;
    notifyListeners();
  }
}
