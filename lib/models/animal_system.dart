import 'package:flutter/foundation.dart';
import 'inventory_system.dart';
import 'time_system.dart';

enum AnimalSpecies {
  chicken(
    name: 'Galinha Caipira',
    icon: '🐔',
    spriteAsset: 'animals/chicken.png',
    frameWidth: 16.0,
    frameHeight: 16.0,
    produceItem: GameItem.egg,
    isMystical: false,
    preferredFeed: 'mat_wood', // or grain
  ),
  amberChicken(
    name: 'Galinha de Âmbar',
    icon: '✨🐔',
    spriteAsset: 'animals/amber_chicken.png',
    frameWidth: 16.0,
    frameHeight: 16.0,
    produceItem: GameItem.amberEgg,
    isMystical: true,
  ),
  cow(
    name: 'Vaca Malhada',
    icon: '🐄',
    spriteAsset: 'animals/cow.png',
    frameWidth: 32.0,
    frameHeight: 32.0,
    produceItem: GameItem.milk,
    isMystical: false,
  ),
  mossCalf(
    name: 'Bezerro-Musgo',
    icon: '🌿🐮',
    spriteAsset: 'animals/moss_calf.png',
    frameWidth: 32.0,
    frameHeight: 32.0,
    produceItem: GameItem.vitalDew,
    isMystical: true,
  ),
  sheep(
    name: 'Ovelha Peluda',
    icon: '🐑',
    spriteAsset: 'animals/sheep.png',
    frameWidth: 24.0,
    frameHeight: 24.0,
    produceItem: GameItem.wool,
    isMystical: false,
  ),
  cloudSheep(
    name: 'Ovelha-Nuvem',
    icon: '☁️🐑',
    spriteAsset: 'animals/cloud_sheep.png',
    frameWidth: 24.0,
    frameHeight: 24.0,
    produceItem: GameItem.floatingWool,
    isMystical: true,
  ),
  pig(
    name: 'Porco Fuçador',
    icon: '🐖',
    spriteAsset: 'animals/pig.png',
    frameWidth: 24.0,
    frameHeight: 24.0,
    produceItem: GameItem.truffle,
    isMystical: false,
  ),
  pet(
    name: 'Cão Pastor do Vale',
    icon: '🐕',
    spriteAsset: 'animals/pet.png',
    frameWidth: 16.0,
    frameHeight: 16.0,
    produceItem: null,
    isMystical: false,
  );

  final String name;
  final String icon;
  final String spriteAsset;
  final double frameWidth;
  final double frameHeight;
  final GameItem? produceItem;
  final bool isMystical;
  final String preferredFeed;

  const AnimalSpecies({
    required this.name,
    required this.icon,
    required this.spriteAsset,
    required this.frameWidth,
    required this.frameHeight,
    required this.produceItem,
    required this.isMystical,
    this.preferredFeed = 'crop_wheat',
  });
}

/// Represents an individual farm animal.
class FarmAnimal {
  final String id;
  final String nickname;
  final AnimalSpecies species;
  int friendship; // 0 to 1000 (200 pts per heart = 5 hearts)
  bool isFed;
  bool isPet;
  bool hasProducedToday;
  bool isOutside;

  FarmAnimal({
    required this.id,
    required this.nickname,
    required this.species,
    this.friendship = 0,
    this.isFed = false,
    this.isPet = false,
    this.hasProducedToday = false,
    this.isOutside = true,
  });

  int get hearts => (friendship / 200).clamp(0, 5).floor();

  /// Feed the animal for the day.
  bool feed() {
    if (isFed) return false;
    isFed = true;
    friendship = (friendship + 15).clamp(0, 1000);
    return true;
  }

  /// Pet the animal (gentle affection).
  bool pet() {
    if (isPet) return false;
    isPet = true;
    friendship = (friendship + 30).clamp(0, 1000);
    return true;
  }

  /// Harvest daily animal produce.
  GameItem? harvestProduce() {
    if (species.produceItem == null || hasProducedToday) return null;
    if (!isFed) return null; // Unfed animals don't produce

    hasProducedToday = true;
    // Extra friendship for collecting produce
    friendship = (friendship + 10).clamp(0, 1000);
    return species.produceItem;
  }

  void onNewDay() {
    isPet = false;
    hasProducedToday = false;
    // If not fed previous day, lose small amount of friendship
    if (!isFed) {
      friendship = (friendship - 20).clamp(0, 1000);
    }
    isFed = false;
  }
}

/// Global Animal Herd Manager.
class AnimalManager extends ChangeNotifier {
  final List<FarmAnimal> animals = [];

  AnimalManager() {
    _initializeDefaultFarmHerd();
  }

  void _initializeDefaultFarmHerd() {
    animals.addAll([
      FarmAnimal(
        id: 'animal_chicken_1',
        nickname: 'Pipoca',
        species: AnimalSpecies.chicken,
        isFed: true,
      ),
      FarmAnimal(
        id: 'animal_amber_chicken',
        nickname: 'Solária',
        species: AnimalSpecies.amberChicken,
        isFed: true,
      ),
      FarmAnimal(
        id: 'animal_cow_1',
        nickname: 'Mimosa',
        species: AnimalSpecies.cow,
        isFed: true,
      ),
      FarmAnimal(
        id: 'animal_moss_calf',
        nickname: 'Brotinho',
        species: AnimalSpecies.mossCalf,
        isFed: true,
      ),
      FarmAnimal(
        id: 'animal_sheep_1',
        nickname: 'Algodão',
        species: AnimalSpecies.sheep,
        isFed: true,
      ),
      FarmAnimal(
        id: 'animal_cloud_sheep',
        nickname: 'Nebulosa',
        species: AnimalSpecies.cloudSheep,
        isFed: true,
      ),
      FarmAnimal(
        id: 'animal_pig_1',
        nickname: 'Torresmo',
        species: AnimalSpecies.pig,
        isFed: true,
      ),
      FarmAnimal(
        id: 'animal_pet_dog',
        nickname: 'Trovão',
        species: AnimalSpecies.pet,
        isFed: true,
      ),
    ]);
  }

  FarmAnimal? getAnimalById(String id) {
    try {
      return animals.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateWeatherAndShelter(GameState state) {
    final shouldBeInside = state.isNight || state.weather == WeatherType.rain || state.weather == WeatherType.fog;
    for (final animal in animals) {
      animal.isOutside = !shouldBeInside;
    }
    notifyListeners();
  }

  void onNewDay() {
    for (final animal in animals) {
      animal.onNewDay();
    }
    notifyListeners();
  }
}
