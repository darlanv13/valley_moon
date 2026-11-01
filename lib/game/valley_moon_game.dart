import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/animal_component.dart';
import '../components/boss_component.dart';
import '../components/combat_and_mine_components.dart';
import '../components/farm_grid_manager.dart';
import '../components/farm_tile.dart';
import '../components/farm_world.dart';
import '../components/lighting_and_weather.dart';
import '../components/map_transition.dart';
import '../components/npc_component.dart';
import '../components/player.dart';
import '../components/spouse_and_child_components.dart';
import '../components/time_manager.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../models/act3_boss_system.dart';
import '../models/animal_system.dart';
import '../models/artisan_system.dart';
import '../models/cabin_and_family_system.dart';
import '../models/combat_and_mining_system.dart';
import '../models/festival_system.dart';
import '../models/fishing_system.dart';
import '../models/inventory_system.dart';
import '../models/npc_dialogue_system.dart';
import '../models/save_system.dart';
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
  final PlayerCombatStats combat = PlayerCombatStats();
  final MineFloorManager mine = MineFloorManager();
  final FestivalManager festivals = FestivalManager();
  final Act3BossState boss = Act3BossState();
  final CabinAndFamilyManager family = CabinAndFamilyManager();
  final ArtisanManager artisan = ArtisanManager();
  FestivalType? activeFestival;

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

    // 10.1 Add Spouse & Children Components on the Farm
    await world.add(SpouseComponent());

    // 10.2 Add Rustic Artisan Machines
    for (final machine in artisan.machines) {
      await world.add(ArtisanMachineComponent(machine: machine));
    }

    // 11. Connect Reactive Hooks for Animals & Relationships
    gameState.onNewDayStarted = () {
      animals.onNewDay();
      animals.updateWeatherAndShelter(gameState);
      relationships.onNewDay();
      family.executeMorningRoutine(
        onWaterCrops: (count) {
          int watered = 0;
          for (final tile in farmGrid.tiles.values) {
            if (tile.crop != null && tile.soilState == TileSoilState.plowedDry) {
              tile.water();
              watered++;
              if (watered >= count) break;
            }
          }
        },
        onFeedAnimals: () {
          for (final a in animals.animals) {
            a.isFed = true;
          }
        },
      );
      artisan.onNewDay();
      activeFestival = festivals.getActiveFestival(gameState.season, gameState.day);
      if (activeFestival != null) {
        playBGM(GameConstants.bgmFestival);
      }
      SaveManager.saveGame(this);
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
        if (mine.currentFloor >= 100) {
          loadFloor100Boss();
        } else {
          playBGM(GameConstants.bgmWind);
          if (mine.activeFloor == null) {
            mine.loadFloor(1, story: story);
          }
          spawnMineFloorMonsters();
        }
        break;
    }
  }

  void loadFloor100Boss() {
    playBGM(GameConstants.bgmBoss);
    for (final monster in world.children.whereType<MonsterComponent>().toList()) {
      monster.removeFromParent();
    }
    for (final arena in world.children.whereType<BossArenaComponent>().toList()) {
      arena.removeFromParent();
    }
    world.add(BossArenaComponent(
      bossState: boss,
      arenaCenter: Vector2(320, 240),
    ));
  }

  void openFestival([FestivalType? f]) {
    final fest = f ?? activeFestival ?? festivals.getActiveFestival(gameState.season, gameState.day) ?? FestivalType.firstSeed;
    activeFestival = fest;
    try {
      overlays.add('Festival');
    } catch (_) {}
  }

  void openAct3VictoryDialog() {
    try {
      overlays.add('Act3Victory');
    } catch (_) {}
  }

  Future<bool> saveCurrentGame() async {
    return await SaveManager.saveGame(this);
  }

  void spawnMineFloorMonsters() {
    if (mine.activeFloor == null) return;
    // Remove existing monsters from the world
    for (final monster in world.children.whereType<MonsterComponent>().toList()) {
      monster.removeFromParent();
    }
    // Spawn monsters from the current floor
    for (int i = 0; i < mine.activeFloor!.monsters.length; i++) {
      final mData = mine.activeFloor!.monsters[i];
      final pos = Vector2(
        100.0 + (i % 4) * 80.0,
        120.0 + (i ~/ 4) * 60.0,
      );
      world.add(MonsterComponent(data: mData, position: pos));
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

  void openForge() {
    if (overlays.isActive('Forge')) {
      overlays.remove('Forge');
    } else {
      try {
        overlays.add('Forge');
      } catch (_) {}
    }
  }

  void openCarpenter() {
    if (overlays.isActive('Carpenter')) {
      overlays.remove('Carpenter');
    } else {
      try {
        overlays.add('Carpenter');
      } catch (_) {}
    }
  }

  void openKitchen() {
    if (overlays.isActive('Kitchen')) {
      overlays.remove('Kitchen');
    } else {
      try {
        overlays.add('Kitchen');
      } catch (_) {}
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

      // Quick Dash dodge with Spacebar
      if (event.logicalKey == LogicalKeyboardKey.space) {
        player.performDash();
        return KeyEventResult.handled;
      }

      // Open Kael's Forge with 'K'
      if (event.logicalKey == LogicalKeyboardKey.keyK) {
        openForge();
        return KeyEventResult.handled;
      }

      // Open Seasonal Festival with 'P'
      if (event.logicalKey == LogicalKeyboardKey.keyP) {
        openFestival();
        return KeyEventResult.handled;
      }

      // Open Carpenter Shop with 'C'
      if (event.logicalKey == LogicalKeyboardKey.keyC) {
        openCarpenter();
        return KeyEventResult.handled;
      }

      // Open Wood Stove Kitchen with 'X'
      if (event.logicalKey == LogicalKeyboardKey.keyX) {
        openKitchen();
        return KeyEventResult.handled;
      }

      // Interact with nearby NPC, Farm Animal, Spouse, Child, or Machine with 'E' or 'Enter'
      if (event.logicalKey == LogicalKeyboardKey.keyE ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        for (final child in world.children.whereType<SpouseComponent>()) {
          if (child.isPlayerNearby) {
            child.interact();
            return KeyEventResult.handled;
          }
        }
        for (final child in world.children.whereType<ChildComponent>()) {
          if (child.isPlayerNearby) {
            child.interact();
            return KeyEventResult.handled;
          }
        }
        for (final child in world.children.whereType<ArtisanMachineComponent>()) {
          if (child.isPlayerNearby) {
            child.interact();
            return KeyEventResult.handled;
          }
        }
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
        if (overlays.isActive('Carpenter')) overlays.remove('Carpenter');
        if (overlays.isActive('Kitchen')) overlays.remove('Kitchen');
        if (overlays.isActive('Act3Victory')) overlays.remove('Act3Victory');
        if (overlays.isActive('Festival')) overlays.remove('Festival');
        if (overlays.isActive('Forge')) overlays.remove('Forge');
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
