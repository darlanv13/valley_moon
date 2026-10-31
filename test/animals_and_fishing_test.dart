import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valley_moon/components/map_transition.dart';
import 'package:valley_moon/game/valley_moon_game.dart';
import 'package:valley_moon/models/animal_system.dart';
import 'package:valley_moon/models/fishing_system.dart';
import 'package:valley_moon/models/inventory_system.dart';
import 'package:valley_moon/models/time_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Valley Moon - Etapa 5: Pecuária Mística e Minigame de Pesca', () {
    late AnimalManager animalManager;
    late InventoryState inventory;
    late GameState gameState;

    setUp(() {
      animalManager = AnimalManager();
      inventory = InventoryState();
      gameState = GameState();
    });

    test('Herd initialization with standard and mystical animals', () {
      expect(animalManager.animals.length, 8);

      final chicken = animalManager.getAnimalById('animal_chicken_1')!;
      expect(chicken.species, AnimalSpecies.chicken);
      expect(chicken.species.isMystical, isFalse);

      final amberChicken = animalManager.getAnimalById('animal_amber_chicken')!;
      expect(amberChicken.species, AnimalSpecies.amberChicken);
      expect(amberChicken.species.isMystical, isTrue);

      final mossCalf = animalManager.getAnimalById('animal_moss_calf')!;
      expect(mossCalf.species, AnimalSpecies.mossCalf);
      expect(mossCalf.species.isMystical, isTrue);

      final cloudSheep = animalManager.getAnimalById('animal_cloud_sheep')!;
      expect(cloudSheep.species, AnimalSpecies.cloudSheep);
      expect(cloudSheep.species.isMystical, isTrue);
    });

    test('Animal care: petting, feeding, and affection points', () {
      final cow = animalManager.getAnimalById('animal_cow_1')!;
      expect(cow.friendship, 0);
      expect(cow.hearts, 0);

      // Petting
      expect(cow.isPet, isFalse);
      expect(cow.pet(), isTrue);
      expect(cow.isPet, isTrue);
      expect(cow.friendship, 30);

      // Petting again on the same day should fail
      expect(cow.pet(), isFalse);

      // Feeding
      cow.isFed = false;
      expect(cow.feed(), isTrue);
      expect(cow.isFed, isTrue);
      expect(cow.friendship, 45); // 30 + 15

      // Add points up to 200 (1 heart)
      for (int i = 0; i < 6; i++) {
        cow.isPet = false;
        cow.pet();
      }
      expect(cow.hearts, greaterThanOrEqualTo(1));
    });

    test('Daily animal produce and mystical items harvesting', () {
      final chicken = animalManager.getAnimalById('animal_chicken_1')!;
      final amberChicken = animalManager.getAnimalById('animal_amber_chicken')!;
      final mossCalf = animalManager.getAnimalById('animal_moss_calf')!;
      final cloudSheep = animalManager.getAnimalById('animal_cloud_sheep')!;

      // Unfed animal produce should be null
      chicken.isFed = false;
      expect(chicken.harvestProduce(), isNull);

      // Fed animals produce their respective item
      chicken.isFed = true;
      final egg = chicken.harvestProduce();
      expect(egg, isNotNull);
      expect(egg!.id, 'produce_egg');
      expect(chicken.hasProducedToday, isTrue);

      inventory.addItem(egg, count: 1);
      expect(inventory.countOf('produce_egg'), 1);

      // Second harvest on same day fails
      expect(chicken.harvestProduce(), isNull);

      // Mystical produce: Amber Egg
      amberChicken.isFed = true;
      final amberEgg = amberChicken.harvestProduce();
      expect(amberEgg, isNotNull);
      expect(amberEgg!.id, 'produce_amber_egg');
      expect(amberEgg.sellPrice, 280);

      // Mystical produce: Vital Dew from Moss-Calf
      mossCalf.isFed = true;
      final vitalDew = mossCalf.harvestProduce();
      expect(vitalDew, isNotNull);
      expect(vitalDew!.id, 'produce_vital_dew');
      expect(vitalDew.healthRestore, 80.0);

      // Mystical produce: Floating Wool from Cloud-Sheep
      cloudSheep.isFed = true;
      final floatingWool = cloudSheep.harvestProduce();
      expect(floatingWool, isNotNull);
      expect(floatingWool!.id, 'produce_floating_wool');
    });

    test('Animal weather shelter and day advancement', () {
      // Daytime + Sunny -> Outside
      gameState.hour = 12;
      gameState.weather = WeatherType.sunny;
      animalManager.updateWeatherAndShelter(gameState);
      for (final a in animalManager.animals) {
        expect(a.isOutside, isTrue);
      }

      // Rainy weather -> Retreat to shelter
      gameState.weather = WeatherType.rain;
      animalManager.updateWeatherAndShelter(gameState);
      for (final a in animalManager.animals) {
        expect(a.isOutside, isFalse);
      }

      // Nighttime -> Retreat to shelter
      gameState.weather = WeatherType.sunny;
      gameState.hour = 21; // Night
      animalManager.updateWeatherAndShelter(gameState);
      for (final a in animalManager.animals) {
        expect(a.isOutside, isFalse);
      }

      // Day advancement resets daily flags
      final cow = animalManager.getAnimalById('animal_cow_1')!;
      cow.isPet = true;
      cow.hasProducedToday = true;
      animalManager.onNewDay();
      expect(cow.isPet, isFalse);
      expect(cow.hasProducedToday, isFalse);
    });

    test('Fishing system fish catalog and random size bounds', () {
      expect(FishData.allFishes.length, 8);

      final brookTrout = FishData.allFishes.firstWhere((f) => f.id == 'fish_brook_trout');
      expect(brookTrout.isLegendary, isFalse);
      expect(brookTrout.minSizeCm, 25);
      expect(brookTrout.maxSizeCm, 50);

      final phantomCatfish = FishData.allFishes.firstWhere((f) => f.id == 'fish_phantom_catfish');
      expect(phantomCatfish.isLegendary, isTrue);
      expect(phantomCatfish.requiresMoonBait, isTrue);
    });

    test('Fish rolling with environmental conditions and Moon Bait', () {
      // 1. Daytime at the farm without bait -> Regular fish (Brook Trout or Pond Tilapia)
      gameState.hour = 12;
      gameState.weather = WeatherType.sunny;
      final fishDayFarm = FishData.rollFish(
        location: GameLocation.farm,
        state: gameState,
        hasMoonBait: false,
      );
      expect(fishDayFarm.isLegendary, isFalse);
      expect(fishDayFarm.allowedLocations, contains(GameLocation.farm));

      // 2. Nighttime in Forest during Full Moon with Moon Bait -> Eligible for Astral Carp
      gameState.hour = 22; // Night
      gameState.moonPhase = MoonPhase.fullMoon;
      final rolledAstral = FishData.rollFish(
        location: GameLocation.forest,
        state: gameState,
        hasMoonBait: true,
      );
      expect(rolledAstral.allowedLocations, contains(GameLocation.forest));

      // 3. Mine Entrance without Moon Bait cannot catch Phantom Catfish
      final rolledWithoutBait = FishData.rollFish(
        location: GameLocation.mineEntrance,
        state: gameState,
        hasMoonBait: false,
      );
      expect(rolledWithoutBait.id, isNot('fish_phantom_catfish'));

      // 4. Village on sunny noon -> Peixe-Sol Dourado or Pier Catfish
      gameState.hour = 12;
      gameState.weather = WeatherType.sunny;
      final rolledVillage = FishData.rollFish(
        location: GameLocation.village,
        state: gameState,
        hasMoonBait: false,
      );
      expect(rolledVillage.allowedLocations, contains(GameLocation.village));
    });

    test('ValleyMoonGame fishing overlay trigger', () {
      final game = ValleyMoonGame();
      game.overlays.addEntry('FishingMinigame', (context, game) => const SizedBox());
      expect(game.overlays.isActive('FishingMinigame'), isFalse);

      final customFish = FishData.allFishes[0];
      game.startFishing(customFish);

      expect(game.activeFishingFish, customFish);
      expect(game.overlays.isActive('FishingMinigame'), isTrue);
    });
  });
}
