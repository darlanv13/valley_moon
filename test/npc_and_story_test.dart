import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valley_moon/components/map_transition.dart';
import 'package:valley_moon/game/valley_moon_game.dart';
import 'package:valley_moon/models/inventory_system.dart';
import 'package:valley_moon/models/npc_dialogue_system.dart';
import 'package:valley_moon/models/story_system.dart';
import 'package:valley_moon/models/time_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Valley Moon - Etapa 4: NPCs, Diálogos, Romance e Diário do Avô', () {
    late RelationshipManager relationshipManager;
    late StoryManager storyManager;
    late InventoryState inventory;

    setUp(() {
      relationshipManager = RelationshipManager();
      storyManager = StoryManager();
      inventory = InventoryState();
    });

    test('NPC relationship points and heart calculations (250 pts per heart)', () {
      final rel = relationshipManager.getRelationship(NpcId.helena);
      expect(rel.hearts, 0);
      expect(rel.friendshipPoints, 0);
      expect(rel.status, RelationshipStatus.stranger);

      // Add points for 1 heart (250 pts)
      rel.addPoints(250);
      expect(rel.hearts, 1);
      expect(rel.friendshipPoints, 250);

      // Reach 8 hearts (2000 pts)
      rel.addPoints(1750);
      expect(rel.hearts, 8);
      expect(rel.friendshipPoints, 2000);
    });

    test('Gift evaluation for different NPCs and daily gift limits', () {
      final helenaRel = relationshipManager.getRelationship(NpcId.helena);
      // Loved gift for Helena: Scream root or health potion
      expect(helenaRel.evaluateGift('crop_scream_root'), GiftReaction.loved);
      // Liked gift: Dew blossom or wood
      expect(helenaRel.evaluateGift('crop_dew_blossom'), GiftReaction.liked);
      // Hated gift: stone
      expect(helenaRel.evaluateGift('mat_stone'), GiftReaction.hated);

      // Bento gift reaction
      final bentoRel = relationshipManager.getRelationship(NpcId.bento);
      expect(bentoRel.evaluateGift('pot_lamp_oil'), GiftReaction.loved);
      expect(bentoRel.evaluateGift('pot_moon_bait'), GiftReaction.hated);

      // Giving loved gift adds 80 points
      final initialPoints = helenaRel.friendshipPoints;
      final success = relationshipManager.giveGift(NpcId.helena, 'crop_scream_root');
      expect(success, isTrue);
      expect(helenaRel.friendshipPoints, initialPoints + 80);
      expect(helenaRel.giftedToday, isTrue);

      // Second gift on same day should be rejected
      final secondGift = relationshipManager.giveGift(NpcId.helena, 'crop_scream_root');
      expect(secondGift, isFalse);
    });

    test('Romance system: dating at 8 hearts and marriage at 10 hearts', () {
      final irisRel = relationshipManager.getRelationship(NpcId.iris);
      expect(irisRel.canDate, isFalse);

      // Cannot date before 8 hearts
      irisRel.addPoints(1750); // 7 hearts
      expect(irisRel.hearts, 7);
      expect(irisRel.canDate, isFalse);
      expect(relationshipManager.giveLunarAmulet(NpcId.iris), isFalse);

      // Reach 8 hearts (2000 pts) -> Dating unlocks
      irisRel.addPoints(250); // 8 hearts
      expect(irisRel.hearts, 8);
      expect(irisRel.canDate, isTrue);
      final datingSuccess = relationshipManager.giveLunarAmulet(NpcId.iris);
      expect(datingSuccess, isTrue);
      expect(irisRel.status, RelationshipStatus.dating);

      // Cannot marry before 10 hearts
      expect(irisRel.canMarry, isFalse);
      expect(relationshipManager.proposeMarriage(NpcId.iris), isFalse);

      // Reach 10 hearts (2500 pts) -> Marriage unlocks
      irisRel.addPoints(500); // 10 hearts
      expect(irisRel.hearts, 10);
      expect(irisRel.canMarry, isTrue);
      final marriageSuccess = relationshipManager.proposeMarriage(NpcId.iris);
      expect(marriageSuccess, isTrue);
      expect(irisRel.status, RelationshipStatus.married);
    });

    test('Non-romanceable NPCs cannot be dated or married', () {
      final bentoRel = relationshipManager.getRelationship(NpcId.bento);
      bentoRel.addPoints(2500); // 10 hearts
      expect(bentoRel.canDate, isFalse);
      expect(bentoRel.canMarry, isFalse);
      expect(relationshipManager.giveLunarAmulet(NpcId.bento), isFalse);
      expect(relationshipManager.proposeMarriage(NpcId.bento), isFalse);

      final lucioRel = relationshipManager.getRelationship(NpcId.lucio);
      lucioRel.addPoints(2500);
      expect(lucioRel.canDate, isFalse);
      expect(lucioRel.canMarry, isFalse);
    });

    test('Grandfather Diary pages unlock with hearts and altar offerings', () {
      // Page 1 is unlocked initially
      expect(storyManager.diaryPages[0].isUnlocked, isTrue);
      expect(storyManager.diaryPages[1].isUnlocked, isFalse);

      // Reach 4 hearts with any villager -> unlocks Page 2
      storyManager.checkRelationshipUnlocks(4);
      expect(storyManager.diaryPages[1].isUnlocked, isTrue);

      // Reach 6 hearts -> unlocks Page 4
      expect(storyManager.diaryPages[3].isUnlocked, isFalse);
      storyManager.checkRelationshipUnlocks(6);
      expect(storyManager.diaryPages[3].isUnlocked, isTrue);
    });

    test('Four Seasonal Altars offerings and restoration', () {
      final springAltar = storyManager.altars[Season.spring]!;
      expect(springAltar.isRestored, isFalse);

      final initialTurnips = inventory.countOf('crop_turnip');
      final initialWood = inventory.countOf('mat_wood');

      // Add 1 more turnip to have at least 5 (starter kit has 4)
      inventory.addItem(GameItem.turnip, count: 1);

      // Offer to Spring Altar -> succeeds and unlocks Diary Page 3
      final springRestored = storyManager.offerToAltar(Season.spring, inventory);
      expect(springRestored, isTrue);
      expect(springAltar.isRestored, isTrue);
      expect(storyManager.diaryPages[2].isUnlocked, isTrue);

      // Items were consumed correctly
      expect(inventory.countOf('crop_turnip'), initialTurnips + 1 - 5);
      expect(inventory.countOf('mat_wood'), initialWood - 10);

      // Restore Summer, Autumn, Winter to trigger climax (Page 6 unlock)
      // Summer: 5 Wheat, 1 Dew Blossom, 10 Stone
      inventory.addItem(GameItem.wheat, count: 5);
      expect(storyManager.offerToAltar(Season.summer, inventory), isTrue);
      expect(storyManager.diaryPages[4].isUnlocked, isTrue);

      // Autumn: 1 Golden Wheat, 1 Vigor Potion, 1 Scarecrow
      inventory.addItem(GameItem.vigorElixir, count: 1);
      expect(storyManager.offerToAltar(Season.autumn, inventory), isTrue);

      // Winter: 1 Lamp Oil, 1 Rain Totem, 1 Health Potion
      inventory.addItem(GameItem.lampOil, count: 1);
      inventory.addItem(GameItem.healthPotion, count: 1);
      expect(storyManager.offerToAltar(Season.winter, inventory), isTrue);

      // All altars restored -> Page 6 unlocked!
      expect(storyManager.diaryPages[5].isUnlocked, isTrue);
    });

    test('Dialogue repository returns appropriate dialogue nodes with choices', () {
      final greetingDay = NpcDialogueRepository.getGreeting(NpcId.helena, 2, false, false);
      expect(greetingDay.text, contains('plantas'));
      expect(greetingDay.choices, isNotNull);
      expect(greetingDay.choices!.length, greaterThanOrEqualTo(2));

      // Blood moon greeting
      final greetingBloodMoon = NpcDialogueRepository.getGreeting(NpcId.helena, 2, true, true);
      expect(greetingBloodMoon.text, contains('carmesim'));
    });

    test('ValleyMoonGame location and portal transitions', () {
      final game = ValleyMoonGame();
      expect(game.currentLocation, GameLocation.farm);

      // Transition to Village
      game.transitionTo(GameLocation.village, Vector2(40, 240));
      expect(game.currentLocation, GameLocation.village);

      // Transition to Forest
      game.transitionTo(GameLocation.forest, Vector2(300, 420));
      expect(game.currentLocation, GameLocation.forest);

      // Transition to Mine Entrance
      game.transitionTo(GameLocation.mineEntrance, Vector2(580, 240));
      expect(game.currentLocation, GameLocation.mineEntrance);
    });
  });
}
