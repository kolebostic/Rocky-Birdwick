// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rocky_birdwick/rocky.dart';
import 'package:rocky_birdwick/barricades.dart';
import 'package:rocky_birdwick/main.dart';

CollectionReference userHighScoreList =
    FirebaseFirestore.instance.collection('Username');

int highScore = 0;

readHighScore() async {
  final user = FirebaseAuth.instance.currentUser!.email;
  FirebaseFirestore.instance
      .collection('Username')
      .get()
      .then((QuerySnapshot qs) {
    qs.docs.forEach((doc) {
      if (doc['email'] == user) {
        highScore = doc['highScore'];
      } else {
        return;
      }
    });
  });
  return highScore;
}

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  static double birdY = 0;
  double initialPosition = birdY;
  double jumpHeight = 0;
  double jumpTime = 0;
  double gravity = -6;
  double velocity = 2.5;
  double rockyWidth = 0.1;
  double rockyHeight = 0.1;
  int score = 0;

  bool hasStarted = false;
  bool hasDied = false;

  static List<double> barricadeX = [2, 2 + 1.5];
  static double barricadeWidth = 0.5;
  List<List<double>> barricadeHeight = [
    [0.9, 0.4],
    [0.4, 0.9],
  ];

  @override
  void initState() {
    super.initState();
    readHighScore();
  }

  Future updateHighScore(score) async {
    final user = FirebaseAuth.instance.currentUser!.email;
    FirebaseFirestore.instance
        .collection('Username')
        .get()
        .then((QuerySnapshot qs) {
      qs.docs.forEach((doc) {
        if (doc['email'] == user && doc['highScore'] < score) {
          userHighScoreList.doc(doc.id).update({'highScore': score});
        }
      });
    });
  }

  void start() {
    hasStarted = true;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      jumpHeight = gravity * jumpTime * jumpTime + velocity * jumpTime;
      setState(() {
        birdY = initialPosition - jumpHeight;
      });

      if (barricadeX[0] < -0.5 || barricadeX[1] < -0.5) {
        score += 1;
      }

      if (onDeath()) {
        updateHighScore(score);
        timer.cancel();
        resetGame();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const GameOverScreen()));
      }
      moveMap();
      jumpTime += 0.03;
    });
  }

  void flap() {
    setState(() {
      jumpTime = 0;
      initialPosition = birdY;
    });
  }

  bool onDeath() {
    hasDied = true;
    if (birdY < -1 || birdY > 1) {
      return true;
    }
    for (int i = 0; i < barricadeX.length; i++) {
      if (barricadeX[i] <= rockyWidth &&
          barricadeX[i] + barricadeWidth >= -rockyWidth &&
          (birdY <= -1 + barricadeHeight[i][0] ||
              birdY + rockyHeight >= 1 - barricadeHeight[i][1])) {
        return true;
      }
    }
    return false;
  }

  void resetGame() {
    hasDied = false;
    setState(() {
      birdY = 0;
      score = 0;
      hasStarted = false;
      jumpTime = 0;
      initialPosition = birdY;
      barricadeX = [1.5, 3];
    });
  }

  void moveMap() {
    for (int i = 0; i < barricadeX.length; i++) {
      // keep barriers moving
      setState(() {
        barricadeX[i] -= 0.03;
        if (score > 50) {
          barricadeX[i] -= 0.005;
        }
        if (score > 100) {
          barricadeX[i] -= 0.005;
        }
        if (score > 150) {
          barricadeX[i] -= 0.01;
        }
        if (score > 200) {
          barricadeX[i] -= 0.01;
        }
        if (score > 250) {
          barricadeX[i] -= 0.01;
        }
        if (score > 300) {
          barricadeX[i] -= 0.01;
        }
        if (score > 350) {
          barricadeX[i] -= 0.01;
        }
        if (score > 400) {
          barricadeX[i] -= 0.01;
        }
        if (score > 450) {
          barricadeX[i] -= 0.01;
        }
        if (score > 500) {
          barricadeX[i] -= 0.01;
        }
        if (score > 550) {
          barricadeX[i] -= 0.01;
        }
        if (score > 600) {
          barricadeX[i] -= 0.01;
        }
        if (score > 650) {
          barricadeX[i] -= 0.01;
        }
        if (score > 700) {
          barricadeX[i] -= 0.01;
        }
        if (score > 750) {
          barricadeX[i] -= 0.01;
        }
        if (score > 800) {
          barricadeX[i] -= 0.01;
        }
      });
      // resets barriers
      if (barricadeX[i] < -1.5) {
        barricadeX[i] += 3;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasStarted ? flap : start,
      child: Scaffold(
          body: Column(
        children: [
          Expanded(
              flex: 3,
              child: Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('lib/images/coolcity.jpg'),
                          fit: BoxFit.cover)),
                  child: Center(
                    child: Stack(children: [
                      MyCoverScreen(hasStarted: hasStarted),
                      Rocky(
                          birdY: birdY,
                          rockyWidth: rockyWidth,
                          rockyHeight: rockyHeight),
                      Barricades(
                        barricadeX: barricadeX[0],
                        barricadeWidth: barricadeWidth,
                        barricadeHeight: barricadeHeight[0][0],
                        isBottomBarrier: false,
                      ),
                      Barricades(
                        barricadeX: barricadeX[0],
                        barricadeWidth: barricadeWidth,
                        barricadeHeight: barricadeHeight[0][1],
                        isBottomBarrier: true,
                      ),
                      Barricades(
                        barricadeX: barricadeX[1],
                        barricadeWidth: barricadeWidth,
                        barricadeHeight: barricadeHeight[1][0],
                        isBottomBarrier: false,
                      ),
                      Barricades(
                        barricadeX: barricadeX[1],
                        barricadeWidth: barricadeWidth,
                        barricadeHeight: barricadeHeight[1][1],
                        isBottomBarrier: true,
                      ),
                    ]),
                  ))),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('lib/images/woodplanks.png'),
                      fit: BoxFit.cover)),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          score.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontFamily: 'Joystix'),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'Score',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Joystix'),
                        ),
                      ],
                    ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text(
                    //       '$highScore',
                    //       style: const TextStyle(
                    //           color: Colors.white, fontSize: 35),
                    //     ),
                    //     const SizedBox(
                    //       height: 15,
                    //     ),
                    //     const Text(
                    //       'High Score',
                    //       style: TextStyle(color: Colors.white, fontSize: 20),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class MyCoverScreen extends StatelessWidget {
  final bool hasStarted;

  const MyCoverScreen({super.key, required this.hasStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0, -0.5),
      child: Text(
        hasStarted ? '' : 'TAP TO FART \'ER UP!',
        style: const TextStyle(color: Colors.black, fontSize: 25),
      ),
    );
  }
}

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HighScoreScreen(),
    );
  }
}

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  @override
  void initState() {
    super.initState();
    readHighScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Main Menu")),
        backgroundColor: Colors.black,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Rocky(birdY: 0, rockyWidth: 0.2, rockyHeight: 0.2),
          // Text('\nHIGH SCORE: $highScore\n',
          //     style: const TextStyle(
          //         color: Colors.blueGrey, fontFamily: 'Joystix')),
          Text(
            "\nGAME OVER, \n${FirebaseAuth.instance.currentUser!.displayName}!\n What's next?\n",
            style: const TextStyle(
                color: Colors.blueGrey, fontSize: 24, fontFamily: 'Joystix'),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const GameScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('PLAY AGAIN!',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'Joystix'))),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ScoreScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('High Scores!',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'Joystix'))),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainMenu()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('Back to Main Menu!',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'Joystix'))),
          ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('Logout',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'Joystix'))),
        ])));
  }
}
