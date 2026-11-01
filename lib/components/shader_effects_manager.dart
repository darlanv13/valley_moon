import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/valley_moon_game.dart';
import '../models/time_system.dart';
import 'map_transition.dart';

/// Preloads and manages compiled Flutter Fragment Programs.
class ShaderManager {
  static ui.FragmentProgram? _waterProgram;
  static ui.FragmentProgram? _windProgram;
  static bool isInitialized = false;

  static Future<void> initialize() async {
    if (isInitialized) return;
    try {
      _waterProgram = await ui.FragmentProgram.fromAsset(
        'assets/shaders/water_distortion.frag',
      );
      _windProgram = await ui.FragmentProgram.fromAsset(
        'assets/shaders/wind_foliage.frag',
      );
      isInitialized = true;
    } catch (_) {
      // In headless unit tests or environments lacking GLSL GPU pipeline,
      // fallback to high-performance math rendering without throwing.
      isInitialized = true;
    }
  }

  static ui.FragmentShader? createWaterShader() => _waterProgram?.fragmentShader();
  static ui.FragmentShader? createWindShader() => _windProgram?.fragmentShader();
}

/// Renders real-time water wave ripples and reflections with GLSL Fragment Shader.
class WaterDistortionOverlayComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  ui.FragmentShader? _shader;
  double _elapsedTime = 0.0;

  // River and pond rects on the farm map (world coordinates)
  final List<Rect> waterZones = [
    const Rect.fromLTWH(0, 340, 640, 80),    // South river
    const Rect.fromLTWH(420, 100, 140, 110), // East pond
  ];

  WaterDistortionOverlayComponent()
      : super(
          position: Vector2.zero(),
          size: Vector2(640, 480),
          priority: 25, // Above ground tiles, below player and crops
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await ShaderManager.initialize();
    _shader = ShaderManager.createWaterShader();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;
  }

  @override
  void render(Canvas canvas) {
    if (game.currentLocation != GameLocation.farm) return;

    final enableShaders = game.settings.enableShaders;
    final isRaining = game.gameState.weather == WeatherType.rain;
    final distortion = isRaining ? 1.6 : 1.0;

    for (final zone in waterZones) {
      if (_shader != null && enableShaders) {
        // Uniform 0, 1: Resolution (Width, Height)
        _shader!.setFloat(0, zone.width);
        _shader!.setFloat(1, zone.height);
        // Uniform 2: Time
        _shader!.setFloat(2, _elapsedTime);
        // Uniform 3: Distortion Strength
        _shader!.setFloat(3, distortion);

        final paint = Paint()..shader = _shader;
        canvas.drawRect(zone, paint);
      } else {
        // High-performance CPU fallback: gentle sinusoidal water ripple reflections
        final paint = Paint()
          ..color = const Color(0x3564B5F6)
          ..style = PaintingStyle.fill;
        canvas.drawRect(zone, paint);

        final ripplePaint = Paint()
          ..color = const Color(0x40E1F5FE)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;

        for (double y = zone.top + 8; y < zone.bottom - 4; y += 14) {
          final path = Path();
          final offset = sin((y + _elapsedTime * 40.0) * 0.1) * 4.0;
          path.moveTo(zone.left, y + offset);
          for (double x = zone.left; x < zone.right; x += 20) {
            final wave = sin((x * 0.08) + (_elapsedTime * 3.0)) * 2.0;
            path.lineTo(x, y + wave + offset);
          }
          canvas.drawPath(path, ripplePaint);
        }
      }
    }
  }
}

/// Particle representing a snowy footprint left by the player during Winter.
class SnowFootprint {
  final Vector2 position;
  final bool isLeftFoot;
  double lifeTime;
  final double maxLifeTime;

  SnowFootprint({
    required this.position,
    required this.isLeftFoot,
    this.maxLifeTime = 4.0,
  }) : lifeTime = maxLifeTime;

