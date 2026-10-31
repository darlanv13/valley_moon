import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/combat_and_mining_system.dart';
import '../models/inventory_system.dart';

/// Floating Damage Text that rises and fades out.
class DamageTextComponent extends PositionComponent {
  final String text;
  final Color color;
  double _lifeTimer = 0.8;
  static const double floatSpeed = 26.0;

  DamageTextComponent({
    required this.text,
    required Vector2 position,
    this.color = const Color(0xFFFFE066),
  }) : super(position: position, priority: 100);

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= floatSpeed * dt;
    _lifeTimer -= dt;
    if (_lifeTimer <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final opacity = (_lifeTimer / 0.8).clamp(0.0, 1.0);
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: GameConstants.fontPixel,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color.withValues(alpha: opacity),
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: opacity),
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);
  }
}

/// Projectile fired by Runic Staff.
class MagicProjectileComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame>, CollisionCallbacks {
  final Vector2 velocity;
  final int damage;
  double _lifetime = 2.0;

  MagicProjectileComponent({
    required Vector2 position,
    required this.velocity,
    required this.damage,
  }) : super(
          position: position,
          size: Vector2(12, 12),
          anchor: Anchor.center,
          priority: 50,
        ) {
    add(CircleHitbox(radius: 6, isSolid: false));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);
    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final glowPaint = Paint()..color = const Color(0x668AE3FF);
    final corePaint = Paint()..color = const Color(0xFF8AE3FF);
    final centerPaint = Paint()..color = Colors.white;

    canvas.drawCircle(const Offset(6, 6), 6, glowPaint);
    canvas.drawCircle(const Offset(6, 6), 4, corePaint);
    canvas.drawCircle(const Offset(6, 6), 2, centerPaint);
  }
}

/// Visual slash arc for melee weapon attacks.
class SlashArcComponent extends PositionComponent {
  double _timer = 0.18;

  SlashArcComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2(24, 24),
          anchor: Anchor.center,
          priority: 45,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _timer -= dt;
    if (_timer <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: (_timer / 0.18).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final glowPaint = Paint()
      ..color = const Color(0x888AE3FF).withValues(alpha: (_timer / 0.18).clamp(0.0, 0.8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    const rect = Rect.fromLTWH(2, 2, 20, 20);
    canvas.drawArc(rect, -pi * 0.4, pi * 0.8, false, glowPaint);
    canvas.drawArc(rect, -pi * 0.4, pi * 0.8, false, arcPaint);
  }
}

/// World monster entity with AI chasing, knockback and damage.
class MonsterComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame>, CollisionCallbacks {
  final MonsterData data;
  late int currentHealth;

  SpriteAnimation? _animation;
  SpriteAnimationComponent? _animComp;

  bool _isHitStunned = false;
  double _hitStunTimer = 0.0;
  final Vector2 _knockbackVelocity = Vector2.zero();

  double _attackCooldown = 0.0;
  final Random _rng = Random();

  MonsterComponent({
    required this.data,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(data.frameWidth, data.frameHeight),
          anchor: Anchor.center,
          priority: position.y.toInt(),
        ) {
    currentHealth = data.maxHealth;
    add(RectangleHitbox(size: size, isSolid: false));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image = await game.images.load(data.spriteAsset);
    _animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.35,
        textureSize: Vector2(data.frameWidth, data.frameHeight),
      ),
    );

    _animComp = SpriteAnimationComponent(
      animation: _animation,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    await add(_animComp!);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Hit Stun & Knockback
    if (_isHitStunned) {
      _hitStunTimer -= dt;
      position.add(_knockbackVelocity * dt);
      if (_hitStunTimer <= 0) {
        _isHitStunned = false;
        _knockbackVelocity.setZero();
      }
      return;
    }

    if (_attackCooldown > 0) {
      _attackCooldown -= dt;
    }

    // AI Chasing logic towards player if in range (140px)
    final toPlayer = game.player.position - position;
    final dist = toPlayer.length;

    if (dist < 140.0 && dist > 12.0) {
      toPlayer.normalize();
      position.add(toPlayer * (data.speed * dt));

      // Flip sprite
      if (toPlayer.x < -0.1 && scale.x > 0) {
        scale.x = -1.0;
      } else if (toPlayer.x > 0.1 && scale.x < 0) {
        scale.x = 1.0;
      }
    } else if (dist <= 12.0 && _attackCooldown <= 0) {
      // Monster attacks player!
      _attackPlayer();
    }

    priority = position.y.toInt();
  }

  void _attackPlayer() {
    _attackCooldown = 1.2;
    final playerDefense = game.combat.equipment.totalDefense;
    final rawDamage = max(1, data.attackDamage - playerDefense);

    // Apply player thorns reflection if wearing Ring of Thorns
    if (game.combat.equipment.ring1?.id == 'ring_thorns' ||
        game.combat.equipment.ring2?.id == 'ring_thorns') {
      final reflectDmg = (rawDamage * 0.3).ceil();
      takeDamage(reflectDmg, Vector2.zero());
    }

    game.gameState.damagePlayer(rawDamage.toDouble());
    game.playSFX(GameConstants.sfxPlayerHurt);

    // Spawn red damage text on player
    game.world.add(DamageTextComponent(
      text: '-$rawDamage',
      position: game.player.position.clone() + Vector2(0, -20),
      color: GameConstants.healthRed,
    ));
  }

  void takeDamage(int amount, Vector2 knockbackDir) {
    final effectiveDmg = max(1, amount - data.defense);
    currentHealth -= effectiveDmg;

    // Trigger hit stun & knockback
    _isHitStunned = true;
    _hitStunTimer = 0.22;
    if (!knockbackDir.isZero()) {
      knockbackDir.normalize();
      _knockbackVelocity.setFrom(knockbackDir * 160.0);
    }

    game.playSFX(GameConstants.sfxMonsterHit);

    // Spawn damage number
    game.world.add(DamageTextComponent(
      text: '$effectiveDmg',
      position: position.clone() + Vector2(0, -14),
      color: Colors.amberAccent,
    ));

    if (currentHealth <= 0) {
      _die();
    }
  }

  void _die() {
    game.playSFX(GameConstants.sfxMonsterDie);
    game.combat.addXp(data.xpReward);

    // Roll loot table
    for (final entry in data.lootTable.entries) {
      if (_rng.nextDouble() < entry.value) {
        final item = GameItem.allOres.firstWhere(
          (o) => o.id == entry.key,
          orElse: () => GameItem.wood,
        );
        game.inventory.addItem(item, count: 1);
      }
    }

    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Health bar above monster
    if (currentHealth < data.maxHealth) {
      final bgPaint = Paint()..color = Colors.black54;
      final hpPaint = Paint()..color = GameConstants.healthRed;
      const barRect = Rect.fromLTWH(-8, -14, 16, 3);
      canvas.drawRect(barRect, bgPaint);

      final fillWidth = 16.0 * (currentHealth / data.maxHealth).clamp(0.0, 1.0);
      canvas.drawRect(Rect.fromLTWH(-8, -14, fillWidth, 3), hpPaint);
    }
  }
}
