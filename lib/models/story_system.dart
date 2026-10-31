import 'package:flutter/foundation.dart';
import 'inventory_system.dart';
import 'time_system.dart';

class DiaryPage {
  final int number;
  final String title;
  final String dateNote;
  final String lore;
  final String unlockedRecipe;
  bool isUnlocked;

  DiaryPage({
    required this.number,
    required this.title,
    required this.dateNote,
    required this.lore,
    required this.unlockedRecipe,
    this.isUnlocked = false,
  });
}

class SeasonAltar {
  final Season season;
  final String name;
  final String description;
  final String blessingName;
  final String blessingDescription;
  final Map<String, int> requiredOfferings; // Item ID -> Count
  bool isRestored;

  SeasonAltar({
    required this.season,
    required this.name,
    required this.description,
    required this.blessingName,
    required this.blessingDescription,
    required this.requiredOfferings,
    this.isRestored = false,
  });
}

/// Storyline Manager: Grandfather's Diary & The Four Season Altars.
class StoryManager extends ChangeNotifier {
  final List<DiaryPage> diaryPages = [
    DiaryPage(
      number: 1,
      title: 'O Chamado da Lua Antiga',
      dateNote: '1º de Primavera, Ano do Carvalho',
      lore: 'Se você encontrou este diário, meu neto, a fazenda agora é sua. Este vale não é comum: as colheitas sentem a respiração da Lua. Quando a névoa rubra da Lua de Sangue descer, proteja a terra com os totens antigos.',
      unlockedRecipe: 'Espantalho Vivo & Cerca de Madeira',
      isUnlocked: true,
    ),
    DiaryPage(
      number: 2,
      title: 'O Segredo da Cinza Silenciosa',
      dateNote: '14 de Primavera, Ano da Névoa',
      lore: 'A Cinza Silenciosa não é uma praga comum da terra; é o lamento dos espíritos esquecidos da floresta. Somente as oferendas nos Quatro Altares e o carinho dos moradores podem reatar o pacto sagrado com Valley Moon.',
      unlockedRecipe: 'Poção de Cura da Floresta (Caldeirão)',
      isUnlocked: false,
    ),
    DiaryPage(
      number: 3,
      title: 'Os Quatro Altares da Floresta',
      dateNote: '22 de Verão, Ano das Pedras',
      lore: 'No coração da Floresta Sussurrante repousam quatro blocos de pedra intocados pelo tempo. Cada estação pede o sacrifício de frutos da terra. O Altar da Primavera clama por Raiz-Gritante e madeira pura.',
      unlockedRecipe: 'Totem de Chuva Rúnico',
      isUnlocked: false,
    ),
    DiaryPage(
      number: 4,
      title: 'O Coração de Aço e Feras',
      dateNote: '7 de Outono, Ano do Fogo',
      lore: 'Kael sabe mais sobre as minas antigas do que aparenta, e os pássaros de Maya carregam recados dos totens. O homem que aprende a ouvir a terra nunca passa fome ou solidão.',
      unlockedRecipe: 'Isca Encantada da Lua (Pesca)',
      isUnlocked: false,
    ),
    DiaryPage(
      number: 5,
      title: 'A Alquimia das Noites Carmesins',
      dateNote: '18 de Outono, Noite de Sangue',
      lore: 'Quando o céu sangrar e a Flor-de-Orvalho se abrir, destile suas lágrimas no caldeirão de ferro forjado. O Elixir de Vigor desperta forças ancestrais adormecidas no corpo.',
      unlockedRecipe: 'Elixir de Vigor Lunar & Óleo Élfico',
      isUnlocked: false,
    ),
    DiaryPage(
      number: 6,
      title: 'O Despertar da Terra Imortal',
      dateNote: 'Ato II - Restauração Completa',
      lore: 'Os Quatro Altares ardem em chamas espirituais puras. A Cinza Silenciosa dissipou-se para sempre. Valley Moon agora brilha sob um céu de estrelas eternas. O legado está cumprido.',
      unlockedRecipe: 'Amuleto da Flor Lunar & Aliança Eterna',
      isUnlocked: false,
    ),
  ];

  final Map<Season, SeasonAltar> altars = {
    Season.spring: SeasonAltar(
      season: Season.spring,
      name: 'Altar da Primavera',
      description: 'Ofereça os primeiros brotos da terra e lenha da floresta.',
      blessingName: 'Passo Ligeiro da Primavera',
      blessingDescription: '+15% de velocidade de movimento permanente ao fazendeiro.',
      requiredOfferings: {
        'crop_turnip': 5,
        'crop_scream_root': 1,
        'mat_wood': 10,
      },
    ),
    Season.summer: SeasonAltar(
      season: Season.summer,
      name: 'Altar do Verão',
      description: 'Ofereça trigo dourado pelo sol e pedras polidas.',
      blessingName: 'Bênção da Água Fértil',
      blessingDescription: 'Colheitas têm 20% de chance de crescer o dobro de rápido.',
      requiredOfferings: {
        'crop_wheat': 5,
        'crop_dew_blossom': 1,
        'mat_stone': 10,
      },
    ),
    Season.autumn: SeasonAltar(
      season: Season.autumn,
      name: 'Altar do Outono',
      description: 'Ofereça colheitas raras do luar e um guardião da terra.',
      blessingName: 'Escudo das Cinzas',
      blessingDescription: 'Protege a fazenda contra a perda de colheitas durante névoas.',
      requiredOfferings: {
        'crop_golden_wheat': 1,
        'pot_vigor': 1,
        'craft_scarecrow': 1,
      },
    ),
    Season.winter: SeasonAltar(
      season: Season.winter,
      name: 'Altar do Inverno',
      description: 'Ofereça a luz de lamparina e os totens de chuva.',
      blessingName: 'Vigor Eterno da Lua',
      blessingDescription: '+30 pontos de energia máxima ao jogador e resistência ao frio.',
      requiredOfferings: {
        'pot_lamp_oil': 1,
        'craft_rain_totem': 1,
        'pot_health': 1,
      },
    ),
  };

  void checkRelationshipUnlocks(int maxHearts) {
    if (maxHearts >= 4 && !diaryPages[1].isUnlocked) {
      diaryPages[1].isUnlocked = true;
      notifyListeners();
    }
    if (maxHearts >= 6 && !diaryPages[3].isUnlocked) {
      diaryPages[3].isUnlocked = true;
      notifyListeners();
    }
  }

  bool offerToAltar(Season season, InventoryState inv) {
    final altar = altars[season]!;
    if (altar.isRestored) return false;

    // Check ingredients
    if (!inv.hasIngredients(altar.requiredOfferings)) return false;

    // Consume ingredients
    inv.consumeIngredients(altar.requiredOfferings);
    altar.isRestored = true;

    // Unlock corresponding diary pages
    if (season == Season.spring) {
      diaryPages[2].isUnlocked = true;
    } else if (season == Season.summer) {
      diaryPages[4].isUnlocked = true;
    }

    // Check if all altars are restored (climax of Act II)
    if (altars.values.every((a) => a.isRestored)) {
      diaryPages[5].isUnlocked = true;
    }

    notifyListeners();
    return true;
  }
}

