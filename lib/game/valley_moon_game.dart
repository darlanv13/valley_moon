import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../components/farm_grid_manager.dart';
import '../components/farm_world.dart';
import '../components/lighting_and_weather.dart';
import '../components/player.dart';
import '../components/time_manager.dart';
import '../core/constants.dart';
import '../models/time_system.dart';

/// The central game class for Valley Moon.
class ValleyMoonGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late final FarmWorldComponent farmWorld;
  late final FarmGridManager farmGrid;
  late final PlayerComponent player;
  late final LightingOverlayComponent lightingOverlay;
  late final WeatherParticlesComponent weatherParticles;
  late final TimeManagerComponent timeManager;
  JoystickComponent? joystick;

  final GameState gameState = GameState();
  bool audioEnabled = true;

  ValleyMoonGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: GameConstants.virtualWidth,
            height: GameConstants.virtualHeight,
          ),
        );

  @override
  Color backgroundColor() => const Color(0xFF1B1713);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Load the Farm World (Tiled Map & Obstacles)
    farmWorld = FarmWorldComponent();
    await world.add(farmWorld);

    // 2. Add Farm Grid Manager (Interactive soil, crops, totems)
    farmGrid = FarmGridManager();
    await world.add(farmGrid);

    // 3. Instantiate and add Player at spawn point
    player = PlayerComponent(
      position: farmWorld.playerSpawnPosition,
    );
    await world.add(player);

    // 4. Add Weather Particle System
    weatherParticles = WeatherParticlesComponent();
    await world.add(weatherParticles);

    // 5. Add Dynamic Day/Night & Lunar Lighting Overlay
    lightingOverlay = LightingOverlayComponent();
    await world.add(lightingOverlay);

    // 6. Add Time & Calendar Manager
    timeManager = TimeManagerComponent();
    await add(timeManager);

    // 7. Configure Camera to follow player smoothly within map boundaries
    camera.follow(player);
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, GameConstants.mapWidth, GameConstants.mapHeight),
      considerViewport: true,
    );

    // 8. Setup Virtual Joystick on Viewport for Mobile/Touch
    _setupJoystick();

    // 9. Start Background Music
    _startAmbientMusic();
  }

  void _setupJoystick() {
    final knobPaint = Paint()
      ..color = const Color(0xCC4A3319)
      ..style = PaintingStyle.fill;
    final bgPaint = Paint()
      ..color = const Color(0x662C1D0F)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0x88DCC8A0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final backgroundComp = CircleComponent(radius: 36, paint: bgPaint)
      ..add(CircleComponent(radius: 36, paint: borderPaint));

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 16, paint: knobPaint),
      background: backgroundComp,
      margin: const EdgeInsets.only(left: 24, bottom: 24),
      priority: 100,
    );

    camera.viewport.add(joystick!);
  }

  void _startAmbientMusic() {
    try {
      if (audioEnabled) {
        FlameAudio.bgm.initialize();
        FlameAudio.bgm.play(GameConstants.bgmVillage, volume: 0.4);
      }
    } catch (_) {}
  }

  void playBGM(String track) {
    if (!audioEnabled) return;
    try {
      FlameAudio.bgm.play(track, volume: 0.4);
    } catch (_) {}
  }

  void playSFX(String sfxName) {
    if (!audioEnabled) return;
    try {
      FlameAudio.play(sfxName, volume: 0.6);
    } catch (_) {}
  }

  @override
  void onRemove() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
    super.onRemove();
  }
}
