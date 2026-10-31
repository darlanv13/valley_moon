import 'package:flutter/foundation.dart';

enum NpcId {
  bento('Bento', 'Prefeito Nervoso', false),
  kael('Kael', 'Ferreiro Recluso', true),
  helena('Helena', 'Herborista Misteriosa', true),
  lucio('Lúcio', 'Pescador Amargurado', false),
  iris('Íris', 'Barda da Taverna', true),
  maya('Maya', 'Criadora de Animais Mágicos', true);

  final String displayName;
  final String title;
  final bool isMarriageCandidate;

  const NpcId(this.displayName, this.title, this.isMarriageCandidate);
}

enum RelationshipStatus {
  stranger('Conhecido', '🩶'),
  friend('Amigo', '💙'),
  dating('Namorado(a)', '💖'),
  married('Cônjuge', '💍');

  final String label;
  final String icon;

  const RelationshipStatus(this.label, this.icon);
}

enum GiftReaction {
  loved,
  liked,
  neutral,
  hated,
}

class NpcRelationship {
  final NpcId id;
  int friendshipPoints = 0; // 0 to 2500 (250 per heart = 10 hearts)
  RelationshipStatus status = RelationshipStatus.stranger;
  bool talkedToday = false;
  bool giftedToday = false;

  NpcRelationship({required this.id});

  int get hearts => (friendshipPoints / 250).clamp(0, 10).floor();

  bool get canDate =>
      id.isMarriageCandidate &&
      hearts >= 8 &&
      status != RelationshipStatus.dating &&
      status != RelationshipStatus.married;

  bool get canMarry =>
      id.isMarriageCandidate &&
      hearts >= 10 &&
      status == RelationshipStatus.dating;

  void addPoints(int points) {
    friendshipPoints = (friendshipPoints + points).clamp(0, 2500);
    if (hearts >= 8 && status == RelationshipStatus.dating) {
      // Maintains dating
    } else if (hearts >= 2 && status == RelationshipStatus.stranger) {
      status = RelationshipStatus.friend;
    }
  }

  GiftReaction evaluateGift(String itemId) {
    switch (id) {
      case NpcId.helena:
        if (itemId == 'crop_scream_root' || itemId == 'pot_health') return GiftReaction.loved;
        if (itemId == 'crop_dew_blossom' || itemId == 'mat_wood') return GiftReaction.liked;
        if (itemId == 'mat_stone') return GiftReaction.hated;
        return GiftReaction.neutral;

      case NpcId.kael:
        if (itemId == 'mat_stone' || itemId == 'tool_sword') return GiftReaction.loved;
        if (itemId == 'mat_wood' || itemId == 'craft_chest') return GiftReaction.liked;
        if (itemId == 'crop_turnip') return GiftReaction.hated;
        return GiftReaction.neutral;

      case NpcId.iris:
        if (itemId == 'crop_golden_wheat' || itemId == 'pot_vigor') return GiftReaction.loved;
        if (itemId == 'crop_turnip' || itemId == 'pot_moon_bait') return GiftReaction.liked;
        if (itemId == 'mat_wood') return GiftReaction.hated;
        return GiftReaction.neutral;

      case NpcId.maya:
        if (itemId == 'crop_dew_blossom' || itemId == 'craft_scarecrow') return GiftReaction.loved;
        if (itemId == 'crop_turnip' || itemId == 'crop_wheat') return GiftReaction.liked;
        if (itemId == 'tool_sword') return GiftReaction.hated;
        return GiftReaction.neutral;

      case NpcId.lucio:
        if (itemId == 'pot_moon_bait') return GiftReaction.loved;
        if (itemId == 'mat_wood' || itemId == 'tool_water') return GiftReaction.liked;
        if (itemId == 'crop_scream_root') return GiftReaction.hated;
        return GiftReaction.neutral;

      case NpcId.bento:
        if (itemId == 'pot_lamp_oil' || itemId == 'crop_turnip') return GiftReaction.loved;
        if (itemId == 'craft_fence' || itemId == 'mat_stone') return GiftReaction.liked;
        if (itemId == 'pot_moon_bait') return GiftReaction.hated;
        return GiftReaction.neutral;
    }
  }

