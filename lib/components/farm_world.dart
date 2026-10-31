import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import '../core/constants.dart';
import 'obstacle.dart';

/// The game world representing Grandfather's Farm loaded from TMX.
class FarmWorldComponent extends Component {
  late final TiledComponent tiledMap;
  Vector2 playerSpawnPosition = Vector2(328, 140);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the TMX map
    tiledMap = await TiledComponent.load(
      GameConstants.tmxFarmMap,
      Vector2.all(GameConstants.tileSize),
      priority: 0,
    );
    add(tiledMap);

    // Parse Collision Objects from Tiled
    final collisionGroup = tiledMap.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionGroup != null) {
      for (final obj in collisionGroup.objects) {
        final obstacle = ObstacleComponent(
          position: Vector2(obj.x, obj.y),
          size: Vector2(obj.width, obj.height),
          obstacleName: obj.name.isNotEmpty ? obj.name : 'Obstacle',
        );
        add(obstacle);
      }
    }

    // Parse Spawn Points
    final spawnGroup = tiledMap.tileMap.getLayer<ObjectGroup>('SpawnPoints');
    if (spawnGroup != null) {
      for (final obj in spawnGroup.objects) {
        if (obj.name == 'PlayerSpawn' || obj.name.isEmpty) {
          playerSpawnPosition = Vector2(obj.x, obj.y);
          break;
        }
      }
    }
  }
}

