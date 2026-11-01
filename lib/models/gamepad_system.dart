import 'dart:async';
import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:gamepads/gamepads.dart';
import '../components/player.dart';
import '../game/valley_moon_game.dart';
import 'time_system.dart';

/// Supported physical controller brands for dynamic UI button glyphs.
enum ControllerBrand {
  xbox('Xbox Controller', 'A', 'B', 'X', 'Y', 'LB', 'RB'),
  playStation('PlayStation Controller', '✕', '○', '□', '△', 'L1', 'R1'),
  generic('Gamepad', 'A', 'B', 'X', 'Y', 'L1', 'R1');

  final String displayName;
  final String btnSouth;
  final String btnEast;
  final String btnWest;
  final String btnNorth;
  final String btnL1;
  final String btnR1;

  const ControllerBrand(
    this.displayName,
    this.btnSouth,
    this.btnEast,
    this.btnWest,
    this.btnNorth,
    this.btnL1,
    this.btnR1,
  );
}

/// The currently active control method: Gamepad, Touch Mobile, or Keyboard/Mouse.
enum ActiveInputMode {
  keyboardMouse,
  touchMobile,
  gamepad,
}

/// Central Gamepad Integration & Dynamic UI Controller for Valley Moon.
class GamepadSystem extends ChangeNotifier {
  final ValleyMoonGame game;

  ActiveInputMode activeInputMode = ActiveInputMode.keyboardMouse;
  ControllerBrand controllerBrand = ControllerBrand.xbox;
  bool isGamepadConnected = false;
  String? connectedGamepadName;

  final Vector2 leftStickDirection = Vector2.zero();
  final Vector2 rightStickDirection = Vector2.zero();

  StreamSubscription<NormalizedGamepadEvent>? _eventsSub;
  StreamSubscription<GamepadConnectionEvent>? _connSub;

  GamepadSystem({required this.game}) {
    _initGamepadListeners();
  }

  void _initGamepadListeners() {
    try {
      _connSub = Gamepads.connectionEvents.listen((event) {
        if (event.type == GamepadConnectionEventType.connected) {
          isGamepadConnected = true;
          connectedGamepadName = event.name;
          _detectControllerBrand(event.name);
          activeInputMode = ActiveInputMode.gamepad;
          notifyListeners();
        } else if (event.type == GamepadConnectionEventType.disconnected) {
          isGamepadConnected = false;
          connectedGamepadName = null;
          activeInputMode = ActiveInputMode.keyboardMouse;
          notifyListeners();
        }
      });

      _eventsSub = Gamepads.normalizedEvents.listen((event) {
        _handleNormalizedEvent(event);
      });
    } catch (_) {
      // In headless test environments or platforms where Gamepads plugin
      // is not natively supported, graceful fallback without exceptions.
    }
  }

  void _detectControllerBrand(String? name) {
    if (name == null) {
      controllerBrand = ControllerBrand.xbox;
      return;
    }
    final lower = name.toLowerCase();
    if (lower.contains('dualshock') ||
        lower.contains('dualsense') ||
        lower.contains('sony') ||
        lower.contains('ps4') ||
        lower.contains('ps5') ||
        lower.contains('playstation')) {
      controllerBrand = ControllerBrand.playStation;
    } else {
      controllerBrand = ControllerBrand.xbox;
    }
  }

  void setTouchMode() {
    if (activeInputMode != ActiveInputMode.touchMobile) {
      activeInputMode = ActiveInputMode.touchMobile;
      game.settings.registerPlayerActivity();
      notifyListeners();
    }
  }

  void setKeyboardMode() {
    if (activeInputMode != ActiveInputMode.keyboardMouse) {
      activeInputMode = ActiveInputMode.keyboardMouse;
      game.settings.registerPlayerActivity();
      notifyListeners();
    }
  }

  void setControllerBrand(ControllerBrand brand) {
    controllerBrand = brand;
    notifyListeners();
  }

  void _handleNormalizedEvent(NormalizedGamepadEvent event) {
    if (event.axis != null) {
      handleAxisInput(event.axis!, event.value);
    } else if (event.button != null) {
      handleButtonInput(event.button!, event.value);
    }
  }

