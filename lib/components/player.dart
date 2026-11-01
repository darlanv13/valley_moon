import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/time_system.dart';
import 'animal_component.dart';
import 'combat_and_mine_components.dart';
import 'farm_tile.dart';
import 'npc_component.dart';
import 'obstacle.dart';
import 'shader_effects_manager.dart';

enum Direction { down, up, left, right }

enum PlayerState {
  idleDown,
  idleUp,
  idleLeft,
  idleRight,
  walkDown,
  walkUp,
  walkLeft,
  walkRight,
  axeDown,
  axeUp,
  axeLeft,
  axeRight,
  hoeDown,
  hoeUp,
  hoeLeft,
  hoeRight,
  waterDown,
  waterUp,
  waterLeft,
  waterRight,
  pickaxeDown,
  pickaxeUp,
  pickaxeLeft,
  pickaxeRight,
  swordDown,
  swordUp,
  swordLeft,
  swordRight,
}

class PlayerComponent extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<ValleyMoonGame>, KeyboardHandler, CollisionCallbacks {
  Direction facing = Direction.down;
  final Vector2 _velocity = Vector2.zero();
  final Vector2 _keyboardDirection = Vector2.zero();
  final Vector2 _previousPosition = Vector2.zero();

  bool isPerformingAction = false;
  double _actionTimer = 0.0;
  static const double actionDuration = 0.35;

  double _footstepTimer = 0.0;
  static const double footstepInterval = 0.35;

  bool _isDashing = false;
  double _dashTimer = 0.0;
  double _dashCooldown = 0.0;

  Vector2? _targetTapPosition;

  void walkTo(Vector2 worldTarget) {
    _targetTapPosition = worldTarget.clone();
    game.settings.registerPlayerActivity();
  }

  void stopMoving() {
    _targetTapPosition = null;
    _velocity.setZero();
  }

  /// Context-sensitive Smart Tap:
  /// - Tapping an adjacent interactable resource/soil/NPC uses the appropriate tool or interacts.
  /// - Tapping an empty space walks smoothly towards that location.
  void smartTap(Vector2 worldTarget) {
    game.gamepad.setTouchMode();
    game.settings.registerPlayerActivity();

    final dist = (worldTarget - position).length;

    // 1. If tapping nearby (within ~48px), interact with tile/entity directly
    if (dist <= 52.0) {
      // Face target
      final diff = worldTarget - position;
      if (diff.x.abs() > diff.y.abs()) {
        facing = diff.x > 0 ? Direction.right : Direction.left;
      } else {
        facing = diff.y > 0 ? Direction.down : Direction.up;
      }

      // Check Obstacle (Tree, Stump, Rock)
      for (final obs in game.world.children.whereType<ObstacleComponent>()) {
        if ((obs.position - worldTarget).length <= 26.0) {
          final nameLower = obs.obstacleName.toLowerCase();
          if (nameLower.contains('rock') || nameLower.contains('pedra') || nameLower.contains('mine')) {
            game.gameState.selectTool(FarmerTool.pickaxe);
            performAction(FarmerTool.pickaxe);
            return;
          } else if (nameLower.contains('tree') || nameLower.contains('arvore') || nameLower.contains('tronco') || nameLower.contains('stump')) {
            game.gameState.selectTool(FarmerTool.axe);
            performAction(FarmerTool.axe);
            return;
          }
        }
      }

      // Check Farm Tile
      final gx = (worldTarget.x / GameConstants.tileSize).floor();
      final gy = (worldTarget.y / GameConstants.tileSize).floor();
      final tile = game.farmGrid.tiles['$gx,$gy'];
      if (tile != null) {
        if (tile.crop != null && tile.crop!.isMature) {
          game.gameState.selectTool(FarmerTool.sickle);
          performAction(FarmerTool.sickle);
          return;
        } else if (tile.soilState == TileSoilState.unplowed) {
          game.gameState.selectTool(FarmerTool.hoe);
          performAction(FarmerTool.hoe);
          return;
        } else if (tile.soilState == TileSoilState.plowedDry) {
          game.gameState.selectTool(FarmerTool.wateringCan);
          performAction(FarmerTool.wateringCan);
          return;
        }
      }

      // Check nearby NPC or Animal
      for (final npc in game.world.children.whereType<NpcComponent>()) {
        if ((npc.position - worldTarget).length <= 32.0) {
          npc.interact();
          return;
        }
      }
      for (final a in game.world.children.whereType<AnimalComponent>()) {
        if ((a.position - worldTarget).length <= 32.0) {
          a.interact();
          return;
        }
      }
    }

    // 2. Empty ground: walk towards destination
    walkTo(worldTarget);
  }

