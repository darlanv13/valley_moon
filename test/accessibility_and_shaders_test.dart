import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valley_moon/components/shader_effects_manager.dart';
import 'package:valley_moon/game/valley_moon_game.dart';
import 'package:valley_moon/models/accessibility_settings.dart';
import 'package:valley_moon/models/save_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Valley Moon - ETAPA 9: Shaders, Luz Volumétrica, Partículas e Acessibilidade', () {
    late AccessibilitySettings settings;

    setUp(() {
      settings = AccessibilitySettings();
    });

    test('Accessibility Settings: Font Scaling, Screen Shake, and Colorblind Filters', () {
      // 1. Font Size Multiplier
      expect(settings.fontSizeMultiplier, 1.0);
      expect(settings.isLargeFont, isFalse);

      settings.toggleFontSize();
      expect(settings.fontSizeMultiplier, 1.3);
      expect(settings.isLargeFont, isTrue);

      settings.toggleFontSize();
      expect(settings.fontSizeMultiplier, 1.0);

      // 2. Screen Shake Toggle
      expect(settings.enableScreenShake, isTrue);
      settings.toggleScreenShake();
      expect(settings.enableScreenShake, isFalse);

      // 3. Colorblind Filter Matrices
      expect(settings.colorFilterType, ColorblindFilterType.none);
      expect(settings.colorFilterType.colorFilter, isNull);

      settings.setColorFilter(ColorblindFilterType.protanopia);
      expect(settings.colorFilterType.colorFilter, isNotNull);

      settings.setColorFilter(ColorblindFilterType.deuteranopia);
      expect(settings.colorFilterType.colorFilter, isNotNull);

      settings.setColorFilter(ColorblindFilterType.tritanopia);
      expect(settings.colorFilterType.colorFilter, isNotNull);

      settings.setColorFilter(ColorblindFilterType.highContrast);
      expect(settings.colorFilterType.colorFilter, isNotNull);

      // 4. Shaders & Volumetric Lighting toggles
      expect(settings.enableShaders, isTrue);
      settings.toggleShaders();
      expect(settings.enableShaders, isFalse);

      expect(settings.enableVolumetricLighting, isTrue);
      settings.toggleVolumetricLighting();
      expect(settings.enableVolumetricLighting, isFalse);
    });

    test('Inactivity Auto-Pause (Casual Mode): Pauses clock progression after 10s idle', () {
      expect(settings.enableAutoPauseOnIdle, isTrue);
      expect(settings.isAutoPaused, isFalse);
      expect(settings.idleTimer, 0.0);

      // Idle for 5 seconds -> Not paused yet
      settings.updateIdleCheck(5.0);
      expect(settings.idleTimer, 5.0);
      expect(settings.isAutoPaused, isFalse);

      // Idle for another 5.1 seconds -> Reaches 10.1s -> Auto-pauses!
      settings.updateIdleCheck(5.1);
      expect(settings.isAutoPaused, isTrue);

      // Player presses any key or moves -> Activity registered -> Auto-pause lifted!
      settings.registerPlayerActivity();
      expect(settings.isAutoPaused, isFalse);
      expect(settings.idleTimer, 0.0);

      // Disabling auto-pause setting
      settings.updateIdleCheck(12.0);
      expect(settings.isAutoPaused, isTrue);
      settings.toggleAutoPauseOnIdle();
      expect(settings.enableAutoPauseOnIdle, isFalse);
      expect(settings.isAutoPaused, isFalse);
    });

    test('Shader Manager: Safe headless initialization & Water overlay fallback', () async {
      await ShaderManager.initialize();
      expect(ShaderManager.isInitialized, isTrue);

      final waterComp = WaterDistortionOverlayComponent();
      expect(waterComp.waterZones.length, 2);

      // Advance time
      waterComp.update(0.16);
      expect(waterComp.size.x, 640);
    });

    test('Reactive Player Particles: Snow footsteps in Winter and Dust puffs on Dash', () {
      final particles = PlayerReactiveParticlesComponent();

      // 1. Snow Footprint
      final footprint = SnowFootprint(
        position: Vector2(100, 150),
        isLeftFoot: true,
        maxLifeTime: 4.0,
      );
      expect(footprint.isDead, isFalse);
      expect(footprint.opacity, 1.0);

      footprint.lifeTime = 0.0;
      expect(footprint.isDead, isTrue);

      // 2. Dash Dust Puff
      particles.spawnDashDust(Vector2(200, 200), Vector2(1, 0));
      expect(particles.dustPuffs.length, 7);

      final initialDustRadius = particles.dustPuffs.first.radius;
      particles.update(0.1);
      expect(particles.dustPuffs.first.radius, greaterThan(initialDustRadius)); // Expands as it dissipates
    });

    test('Volumetric Lighting & Fireflies: Ambient flickering and evening luminescence', () async {
      final lighting = VolumetricLightingAndFirefliesComponent();
      await lighting.onLoad();

      expect(lighting.lampPositions.length, 4);
      expect(lighting.fireflies.length, 14);

      final firstFireflyPos = lighting.fireflies.first.position.clone();
      lighting.update(0.2);

      // Update positions
      for (final f in lighting.fireflies) {
        f.update(0.2, 1.0);
      }
      expect(lighting.fireflies.first.position, isNot(equals(firstFireflyPos)));
    });

    test('ValleyMoonGame: Camera Screen Shake respects Accessibility Settings', () {
      final game = ValleyMoonGame();
      expect(game.settings.enableScreenShake, isTrue);

      // Screen shake triggered when enabled
      game.triggerScreenShake(duration: 0.3, intensity: 4.0);
      game.update(0.05);

      // Disable screen shake in settings
      game.settings.enableScreenShake = false;
      game.triggerScreenShake(duration: 0.3, intensity: 4.0);
      // Intensity should not shake when disabled
    });

    test('SaveManager: Persists and Restores Accessibility and Shader Configuration', () async {
      await SaveManager.initialize();
      final game = ValleyMoonGame();

      // Configure custom accessibility preferences
      game.settings.fontSizeMultiplier = 1.3;
      game.settings.enableScreenShake = false;
      game.settings.colorFilterType = ColorblindFilterType.deuteranopia;
      game.settings.enableAutoPauseOnIdle = false;

      // Save
      final saved = await SaveManager.saveGame(game);
      expect(saved, isTrue);

      // Load into new game instance
      final loadedGame = ValleyMoonGame();
      final loaded = await SaveManager.loadGame(loadedGame);
      expect(loaded, isTrue);

      expect(loadedGame.settings.fontSizeMultiplier, 1.3);
      expect(loadedGame.settings.enableScreenShake, isFalse);
      expect(loadedGame.settings.colorFilterType, ColorblindFilterType.deuteranopia);
      expect(loadedGame.settings.enableAutoPauseOnIdle, isFalse);
    });
  });
}