  bool get isDead => lifeTime <= 0;
  double get opacity => (lifeTime / maxLifeTime).clamp(0.0, 1.0);
}

/// Particle representing a dust puff kicked up when dashing.
class DustPuff {
  Vector2 position;
  Vector2 velocity;
  double radius;
  double lifeTime;
  final double maxLifeTime;

  DustPuff({
    required this.position,
    required this.velocity,
    this.radius = 3.5,
    this.maxLifeTime = 0.5,
  }) : lifeTime = maxLifeTime;

  bool get isDead => lifeTime <= 0;
  double get opacity => (lifeTime / maxLifeTime).clamp(0.0, 1.0);
}

/// A glowing firefly that drifts naturally in the evening and night air.
class Firefly {
  Vector2 position;
  double phaseOffset;
  double speed;
  double size;

  Firefly({
    required this.position,
    required this.phaseOffset,
    this.speed = 12.0,
    this.size = 2.5,
  });

  void update(double dt, double time) {
    position.x += sin(time * 1.2 + phaseOffset) * speed * dt;
    position.y += cos(time * 0.9 + phaseOffset * 1.5) * (speed * 0.7) * dt;
  }
}

/// Reactive Particles on Player: Snow Footsteps in Winter & Dust Puffs on Dash.
class PlayerReactiveParticlesComponent extends Component
    with HasGameReference<ValleyMoonGame> {
  final List<SnowFootprint> footprints = [];
  final List<DustPuff> dustPuffs = [];
  final Vector2 _lastPlayerPos = Vector2.zero();
  double _footstepTimer = 0.0;
  bool _footToggle = false;
  final Random _rng = Random();

  @override
  void update(double dt) {
    super.update(dt);

    if (isMounted) {
      final player = game.player;
      final currentPos = player.position;

      // 1. Snow Footprints (Only in Winter when player moves)
      if (game.gameState.season == Season.winter) {
        final movedDist = (currentPos - _lastPlayerPos).length;
        if (movedDist > 1.0) {
          _footstepTimer += dt;
          if (_footstepTimer >= 0.30) {
            _footstepTimer = 0.0;
            _footToggle = !_footToggle;
            final footOffset = _footToggle ? Vector2(-3, 0) : Vector2(3, 0);
            footprints.add(SnowFootprint(
              position: currentPos + footOffset,
              isLeftFoot: _footToggle,
            ));
          }
        }
      }
      _lastPlayerPos.setFrom(currentPos);
    }

    // Update footprint lifespans
    for (int i = footprints.length - 1; i >= 0; i--) {
      footprints[i].lifeTime -= dt;
      if (footprints[i].isDead) {
        footprints.removeAt(i);
      }
    }

    // 2. Update Dust Puffs
    for (int i = dustPuffs.length - 1; i >= 0; i--) {
      final p = dustPuffs[i];
      p.lifeTime -= dt;
      p.position += p.velocity * dt;
      p.radius += dt * 3.0; // Expands as it dissipates
      if (p.isDead) {
        dustPuffs.removeAt(i);
      }
    }
  }

  /// Spawns a burst of dust particles behind player when dashing.
  void spawnDashDust(Vector2 origin, Vector2 direction) {
    final backward = -direction.normalized();
    for (int i = 0; i < 7; i++) {
      final spread = (_rng.nextDouble() - 0.5) * 1.2;
      final speed = 30.0 + _rng.nextDouble() * 35.0;
      final vel = Vector2(
        backward.x * speed + spread * 15.0,
        backward.y * speed + spread * 15.0,
      );
      dustPuffs.add(DustPuff(
        position: origin.clone() + Vector2((_rng.nextDouble() - 0.5) * 6, (_rng.nextDouble() - 0.5) * 4),
        velocity: vel,
        radius: 2.5 + _rng.nextDouble() * 2.0,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render Snow Footprints
    for (final fp in footprints) {
      final paint = Paint()
        ..color = Color.fromRGBO(190, 215, 235, fp.opacity * 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(fp.position.x, fp.position.y),
          width: 3.5,
          height: 5.0,
        ),
        paint,
      );
    }

    // Render Dust Puffs
    for (final p in dustPuffs) {
      final paint = Paint()
        ..color = Color.fromRGBO(160, 130, 95, p.opacity * 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.position.x, p.position.y), p.radius, paint);
    }
  }
}

/// Volumetric rustic lighting system: flickering oil lamps, warm halos, and evening fireflies.
class VolumetricLightingAndFirefliesComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  final List<Firefly> fireflies = [];
  double _elapsedTime = 0.0;
  final Random _rng = Random();

  // Positions of rustic lanterns and hearths on the farm
  final List<Vector2> lampPositions = [
    Vector2(195, 125), // Cabin porch lantern
    Vector2(290, 130), // Well oil lamp
    Vector2(120, 220), // Barn entrance lantern
    Vector2(320, 210), // Artisan workshop lantern
  ];

  VolumetricLightingAndFirefliesComponent()
      : super(
          position: Vector2.zero(),
          size: Vector2(640, 480),
          priority: 200, // Above normal entities to cast ambient glow
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Spawn 14 evening fireflies scattered around farm flora
    for (int i = 0; i < 14; i++) {
      fireflies.add(Firefly(
        position: Vector2(
          80.0 + _rng.nextDouble() * 480.0,
          80.0 + _rng.nextDouble() * 320.0,
        ),
        phaseOffset: _rng.nextDouble() * 2 * pi,
        speed: 10.0 + _rng.nextDouble() * 8.0,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;

    final shouldDrift = !isMounted || game.gameState.isNight || game.gameState.hour >= 18;
    if (shouldDrift) {
      for (final f in fireflies) {
        f.update(dt, _elapsedTime);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (game.currentLocation != GameLocation.farm) return;
    if (!game.settings.enableVolumetricLighting) return;

    super.render(canvas);

    final isNight = game.gameState.isNight;
    final isDusk = game.gameState.hour >= 17 && game.gameState.hour < 20;

    // 1. Render Flickering Volumetric Halos around Oil Lanterns
    for (final lamp in lampPositions) {
      // Stochastic sinusoidal flicker simulates flickering oil wick
      final flicker = sin(_elapsedTime * 8.5 + lamp.x) * 0.07 +
          cos(_elapsedTime * 17.2 + lamp.y) * 0.04;
      final baseRadius = isNight ? 42.0 : 28.0;
      final radius = baseRadius * (1.0 + flicker);
      final alpha = (isNight ? 0.35 : 0.18) * (1.0 + flicker);

      final gradient = ui.Gradient.radial(
        Offset(lamp.x, lamp.y),
        radius,
        [
          Color.fromRGBO(255, 210, 110, alpha),
          Color.fromRGBO(255, 170, 60, alpha * 0.45),
          const Color(0x00FF8000),
        ],
        [0.0, 0.45, 1.0],
      );

      final paint = Paint()
        ..shader = gradient
        ..blendMode = BlendMode.screen;
      canvas.drawCircle(Offset(lamp.x, lamp.y), radius, paint);
    }

    // 2. Render Bioluminescent Fireflies at Dusk and Night
    if (isNight || isDusk) {
      for (final f in fireflies) {
        final glowPulse = (sin(_elapsedTime * 3.5 + f.phaseOffset) + 1.0) * 0.5;
        if (glowPulse < 0.15) continue; // Firefly dark interval

        final glowRadius = 5.0 + glowPulse * 4.0;
        final glowPaint = Paint()
          ..color = Color.fromRGBO(210, 255, 90, glowPulse * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
        canvas.drawCircle(Offset(f.position.x, f.position.y), glowRadius, glowPaint);

        // Core bright spark
        final corePaint = Paint()
          ..color = Color.fromRGBO(255, 255, 200, glowPulse * 0.9)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(f.position.x, f.position.y), f.size, corePaint);
      }
    }
  }
}