  bool get isInvincible => _isDashing;

  // Collision hitbox: centered at the character's feet (in 48x48 cell)
  late final RectangleHitbox feetHitbox;

  PlayerComponent({required super.position})
      : super(
          size: Vector2.all(48),
          anchor: Anchor.center,
          priority: 10,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Configure paint for sharp pixel art
    paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none;

    // Load animations from images
    await _loadAnimations();

    // Hitbox at the feet of the 48x48 sprite:
    // Character feet are roughly located at x=18..30, y=26..32
    feetHitbox = RectangleHitbox(
      position: Vector2(18, 26),
      size: Vector2(12, 6),
      isSolid: true,
    );
    add(feetHitbox);

    current = PlayerState.idleDown;
    _previousPosition.setFrom(position);
  }

  Future<void> _loadAnimations() async {
    final walkImage = await game.images.load('player/player_walk.png');
    final actionsImage = await game.images.load('player/player_actions.png');

    SpriteAnimation createAnim(
      dynamic img, {
      required int row,
      required int startCol,
      required int frameCount,
      required double stepTime,
      bool loop = true,
    }) {
      final sprites = <Sprite>[];
      for (var i = 0; i < frameCount; i++) {
        sprites.add(
          Sprite(
            img,
            srcPosition: Vector2((startCol + i) * 48.0, row * 48.0),
            srcSize: Vector2.all(48.0),
          ),
        );
      }
      return SpriteAnimation.spriteList(sprites, stepTime: stepTime, loop: loop);
    }

    animations = {
      // Idle (Col 0..1, row 0..3)
      PlayerState.idleDown: createAnim(walkImage, row: 0, startCol: 0, frameCount: 2, stepTime: 0.35),
      PlayerState.idleUp: createAnim(walkImage, row: 1, startCol: 0, frameCount: 2, stepTime: 0.35),
      PlayerState.idleLeft: createAnim(walkImage, row: 2, startCol: 0, frameCount: 2, stepTime: 0.35),
      PlayerState.idleRight: createAnim(walkImage, row: 3, startCol: 0, frameCount: 2, stepTime: 0.35),

      // Walk (Col 2..3, row 0..3)
      PlayerState.walkDown: createAnim(walkImage, row: 0, startCol: 2, frameCount: 2, stepTime: 0.16),
      PlayerState.walkUp: createAnim(walkImage, row: 1, startCol: 2, frameCount: 2, stepTime: 0.16),
      PlayerState.walkLeft: createAnim(walkImage, row: 2, startCol: 2, frameCount: 2, stepTime: 0.16),
      PlayerState.walkRight: createAnim(walkImage, row: 3, startCol: 2, frameCount: 2, stepTime: 0.16),

      // Axe Action (Rows 0..3, cols 0..1)
      PlayerState.axeDown: createAnim(actionsImage, row: 0, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.axeUp: createAnim(actionsImage, row: 1, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.axeLeft: createAnim(actionsImage, row: 2, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.axeRight: createAnim(actionsImage, row: 3, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),

      // Hoe Action (Rows 4..7, cols 0..1)
      PlayerState.hoeDown: createAnim(actionsImage, row: 4, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.hoeUp: createAnim(actionsImage, row: 5, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.hoeLeft: createAnim(actionsImage, row: 6, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.hoeRight: createAnim(actionsImage, row: 7, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),

      // Watering Action (Rows 8..11, cols 0..1)
      PlayerState.waterDown: createAnim(actionsImage, row: 8, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.waterUp: createAnim(actionsImage, row: 9, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.waterLeft: createAnim(actionsImage, row: 10, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.waterRight: createAnim(actionsImage, row: 11, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),

      // Pickaxe Action (Mining strike)
      PlayerState.pickaxeDown: createAnim(actionsImage, row: 4, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.pickaxeUp: createAnim(actionsImage, row: 5, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.pickaxeLeft: createAnim(actionsImage, row: 6, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),
      PlayerState.pickaxeRight: createAnim(actionsImage, row: 7, startCol: 0, frameCount: 2, stepTime: 0.18, loop: false),

      // Sword Action (Slash)
      PlayerState.swordDown: createAnim(actionsImage, row: 0, startCol: 0, frameCount: 2, stepTime: 0.15, loop: false),
      PlayerState.swordUp: createAnim(actionsImage, row: 1, startCol: 0, frameCount: 2, stepTime: 0.15, loop: false),
      PlayerState.swordLeft: createAnim(actionsImage, row: 2, startCol: 0, frameCount: 2, stepTime: 0.15, loop: false),
      PlayerState.swordRight: createAnim(actionsImage, row: 3, startCol: 0, frameCount: 2, stepTime: 0.15, loop: false),
    };
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardDirection.setZero();

    // Horizontal WASD & Arrows
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _keyboardDirection.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _keyboardDirection.x += 1;
    }

    // Vertical WASD & Arrows
    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      _keyboardDirection.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      _keyboardDirection.y += 1;
    }

    // Action Key (Space / Enter / Key E)
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.keyE)) {
      performAction(game.gameState.selectedTool);
    }

    return true;
  }

  bool performDash() {
    if (_dashCooldown > 0 || isPerformingAction) return false;
    _isDashing = true;
    _dashTimer = 0.18;
    _dashCooldown = 0.65;
    game.playSFX(GameConstants.sfxDash);

    final dashDir = Vector2.zero();
    switch (facing) {
      case Direction.down: dashDir.y = 1; break;
      case Direction.up: dashDir.y = -1; break;
      case Direction.left: dashDir.x = -1; break;
      case Direction.right: dashDir.x = 1; break;
    }
    _velocity.setFrom(dashDir * (GameConstants.playerRunSpeed * 1.8));

    // Spawn dust puff particles
    for (final p in game.world.children.whereType<PlayerReactiveParticlesComponent>()) {
      p.spawnDashDust(position, dashDir);
    }

    // Camera screen shake if enabled
    if (game.settings.enableScreenShake) {
      game.triggerScreenShake(duration: 0.15, intensity: 2.5);
    }

    game.settings.registerPlayerActivity();
    return true;
  }

  void performAction(FarmerTool tool) {
    game.settings.registerPlayerActivity();
    if (isPerformingAction) return;

    // Check if player is near any NPC or Animal when interacting with hands or brush
    if (tool == FarmerTool.hands || tool == FarmerTool.brush) {
      for (final child in game.world.children.whereType<NpcComponent>()) {
        if (child.isPlayerNearby) {
          child.interact();
          return;
        }
      }
      for (final child in game.world.children.whereType<AnimalComponent>()) {
        if (child.isPlayerNearby) {
          child.interact();
          return;
        }
      }
    }

    if (tool == FarmerTool.fishingRod) {
      game.startFishing();
      return;
    }

    isPerformingAction = true;
    _actionTimer = actionDuration;

    // Target the farm tile directly in front of the player
    final targetPos = position.clone();
    switch (facing) {
      case Direction.down: targetPos.y += 18; break;
      case Direction.up: targetPos.y -= 18; break;
      case Direction.left: targetPos.x -= 18; break;
      case Direction.right: targetPos.x += 18; break;
    }
    game.farmGrid.interact(targetPos, tool);

    // Trigger tool animation
    switch (tool) {
      case FarmerTool.axe:
        game.playSFX(GameConstants.sfxChop);
        game.gameState.useEnergy(2.0);
        if (animations != null) {
          switch (facing) {
            case Direction.down: current = PlayerState.axeDown; break;
            case Direction.up: current = PlayerState.axeUp; break;
            case Direction.left: current = PlayerState.axeLeft; break;
            case Direction.right: current = PlayerState.axeRight; break;
          }
        }
        break;
      case FarmerTool.hoe:
        game.playSFX(GameConstants.sfxToolSwing);
        game.gameState.useEnergy(1.5);
        if (animations != null) {
          switch (facing) {
            case Direction.down: current = PlayerState.hoeDown; break;
            case Direction.up: current = PlayerState.hoeUp; break;
            case Direction.left: current = PlayerState.hoeLeft; break;
            case Direction.right: current = PlayerState.hoeRight; break;
          }
        }
        break;
      case FarmerTool.wateringCan:
        game.playSFX(GameConstants.sfxToolSwing);
        game.gameState.useEnergy(1.0);
        if (animations != null) {
          switch (facing) {
            case Direction.down: current = PlayerState.waterDown; break;
            case Direction.up: current = PlayerState.waterUp; break;
            case Direction.left: current = PlayerState.waterLeft; break;
            case Direction.right: current = PlayerState.waterRight; break;
          }
        }
        break;
      case FarmerTool.pickaxe:
        game.playSFX(GameConstants.sfxChop);
        game.gameState.useEnergy(2.0);
        if (animations != null) {
          switch (facing) {
            case Direction.down: current = PlayerState.pickaxeDown; break;
            case Direction.up: current = PlayerState.pickaxeUp; break;
            case Direction.left: current = PlayerState.pickaxeLeft; break;
            case Direction.right: current = PlayerState.pickaxeRight; break;
          }
        }
        break;
      case FarmerTool.sword:
      case FarmerTool.sickle:
        game.playSFX(GameConstants.sfxToolSwing);
        game.gameState.useEnergy(1.0);

        // Spawn Melee Slash Arc
        game.world.add(SlashArcComponent(position: targetPos));

        // Knockback direction
        final knockback = Vector2.zero();
        switch (facing) {
          case Direction.down: knockback.y = 1; if (animations != null) current = PlayerState.swordDown; break;
          case Direction.up: knockback.y = -1; if (animations != null) current = PlayerState.swordUp; break;
          case Direction.left: knockback.x = -1; if (animations != null) current = PlayerState.swordLeft; break;
          case Direction.right: knockback.x = 1; if (animations != null) current = PlayerState.swordRight; break;
        }

        // Hit monsters in range
        final meleeDamage = game.combat.calculateMeleeDamage();
        for (final monster in game.world.children.whereType<MonsterComponent>()) {
          if ((monster.position - targetPos).length <= 28.0) {
            monster.takeDamage(meleeDamage, knockback);
          }
        }

        // If equipped with Runic Staff, fire magic projectile
        if (game.combat.equipment.weapon?.id == 'weapon_runic_staff') {
          game.playSFX(GameConstants.sfxMagicCast);
          game.world.add(MagicProjectileComponent(
            position: position.clone(),
            velocity: knockback * 200.0,
            damage: game.combat.calculateMagicDamage(),
          ));
        }
        break;
      case FarmerTool.hands:
      case FarmerTool.brush:
      case FarmerTool.fishingRod:
      case FarmerTool.seedsTurnip:
      case FarmerTool.seedsWheat:
      case FarmerTool.seedsScreamRoot:
      case FarmerTool.seedsDewBlossom:
      case FarmerTool.seedsGoldenWheat:
      case FarmerTool.placeScarecrow:
      case FarmerTool.placeRainTotem:
        game.playSFX(GameConstants.sfxToolSwing);
        if (animations != null) {
          switch (facing) {
            case Direction.down: current = PlayerState.hoeDown; break;
            case Direction.up: current = PlayerState.hoeUp; break;
            case Direction.left: current = PlayerState.hoeLeft; break;
            case Direction.right: current = PlayerState.hoeRight; break;
          }
        }
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_dashCooldown > 0) _dashCooldown -= dt;

    if (_isDashing) {
      _dashTimer -= dt;
      position.add(_velocity * dt);
      if (_dashTimer <= 0) {
        _isDashing = false;
        _velocity.setZero();
      }
      return;
    }

    if (isPerformingAction) {
      _actionTimer -= dt;
      if (_actionTimer <= 0) {
        isPerformingAction = false;
        _updateAnimation(Vector2.zero());
      }
      return;
    }

    // Determine movement direction: Combine Smart Tap, Gamepad, Virtual Joystick and Keyboard
    final moveDir = Vector2.zero();

    // 1. Smart Tap-to-move path
    if (_targetTapPosition != null) {
      final diff = _targetTapPosition! - position;
      if (diff.length > 5.0) {
        moveDir.setFrom(diff.normalized());
      } else {
        _targetTapPosition = null;
        _velocity.setZero();
      }
    }

    // 2. Physical Gamepad Analog Stick / D-Pad
    if (!game.gamepad.leftStickDirection.isZero()) {
      _targetTapPosition = null;
      moveDir.setFrom(game.gamepad.leftStickDirection);
    }
    // 3. Virtual Touch Joystick
    else if (game.joystick != null && !game.joystick!.relativeDelta.isZero()) {
      _targetTapPosition = null;
      moveDir.setFrom(game.joystick!.relativeDelta);
    }
    // 4. Keyboard Arrow / WASD keys
    else if (!_keyboardDirection.isZero()) {
      _targetTapPosition = null;
      moveDir.setFrom(_keyboardDirection);
    }

    if (!moveDir.isZero()) {
      moveDir.normalize();
      _velocity.setFrom(moveDir * GameConstants.playerWalkSpeed);

      // Save previous position before moving
      _previousPosition.setFrom(position);

      // Move player
      position.add(_velocity * dt);

      // Dynamic Y sorting (depth ordering): components further down render in front
      priority = position.y.toInt();

      // Footstep sound logic
      _footstepTimer += dt;
      if (_footstepTimer >= footstepInterval) {
        _footstepTimer = 0.0;
        game.playSFX(GameConstants.sfxFootstep);
      }
    } else {
      _velocity.setZero();
      _footstepTimer = 0.0;
    }

    _updateAnimation(moveDir);
  }

  void _updateAnimation(Vector2 moveDir) {
    if (isPerformingAction) return;

    final isMoving = !moveDir.isZero();

    // Determine facing direction from movement
    if (isMoving) {
      if (moveDir.y.abs() > moveDir.x.abs()) {
        facing = moveDir.y > 0 ? Direction.down : Direction.up;
      } else {
        facing = moveDir.x > 0 ? Direction.right : Direction.left;
      }
    }

    // Assign appropriate animation state
    if (animations != null) {
      if (isMoving) {
        switch (facing) {
          case Direction.down: current = PlayerState.walkDown; break;
          case Direction.up: current = PlayerState.walkUp; break;
          case Direction.left: current = PlayerState.walkLeft; break;
          case Direction.right: current = PlayerState.walkRight; break;
        }
      } else {
        switch (facing) {
          case Direction.down: current = PlayerState.idleDown; break;
          case Direction.up: current = PlayerState.idleUp; break;
          case Direction.left: current = PlayerState.idleLeft; break;
          case Direction.right: current = PlayerState.idleRight; break;
        }
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is ObstacleComponent) {
      // Restore previous safe position to prevent wall penetration
      position.setFrom(_previousPosition);
    }
  }
}
