import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/act3_boss_system.dart';
import 'combat_and_mine_components.dart';

/// Flame Component rendering the Floor 100 Boss Arena:
/// - Corrupted Mountain Guardian (128x128)
/// - Grandfather in Amber Crystal (48x48)
/// - Sacred Soil and the Tree of Light (48x48)
class BossArenaComponent extends PositionComponent with HasGameReference<ValleyMoonGame> {
  final Act3BossState bossState;
  final Vector2 arenaCenter;

  Sprite? _bossSpriteArmored;
  Sprite? _bossSpriteAttack;
  Sprite? _bossSpriteCore;
  Sprite? _bossSpritePurified;

  Sprite? _amberFrozen;
  Sprite? _amberShattered;

  Sprite? _treeSeed;
  Sprite? _treeSapling;
  Sprite? _treeFull;

  double _attackTimer = 0.0;
  bool _isAttackingAnim = false;

  BossArenaComponent({
    required this.bossState,
    required this.arenaCenter,
  }) : super(
          position: arenaCenter,
          size: Vector2(320, 240),
          anchor: Anchor.center,
          priority: 50,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Load Boss frames from corrupted_guardian.png (256x64 -> 4 frames of 64x64)
    final bossImage = await game.images.load(GameConstants.corruptedGuardianImg);
    _bossSpriteArmored = Sprite(bossImage, srcPosition: Vector2(0, 0), srcSize: Vector2(64, 64));
    _bossSpriteAttack = Sprite(bossImage, srcPosition: Vector2(64, 0), srcSize: Vector2(64, 64));
    _bossSpriteCore = Sprite(bossImage, srcPosition: Vector2(128, 0), srcSize: Vector2(64, 64));
    _bossSpritePurified = Sprite(bossImage, srcPosition: Vector2(192, 0), srcSize: Vector2(64, 64));

    // 2. Load Amber crystal frames from grandfather_amber.png (96x48 -> 2 frames of 48x48)
    final amberImage = await game.images.load(GameConstants.grandfatherAmberImg);
    _amberFrozen = Sprite(amberImage, srcPosition: Vector2(0, 0), srcSize: Vector2(48, 48));
    _amberShattered = Sprite(amberImage, srcPosition: Vector2(48, 0), srcSize: Vector2(48, 48));

    // 3. Load Tree of Light frames from lunar_tree.png (144x48 -> 3 frames of 48x48)
    final treeImage = await game.images.load(GameConstants.lunarTreeImg);
    _treeSeed = Sprite(treeImage, srcPosition: Vector2(0, 0), srcSize: Vector2(48, 48));
    _treeSapling = Sprite(treeImage, srcPosition: Vector2(48, 0), srcSize: Vector2(48, 48));
    _treeFull = Sprite(treeImage, srcPosition: Vector2(96, 0), srcSize: Vector2(48, 48));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (bossState.phase == BossBattlePhase.victory) return;

    _attackTimer += dt;
    if (_attackTimer >= 4.0) {
      _attackTimer = 0.0;
      _triggerBossAttack();
    }
  }

  void _triggerBossAttack() {
    _isAttackingAnim = true;
    game.playSFX(GameConstants.sfxBossRoar);

    // Spawn falling rock hazard near player
    final targetPos = game.player.position.clone();
    Future.delayed(const Duration(milliseconds: 700), () {
      _isAttackingAnim = false;
      if (isMounted) {
        final dist = (game.player.position - targetPos).length;
        if (dist < 32.0 && !game.player.isInvincible) {
          game.gameState.damagePlayer(15);
          game.playSFX(GameConstants.sfxPlayerHurt);
        }
      }
    });
  }

  void hitBoss(double damage) {
    if (bossState.phase == BossBattlePhase.phase1Armor) {
      final oldArmor = bossState.currentArmor;
      bossState.applyWeaponDamage(damage);
      game.playSFX(GameConstants.sfxMonsterHit);

      // Spawn damage indicator
      parent?.add(DamageTextComponent(
        text: '${damage.toInt()}',
        position: arenaCenter + Vector2(0, -50),
        color: damage >= 30 ? Colors.redAccent : const Color(0xFFFFE066),
      ));

      if (bossState.currentArmor <= 0 && oldArmor > 0) {
        game.playSFX(GameConstants.sfxBossRoar);
      }
    } else if (bossState.phase == BossBattlePhase.phase2Purification) {
      // Weapons are immune in Phase 2
      parent?.add(DamageTextComponent(
        text: '0 (IMUNE)',
        position: arenaCenter + Vector2(0, -50),
        color: Colors.white60,
      ));
      game.playSFX(GameConstants.sfxWoodClick);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Render Grandfather Amber Crystal (Behind Boss at top center)
    final amberSprite = bossState.grandfatherFreed ? _amberShattered : _amberFrozen;
    amberSprite?.render(
      canvas,
      position: Vector2(size.x / 2 - 24, 16),
      size: Vector2(48, 48),
    );

    // 2. Render Corrupted Mountain Guardian (Center Top)
    Sprite? bossSprite;
    if (bossState.phase == BossBattlePhase.victory) {
      bossSprite = _bossSpritePurified;
    } else if (bossState.phase == BossBattlePhase.phase2Purification) {
      bossSprite = _bossSpriteCore;
    } else if (_isAttackingAnim) {
      bossSprite = _bossSpriteAttack;
    } else {
      bossSprite = _bossSpriteArmored;
    }

    bossSprite?.render(
      canvas,
      position: Vector2(size.x / 2 - 40, 50),
      size: Vector2(80, 80),
    );

    // 3. Render Sacred Soil & Tree of Light (Center Bottom of Arena)
    final treePos = Vector2(size.x / 2 - 24, 150);

    // Sacred Soil Circle
    final soilPaint = Paint()
      ..color = bossState.isSoilTilled ? const Color(0xFF6B4724) : const Color(0xFF3D2E1E)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(treePos.x + 24, treePos.y + 36), width: 56, height: 24),
      soilPaint,
    );

    if (bossState.phase == BossBattlePhase.victory || bossState.waterCycles >= 3) {
      _treeFull?.render(canvas, position: treePos, size: Vector2(48, 48));
    } else if (bossState.waterCycles >= 1) {
      _treeSapling?.render(canvas, position: treePos, size: Vector2(48, 48));
    } else if (bossState.isSeedPlanted) {
      _treeSeed?.render(canvas, position: treePos, size: Vector2(48, 48));
    }
  }
}
