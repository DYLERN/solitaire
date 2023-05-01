class Game {
  final List<PlayingCard> deck = [];

  static const numFoundations = 4;
  static const numTableu = 7;

  final List<CardPile> cardPiles = [
    // Foundations
    for (int i = 0; i < numFoundations; i++) Foundation(),
    // Tableus
    for (int i = 0; i < numTableu; i++) Tableu(),
  ];

  void init() {
    deck.clear();

    for (final suit in Suit.values) {
      for (final face in Face.values) {
        deck.add(PlayingCard(suit: suit, face: face));
      }
    }

    deck.shuffle();

    for (int i = 0; i < numTableu; i++) {
      final numCards = i + 1;
      final cards = deck.take(numCards).toList();
      deck.removeRange(0, numCards);

      cardPiles[i + numFoundations].addCards(cards);
    }
  }

  // TODO change to list of cards
  void moveCard({
    required PlayingCard card,
    required int fromPileIndex,
    required int toPileIndex,
  }) {
    final fromPile = cardPiles[fromPileIndex];
    final toPile = cardPiles[toPileIndex];

    if (!toPile.willAcceptCard(card)) {
      return;
    }

    toPile.addCard(card);
    fromPile.removeCard(card);
  }
}

abstract class CardPile {
  final List<PlayingCard> cards = [];

  PlayingCard? get topCard => cards.isEmpty ? null : cards.last;

  void addCard(PlayingCard card) {
    cards.add(card);
  }

  void addCards(List<PlayingCard> cards) {
    this.cards.addAll(cards);
  }

  void removeCard(PlayingCard card) {
    cards.remove(card);
  }

  bool willAcceptCard(PlayingCard card);
}

class Foundation extends CardPile {
  @override
  bool willAcceptCard(PlayingCard card) {
    final top = topCard;

    if (top == null) {
      // add if ace
      return card.face == Face.Ace;
    } else {
      // add if same suit and one higher
      final sameSuit = card.suit == top.suit;
      final valueDiff = card.face.cardValue - top.face.cardValue;
      return sameSuit && valueDiff == 1;
    }
  }
}

class Tableu extends CardPile {
  @override
  bool willAcceptCard(PlayingCard card) {
    final top = topCard;

    if (top == null) {
      // add if king
      return card.face == Face.King;
    } else {
      // add if different suit color and one lower
      final differentColor = card.suit.color != top.suit.color;
      final valueDiff = card.face.cardValue - top.face.cardValue;
      return differentColor && valueDiff == -1;
    }
  }
}

class PlayingCard {
  final Suit suit;
  final Face face;

  const PlayingCard({
    required this.suit,
    required this.face,
  });

  @override
  String toString() {
    return '${face.name} of ${suit.name}';
  }
}

enum Suit {
  Spades('♠', SuitColor.black),
  Clubs('♣', SuitColor.black),
  Hearts('♥', SuitColor.red),
  Diamonds('♦', SuitColor.red);

  final String textOnCard;
  final SuitColor color;

  const Suit(this.textOnCard, this.color);
}

enum SuitColor { red, black }

enum Face {
  Ace(1, 'A'),
  Two(2, '2'),
  Three(3, '3'),
  Four(4, '4'),
  Five(5, '5'),
  Six(6, '6'),
  Seven(7, '7'),
  Eight(8, '8'),
  Nine(9, '9'),
  Ten(10, '10'),
  Jack(11, 'J'),
  Queen(12, 'Q'),
  King(13, 'K');

  final int cardValue;
  final String textOnCard;

  const Face(
    this.cardValue,
    this.textOnCard,
  );
}