  void handleAxisInput(GamepadAxis axis, double val) {
    if (activeInputMode != ActiveInputMode.gamepad) {
      activeInputMode = ActiveInputMode.gamepad;
      notifyListeners();
    }
    game.settings.registerPlayerActivity();

    switch (axis) {
      case GamepadAxis.leftStickX:
        leftStickDirection.x = (val.abs() > 0.18) ? val : 0.0;
        break;
      case GamepadAxis.leftStickY:
        // Note: Stick Y is positive UP in standard normalizer; Flame Y is positive DOWN
        leftStickDirection.y = (val.abs() > 0.18) ? -val : 0.0;
        break;
      case GamepadAxis.rightStickX:
        rightStickDirection.x = (val.abs() > 0.22) ? val : 0.0;
        _updateAimDirection();
        break;
      case GamepadAxis.rightStickY:
        rightStickDirection.y = (val.abs() > 0.22) ? -val : 0.0;
        _updateAimDirection();
        break;
      default:
        break;
    }
  }

  void handleButtonInput(GamepadButton btn, double value) {
    if (activeInputMode != ActiveInputMode.gamepad) {
      activeInputMode = ActiveInputMode.gamepad;
      notifyListeners();
    }
    game.settings.registerPlayerActivity();

    if (value > 0.5) {
      switch (btn) {
        // [A] / [Cross] -> Use current tool or interact
        case GamepadButton.a:
          game.player.performAction(game.gameState.selectedTool);
          break;

        // [X] / [Square] -> Melee attack / tool swing
        case GamepadButton.x:
          game.player.performAction(FarmerTool.sword);
          break;

        // [B] / [Circle] -> Dash or Cancel/Close overlays
        case GamepadButton.b:
          if (game.overlays.isActive('Inventory')) {
            game.overlays.remove('Inventory');
          } else if (game.overlays.isActive('Dialogue')) {
            game.overlays.remove('Dialogue');
          } else if (game.overlays.isActive('Settings')) {
            game.overlays.remove('Settings');
          } else if (game.overlays.isActive('Carpenter')) {
            game.overlays.remove('Carpenter');
          } else if (game.overlays.isActive('Kitchen')) {
            game.overlays.remove('Kitchen');
          } else {
            game.player.performDash();
          }
          break;

        // [Y] / [Triangle] -> Open/Close Inventory
        case GamepadButton.y:
          game.toggleInventory();
          break;

        // [LB] / [L1] -> Cycle Hotbar left
        case GamepadButton.leftBumper:
          final newIdx = (game.inventory.selectedHotbarIndex - 1 + 10) % 10;
          game.inventory.selectHotbarSlot(newIdx);
          _syncSelectedTool();
          break;

        // [RB] / [R1] -> Cycle Hotbar right
        case GamepadButton.rightBumper:
          final newIdx = (game.inventory.selectedHotbarIndex + 1) % 10;
          game.inventory.selectHotbarSlot(newIdx);
          _syncSelectedTool();
          break;

        // [Start] / [Menu] -> Open Settings
        case GamepadButton.start:
          game.openSettings();
          break;

        // [Back] / [Share] -> Open Grandfather Diary & Altars
        case GamepadButton.back:
          game.openDiaryAndAltars();
          break;

        // D-Pad Movement
        case GamepadButton.dpadUp:
          leftStickDirection.setValues(0, -1);
          break;
        case GamepadButton.dpadDown:
          leftStickDirection.setValues(0, 1);
          break;
        case GamepadButton.dpadLeft:
          leftStickDirection.setValues(-1, 0);
          break;
        case GamepadButton.dpadRight:
          leftStickDirection.setValues(1, 0);
          break;
        default:
          break;
      }
    } else {
      // D-Pad release check
      if (btn == GamepadButton.dpadUp ||
          btn == GamepadButton.dpadDown ||
          btn == GamepadButton.dpadLeft ||
          btn == GamepadButton.dpadRight) {
        leftStickDirection.setZero();
      }
    }
  }

  void _syncSelectedTool() {
    final item = game.inventory.selectedHotbarItem?.item;
    if (item?.associatedTool != null) {
      game.gameState.selectTool(item!.associatedTool!);
    }
    game.playSFX('wood_click.ogg');
  }

  void _updateAimDirection() {
    if (rightStickDirection.isZero()) return;
    if (rightStickDirection.x.abs() > rightStickDirection.y.abs()) {
      game.player.facing = rightStickDirection.x > 0 ? Direction.right : Direction.left;
    } else {
      game.player.facing = rightStickDirection.y > 0 ? Direction.down : Direction.up;
    }
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    _connSub?.cancel();
    super.dispose();
  }
}
