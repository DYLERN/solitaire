import 'package:flutter/material.dart';
import 'package:solitaire/game.dart';

const cardWidth = 100.0;
const cardHeight = 140.0;
const revealedCardStackOffset = 30.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final game = Game();

  @override
  void initState() {
    super.initState();
    game.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            Row(
              children: [
                for (int i = 0; i < 4; i++) ...[
                  CardPile(
                    index: i,
                    cards: game.cardPiles[i].cards,
                    type: CardPileType.foundation,
                    onCardAdded: (movingCard) {
                      setState(() {
                        game.moveCard(
                          card: movingCard.card,
                          fromPileIndex: movingCard.fromPileIndex,
                          toPileIndex: i,
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 8.0),
                ],
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 4; i < 11; i++) ...[
                      CardPile(
                        index: i,
                        cards: game.cardPiles[i].cards,
                        type: CardPileType.tableu,
                        onCardAdded: (movingCard) {
                          setState(() {
                            game.moveCard(
                              card: movingCard.card,
                              fromPileIndex: movingCard.fromPileIndex,
                              toPileIndex: i,
                            );
                          });
                        },
                      ),
                      const SizedBox(width: 8.0),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef CardAddedCallback = void Function(MovingCard card);

class CardPile extends StatelessWidget {
  final int index;
  final List<PlayingCard> cards;
  final CardPileType type;
  final CardAddedCallback onCardAdded;

  const CardPile({
    Key? key,
    required this.index,
    required this.cards,
    required this.type,
    required this.onCardAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<MovingCard>(
      onWillAccept: (card) {
        return card != null;
      },
      onAccept: onCardAdded,
      builder: (context, _, __) => Container(
        width: cardWidth,
        constraints: const BoxConstraints(minHeight: cardHeight),
        decoration: BoxDecoration(
          border: cards.isEmpty
              ? Border.all(color: Theme.of(context).colorScheme.onBackground)
              : null,
        ),
        child: Builder(
          builder: (context) {
            switch (type) {
              case CardPileType.foundation:
                if (cards.isEmpty) {
                  return const Center(
                    child: Text('A'),
                  );
                } else {
                  final top = cards.last;
                  return CardWidget(
                    pileIndex: index,
                    card: top,
                  );
                }
              case CardPileType.tableu:
                if (cards.isEmpty) {
                  return const SizedBox.shrink();
                } else {
                  const offset = 30.0;

                  return SizedBox(
                    height: cardHeight + ((cards.length - 1) * offset),
                    child: Stack(
                      children: [
                        for (int i = 0; i < cards.length; i++)
                          Builder(
                            builder: (context) {
                              final card = cards[i];
                              return Positioned(
                                top: i * offset,
                                child: CardWidget(
                                  pileIndex: index,
                                  card: card,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }
}

enum CardPileType { foundation, tableu }

class CardWidget extends StatelessWidget {
  final int pileIndex;
  final PlayingCard card;

  const CardWidget({
    super.key,
    required this.pileIndex,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardTextColor;
    switch (card.suit) {
      case Suit.Spades:
      case Suit.Clubs:
        cardTextColor = Theme.of(context).colorScheme.onBackground;
        break;
      case Suit.Hearts:
      case Suit.Diamonds:
        cardTextColor = Colors.red;
        break;
    }

    final cardContainer = Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: Border.all(color: Theme.of(context).colorScheme.onBackground),
      ),
      child: Builder(
        builder: (context) {
          if (!card.faceUp) {
            // TODO needs a better back
            return const Placeholder();
          }

          return DefaultTextStyle(
            style: TextStyle(color: cardTextColor),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: Text(card.face.textOnCard),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Text(card.suit.textOnCard),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(card.suit.textOnCard),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Text(card.suit.textOnCard),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Text(card.face.textOnCard),
                ),
              ],
            ),
          );
        }
      ),
    );

    return Draggable<MovingCard>(
      feedback: cardContainer,
      data: MovingCard(pileIndex, card),
      childWhenDragging: const SizedBox.shrink(),
      child: cardContainer,
    );
  }
}

class MovingCard {
  final int fromPileIndex;
  final PlayingCard card;

  MovingCard(this.fromPileIndex, this.card);
}
