import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/artisan_system.dart';
import '../models/cabin_and_family_system.dart';
import 'map_transition.dart';

/// Renders the player's married spouse on the farm cabin porch.
class SpouseComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  Sprite? spouseSprite;
  bool isPlayerNearby = false;
  double _heartTimer = 0.0;
  bool _showHearts = false;

  SpouseComponent()
      : super(
          position: Vector2(210, 145),
          size: Vector2(16, 24),
          anchor: Anchor.bottomCenter,
          priority: 150,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadSpouseSprite();
  }

  Future<void> _loadSpouseSprite() async {
    final spouseId = game.family.spouseId;
    if (spouseId == null) return;

    final npcsImage = await game.images.load('characters/npcs.png');
    spouseSprite = Sprite(
      npcsImage,
      srcPosition: Vector2(0, spouseId.index * 24.0),
      srcSize: Vector2(16, 24),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.family.spouseId == null) return;
    if (spouseSprite == null) {
      _loadSpouseSprite();
    }

    if (_showHearts) {
      _heartTimer -= dt;
      if (_heartTimer <= 0) {
        _showHearts = false;
      }
    }

    // Only visible when player is on the farm
    if (game.currentLocation != GameLocation.farm) return;

    final dist = (position - game.player.position).length;
    isPlayerNearby = dist <= 32.0;
  }

  @override
  void render(Canvas canvas) {
    if (game.family.spouseId == null) return;
    if (game.currentLocation != GameLocation.farm) return;

    super.render(canvas);

    if (spouseSprite != null) {
      spouseSprite!.render(canvas, size: size);
    }

    // Nearby interaction indicator
    if (isPlayerNearby) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '💖 [E]',
          style: const TextStyle(
            color: Color(0xFFFF8DA1),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(-8, -14));
    }

    // Floating heart effect on kiss
    if (_showHearts) {
      final heartPainter = TextPainter(
        text: const TextSpan(
          text: '💖 ✨ 💖',
          style: TextStyle(fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      heartPainter.paint(canvas, Offset(-14, -28 - (1.5 - _heartTimer) * 10));
    }
  }

  void interact() {
    if (game.family.spouseId == null) return;

    // Trigger kiss/hug
    game.family.kissSpouse(game.relationships);
    _showHearts = true;
    _heartTimer = 1.5;
    game.playSFX(GameConstants.sfxAnimalPet);

    // If spouse has daily gift, deliver to player
    final gift = game.family.claimDailySpouseGift(game.inventory);
    if (gift != null) {
      game.playSFX(GameConstants.sfxCoins);
    }

    // Open dialogue
    game.openDialogueWithNpc(game.family.spouseId!);
  }
}

/// Renders a child (baby in crib or toddler playing) on the farm.
class ChildComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  final ChildData child;
  Sprite? childSprite;
  bool isPlayerNearby = false;
  double _wanderTimer = 0.0;
  final Vector2 _wanderTarget = Vector2.zero();
  final Random _rng = Random();

  ChildComponent({
    required this.child,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(24, 24),
          anchor: Anchor.bottomCenter,
          priority: 140,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final childSheet = await game.images.load(GameConstants.childrenSheet);

    if (child.stage == ChildStage.baby) {
      // Frame A (0, 0, 32, 32)
      childSprite = Sprite(
        childSheet,
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(32, 32),
      );
    } else {
      // Toddler: boy at (64, 0), girl at (96, 0)
      final srcX = child.isBoy ? 64.0 : 96.0;
      childSprite = Sprite(
        childSheet,
        srcPosition: Vector2(srcX, 0),
        srcSize: Vector2(32, 32),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.currentLocation != GameLocation.farm) return;

    final dist = (position - game.player.position).length;
    isPlayerNearby = dist <= 28.0;

    // Toddler wandering AI
    if (child.stage == ChildStage.toddler) {
      _wanderTimer -= dt;
      if (_wanderTimer <= 0) {
        _wanderTimer = 2.0 + _rng.nextDouble() * 3.0;
        _wanderTarget.setValues(
          180.0 + _rng.nextDouble() * 80.0,
          140.0 + _rng.nextDouble() * 40.0,
        );
      }

      // Smooth step towards target
      final diff = _wanderTarget - position;
      if (diff.length > 2.0) {
        position += diff.normalized() * (15.0 * dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (game.currentLocation != GameLocation.farm) return;
    super.render(canvas);

    if (childSprite != null) {
      childSprite!.render(canvas, size: size);
    }

    if (isPlayerNearby) {
      final label = child.stage == ChildStage.baby ? '👶 Ninar' : '🧸 Brincar';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Color(0xFFFFD54F),
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-4, -12));
    }
  }

  void interact() {
    final played = child.playWithChild();
    if (played) {
      game.playSFX(GameConstants.sfxBabyGiggle);
    }
  }
}

/// Renders a rustic artisan machine placed on the farm with live progress feedback.
class ArtisanMachineComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  final ArtisanMachine machine;
  Sprite? machineSprite;
  bool isPlayerNearby = false;
  double _animTime = 0.0;

  ArtisanMachineComponent({
    required this.machine,
  }) : super(
          position: machine.position,
          size: Vector2(32, 32),
          anchor: Anchor.bottomCenter,
          priority: machine.position.y.toInt() + 10,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final machinesSheet = await game.images.load(GameConstants.artisanMachinesImg);

    // Each machine is 48x48 slice at x = type.index * 48
    final srcX = machine.type.index * 48.0;
    machineSprite = Sprite(
      machinesSheet,
      srcPosition: Vector2(srcX, 8),
      srcSize: Vector2(48, 48),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.currentLocation != GameLocation.farm) return;

    _animTime += dt;
    final dist = (position - game.player.position).length;
    isPlayerNearby = dist <= 32.0;
  }

  @override
  void render(Canvas canvas) {
    if (game.currentLocation != GameLocation.farm) return;
    super.render(canvas);

    if (machineSprite != null) {
      machineSprite!.render(canvas, size: size);
    }

    // Ready bouncing finished good icon!
    if (machine.isReady) {
      final bounceY = -24.0 + sin(_animTime * 6.0) * 3.0;
      final icon = machine.resultItem?.icon ?? '✨';
      final tp = TextPainter(
        text: TextSpan(
          text: icon,
          style: const TextStyle(fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(8, bounceY));

      // Harvest tooltip
      if (isPlayerNearby) {
        final tip = TextPainter(
          text: const TextSpan(
            text: '[E] Colher',
            style: TextStyle(
              color: Color(0xFF81C784),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tip.paint(canvas, Offset(0, -32));
      }
    } else if (machine.isProcessing) {
      // Processing steam/bubbles indicator
      final pct = (machine.progressPercentage * 100).toInt();
      final tip = TextPainter(
        text: TextSpan(
          text: '⏳ $pct%',
          style: const TextStyle(
            color: Color(0xFFFFD54F),
            fontSize: 7,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tip.paint(canvas, Offset(2, -12));
    } else if (isPlayerNearby) {
      // Idle tooltip
      final tip = TextPainter(
        text: TextSpan(
          text: machine.type.name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 7,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tip.paint(canvas, Offset(-4, -10));
    }
  }

  void interact() {
    if (machine.isReady) {
      final item = game.artisan.tryHarvest(machine, game.inventory);
      if (item != null) {
        game.playSFX(GameConstants.sfxCoins);
      }
    } else if (!machine.isProcessing) {
      // Try to auto-feed compatible item from inventory
      bool inserted = false;
      for (final slot in [...game.inventory.hotbar, ...game.inventory.backpack]) {
        if (slot == null) continue;
        if (game.artisan.tryInsertItem(machine, game.inventory, slot.item.id)) {
          inserted = true;
          game.playSFX(machine.type.sfx);
          break;
        }
      }

      if (!inserted) {
        // If not matched, open carpenter/artisan info or notify
        game.playSFX(GameConstants.sfxWoodClick);
      }
    }
  }
}
