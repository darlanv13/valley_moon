import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/valley_moon_game.dart';
import 'ui/hud_overlay.dart';

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
          },
          initialActiveOverlays: const ['HUD'],
        ),
      ),
    );
  }
}
