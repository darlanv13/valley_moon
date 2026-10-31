import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';

enum GameLocation {
  farm('Fazenda do Avô', '🌾'),
  village('Vila da Lareira', '🏘️'),
  forest('Floresta Sussurrante', '🌲'),
  mineEntrance('Entrada da Mina', '⛏️'),
  tavern('Taverna da Lareira', '🍺');

  final String displayName;
  final String icon;

  const GameLocation(this.displayName, this.icon);
}

/// Portal trigger component connecting maps and zones.
class MapTransitionComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame>, CollisionCallbacks {
  final GameLocation targetLocation;
  final Vector2 targetSpawnPosition;
  final String portalName;

  bool _isActive = true;

  MapTransitionComponent({
    required this.targetLocation,
    required this.targetSpawnPosition,
    required super.position,
    required super.size,
    this.portalName = 'Portal',
  }) : super(anchor: Anchor.topLeft) {
    add(RectangleHitbox(size: size, isSolid: false));
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (_isActive && other == game.player) {
      _isActive = false;
      game.transitionTo(targetLocation, targetSpawnPosition);
      game.playSFX(GameConstants.sfxDoorOpen);
      // Re-enable portal after small delay
      Future.delayed(const Duration(seconds: 1), () => _isActive = true);
    }
  }
}

