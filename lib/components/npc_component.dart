import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/npc_dialogue_system.dart';
import '../models/time_system.dart';
import 'map_transition.dart';

class NpcSchedule {
  final int startHour;
  final int endHour;
  final GameLocation location;
  final Vector2 position;
  final String activity;

  NpcSchedule({
    required this.startHour,
    required this.endHour,
    required this.location,
    required this.position,
    required this.activity,
  });
}

/// World NPC Component with dynamic schedules, speech bubble, and interaction.
class NpcComponent extends PositionComponent
    with HasGameReference<ValleyMoonGame> {
  final NpcId npcId;
  Sprite? sprite;
  bool isPlayerNearby = false;
  double renderOpacity = 1.0;

  NpcComponent({
    required this.npcId,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(16, 24),
          anchor: Anchor.bottomCenter,
          priority: position.y.toInt() + 5,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load NPC sprite from npcs.png
    // Row 0=Bento, 1=Kael, 2=Helena, 3=Lúcio, 4=Íris, 5=Maya
    final npcsImage = await game.images.load('characters/npcs.png');
    final rowIdx = npcId.index;
    sprite = Sprite(
      npcsImage,
      srcPosition: Vector2(0, rowIdx * 24.0),
      srcSize: Vector2(16, 24),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update routine state based on game time & weather
    _updateRoutineSchedule();

    // Check distance to player
    final dist = (position - game.player.position).length;
    isPlayerNearby = dist <= 32.0;

    // Depth sorting
    priority = position.y.toInt();
  }

  void _updateRoutineSchedule() {
    final hour = game.gameState.hour;
    final weather = game.gameState.weather;
    final schedules = _getSchedulesForNpc(npcId, weather);

    for (final sch in schedules) {
      if (hour >= sch.startHour && hour < sch.endHour) {
        // Check if NPC is in player's current map
        final isHere = sch.location == game.currentLocation;
        if (isHere) {
          position.setFrom(sch.position);
          renderOpacity = 1.0;
        } else {
          // Off-screen in another location
          renderOpacity = 0.0;
        }
        break;
      }
    }
  }

  List<NpcSchedule> _getSchedulesForNpc(NpcId id, WeatherType weather) {
    switch (id) {
      case NpcId.helena:
        return [
          // Morning: Gathering herbs in the forest
          NpcSchedule(startHour: 6, endHour: 12, location: GameLocation.forest, position: Vector2(120, 160), activity: 'Colhendo Ervas'),
          // Afternoon: In the village apothecary
          NpcSchedule(startHour: 12, endHour: 19, location: GameLocation.village, position: Vector2(280, 140), activity: 'Atendendo Moradores'),
          // Night: Near the ancient altar or farm edge
          NpcSchedule(startHour: 19, endHour: 24, location: GameLocation.farm, position: Vector2(80, 110), activity: 'Venerando a Lua'),
          NpcSchedule(startHour: 0, endHour: 6, location: GameLocation.village, position: Vector2(280, 140), activity: 'Dormindo'),
        ];

      case NpcId.kael:
        return [
          // Blacksmith forge all day
          NpcSchedule(startHour: 6, endHour: 18, location: GameLocation.village, position: Vector2(180, 150), activity: 'Forjando Lâminas'),
          // Evening: Overlooking river or in tavern
          NpcSchedule(startHour: 18, endHour: 23, location: GameLocation.tavern, position: Vector2(100, 120), activity: 'Descansando'),
          NpcSchedule(startHour: 23, endHour: 6, location: GameLocation.village, position: Vector2(180, 150), activity: 'Dormindo'),
        ];

      case NpcId.iris:
        return [
          // Morning: Walking in village square
          NpcSchedule(startHour: 8, endHour: 16, location: GameLocation.village, position: Vector2(240, 200), activity: 'Compondo Poemas'),
          // Night: Singing and playing lute at the tavern
          NpcSchedule(startHour: 16, endHour: 24, location: GameLocation.tavern, position: Vector2(160, 90), activity: 'Tocando Alaúde'),
          NpcSchedule(startHour: 0, endHour: 8, location: GameLocation.tavern, position: Vector2(160, 90), activity: 'Dormindo'),
        ];

      case NpcId.lucio:
        // Foggy/rainy nights or morning fishing at pier
        final pierHourEnd = (weather == WeatherType.fog || weather == WeatherType.rain) ? 20 : 14;
        return [
          NpcSchedule(startHour: 6, endHour: pierHourEnd, location: GameLocation.village, position: Vector2(80, 260), activity: 'Pescando no Píer'),
          NpcSchedule(startHour: pierHourEnd, endHour: 24, location: GameLocation.tavern, position: Vector2(80, 140), activity: 'Tomando Hidromel'),
          NpcSchedule(startHour: 0, endHour: 6, location: GameLocation.village, position: Vector2(80, 260), activity: 'Dormindo'),
        ];

      case NpcId.bento:
        return [
          NpcSchedule(startHour: 6, endHour: 17, location: GameLocation.village, position: Vector2(340, 120), activity: 'Administrando a Vila'),
          NpcSchedule(startHour: 17, endHour: 22, location: GameLocation.farm, position: Vector2(300, 150), activity: 'Fiscalizando a Fazenda'),
          NpcSchedule(startHour: 22, endHour: 6, location: GameLocation.village, position: Vector2(340, 120), activity: 'Dormindo'),
        ];

      case NpcId.maya:
        return [
          // Farm pastures / animals
          NpcSchedule(startHour: 6, endHour: 16, location: GameLocation.farm, position: Vector2(220, 260), activity: 'Cuidando das Galinhas'),
          // Forest walk with nature spirits
          NpcSchedule(startHour: 16, endHour: 22, location: GameLocation.forest, position: Vector2(200, 180), activity: 'Alimentando Feras'),
          NpcSchedule(startHour: 22, endHour: 6, location: GameLocation.farm, position: Vector2(220, 260), activity: 'Dormindo'),
        ];
    }
  }

  void interact() {
    game.openDialogueWithNpc(npcId);
  }

  @override
  void render(Canvas canvas) {
    if (renderOpacity <= 0.0) return;
    super.render(canvas);

    sprite?.render(canvas, size: size);

    // Floating speech bubble indicator when player is close
    if (isPlayerNearby) {
      final bubblePaint = Paint()..color = GameConstants.parchmentLight;
      final borderPaint = Paint()
        ..color = GameConstants.rusticWood
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      const bubbleRect = Rect.fromLTWH(3, -12, 10, 8);
      canvas.drawRRect(RRect.fromRectAndRadius(bubbleRect, const Radius.circular(3)), bubblePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(bubbleRect, const Radius.circular(3)), borderPaint);

      // Dots
      final dotPaint = Paint()..color = GameConstants.rusticWoodDark;
      canvas.drawCircle(const Offset(5.5, -8), 0.8, dotPaint);
      canvas.drawCircle(const Offset(8.0, -8), 0.8, dotPaint);
      canvas.drawCircle(const Offset(10.5, -8), 0.8, dotPaint);
    }
  }
}
