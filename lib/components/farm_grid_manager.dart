import 'package:flame/components.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/time_system.dart';
import 'earth_magic.dart';
import 'farm_tile.dart';

/// Manages interactive agricultural tiles and earth magic totems.
class FarmGridManager extends Component with HasGameReference<ValleyMoonGame> {
  final Map<String, FarmTileComponent> tiles = {};
  final List<ScarecrowComponent> scarecrows = [];
  final List<RainTotemComponent> rainTotems = [];

  // Farm field boundaries in tile coordinates (central abandoned plot)
  static const int minGridX = 9;
  static const int maxGridX = 18;
  static const int minGridY = 9;
  static const int maxGridY = 14;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Generate farm tiles in the central field
    for (var gy = minGridY; gy <= maxGridY; gy++) {
      for (var gx = minGridX; gx <= maxGridX; gx++) {
        final pos = Vector2(
          gx * GameConstants.tileSize,
          gy * GameConstants.tileSize,
        );
        final tile = FarmTileComponent(
          gridX: gx,
          gridY: gy,
          position: pos,
        );

        // Pre-till a few plots as in grandfather's old farm
        if ((gx + gy) % 2 == 0) {
          tile.soilState = TileSoilState.plowedDry;
        }

        tiles['$gx,$gy'] = tile;
        add(tile);
      }
    }

    // 2. Pre-place a rustic Living Scarecrow at the edge of the field
    placeScarecrow(10, 8);

    // 3. Pre-place a Rain Totem near the center
    placeRainTotem(16, 8);

    // 4. Hook into daily cycle
    game.gameState.onNewDayStarted = onNewDay;
  }

  void placeScarecrow(int gx, int gy) {
    final pos = Vector2(
      gx * GameConstants.tileSize + 8,
      gy * GameConstants.tileSize + 16,
    );
    final sc = ScarecrowComponent(gridX: gx, gridY: gy, position: pos);
    scarecrows.add(sc);
    add(sc);
  }

  void placeRainTotem(int gx, int gy) {
    final pos = Vector2(
      gx * GameConstants.tileSize + 8,
      gy * GameConstants.tileSize + 16,
    );
    final rt = RainTotemComponent(gridX: gx, gridY: gy, position: pos);
    rainTotems.add(rt);
    add(rt);
  }

  void onNewDay() {
    final isRaining = game.gameState.weather == WeatherType.rain;
    final isAshFog = game.gameState.weather == WeatherType.fog;

    // 1. Rain Totems water their 3x3 surrounding tiles
    for (final totem in rainTotems) {
      for (var dy = -1; dy <= 1; dy++) {
        for (var dx = -1; dx <= 1; dx++) {
          final tx = totem.gridX + dx;
          final ty = totem.gridY + dy;
          final tile = tiles['$tx,$ty'];
          if (tile != null &&
              (tile.soilState == TileSoilState.plowedDry ||
                  tile.soilState == TileSoilState.plowedWatered)) {
            tile.soilState = TileSoilState.plowedWatered;
            if (tile.crop != null) {
              tile.crop!.isWateredToday = true;
            }
          }
        }
      }
    }

    // 2. Update all farm tiles
    for (final tile in tiles.values) {
      final isProtected = scarecrows.any((sc) => sc.protectsTile(tile.gridX, tile.gridY));
      tile.onNewDay(
        isRaining: isRaining,
        isAshFog: isAshFog,
        isProtectedByScarecrow: isProtected,
      );
    }
  }

  /// Interacts with the tile in front of the player
  bool interact(Vector2 targetWorldPos, FarmerTool tool) {
    final gx = (targetWorldPos.x / GameConstants.tileSize).floor();
    final gy = (targetWorldPos.y / GameConstants.tileSize).floor();

    // Earth Magic Placement
    if (tool == FarmerTool.placeScarecrow) {
      placeScarecrow(gx, gy);
      game.playSFX(GameConstants.sfxChop);
      return true;
    }
    if (tool == FarmerTool.placeRainTotem) {
      placeRainTotem(gx, gy);
      game.playSFX(GameConstants.sfxWater);
      return true;
    }

    final tile = tiles['$gx,$gy'];
    if (tile == null) return false;

    // Tool usage
    switch (tool) {
      case FarmerTool.hoe:
        return tile.plow();
      case FarmerTool.wateringCan:
        return tile.water();
      case FarmerTool.sickle:
      case FarmerTool.hands:
      case FarmerTool.axe:
        return tile.harvest();
      case FarmerTool.seedsTurnip:
      case FarmerTool.seedsWheat:
      case FarmerTool.seedsScreamRoot:
      case FarmerTool.seedsDewBlossom:
      case FarmerTool.seedsGoldenWheat:
        final cropType = tool.cropType;
        if (cropType != null) {
          return tile.plant(cropType);
        }
        break;
      default:
        return tile.harvest();
    }
    return false;
  }
}

