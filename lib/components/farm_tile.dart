import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/time_system.dart';

enum TileSoilState {
  unplowed,
  plowedDry,
  plowedWatered,
  blighted, // Blighted by Silent Ash Fog
}

/// Represents an active crop planted in a farm tile.
class CropInstance {
  final CropType type;
  int currentStage = 0; // 0=Seed, 1=Sprout, 2=Growing, 3=Mature, 4=Withered
  int daysWatered = 0;
  bool isWateredToday = false;

  CropInstance({required this.type});

  bool get isMature => currentStage == 3;
  bool get isWithered => currentStage == 4;

  void onNewDay({
    required bool hasWater,
    required bool isSilentAshFog,
    required bool isProtectedByScarecrow,
    required MoonPhase moonPhase,
  }) {
    if (isWithered) return;

    // Check blight from Silent Ash Fog
    if (isSilentAshFog && !isProtectedByScarecrow) {
      currentStage = 4; // Withers into ash
      return;
    }

    if (hasWater) {
      daysWatered += 1;
      isWateredToday = false;

      // Magical crops special lunar boost
      final lunarBoost = type.isMagical &&
          (moonPhase == MoonPhase.fullMoon || moonPhase == MoonPhase.bloodMoon);

      if (lunarBoost) {
        daysWatered += 1; // Lunar aura accelerates growth
      }

      // Compute stage based on growthDays (0=Seed, 1=Sprout, 2=Growing, 3=Mature)
      if (daysWatered >= type.growthDays) {
        currentStage = 3;
      } else if (daysWatered >= (type.growthDays * 2 / 3).ceil()) {
        currentStage = 2;
      } else if (daysWatered >= (type.growthDays / 3).ceil()) {
        currentStage = 1;
      } else {
        currentStage = 0;
      }
    }
  }
}

/// Interactive 16x16 farm tile.
class FarmTileComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  final int gridX;
  final int gridY;

  TileSoilState soilState = TileSoilState.unplowed;
  CropInstance? crop;

  // Shared sprites
  static Sprite? drySoilSprite;
  static Sprite? wetSoilSprite;
  static Sprite? blightedSoilSprite;
  static ui.Image? cropsImage;

  FarmTileComponent({
    required this.gridX,
    required this.gridY,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(GameConstants.tileSize),
          anchor: Anchor.topLeft,
          priority: 2,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Cache sprites once
    if (cropsImage == null) {
      cropsImage = await game.images.load(GameConstants.cropsSheet);
      final tilesImage = await game.images.load('tiles/farm_tiles.png');

      // Dry Soil is Row 0, Col 7 (x=112, y=0)
      drySoilSprite = Sprite(
        tilesImage,
        srcPosition: Vector2(112, 0),
        srcSize: Vector2.all(16),
      );

      // Wet Soil is Row 0, Col 8 (x=128, y=0)
      wetSoilSprite = Sprite(
        tilesImage,
        srcPosition: Vector2(128, 0),
        srcSize: Vector2.all(16),
      );

      // Blighted Soil (dark grey tinted soil)
      blightedSoilSprite = Sprite(
        tilesImage,
        srcPosition: Vector2(112, 0),
        srcSize: Vector2.all(16),
      );
    }
  }

  /// Plow soil with hoe
  bool plow() {
    if (soilState == TileSoilState.unplowed || soilState == TileSoilState.blighted) {
      soilState = TileSoilState.plowedDry;
      game.playSFX(GameConstants.sfxDig);
      game.gameState.useEnergy(2.0);
      return true;
    }
    return false;
  }

  /// Water soil with can
  bool water() {
    if (soilState == TileSoilState.plowedDry) {
      soilState = TileSoilState.plowedWatered;
      if (crop != null) {
        crop!.isWateredToday = true;
      }
      game.playSFX(GameConstants.sfxWater);
      game.gameState.useEnergy(1.5);
      return true;
    }
    return false;
  }

  /// Plant a seed
  bool plant(CropType type) {
    if (soilState != TileSoilState.plowedDry && soilState != TileSoilState.plowedWatered) {
      return false;
    }
    if (crop != null) return false;

    // Check Lunar Rule: Magical seeds require night or Full/Blood Moon
    if (type.isMagical) {
      final validLunarTime = game.gameState.isNight ||
          game.gameState.moonPhase == MoonPhase.fullMoon ||
          game.gameState.moonPhase == MoonPhase.bloodMoon;

      if (!validLunarTime) {
        // Magical seed fails to awaken in plain daylight
        game.playSFX(GameConstants.sfxToolSwing);
        return false;
      }
    }

    crop = CropInstance(type: type);
    crop!.isWateredToday = soilState == TileSoilState.plowedWatered;
    game.playSFX(GameConstants.sfxDig);
    game.gameState.useEnergy(1.0);
    return true;
  }

  /// Harvest or clear tile
  bool harvest() {
    if (crop != null) {
      if (crop!.isMature) {
        game.playSFX(GameConstants.sfxCoins);
        game.gameState.addCoins(crop!.type.sellPrice);
        game.gameState.addItem(crop!.type.name, 1);
        crop = null;
        return true;
      } else if (crop!.isWithered) {
        // Remove dead crop
        game.playSFX(GameConstants.sfxChop);
        crop = null;
        return true;
      }
    }
    return false;
  }

  /// Advances day: updates soil moisture and growth
  void onNewDay({
    required bool isRaining,
    required bool isAshFog,
    required bool isProtectedByScarecrow,
  }) {
    final hadWater = (soilState == TileSoilState.plowedWatered) || isRaining;

    if (crop != null) {
      crop!.onNewDay(
        hasWater: hadWater,
        isSilentAshFog: isAshFog,
        isProtectedByScarecrow: isProtectedByScarecrow,
        moonPhase: game.gameState.moonPhase,
      );
    }

    // Reset soil or keep wet if raining
    if (soilState == TileSoilState.plowedWatered || soilState == TileSoilState.plowedDry) {
      soilState = isRaining ? TileSoilState.plowedWatered : TileSoilState.plowedDry;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Render Soil
    if (soilState == TileSoilState.plowedDry) {
      drySoilSprite?.render(canvas, size: size);
    } else if (soilState == TileSoilState.plowedWatered) {
      wetSoilSprite?.render(canvas, size: size);
    } else if (soilState == TileSoilState.blighted) {
      blightedSoilSprite?.render(
        canvas,
        size: size,
        overridePaint: Paint()..colorFilter = const ColorFilter.mode(Colors.grey, BlendMode.modulate),
      );
    }

    // 2. Render Crop
    if (crop != null && cropsImage != null) {
      final col = crop!.currentStage.clamp(0, 4);
      final row = crop!.type.spriteRow;

      final cropSprite = Sprite(
        cropsImage!,
        srcPosition: Vector2(col * 16.0, row * 16.0),
        srcSize: Vector2.all(16.0),
      );

      cropSprite.render(canvas, size: size);

      // Magical glow aura for mature lunar crops
      if (crop!.isMature && crop!.type.isMagical) {
        final glowPaint = Paint()
          ..color = (crop!.type == CropType.screamRoot
                  ? const Color(0x66FF66FF)
                  : crop!.type == CropType.dewBlossom
                      ? const Color(0x6666FFFF)
                      : const Color(0x66FFFF66))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(const Offset(8, 8), 7, glowPaint);
      }
    }
  }
}
