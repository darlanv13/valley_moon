import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/time_system.dart';
import 'obstacle.dart';

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

  void performAction(FarmerTool tool) {
    if (isPerformingAction) return;

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
        switch (facing) {
          case Direction.down: current = PlayerState.axeDown; break;
          case Direction.up: current = PlayerState.axeUp; break;
          case Direction.left: current = PlayerState.axeLeft; break;
          case Direction.right: current = PlayerState.axeRight; break;
        }
        break;
      case FarmerTool.hoe:
        game.playSFX(GameConstants.sfxToolSwing);
        game.gameState.useEnergy(1.5);
        switch (facing) {
          case Direction.down: current = PlayerState.hoeDown; break;
          case Direction.up: current = PlayerState.hoeUp; break;
          case Direction.left: current = PlayerState.hoeLeft; break;
          case Direction.right: current = PlayerState.hoeRight; break;
        }
        break;
      case FarmerTool.wateringCan:
        game.playSFX(GameConstants.sfxToolSwing);
        game.gameState.useEnergy(1.0);
        switch (facing) {
          case Direction.down: current = PlayerState.waterDown; break;
          case Direction.up: current = PlayerState.waterUp; break;
          case Direction.left: current = PlayerState.waterLeft; break;
          case Direction.right: current = PlayerState.waterRight; break;
        }
        break;
      case FarmerTool.pickaxe:
        game.playSFX(GameConstants.sfxChop);
        game.gameState.useEnergy(2.0);
        switch (facing) {
          case Direction.down: current = PlayerState.pickaxeDown; break;
          case Direction.up: current = PlayerState.pickaxeUp; break;
          case Direction.left: current = PlayerState.pickaxeLeft; break;
          case Direction.right: current = PlayerState.pickaxeRight; break;
        }
        break;
      case FarmerTool.sword:
      case FarmerTool.sickle:
        game.playSFX(GameConstants.sfxToolSwing);
        game.gameState.useEnergy(1.0);
        switch (facing) {
          case Direction.down: current = PlayerState.swordDown; break;
          case Direction.up: current = PlayerState.swordUp; break;
          case Direction.left: current = PlayerState.swordLeft; break;
          case Direction.right: current = PlayerState.swordRight; break;
        }
        break;
      case FarmerTool.hands:
      case FarmerTool.seedsTurnip:
      case FarmerTool.seedsWheat:
      case FarmerTool.seedsScreamRoot:
      case FarmerTool.seedsDewBlossom:
      case FarmerTool.seedsGoldenWheat:
      case FarmerTool.placeScarecrow:
      case FarmerTool.placeRainTotem:
        game.playSFX(GameConstants.sfxToolSwing);
        switch (facing) {
          case Direction.down: current = PlayerState.hoeDown; break;
          case Direction.up: current = PlayerState.hoeUp; break;
          case Direction.left: current = PlayerState.hoeLeft; break;
          case Direction.right: current = PlayerState.hoeRight; break;
        }
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isPerformingAction) {
      _actionTimer -= dt;
      if (_actionTimer <= 0) {
        isPerformingAction = false;
        _updateAnimation(Vector2.zero());
      }
      return;
    }

    // Determine movement direction: Combine keyboard and virtual joystick
    final moveDir = Vector2.zero();

    // Check joystick first
    if (game.joystick != null && !game.joystick!.relativeDelta.isZero()) {
      moveDir.setFrom(game.joystick!.relativeDelta);
    } else {
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

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is ObstacleComponent) {
      // Restore previous safe position to prevent wall penetration
      position.setFrom(_previousPosition);
    }
  }
}
