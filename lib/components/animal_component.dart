import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/animal_system.dart';
import 'farm_tile.dart';

/// World Flame component representing a farm animal with roaming AI and heart emotes.
class AnimalComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  final FarmAnimal animal;
  final Vector2 homeBarnPosition;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation walkAnimation;
  SpriteAnimationComponent? _animComponent;
  Sprite? _heartSprite;

  final Random _rng = Random();
  double _roamTimer = 0.0;
  final Vector2 _roamTarget = Vector2.zero();
  bool _isMoving = false;
  static const double moveSpeed = 18.0;

  double _heartTimer = 0.0;
  bool isPlayerNearby = false;

  AnimalComponent({
    required this.animal,
    required Vector2 spawnPosition,
    required this.homeBarnPosition,
  }) : super(
          position: spawnPosition,
          size: Vector2(animal.species.frameWidth, animal.species.frameHeight),
          anchor: Anchor.bottomCenter,
          priority: spawnPosition.y.toInt(),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Load Animal Spritesheet
    final image = await game.images.load(animal.species.spriteAsset);
    final w = animal.species.frameWidth;
    final h = animal.species.frameHeight;

    idleAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.5,
        textureSize: Vector2(w, h),
      ),
    );

    walkAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.25,
        textureSize: Vector2(w, h),
        texturePosition: Vector2(w * 2, 0),
      ),
    );

    _animComponent = SpriteAnimationComponent(
      animation: idleAnimation,
      size: size,
      anchor: Anchor.topLeft,
    );
    await add(_animComponent!);

    // 2. Load Heart Emote Sprite
    final heartImg = await game.images.load('animals/heart_emote.png');
    _heartSprite = Sprite(heartImg);

    _roamTarget.setFrom(position);
    _roamTimer = 2.0 + _rng.nextDouble() * 3.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Weather & Shelter Check
    final isSheltered = !animal.isOutside;
    if (isSheltered) {
      // In shelter, stay near home barn
      position.setFrom(homeBarnPosition);
      _isMoving = false;
      _animComponent?.animation = idleAnimation;
      return;
    }

    // AI Wandering Roam Logic
    _roamTimer -= dt;
    if (_roamTimer <= 0) {
      _roamTimer = 3.0 + _rng.nextDouble() * 5.0;
      if (_rng.nextBool()) {
        // Pick random point around barn
        final ox = (_rng.nextDouble() - 0.5) * 80.0;
        final oy = (_rng.nextDouble() - 0.5) * 60.0;
        _roamTarget.setValues(
          (homeBarnPosition.x + ox).clamp(80.0, 560.0),
          (homeBarnPosition.y + oy).clamp(80.0, 420.0),
        );
        _isMoving = true;
        _animComponent?.animation = walkAnimation;
      } else {
        _isMoving = false;
        _animComponent?.animation = idleAnimation;
      }
    }

    if (_isMoving) {
      final diff = _roamTarget - position;
      final dist = diff.length;
      if (dist > 2.0) {
        diff.normalize();
        position.add(diff * (moveSpeed * dt));
        // Flip sprite if moving left
        if (diff.x < -0.1 && scale.x > 0) {
          scale.x = -1.0;
        } else if (diff.x > 0.1 && scale.x < 0) {
          scale.x = 1.0;
        }
      } else {
        _isMoving = false;
        _animComponent?.animation = idleAnimation;
      }
    }

    // Y Depth sorting
    priority = position.y.toInt();

    // Check distance to player
    final distToPlayer = (position - game.player.position).length;
    isPlayerNearby = distToPlayer <= 32.0;

    // Heart Emote timer
    if (_heartTimer > 0) {
      _heartTimer -= dt;
    }

    // Moss-Calf Nature Buff: Bless nearby crops within 48px
    if (animal.species == AnimalSpecies.mossCalf) {
      _applyMossCalfGrowthBuff();
    }
  }

  void _applyMossCalfGrowthBuff() {
    // Check farm tiles within 48 pixels
    for (final tile in game.farmGrid.tiles.values) {
      if (tile.crop != null && (tile.position - position).length <= 48.0) {
        // Speed up hydration or growth
        if (tile.soilState != TileSoilState.plowedWatered) {
          tile.water();
        }
      }
    }
  }

  /// Interact with animal: Pet or Harvest Produce.
  bool interact() {
    // 1. Try to harvest produce if available
    final produce = animal.harvestProduce();
    if (produce != null) {
      game.inventory.addItem(produce, count: 1);
      game.playSFX(GameConstants.sfxCoins);
      _heartTimer = 2.0;
      return true;
    }

    // 2. Pet the animal for affection
    if (animal.pet()) {
      _heartTimer = 2.0;
      game.playSFX(GameConstants.sfxAnimalPet);
      return true;
    }

    // 3. Try to feed if player holds feed
    if (!animal.isFed) {
      final feedItem = animal.species.preferredFeed;
      if (game.inventory.consumeIngredients({feedItem: 1})) {
        animal.feed();
        _heartTimer = 2.0;
        game.playSFX(GameConstants.sfxCoins);
        return true;
      }
    }

    // Already pet and fed today
    _heartTimer = 1.0;
    return false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render Floating Heart Emote above animal head
    if (_heartTimer > 0 && _heartSprite != null) {
      final floatY = -18.0 - (2.0 - _heartTimer) * 4.0;
      _heartSprite!.render(
        canvas,
        position: Vector2(-8, floatY),
        size: Vector2(16, 16),
      );
    }
  }
}
