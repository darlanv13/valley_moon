import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/farm_grid_manager.dart';
import '../components/farm_world.dart';
import '../components/lighting_and_weather.dart';
import '../components/player.dart';
import '../components/time_manager.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../models/inventory_system.dart';
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
  final InventoryState inventory = InventoryState();
  final ValleyMoonAudioManager audioManager = ValleyMoonAudioManager();

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

    // 1. Initialize Audio Manager
    await audioManager.initialize();

    // 2. Load the Farm World (Tiled Map & Obstacles)
    farmWorld = FarmWorldComponent();
    await world.add(farmWorld);

    // 3. Add Farm Grid Manager (Interactive soil, crops, totems)
    farmGrid = FarmGridManager();
    await world.add(farmGrid);

    // 4. Instantiate and add Player at spawn point
    player = PlayerComponent(
      position: farmWorld.playerSpawnPosition,
    );
    await world.add(player);

    // 5. Add Weather Particle System
    weatherParticles = WeatherParticlesComponent();
    await world.add(weatherParticles);

    // 6. Add Dynamic Day/Night & Lunar Lighting Overlay
    lightingOverlay = LightingOverlayComponent();
    await world.add(lightingOverlay);

    // 7. Add Time & Calendar Manager
    timeManager = TimeManagerComponent();
    await add(timeManager);

    // 8. Configure Camera to follow player smoothly within map boundaries
    camera.follow(player);
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, GameConstants.mapWidth, GameConstants.mapHeight),
      considerViewport: true,
    );

    // 9. Setup Virtual Joystick on Viewport for Mobile/Touch
    _setupJoystick();

    // 10. Start Initial Daytime Music
    playBGM(GameConstants.bgmVillage);
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

  void playBGM(String track) {
    if (!audioEnabled) return;
    audioManager.crossfadeTo(track);
  }

  void playSFX(String sfxName) {
    if (!audioEnabled) return;
    audioManager.playSFX(sfxName);
  }

  void toggleInventory() {
    if (overlays.isActive('Inventory')) {
      overlays.remove('Inventory');
    } else {
      overlays.add('Inventory');
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      // Toggle Inventory Modal with 'I' or 'B'
      if (event.logicalKey == LogicalKeyboardKey.keyI ||
          event.logicalKey == LogicalKeyboardKey.keyB) {
        toggleInventory();
        return KeyEventResult.handled;
      }

      // Hotbar Quick Slots 1 to 0
      final hotbarKeys = [
        LogicalKeyboardKey.digit1,
        LogicalKeyboardKey.digit2,
        LogicalKeyboardKey.digit3,
        LogicalKeyboardKey.digit4,
        LogicalKeyboardKey.digit5,
        LogicalKeyboardKey.digit6,
        LogicalKeyboardKey.digit7,
        LogicalKeyboardKey.digit8,
        LogicalKeyboardKey.digit9,
        LogicalKeyboardKey.digit0,
      ];

      final keyIdx = hotbarKeys.indexOf(event.logicalKey);
      if (keyIdx != -1) {
        inventory.selectHotbarSlot(keyIdx);
        final item = inventory.selectedHotbarItem?.item;
        if (item?.associatedTool != null) {
          gameState.selectTool(item!.associatedTool!);
        }
        playSFX('wood_click.ogg');
        return KeyEventResult.handled;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onRemove() {
    audioManager.stop();
    super.onRemove();
  }
}
