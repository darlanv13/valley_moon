import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamepads/gamepads.dart';
import 'package:valley_moon/components/farm_grid_manager.dart';
import 'package:valley_moon/components/farm_tile.dart';
import 'package:valley_moon/components/obstacle.dart';
import 'package:valley_moon/components/player.dart';
import 'package:valley_moon/game/valley_moon_game.dart';
import 'package:valley_moon/models/gamepad_system.dart';
import 'package:valley_moon/models/time_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Valley Moon - ETAPA 10: Gamepad (Xbox/PlayStation), Smart Tap e Otimização Mobile', () {
    late ValleyMoonGame game;
    late GamepadSystem gamepad;
    late PlayerComponent player;

    setUp(() {
      game = ValleyMoonGame();
      game.audioEnabled = false;
      gamepad = game.gamepad;

      player = PlayerComponent(position: Vector2(100, 100));
      game.player = player;
      game.world.add(player);

      game.farmGrid = FarmGridManager();
      game.world.add(game.farmGrid);
    });

    test('Controller Brand detection and button glyph metadata', () {
      expect(ControllerBrand.xbox.displayName, 'Xbox Controller');
      expect(ControllerBrand.xbox.btnSouth, 'A');
      expect(ControllerBrand.xbox.btnEast, 'B');
      expect(ControllerBrand.xbox.btnWest, 'X');
      expect(ControllerBrand.xbox.btnNorth, 'Y');
      expect(ControllerBrand.xbox.btnL1, 'LB');
      expect(ControllerBrand.xbox.btnR1, 'RB');

      expect(ControllerBrand.playStation.displayName, 'PlayStation Controller');
      expect(ControllerBrand.playStation.btnSouth, '✕');
      expect(ControllerBrand.playStation.btnEast, '○');
      expect(ControllerBrand.playStation.btnWest, '□');
      expect(ControllerBrand.playStation.btnNorth, '△');
      expect(ControllerBrand.playStation.btnL1, 'L1');
      expect(ControllerBrand.playStation.btnR1, 'R1');

      // Detection
      gamepad.setControllerBrand(ControllerBrand.xbox);
      expect(gamepad.controllerBrand, ControllerBrand.xbox);

      gamepad.setControllerBrand(ControllerBrand.playStation);
      expect(gamepad.controllerBrand, ControllerBrand.playStation);
    });

    test('Input Mode transitions: Gamepad, Touch Mobile, Keyboard/Mouse', () {
      expect(gamepad.activeInputMode, ActiveInputMode.keyboardMouse);

      // Transition to Touch Mobile
      gamepad.setTouchMode();
      expect(gamepad.activeInputMode, ActiveInputMode.touchMobile);

      // Gamepad button input transitions to Gamepad mode
      gamepad.handleButtonInput(GamepadButton.a, 1.0);
      expect(gamepad.activeInputMode, ActiveInputMode.gamepad);

      // Transition back to Keyboard mode
      gamepad.setKeyboardMode();
      expect(gamepad.activeInputMode, ActiveInputMode.keyboardMouse);
    });

    test('Gamepad Analog Stick with deadzones and inverted Flame Y axis', () {
      // Below deadzone (< 0.18) -> stays zero
      gamepad.handleAxisInput(GamepadAxis.leftStickX, 0.12);
      expect(gamepad.leftStickDirection.x, 0.0);

      // Above deadzone -> applied
      gamepad.handleAxisInput(GamepadAxis.leftStickX, 0.75);
      expect(gamepad.leftStickDirection.x, 0.75);

      // Inverted Y: positive UP (+1.0) maps to negative Y (-1.0) in Flame (upward movement)
      gamepad.handleAxisInput(GamepadAxis.leftStickY, 1.0);
      expect(gamepad.leftStickDirection.y, -1.0);

      // Negative UP (-1.0) maps to downward movement in Flame (+1.0)
      gamepad.handleAxisInput(GamepadAxis.leftStickY, -1.0);
      expect(gamepad.leftStickDirection.y, 1.0);
    });

    test('Gamepad D-Pad movement and release', () {
      // D-Pad Up
      gamepad.handleButtonInput(GamepadButton.dpadUp, 1.0);
      expect(gamepad.leftStickDirection.x, 0.0);
      expect(gamepad.leftStickDirection.y, -1.0);

      // D-Pad Release
      gamepad.handleButtonInput(GamepadButton.dpadUp, 0.0);
      expect(gamepad.leftStickDirection.isZero(), isTrue);

      // D-Pad Right
      gamepad.handleButtonInput(GamepadButton.dpadRight, 1.0);
      expect(gamepad.leftStickDirection.x, 1.0);
      expect(gamepad.leftStickDirection.y, 0.0);

      // D-Pad Release
      gamepad.handleButtonInput(GamepadButton.dpadRight, 0.0);
      expect(gamepad.leftStickDirection.isZero(), isTrue);
    });

    test('Gamepad Hotbar navigation with LB (L1) and RB (R1)', () {
      expect(game.inventory.selectedHotbarIndex, 0);

      // RB -> next slot (1)
      gamepad.handleButtonInput(GamepadButton.rightBumper, 1.0);
      expect(game.inventory.selectedHotbarIndex, 1);

      // RB again -> next slot (2)
      gamepad.handleButtonInput(GamepadButton.rightBumper, 1.0);
      expect(game.inventory.selectedHotbarIndex, 2);

      // LB -> previous slot (1)
      gamepad.handleButtonInput(GamepadButton.leftBumper, 1.0);
      expect(game.inventory.selectedHotbarIndex, 1);

      // LB wrap-around: 1 -> 0 -> 9
      gamepad.handleButtonInput(GamepadButton.leftBumper, 1.0);
      expect(game.inventory.selectedHotbarIndex, 0);
      gamepad.handleButtonInput(GamepadButton.leftBumper, 1.0);
      expect(game.inventory.selectedHotbarIndex, 9);
    });

    test('Player WalkTo and StopMoving pathing', () {
      player.walkTo(Vector2(200, 200));
      player.stopMoving();

      expect(player.position.x, 100);
      expect(player.position.y, 100);
    });

    test('Context-Sensitive Smart Tap: Empty space initiates WalkTo', () {
      // Tap far away on empty space (200, 200)
      player.smartTap(Vector2(200, 200));
      expect(gamepad.activeInputMode, ActiveInputMode.touchMobile);
    });

    test('Context-Sensitive Smart Tap: Adjacent Rock automatically selects Pickaxe', () {
      final rock = ObstacleComponent(
        position: Vector2(116, 100),
        size: Vector2(16, 16),
        obstacleName: 'Rock Miner',
      );
      game.world.add(rock);

      // Initial tool is hoe
      game.gameState.selectTool(FarmerTool.hoe);
      expect(game.gameState.selectedTool, FarmerTool.hoe);

      // Smart tap on adjacent rock
      player.smartTap(Vector2(116, 100));

      // Pickaxe should be automatically chosen
      expect(game.gameState.selectedTool, FarmerTool.pickaxe);
    });

    test('Context-Sensitive Smart Tap: Adjacent Tree automatically selects Axe', () {
      final tree = ObstacleComponent(
        position: Vector2(100, 116),
        size: Vector2(16, 16),
        obstacleName: 'Oak Tree',
      );
      game.world.add(tree);

      game.gameState.selectTool(FarmerTool.hoe);

      // Smart tap on adjacent tree
      player.smartTap(Vector2(100, 116));

      // Axe should be automatically chosen
      expect(game.gameState.selectedTool, FarmerTool.axe);
    });

    test('Context-Sensitive Smart Tap: Adjacent Unplowed soil selects Hoe; Dry soil selects Watering Can', () {
      // Tile coordinate corresponding to world pos (112, 100):
      // gx = 112 / 16 = 7, gy = 100 / 16 = 6
      final tile = FarmTileComponent(
        gridX: 7,
        gridY: 6,
        position: Vector2(112, 96),
      );
      game.world.add(tile);
      game.farmGrid.tiles['7,6'] = tile;

      // 1. Unplowed tile -> Selects Hoe
      tile.soilState = TileSoilState.unplowed;
      game.gameState.selectTool(FarmerTool.axe);
      player.smartTap(Vector2(112, 100));
      expect(game.gameState.selectedTool, FarmerTool.hoe);

      // 2. Plowed Dry tile -> Selects Watering Can
      tile.soilState = TileSoilState.plowedDry;
      player.smartTap(Vector2(112, 100));
      expect(game.gameState.selectedTool, FarmerTool.wateringCan);
    });
  });
}
