import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/time_system.dart';

/// Dynamic lighting overlay simulating Day/Night, Sunset, Moonlight, and Blood Moon.
class LightingOverlayComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  LightingOverlayComponent()
      : super(
          size: Vector2(GameConstants.mapWidth, GameConstants.mapHeight),
          priority: 40,
        );

  Color _getAmbientColor() {
    final state = game.gameState;
    final time = state.hour + (state.minute / 60.0);

    // Blood Moon overrides night color with an ominous crimson haze
    if (state.moonPhase == MoonPhase.bloodMoon && (time >= 19.0 || time < 5.0)) {
      return const Color(0xCC5A0D15);
    }

    // 06:00 - 08:00 (Dawn)
    if (time >= 6.0 && time < 8.0) {
      final t = (time - 6.0) / 2.0;
      return Color.lerp(
        const Color(0x88423456),
        const Color(0x00FFFFFF),
        t,
      )!;
    }

    // 08:00 - 17:00 (Full Daylight)
    if (time >= 8.0 && time < 17.0) {
      return const Color(0x00FFFFFF);
    }

    // 17:00 - 19:30 (Warm Golden Sunset)
    if (time >= 17.0 && time < 19.5) {
      final t = (time - 17.0) / 2.5;
      return Color.lerp(
        const Color(0x00FFFFFF),
        const Color(0x88CC6A28), // Golden amber sunset
        t,
      )!;
    }

    // 19:30 - 21:00 (Twilight into Night)
    if (time >= 19.5 && time < 21.0) {
      final t = (time - 19.5) / 1.5;
      final nightColor = state.moonPhase == MoonPhase.fullMoon
          ? const Color(0xBB1E2C52) // Silver-blue Full Moonlight
          : const Color(0xDD12182E); // Deep dark night

      return Color.lerp(
        const Color(0x88CC6A28),
        nightColor,
        t,
      )!;
    }

    // 21:00 - 05:00 (Deep Night)
    if (state.moonPhase == MoonPhase.fullMoon) {
      return const Color(0xBB1E2C52);
    }
    return const Color(0xDD12182E);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final ambientColor = _getAmbientColor();
    if (ambientColor.a == 0) return;

    final bounds = Rect.fromLTWH(0, 0, size.x, size.y);

    // Use saveLayer to punch light holes through the darkness
    canvas.saveLayer(bounds, Paint());

    // 1. Fill darkness
    canvas.drawRect(bounds, Paint()..color = ambientColor);

    // 2. Punch cutout light for Player's Oil Lamp
    final playerPos = game.player.position;
    final lampPaint = Paint()
      ..blendMode = BlendMode.dstOut
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0x88FFFFFF),
          const Color(0x00FFFFFF),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(playerPos.x, playerPos.y), radius: 50),
      );

    canvas.drawCircle(Offset(playerPos.x, playerPos.y), 50, lampPaint);

    // 3. Punch glowing light for Moonstone Totem Altar (x=80, y=80)
    final totemPaint = Paint()
      ..blendMode = BlendMode.dstOut
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0x00FFFFFF),
        ],
      ).createShader(
        Rect.fromCircle(center: const Offset(80, 80), radius: 36),
      );
    canvas.drawCircle(const Offset(80, 80), 36, totemPaint);

    // 4. Punch lights for mature magical crops
    for (final tile in game.farmGrid.tiles.values) {
      if (tile.crop != null && tile.crop!.isMature && tile.crop!.type.isMagical) {
        final cx = tile.position.x + 8;
        final cy = tile.position.y + 8;
        final cropLight = Paint()
          ..blendMode = BlendMode.dstOut
          ..shader = RadialGradient(
            colors: [
              const Color(0xCCFFFFFF),
              const Color(0x00FFFFFF),
            ],
          ).createShader(
            Rect.fromCircle(center: Offset(cx, cy), radius: 22),
          );
        canvas.drawCircle(Offset(cx, cy), 22, cropLight);
      }
    }

    canvas.restore();
  }
}

