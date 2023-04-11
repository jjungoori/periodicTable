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

class ButtonsNotifier extends StateNotifier<List<Element>> {
  ButtonsNotifier() : super(randomElements(5));

  makeRandom(Element req) {
    final a = randomElements(5);
    if (!a.contains(req)) {
      a[r.nextInt(5)] = req;
    }
    state = a;
  }
}

final buttonsManager = StateNotifierProvider<ButtonsNotifier, List<Element>>(
    (ref) => ButtonsNotifier());

class Game {
  bool isPlaying = false;

  int selectedFamily = 0;
  int selectedMember = 0;

  bool right = false;

  Game({int a = 0}) {
    this.selectedFamily = a;
  }

  gameStart() {
    isPlaying = true;

    selectedFamily = r.nextInt(8);
  }
}

class GameNotifier extends StateNotifier<Game> {
  GameNotifier() : super(Game());

  gameStart() {
    final a = state;
    a.gameStart();
    state = a;
  }

  selectMem(int val) {
    final a = state;
    a.selectedMember = val;
    state = a;
  }

  selectFam(int val) {
    final a = state;
    a.selectedFamily = val;
    if (val > 7) {
      a.selectedFamily = 0;
    }
    state = a;
  }

  selectFM(int f, int m) {
    final a = state;
    a.selectedFamily = f;
    if (f > 7) {
      a.selectedFamily = 0;
    }
    a.selectedMember = m;
    state = a;
  }

  isR(bool r) {
    final a = state;
    a.right = r;
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

  select(WidgetRef ref, Element ans) {
    final g = ref.read(gameManager);
    if (ans.char == familyElements[g.selectedFamily][g.selectedMember + 1]) {
      if (g.selectedMember < familyElements[g.selectedFamily].length - 2) {
        ref
            .read(buttonsManager.notifier)
            .makeRandom(Element(g.selectedFamily, g.selectedMember + 2));
        print(Element(g.selectedFamily, g.selectedMember + 2).char);
        ref
            .read(gameManager.notifier)
            .selectMem(ref.read(gameManager).selectedMember + 1);
      } else {
        print("hello");
        ref.read(gameManager.notifier).selectFM(g.selectedFamily + 1, 0);
        ref.read(gameManager.notifier).isR(true);
        ref
            .read(buttonsManager.notifier)
            .makeRandom(Element(g.selectedFamily, 1));
      }
    } else {
      ref.read(gameManager.notifier).isR(false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gameManager);
    final b = ref.watch(buttonsManager);

    return Scaffold(
      body: Column(children: [
        Text(familyElements[g.selectedFamily][g.selectedMember]),
        Row(
          children: List.generate(
              5,
              (index) => ElevatedButton(
                  onPressed: () {
                    select(ref, b[index]);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text(
                    b[index].char,
                  ))),
        ),
        ElevatedButton(
            onPressed: () {
              ref.read(gameManager.notifier).gameStart();
              ref
                  .read(buttonsManager.notifier)
                  .makeRandom(Element(g.selectedFamily, g.selectedMember + 1));
              print(g.selectedMember);
            },
            child: Text("start"))
      ]),
    );
  }
}
