import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Collision obstacle representing solid objects (Cabin, Trees, Pond, Fences, Borders).
class ObstacleComponent extends PositionComponent with CollisionCallbacks {
  final String obstacleName;

  ObstacleComponent({
    required super.position,
    required super.size,
    this.obstacleName = 'Obstacle',
  }) : super(anchor: Anchor.topLeft) {
    add(RectangleHitbox(size: size, isSolid: true));
  }
}
