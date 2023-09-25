import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rocky_birdwick/game.dart';
import 'package:rocky_birdwick/rocky.dart';
import 'firebase_options.dart';

void main() async {
  runApp(const MaterialApp(title: "Term Project", home: LoginScreen()));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? email;
  String? username;
  String? password1;
  String? password2;
  String? error;
  int highScore = 0;
  final _formKey = GlobalKey<FormState>();
  final userRef = FirebaseFirestore.instance.collection('Username');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign-up Screen")),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ROCKY BIRDWICK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      fontSize: 40,
                      fontFamily: 'Joystix')),
              TextFormField(
                  style: const TextStyle(color: Colors.blueGrey),
                  decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                          color: Colors.blueGrey, fontFamily: 'Joystix'),
                      floatingLabelStyle: TextStyle(color: Colors.blueGrey)),
                  maxLength: 64,
                  onChanged: (value) => email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  }),
              TextFormField(
                style: const TextStyle(color: Colors.blueGrey),
                decoration: const InputDecoration(
                    hintText: 'Username',
                    hintStyle: TextStyle(
                        color: Colors.blueGrey, fontFamily: 'Joystix'),
                    floatingLabelStyle: TextStyle(color: Colors.blueGrey)),
                maxLength: 64,
                onChanged: (value) => username = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text.';
                  } else if (!(16 > value.length && value.length > 2)) {
                    return 'Username must be between 3 and 16 characters.';
                  }
                  return null;
                },
              ),
              TextFormField(
                  style: const TextStyle(color: Colors.blueGrey),
                  decoration: const InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(
                          color: Colors.blueGrey, fontFamily: 'Joystix')),
                  obscureText: true,
                  onChanged: (value) => password1 = value,
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Your password must contain at least 8 characters.';
                    }
                    return null;
                  }),
              TextFormField(
                  style: const TextStyle(color: Colors.blueGrey),
                  decoration: const InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(
                          color: Colors.blueGrey, fontFamily: 'Joystix')),
                  obscureText: true,
                  onChanged: (value) => password2 = value,
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Your password must contain at least 8 characters.';
                    } else if (password1 != password2) {
                      return 'Your given passwords do not match.';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      password1 == password2) {
                    trySignUp();
                  }
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                child: const Text('SIGN UP!',
                    style: TextStyle(fontFamily: 'Joystix')),
              ),
              if (error != null)
                Text(
                  "Error: $error",
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                )
            ],
          ),
        ),
      ),
    );
  }

  void addUser(email, username) async {
    try {
      Users user = Users.addUsernameToUser(email, username, highScore);
      await userRef.add(user.toMap());
      FirebaseAuth.instance.currentUser!.updateDisplayName(username);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Success! Added $username to account associated with $email'),
        duration: const Duration(milliseconds: 5000),
      ));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong! ${e.message}'),
        duration: const Duration(milliseconds: 5000),
      ));
    }
  }

  void trySignUp() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!, password: password1!);
      addUser(email, username);
      error = null;
      setState(() {});

      if (!mounted) return;

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        error = 'This email address is already in use!';
      } else if (e.code == 'invalid-email') {
        error = 'Not a valid email address.';
      } else if (password1 != password2) {
        error = 'Given passwords do not match.';
      } else {
        error = 'An error occurred: ${e.message}';
      }
      setState(() {});
    }
  }
}

class _LoginScreenState extends State<LoginScreen> {
  String? email;
  String? password;
  String? error;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Screen")),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Rocky(birdY: 0, rockyWidth: 0.3, rockyHeight: 0.3),
              const Text('ROCKY BIRDWICK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      fontSize: 40,
                      fontFamily: 'Joystix')),
              const Text('\n', style: TextStyle(fontSize: 6)),
              TextFormField(
                  style: const TextStyle(color: Colors.blueGrey),
                  decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                          color: Colors.blueGrey, fontFamily: 'Joystix'),
                      floatingLabelStyle: TextStyle(color: Colors.blueGrey)),
                  maxLength: 64,
                  onChanged: (value) => email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  }),
              TextFormField(
                  style: const TextStyle(color: Colors.blueGrey),
                  decoration: const InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(
                          color: Colors.blueGrey, fontFamily: 'Joystix')),
                  obscureText: true,
                  onChanged: (value) => password = value,
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Your password must contain at least 8 characters.';
                    }
                    return null;
                  }),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        tryLogin();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey),
                    child: const Text('LET\'S GO!',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Joystix'))),
                const Text('          '),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey),
                    child: const Text('SIGN UP NOW!',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Joystix')))
              ]),
              if (error != null)
                Text(
                  "Error: $error",
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void tryLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);
      error = null;
      setState(() {});

      if (!mounted) return;

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MainMenu(),
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        error = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        error = 'Wrong password provided for that user.';
      } else {
        error = 'An error occurred: ${e.message}';
      }
      setState(() {});
    }
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Main Menu")),
        backgroundColor: Colors.black,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "What do you wanna do, ${FirebaseAuth.instance.currentUser!.displayName}? \n \n",
            style: const TextStyle(
                color: Colors.blueGrey, fontSize: 30, fontFamily: 'Joystix'),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const GameScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('Play the Game!',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'Joystix'))),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HighScoreScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('High Scores!',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'Joystix'))),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const AboutScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('About this Game!',
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
                  style: TextStyle(color: Colors.black, fontFamily: 'Joystix')))
        ])));
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("About the Game")),
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const Text("Created by Kole Bostic!\n",
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        fontFamily: 'Joystix'),
                    textAlign: TextAlign.center),
                const Rocky(birdY: 0, rockyWidth: 0.2, rockyHeight: 0.2),
                const Text(
                  """\nHave you ever played Flappy Bird? \n \nHave you ever wanted to play Flappy Bird with increasingly feverish speed as you progress? \n \nWell, look no further! \n \nWelcome to Rocky Birdwick! \n \nJust tap the screen anywhere to bounce Rocky upward as he flies, and you'll be well on your way... to inevitable death! \n \nHave fun! :D\n""",
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 14,
                      fontFamily: 'Joystix'),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MainMenu()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey),
                    child: const Text('Go Back',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Joystix'))),
              ])),
        ));
  }
}

class HighScoreScreen extends StatefulWidget {
  const HighScoreScreen({super.key});

  @override
  State<HighScoreScreen> createState() => _HighScoreScreenState();
}

class _HighScoreScreenState extends State<HighScoreScreen> {
  Query userList = FirebaseFirestore.instance
      .collection('Username')
      .orderBy('highScore', descending: true)
      .limit(10);
  late Stream<QuerySnapshot> streamUserList;

  @override
  void initState() {
    super.initState();
    streamUserList = userList.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    userList.snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text("List of Scores From Firestore")),
      backgroundColor: Colors.black,
      body: StreamBuilder(
          stream: streamUserList,
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return Card(
                      color: Colors.blueGrey,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                          title: Text(documentSnapshot['uname'],
                              style: const TextStyle(fontSize: 20)),
                          subtitle: Text(
                              documentSnapshot['highScore'].toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20))));
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class Users {
  Users({required this.email, required this.username, required this.highScore});
  final String email;
  final String username;
  int highScore;

  // Also adds a base high score of 0 for each new user
  static Users addUsernameToUser(email, username, highScore) {
    return Users(email: email, username: username, highScore: highScore);
  }

  Map<String, Object?> toMap() {
    return {'email': email, 'uname': username, 'highScore': highScore};
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Game(),
    );
  }
}
