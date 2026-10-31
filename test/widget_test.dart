import 'package:flutter_test/flutter_test.dart';
import 'package:valley_moon/main.dart';
import 'package:valley_moon/models/time_system.dart';

void main() {
  group('Valley Moon - App & Core Systems Test', () {
    test('GameState advances time and lunar phases', () {
      final state = GameState();

      expect(state.day, 1);
      expect(state.hour, 6);
      expect(state.minute, 0);
      expect(state.moonPhase, MoonPhase.waxingMoon);

      // Advance time by 36 real seconds (60 in-game minutes in 12-min day cycle)
      state.updateTime(36.0);

      expect(state.hour, 7);
      expect(state.minute, 0);

      // Tool selection
      state.selectTool(FarmerTool.axe);
      expect(state.selectedTool, FarmerTool.axe);

      // Energy usage
      state.useEnergy(10.0);
      expect(state.energy, 90.0);

      // Day advancement restores energy and advances day
      state.advanceDay();
      expect(state.day, 2);
      expect(state.energy, 100.0);
    });

    testWidgets('ValleyMoonApp widget initializes', (tester) async {
      await tester.pumpWidget(const ValleyMoonApp());
      expect(find.byType(ValleyMoonApp), findsOneWidget);
    });
  });
}
