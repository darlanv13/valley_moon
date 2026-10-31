import 'package:flutter/material.dart';

/// Constants and configuration for Valley Moon.
class GameConstants {
  // World & Grid
  static const double tileSize = 16.0;
  static const int mapTileWidth = 32;
  static const int mapTileHeight = 24;
  static const double mapWidth = mapTileWidth * tileSize; // 512.0
  static const double mapHeight = mapTileHeight * tileSize; // 384.0

  // Camera Virtual Resolution (Retro 16:9 pixel-perfect viewport)
  static const double virtualWidth = 384.0;
  static const double virtualHeight = 256.0;

  // Player Speeds
  static const double playerWalkSpeed = 75.0;
  static const double playerRunSpeed = 120.0;

  // Aesthetic Rustic Colors (Parchment, Aged Timber, Moonstone Glow)
  static const Color parchmentLight = Color(0xFFF4ECD8);
  static const Color parchmentDark = Color(0xFFDCC8A0);
  static const Color rusticWood = Color(0xFF4A3319);
  static const Color rusticWoodDark = Color(0xFF2C1D0F);
  static const Color moonstoneGlow = Color(0xFF8AE3FF);
  static const Color energyGreen = Color(0xFF5BB341);
  static const Color healthRed = Color(0xFFC0392B);

  // Asset Paths
  static const String fontPixel = 'PressStart2P';
  static const String tmxFarmMap = 'farm_map.tmx';

  // Audio Assets
  static const String bgmVillage = 'village.ogg';
  static const String bgmForest = 'forest.ogg';
  static const String bgmRain = 'rain.ogg';
  static const String bgmWind = 'wind.ogg';
  static const String sfxFootstep = 'footstep_grass.ogg';
  static const String sfxChop = 'chop.ogg';
  static const String sfxToolSwing = 'tool_swing.ogg';
  static const String sfxDoorOpen = 'door_open.ogg';
  static const String sfxCoins = 'coins.ogg';
  static const String sfxDig = 'dig.ogg';
  static const String sfxWater = 'water.ogg';
  static const String sfxSplash = 'splash.ogg';
  static const String sfxAnimalPet = 'animal_pet.ogg';
  static const String sfxFishingCast = 'fishing_cast.ogg';
  static const String sfxFishingBite = 'fishing_bite.ogg';
  static const String sfxFishCaught = 'fish_caught.ogg';

  // Crop, Magic & Creature Sprites
  static const String cropsSheet = 'tiles/crops.png';
  static const String scarecrowImg = 'tiles/scarecrow.png';
  static const String rainTotemImg = 'tiles/rain_totem.png';
  static const String fishesSheet = 'fishing/fishes.png';
  static const String bobberImg = 'fishing/bobber.png';
  static const String rodImg = 'fishing/rod.png';
}

