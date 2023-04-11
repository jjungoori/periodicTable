import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final familyElements = [
  ['수', '리', '나', '칼', '루'],
  ['베', '마', '칼', '스'],
  ['붕', '알', '갈', '인'],
  ['탄', '규', '저', '주'],
  ['질', '인', '비', '안'],
  ['산', '황', '셀', '텔'],
  ['플', '염', '브', '아'],
  ['헬', '네', '아', '크', '제']
];

final r = Random();

List<Element> randomElements(int amount) {
  List<Element> outs = [];

  for (int i = 0; i < amount; i++) {
    int f = r.nextInt(8);
    outs.add(Element(f, familyElements[f].length - 1));
  }

  return outs;
}

class Element {
  int fam = 0;
  int num = 0;
  String char = "수";

  Element(int fam, int num) {
    changeData(fam, num);
  }

  changeData(int fam, int num) {
    this.fam = fam;
    this.num = num;

    this.char = familyElements[fam][num];
  }
}

class Game {
  bool isPlaying = false;

  int selectedFamily = 0;
  int selectedMember = 0;
  List<Element> buttonsElement = [
    Element(1, 1),
    Element(1, 1),
    Element(1, 2),
    Element(3, 1),
    Element(1, 1)
  ];

  Game({int a = 0}) {
    this.selectedFamily = a;
  }

  gameStart() {
    isPlaying = true;

    selectedFamily = r.nextInt(8);

    buttonsElement = randomElements(5);
    if (!buttonsElement.contains(Element(selectedFamily, selectedMember + 1))) {
      buttonsElement[r.nextInt(4)] =
          Element(selectedFamily, selectedMember + 1);
    }
  }

  select(int num) {
    if (buttonsElement[num].char !=
        Element(selectedFamily, selectedMember + 1).char) {
      return;
    }
    selectedMember += 1;
    buttonsElement = randomElements(5);
    if (!buttonsElement.contains(Element(selectedFamily, selectedMember + 1))) {
      buttonsElement[r.nextInt(5)] =
          Element(selectedFamily, selectedMember + 1);
    }
  }
}

class GameNotifier extends StateNotifier<Game> {
  GameNotifier() : super(Game());

  gameStart() {
    final a = state;
    a.gameStart();
    state = a;
  }

  select(num) {
    final a = state;
    a.select(num);
    state = a;
  }
}

final gameManager =
    StateNotifierProvider<GameNotifier, Game>((ref) => GameNotifier());

void main(List<String> args) {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gameManager);

    return Scaffold(
      body: Column(children: [
        Text(familyElements[g.selectedFamily][g.selectedMember]),
        Row(
          children: List.generate(
              5,
              (index) => ElevatedButton(
                  onPressed: () {
                    ref.read(gameManager.notifier).select(index);
                  },
                  child: ProviderScope(
                      child: Text(g.buttonsElement[index].char)))),
        ),
        ElevatedButton(
            onPressed: () {
              ref.watch(gameManager.notifier).gameStart();
              print(g.selectedMember);
            },
            child: Text("start"))
      ]),
    );
  }
}