/// Weather Particles Component: Rain, Dense Mist (Cinza Silenciosa), and Autumn Leaves.
class WeatherParticlesComponent extends Component
    with HasGameReference<ValleyMoonGame> {
  final List<_RainDrop> _rainDrops = [];
  final List<_AutumnLeaf> _leaves = [];
  final List<_FogCloud> _fogClouds = [];
  final Random _rng = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize 60 rain drops
    for (var i = 0; i < 60; i++) {
      _rainDrops.add(_RainDrop(
        x: _rng.nextDouble() * GameConstants.mapWidth,
        y: _rng.nextDouble() * GameConstants.mapHeight,
        speed: 160 + _rng.nextDouble() * 80,
        length: 5 + _rng.nextDouble() * 5,
      ));
    }

    // Initialize 25 autumn leaves
    for (var i = 0; i < 25; i++) {
      _leaves.add(_AutumnLeaf(
        x: _rng.nextDouble() * GameConstants.mapWidth,
        y: _rng.nextDouble() * GameConstants.mapHeight,
        speedX: 20 + _rng.nextDouble() * 25,
        speedY: 25 + _rng.nextDouble() * 30,
        color: _rng.nextBool()
            ? const Color(0xFFD66D28) // Russet amber
            : const Color(0xFFE5A638), // Golden leaf
      ));
    }

    // Initialize 4 drifting fog clouds
    for (var i = 0; i < 4; i++) {
      _fogClouds.add(_FogCloud(
        x: _rng.nextDouble() * GameConstants.mapWidth,
        y: i * 90.0,
        speedX: 10 + _rng.nextDouble() * 12,
        radius: 120 + _rng.nextDouble() * 60,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final weather = game.gameState.weather;

    // Rain
    if (weather == WeatherType.rain) {
      for (final drop in _rainDrops) {
        drop.y += drop.speed * dt;
        drop.x -= 20 * dt; // slight wind slant
        if (drop.y > GameConstants.mapHeight) {
          drop.y = -10;
          drop.x = _rng.nextDouble() * (GameConstants.mapWidth + 50);
        }
      }
    }

    // Autumn Leaves
    if (weather == WeatherType.autumnLeaves) {
      for (final leaf in _leaves) {
        leaf.y += leaf.speedY * dt;
        leaf.x += (leaf.speedX + sin(leaf.y * 0.05) * 15) * dt;
        if (leaf.y > GameConstants.mapHeight || leaf.x > GameConstants.mapWidth) {
          leaf.y = -10;
          leaf.x = _rng.nextDouble() * GameConstants.mapWidth;
        }
      }
    }

    // Dense Fog / Cinza Silenciosa
    if (weather == WeatherType.fog) {
      for (final fog in _fogClouds) {
        fog.x += fog.speedX * dt;
        if (fog.x - fog.radius > GameConstants.mapWidth) {
          fog.x = -fog.radius;
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final weather = game.gameState.weather;

    // 1. Rain
    if (weather == WeatherType.rain) {
      final rainPaint = Paint()
        ..color = const Color(0x99A8D5E5)
        ..strokeWidth = 1.2;

      for (final drop in _rainDrops) {
        canvas.drawLine(
          Offset(drop.x, drop.y),
          Offset(drop.x - 2, drop.y + drop.length),
          rainPaint,
        );
      }
    }

    // 2. Autumn Leaves
    if (weather == WeatherType.autumnLeaves) {
      for (final leaf in _leaves) {
        final leafPaint = Paint()..color = leaf.color;
        canvas.drawCircle(Offset(leaf.x, leaf.y), 2.2, leafPaint);
      }
    }

    // 3. Dense Fog / Cinza Silenciosa
    if (weather == WeatherType.fog) {
      final isBlood = game.gameState.moonPhase == MoonPhase.bloodMoon;
      final fogPaint = Paint()
        ..color = isBlood
            ? const Color(0x33882025) // Blood ash
            : const Color(0x33A0A8B8) // Pale ghost mist
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

      for (final fog in _fogClouds) {
        canvas.drawCircle(Offset(fog.x, fog.y), fog.radius, fogPaint);
      }
    }
  }
}

class _RainDrop {
  double x;
  double y;
  double speed;
  double length;

  _RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
  });
}

class _AutumnLeaf {
  double x;
  double y;
  double speedX;
  double speedY;
  Color color;

  _AutumnLeaf({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.color,
  });
}

class _FogCloud {
  double x;
  double y;
  double speedX;
  double radius;

  _FogCloud({
    required this.x,
    required this.y,
    required this.speedX,
    required this.radius,
  });
}
