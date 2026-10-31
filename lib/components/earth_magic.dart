import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';

/// Espantalho Vivo (Living Scarecrow) - Protects 5x5 tiles against crows & Silent Ash Fog.
class ScarecrowComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  final int gridX;
  final int gridY;
  Sprite? sprite;
  double _glowPulse = 0.0;

  ScarecrowComponent({
    required this.gridX,
    required this.gridY,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(16, 32),
          anchor: Anchor.bottomCenter,
          priority: position.y.toInt() + 10,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final img = await game.images.load(GameConstants.scarecrowImg);
    sprite = Sprite(img);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _glowPulse += dt * 3;
  }

  /// Checks if a tile is within the 5x5 protective aura (radius 2 tiles)
  bool protectsTile(int tx, int ty) {
    return (tx - gridX).abs() <= 2 && (ty - gridY).abs() <= 2;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite?.render(canvas, size: size);

    // Subtle living rune pulse from eyes/chest
    final pulseAlpha = (120 + 80 * sin(_glowPulse)).toInt().clamp(0, 255);
    final glowPaint = Paint()
      ..color = Color.fromARGB(pulseAlpha, 255, 220, 60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(const Offset(8, 8), 3, glowPaint);
  }
}

/// Totem de Chuva (Rain Totem) - Waters a 3x3 radius every morning with runic water.
class RainTotemComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  final int gridX;
  final int gridY;
  Sprite? sprite;
  double _waterPulse = 0.0;

  RainTotemComponent({
    required this.gridX,
    required this.gridY,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(16, 32),
          anchor: Anchor.bottomCenter,
          priority: position.y.toInt() + 10,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final img = await game.images.load(GameConstants.rainTotemImg);
    sprite = Sprite(img);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _waterPulse += dt * 2.5;
  }

  /// Checks if a tile is within the 3x3 automatic watering aura (radius 1 tile)
  bool watersTile(int tx, int ty) {
    return (tx - gridX).abs() <= 1 && (ty - gridY).abs() <= 1;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite?.render(canvas, size: size);

    // Aquamarine moisture rune pulse
    final pulseAlpha = (100 + 70 * sin(_waterPulse)).toInt().clamp(0, 255);
    final runePaint = Paint()
      ..color = Color.fromARGB(pulseAlpha, 80, 230, 255)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(const Offset(8, 16), 4, runePaint);
  }
}