  void onNewDay() {
    talkedToday = false;
    giftedToday = false;
  }
}

class DialogueChoice {
  final String text;
  final String response;
  final int pointsBonus;

  const DialogueChoice({
    required this.text,
    required this.response,
    this.pointsBonus = 20,
  });
}

class DialogueNode {
  final NpcId npc;
  final String text;
  final String expression; // neutral, happy, surprised, blushing, sad
  final List<DialogueChoice>? choices;

  const DialogueNode({
    required this.npc,
    required this.text,
    this.expression = 'neutral',
    this.choices,
  });
}

class NpcDialogueRepository {
  static DialogueNode getGreeting(NpcId id, int hearts, bool isBloodMoon, bool isNight) {
    if (isBloodMoon) {
      switch (id) {
        case NpcId.helena:
          return const DialogueNode(
            npc: NpcId.helena,
            text: 'A névoa carmesim queima a pele do pântano... O véu entre nós e os espíritos antigos está rasgado!',
            expression: 'surprised',
          );
        case NpcId.kael:
          return const DialogueNode(
            npc: NpcId.kael,
            text: 'Fique perto da forja, forasteiro. Minhas lâminas vibram sozinhas nesta noite de sangue.',
            expression: 'neutral',
          );
        case NpcId.bento:
          return const DialogueNode(
            npc: NpcId.bento,
            text: 'Pelos céus! Tranque as portas da fazenda! A Cinza Silenciosa está descendo sobre o vale!',
            expression: 'surprised',
          );
        case NpcId.iris:
          return const DialogueNode(
            npc: NpcId.iris,
            text: 'Nem as cordas do meu alaúde conseguem abafar os sussurros que vêm dos bosques esta noite...',
            expression: 'surprised',
          );
        case NpcId.maya:
          return const DialogueNode(
            npc: NpcId.maya,
            text: 'Os animais estão inquietos... Proteja seus canteiros com os Espantalhos antes que seja tarde!',
            expression: 'surprised',
          );
        case NpcId.lucio:
          return const DialogueNode(
            npc: NpcId.lucio,
            text: 'A água do lago virou tinta escura. Nenhum peixe de bom senso nada sob a Lua de Sangue.',
            expression: 'sad',
          );
      }
    }

    switch (id) {
      case NpcId.bento:
        return DialogueNode(
          npc: NpcId.bento,
          text: 'Ah, o novo herdeiro da fazenda! Espero que você consiga reerguer as terras do seu finado avô.',
          expression: 'neutral',
          choices: const [
            DialogueChoice(
              text: 'Estou me esforçando para cuidar de tudo!',
              response: 'Excelente! A vila precisa de sangue novo e colheitas fartas.',
              pointsBonus: 25,
            ),
            DialogueChoice(
              text: 'A fazenda guarda muitos mistérios...',
              response: 'Mistérios? Cuidado com o que desenterra na floresta...',
              pointsBonus: 15,
            ),
          ],
        );

      case NpcId.kael:
        return DialogueNode(
          npc: NpcId.kael,
          text: hearts >= 4
              ? 'Bom ver você por aqui. O calor da forja é melhor quando temos boa companhia.'
              : 'Se precisa de ferramentas afiadas, está no lugar certo. Não sou homem de muita conversa.',
          expression: hearts >= 4 ? 'happy' : 'neutral',
          choices: [
            const DialogueChoice(
              text: 'Seu trabalho com aço e ferro é impressionante.',
              response: 'Obrigado. O aço nunca mente para quem o forja com respeito.',
              pointsBonus: 30,
            ),
            const DialogueChoice(
              text: 'Vim apenas dar uma olhada.',
              response: 'Fique à vontade, só não encoste na bigorna quente.',
              pointsBonus: 10,
            ),
          ],
        );

      case NpcId.helena:
        return DialogueNode(
          npc: NpcId.helena,
          text: hearts >= 4
              ? 'As raízes da floresta cantam sobre sua dedicação. Há magia antiga correndo em suas mãos.'
              : 'As plantas do vale têm segredos que os olhos apressados nunca perceberão.',
          expression: hearts >= 4 ? 'happy' : 'neutral',
          choices: [
            const DialogueChoice(
              text: 'Adoraria aprender sobre a alquimia e as ervas.',
              response: 'A colheita noturna sob o luar é o primeiro passo para ouvir o caldeirão.',
              pointsBonus: 35,
            ),
            const DialogueChoice(
              text: 'O pântano parece meio sombrio.',
              response: 'O que você chama de sombrio, eu chamo de lar.',
              pointsBonus: 5,
            ),
          ],
        );

      case NpcId.lucio:
        return const DialogueNode(
          npc: NpcId.lucio,
          text: 'Paciência é tudo na pesca. O rio dá para quem sabe esperar e tira de quem tem pressa.',
          expression: 'neutral',
          choices: [
            DialogueChoice(
              text: 'Você conhece os peixes mágicos do lago?',
              response: 'As Iscas da Lua trazem criaturas que brilham no escuro... Coisa de arrepiar.',
              pointsBonus: 25,
            ),
          ],
        );

      case NpcId.iris:
        return DialogueNode(
          npc: NpcId.iris,
          text: hearts >= 4
              ? 'Ah! Meu fazendeiro favorito! Trouxe alguma inspiração para minha próxima canção?'
              : 'Uma boa melodia de alaúde faz até a cerveja amarga da taverna descer como néctar.',
          expression: hearts >= 4 ? 'blushing' : 'happy',
          choices: [
            const DialogueChoice(
              text: 'Sua música ilumina o vale inteiro.',
              response: 'Ora, assim você me deixa sem graça... Mas continue elogiando!',
              pointsBonus: 30,
            ),
            const DialogueChoice(
              text: 'A taverna é muito movimentada à noite?',
              response: 'Sempre! Os camponeses adoram dançar ao redor da lareira.',
              pointsBonus: 15,
            ),
          ],
        );

      case NpcId.maya:
        return DialogueNode(
          npc: NpcId.maya,
          text: hearts >= 4
              ? 'Os passarinhos me contaram que você colocou um Espantalho Vivo na fazenda! Eles se sentem seguros.'
              : 'Trate a terra e os animais com ternura, e o vale retribuirá em abundância.',
          expression: hearts >= 4 ? 'happy' : 'neutral',
          choices: [
            const DialogueChoice(
              text: 'Os animais místicos são fascinantes.',
              response: 'Eles sentem a pureza da sua intenção. Venha me visitar sempre!',
              pointsBonus: 30,
            ),
          ],
        );
    }
  }
}

