class Game {
  final foundationPiles = List.unmodifiable([
    for (int i = 0; i < 4; i++) FoundationPile(),
  ]);

  final tableuPiles = List.unmodifiable([
    for (int i = 0; i < 7; i++) TableuPile(),
  ]);

  final drawPile = DrawPile();
  final stockPile = StockPile();

  void init() {
    final deck = <PlayingCard>[];

    for (final suit in Suit.values) {
      for (final face in Face.values) {
        deck.add(PlayingCard(suit: suit, face: face));
      }
    }

    deck.shuffle();

    for (int i = 0; i < tableuPiles.length; i++) {
      final numCards = i + 1;
      final cards = deck.take(numCards).toList();
      cards.last.faceUp = true;
      deck.removeRange(0, numCards);

      tableuPiles[i].addCards(cards);
    }

    stockPile.addCards(deck);
    deck.clear();
  }

  // TODO change to list of cards
  void moveCard({
    required PlayingCard card,
    required CardPile fromPile,
    required CardPile toPile,
  }) {
    if (!card.faceUp || !toPile.willAcceptCard(card)) {
      return;
    }

    final cardsAbove = fromPile.cards.skipWhile((value) => value != card);

    toPile.addCards(cardsAbove);
    fromPile.removeCards(cardsAbove);

    if (fromPile is TableuPile && fromPile.isNotEmpty) {
      fromPile.cards.last.faceUp = true;
    }
  }

  void pullFromStock() {
    final stockEmpty = stockPile.isEmpty;
    final drawEmpty = drawPile.isEmpty;

    if (stockEmpty && drawEmpty) {
      return;
    } else if (stockEmpty) {
      // recycle
      final drawCards = drawPile.cards;
      for (final card in drawCards) {
        card.faceUp = false;
      }
      stockPile.addCards(drawCards.reversed);
      drawPile.removeAll();
    } else {
      // draw
      final stockTop = stockPile.topCard!;
      stockPile.removeCard(stockTop);
      stockTop.faceUp = true;
      drawPile.addCard(stockTop);
    }
  }
}

abstract class CardPile {
  final List<PlayingCard> cards = [];

  PlayingCard? get topCard => cards.isEmpty ? null : cards.last;

  bool get isEmpty => cards.isEmpty;

  bool get isNotEmpty => !isEmpty;

  void addCard(PlayingCard card) {
    cards.add(card);
  }

  void addCards(Iterable<PlayingCard> cards) {
    this.cards.addAll(cards);
  }

  void removeCard(PlayingCard card) {
    cards.remove(card);
  }

  void removeCards(Iterable<PlayingCard> cards) {
    this.cards.removeWhere((element) => cards.contains(element));
  }

  void removeAll() {
    cards.clear();
  }

  bool willAcceptCard(PlayingCard card);
}

class FoundationPile extends CardPile {
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

class TableuPile extends CardPile {
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

class DrawPile extends CardPile {
  @override
  bool willAcceptCard(PlayingCard card) {
    return false;
  }
}

class StockPile extends CardPile {
  @override
  bool willAcceptCard(PlayingCard card) {
    return false;
  }
}

class PlayingCard {
  final Suit suit;
  final Face face;
  bool faceUp;

  PlayingCard({
    required this.suit,
    required this.face,
    this.faceUp = false,
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
