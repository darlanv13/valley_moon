import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/animal_component.dart';
import '../components/farm_grid_manager.dart';
import '../components/farm_world.dart';
import '../components/lighting_and_weather.dart';
import '../components/map_transition.dart';
import '../components/npc_component.dart';
import '../components/player.dart';
import '../components/time_manager.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../models/animal_system.dart';
import '../models/fishing_system.dart';
import '../models/inventory_system.dart';
import '../models/npc_dialogue_system.dart';
import '../models/story_system.dart';
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
  final RelationshipManager relationships = RelationshipManager();
  final StoryManager story = StoryManager();
  final AnimalManager animals = AnimalManager();

  GameLocation currentLocation = GameLocation.farm;
  NpcId? activeDialogueNpc;
  FishData? activeFishingFish;
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

    // 5. Add World NPCs with dynamic schedules
    for (final npcId in NpcId.values) {
      final npc = NpcComponent(
        npcId: npcId,
        position: Vector2(180 + npcId.index * 36.0, 160),
      );
      await world.add(npc);
    }

    // 6. Add Farm Animals & Mystical Creatures
    for (int i = 0; i < animals.animals.length; i++) {
      final a = animals.animals[i];
      final homePos = Vector2(130.0 + (i % 4) * 36.0, 240.0 + (i ~/ 4) * 32.0);
      final animalComp = AnimalComponent(
        animal: a,
        spawnPosition: homePos,
        homeBarnPosition: homePos,
      );
      await world.add(animalComp);
    }

    // 7. Add Map Portals / Transitions
    await _setupMapPortals();

    // 8. Add Weather Particle System
    weatherParticles = WeatherParticlesComponent();
    await world.add(weatherParticles);

    // 9. Add Dynamic Day/Night & Lunar Lighting Overlay
    lightingOverlay = LightingOverlayComponent();
    await world.add(lightingOverlay);

    // 10. Add Time & Calendar Manager
    timeManager = TimeManagerComponent();
    await add(timeManager);

    // 11. Connect Reactive Hooks for Animals & Relationships
    gameState.onNewDayStarted = () {
      animals.onNewDay();
      animals.updateWeatherAndShelter(gameState);
      relationships.onNewDay();
    };

    gameState.addListener(() {
      animals.updateWeatherAndShelter(gameState);
    });

    // 12. Configure Camera to follow player smoothly within map boundaries
    camera.follow(player);
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, GameConstants.mapWidth, GameConstants.mapHeight),
      considerViewport: true,
    );

    // 11. Setup Virtual Joystick on Viewport for Mobile/Touch
    _setupJoystick();

    // 12. Start Initial Daytime Music
    playBGM(GameConstants.bgmVillage);
  }

  Future<void> _setupMapPortals() async {
    // East Exit: Farm -> Village
    await world.add(MapTransitionComponent(
      targetLocation: GameLocation.village,
      targetSpawnPosition: Vector2(40, 240),
      position: Vector2(624, 200),
      size: Vector2(16, 80),
      portalName: 'Caminho para a Vila da Lareira',
    ));

    // North Exit: Farm -> Forest
    await world.add(MapTransitionComponent(
      targetLocation: GameLocation.forest,
      targetSpawnPosition: Vector2(300, 420),
      position: Vector2(280, 0),
      size: Vector2(80, 16),
      portalName: 'Floresta Sussurrante',
    ));

    // West Exit: Farm -> Mine Entrance
    await world.add(MapTransitionComponent(
      targetLocation: GameLocation.mineEntrance,
      targetSpawnPosition: Vector2(580, 240),
      position: Vector2(0, 200),
      size: Vector2(16, 80),
      portalName: 'Entrada da Mina Antiga',
    ));
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

  void transitionTo(GameLocation target, Vector2 spawnPos) {
    currentLocation = target;
    if (isLoaded) {
      player.position.setFrom(spawnPos);
    }

    switch (target) {
      case GameLocation.farm:
      case GameLocation.village:
        playBGM(GameConstants.bgmVillage);
        break;
      case GameLocation.forest:
      case GameLocation.tavern:
        playBGM(GameConstants.bgmForest);
        break;
      case GameLocation.mineEntrance:
        playBGM(GameConstants.bgmWind);
        break;
    }
  }

  void openDialogueWithNpc(NpcId id) {
    activeDialogueNpc = id;
    overlays.add('Dialogue');
  }

  void openDiaryAndAltars() {
    if (overlays.isActive('DiaryAltars')) {
      overlays.remove('DiaryAltars');
    } else {
      overlays.add('DiaryAltars');
    }
  }

  void startFishing([FishData? customFish]) {
    if (customFish != null) {
      activeFishingFish = customFish;
    } else {
      final hasMoonBait = inventory.countOf('pot_moon_bait') > 0;
      final rolled = FishData.rollFish(
        location: currentLocation,
        state: gameState,
        hasMoonBait: hasMoonBait,
      );
      if (rolled.requiresMoonBait && hasMoonBait) {
        inventory.consumeIngredients({'pot_moon_bait': 1});
      }
      activeFishingFish = rolled;
    }
    try {
      overlays.add('FishingMinigame');
    } catch (_) {}
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

      // Toggle Grandfather's Diary & Altars with 'J'
      if (event.logicalKey == LogicalKeyboardKey.keyJ) {
        openDiaryAndAltars();
        return KeyEventResult.handled;
      }

      // Quick Fish action with 'F'
      if (event.logicalKey == LogicalKeyboardKey.keyF) {
        startFishing();
        return KeyEventResult.handled;
      }

      // Interact with nearby NPC or Farm Animal with 'E' or 'Enter'
      if (event.logicalKey == LogicalKeyboardKey.keyE ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        for (final child in world.children.whereType<NpcComponent>()) {
          if (child.isPlayerNearby) {
            child.interact();
            return KeyEventResult.handled;
          }
        }
        for (final child in world.children.whereType<AnimalComponent>()) {
          if (child.isPlayerNearby) {
            child.interact();
            return KeyEventResult.handled;
          }
        }
      }

      // Close modal on Escape
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (overlays.isActive('FishingMinigame')) overlays.remove('FishingMinigame');
        if (overlays.isActive('Dialogue')) overlays.remove('Dialogue');
        if (overlays.isActive('DiaryAltars')) overlays.remove('DiaryAltars');
        if (overlays.isActive('Inventory')) overlays.remove('Inventory');
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