/// Manages all NPC relationship states and heart progression.
class RelationshipManager extends ChangeNotifier {
  final Map<NpcId, NpcRelationship> relationships = {};

  RelationshipManager() {
    for (final id in NpcId.values) {
      relationships[id] = NpcRelationship(id: id);
    }
  }

  NpcRelationship getRelationship(NpcId id) => relationships[id]!;

  bool giveGift(NpcId id, String itemId) {
    final rel = relationships[id]!;
    if (rel.giftedToday) return false;

    rel.giftedToday = true;
    final reaction = rel.evaluateGift(itemId);

    switch (reaction) {
      case GiftReaction.loved:
        rel.addPoints(80);
        break;
      case GiftReaction.liked:
        rel.addPoints(45);
        break;
      case GiftReaction.neutral:
        rel.addPoints(20);
        break;
      case GiftReaction.hated:
        rel.addPoints(-40);
        break;
    }

    notifyListeners();
    return true;
  }

  bool giveMoonflowerAmulet(NpcId id) {
    final rel = relationships[id]!;
    if (!id.isMarriageCandidate) return false;
    if (rel.hearts >= 8 && rel.status != RelationshipStatus.dating) {
      rel.status = RelationshipStatus.dating;
      rel.addPoints(100);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool giveLunarAmulet(NpcId id) => giveMoonflowerAmulet(id);

  bool proposeMarriage(NpcId id) {
    final rel = relationships[id]!;
    if (!id.isMarriageCandidate) return false;
    if (rel.hearts >= 10 && rel.status == RelationshipStatus.dating) {
      rel.status = RelationshipStatus.married;
      rel.addPoints(150);
      notifyListeners();
      return true;
    }
    return false;
  }

  void onNewDay() {
    for (final rel in relationships.values) {
      rel.onNewDay();
    }
    notifyListeners();
  }
}

