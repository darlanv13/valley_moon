import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valley_moon/components/earth_magic.dart';
import 'package:valley_moon/components/farm_tile.dart';
import 'package:valley_moon/models/time_system.dart';

void main() {
  group('Valley Moon - Etapa 2: Tempo, Ciclo Lunar e Magia Rústica', () {
    test('Ciclo de Tempo: 12 minutos reais por dia e desmaio às 02:00 AM', () {
      final state = GameState();
      expect(state.hour, 6);
      expect(state.minute, 0);

      // In 0.6 real seconds, 1 in-game minute passes (1200 in-game min / 720 real sec)
      state.updateTime(0.6);
      expect(state.minute, 1);

      // Advance to 01:59 AM
      state.hour = 1;
      state.minute = 59;

      bool fainted = false;
      state.onPlayerFainted = () {
        fainted = true;
      };

      // Tick to 02:00 AM -> Should trigger exhaustion, advance day to 06:00 AM
      state.updateTime(1.0);

      expect(fainted, isTrue);
      expect(state.day, 2);
      expect(state.hour, 6);
      expect(state.minute, 0);
      expect(state.energy, 50.0); // Exhaustion penalty
    });

    test('4 Estações (28 dias cada) e Ciclo Lunar com Lua de Sangue', () {
      final state = GameState();
      expect(state.season, Season.spring);
      expect(state.day, 1);

      // Advance 13 days -> Day 14 is Blood Moon
      for (var i = 0; i < 13; i++) {
        state.advanceDay();
      }

      expect(state.day, 14);
      expect(state.moonPhase, MoonPhase.bloodMoon);
      expect(state.weather, WeatherType.fog); // Silent Ash Fog occurs

      // Advance remaining 15 days -> Triggers season rollover to Summer (day 1)
      for (var i = 0; i < 15; i++) {
        state.advanceDay();
      }

      expect(state.day, 1);
      expect(state.season, Season.summer);
    });

    test('Ciclo Agrícola: Arar, Regar, Plantar e Colher', () {
      final tile = FarmTileComponent(
        gridX: 10,
        gridY: 10,
        position: Vector2(160, 160),
      );

      expect(tile.soilState, TileSoilState.unplowed);

      // 1. Arar solo
      tile.soilState = TileSoilState.plowedDry;
      expect(tile.soilState, TileSoilState.plowedDry);

      // 2. Regar solo
      tile.soilState = TileSoilState.plowedWatered;
      expect(tile.soilState, TileSoilState.plowedWatered);

      // 3. Plantar Nabo
      tile.crop = CropInstance(type: CropType.turnip);
      expect(tile.crop!.currentStage, 0); // Seed
      expect(tile.crop!.isMature, isFalse);

      // 4. Simular 4 dias regados
      for (var d = 0; d < 4; d++) {
        tile.crop!.onNewDay(
          hasWater: true,
          isSilentAshFog: false,
          isProtectedByScarecrow: true,
          moonPhase: MoonPhase.waxingMoon,
        );
      }

      // Nabo deve estar maduro
      expect(tile.crop!.isMature, isTrue);
    });

    test('Magia da Terra: Espantalho Vivo e Totem de Chuva', () {
      // Espantalho Vivo cobre raio de 5x5 (dx <= 2, dy <= 2)
      final scarecrow = ScarecrowComponent(
        gridX: 10,
        gridY: 10,
        position: Vector2(160, 160),
      );

      expect(scarecrow.protectsTile(10, 10), isTrue);
      expect(scarecrow.protectsTile(12, 12), isTrue); // Raio 2
      expect(scarecrow.protectsTile(13, 10), isFalse); // Fora do raio (dx = 3)

      // Teste de proteção contra a Cinza Silenciosa
      final protectedCrop = CropInstance(type: CropType.turnip);
      protectedCrop.onNewDay(
        hasWater: true,
        isSilentAshFog: true,
        isProtectedByScarecrow: scarecrow.protectsTile(11, 11),
        moonPhase: MoonPhase.bloodMoon,
      );
      expect(protectedCrop.isWithered, isFalse);

      final unprotectedCrop = CropInstance(type: CropType.turnip);
      unprotectedCrop.onNewDay(
        hasWater: true,
        isSilentAshFog: true,
        isProtectedByScarecrow: scarecrow.protectsTile(15, 15),
        moonPhase: MoonPhase.bloodMoon,
      );
      expect(unprotectedCrop.isWithered, isTrue);

      // Totem de Chuva cobre raio de 3x3 (dx <= 1, dy <= 1)
      final rainTotem = RainTotemComponent(
        gridX: 16,
        gridY: 10,
        position: Vector2(256, 160),
      );

      expect(rainTotem.watersTile(16, 10), isTrue);
      expect(rainTotem.watersTile(17, 11), isTrue); // Raio 1
      expect(rainTotem.watersTile(18, 10), isFalse); // Fora do raio (dx = 2)
    });
  });
}
