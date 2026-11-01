import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/valley_moon_game.dart';
import 'models/festival_system.dart';
import 'models/fishing_system.dart';
import 'models/npc_dialogue_system.dart';
import 'ui/act3_dialog.dart';
import 'ui/carpenter_dialog.dart';
import 'ui/dialogue_dialog.dart';
import 'ui/diary_and_altars_dialog.dart';
import 'ui/festival_dialog.dart';
import 'ui/fishing_minigame_dialog.dart';
import 'ui/forge_dialog.dart';
import 'ui/hud_overlay.dart';
import 'ui/inventory_dialog.dart';
import 'ui/kitchen_dialog.dart';
import 'ui/settings_dialog.dart';
import 'ui/title_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const ValleyMoonApp());
}

class ValleyMoonApp extends StatefulWidget {
  const ValleyMoonApp({super.key});

  @override
  State<ValleyMoonApp> createState() => _ValleyMoonAppState();
}

class _ValleyMoonAppState extends State<ValleyMoonApp> {
  late final ValleyMoonGame _game;

  @override
  void initState() {
    super.initState();
    _game = ValleyMoonGame();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valley Moon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1B1713),
      ),
      home: Scaffold(
        body: ListenableBuilder(
          listenable: _game.settings,
          builder: (context, _) {
            final filter = _game.settings.colorFilterType.colorFilter;

            Widget gameWidget = GameWidget<ValleyMoonGame>(
              game: _game,
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
                'Forge': (context, game) => ForgeDialog(
                      game: game,
                      onClose: () => game.overlays.remove('Forge'),
                    ),
                'Carpenter': (context, game) => CarpenterDialog(
                      game: game,
                      onClose: () => game.overlays.remove('Carpenter'),
                    ),
                'Kitchen': (context, game) => KitchenDialog(
                      game: game,
                      onClose: () => game.overlays.remove('Kitchen'),
                    ),
                'Settings': (context, game) => SettingsDialog(
                      game: game,
                      onClose: () => game.overlays.remove('Settings'),
                    ),
                'Festival': (context, game) => FestivalDialog(
                      game: game,
                      festival: game.activeFestival ?? FestivalType.firstSeed,
                      onClose: () => game.overlays.remove('Festival'),
                    ),
                'Act3Victory': (context, game) => Act3VictoryDialog(
                      game: game,
                      onClose: () => game.overlays.remove('Act3Victory'),
                    ),
                'Title': (context, game) => TitleScreenOverlay(
                      game: game,
                      onStartGame: () => game.overlays.remove('Title'),
                    ),
              },
              initialActiveOverlays: const ['HUD', 'Title'],
            );

            if (filter != null) {
              return ColorFiltered(
                colorFilter: filter,
                child: gameWidget,
              );
            }
            return gameWidget;
          },
        ),
      ),
    );
  }
}
