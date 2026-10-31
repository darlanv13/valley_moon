import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/valley_moon_game.dart';
import 'models/fishing_system.dart';
import 'models/npc_dialogue_system.dart';
import 'ui/dialogue_dialog.dart';
import 'ui/diary_and_altars_dialog.dart';
import 'ui/fishing_minigame_dialog.dart';
import 'ui/hud_overlay.dart';
import 'ui/inventory_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const ValleyMoonApp());
}

class ValleyMoonApp extends StatelessWidget {
  const ValleyMoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valley Moon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1B1713),
      ),
      home: Scaffold(
        body: GameWidget<ValleyMoonGame>(
          game: ValleyMoonGame(),
          overlayBuilderMap: {
            'HUD': (context, game) => HudOverlay(game: game),
            'Inventory': (context, game) => InventoryDialog(
                  game: game,
                  onClose: () => game.overlays.remove('Inventory'),
                ),
            'Dialogue': (context, game) {
              final npc = game.activeDialogueNpc ?? NpcId.bento;
              return DialogueDialog(
                key: ValueKey(npc),
                game: game,
                npcId: npc,
                onClose: () => game.overlays.remove('Dialogue'),
              );
            },
            'DiaryAltars': (context, game) => DiaryAndAltarsDialog(
                  game: game,
                  onClose: () => game.overlays.remove('DiaryAltars'),
                ),
            'FishingMinigame': (context, game) {
              final fish = game.activeFishingFish ?? FishData.allFishes[0];
              return FishingMinigameDialog(
                key: ValueKey(fish.id),
                game: game,
                fish: fish,
                onClose: () => game.overlays.remove('FishingMinigame'),
              );
            },
          },
          initialActiveOverlays: const ['HUD'],
        ),
      ),
    );
  }
}
