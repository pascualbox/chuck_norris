import 'package:flutter/material.dart';
import 'package:norris/classes/joke.dart';

class SeeJoke extends StatefulWidget {
  const SeeJoke({Key? key, required this.joke}) : super(key: key);
  final Joke joke;
  @override
  State<SeeJoke> createState() => _SeeJokeState();
}

class _SeeJokeState extends State<SeeJoke> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(widget.joke.value), Image.network(widget.joke.icon)],
      ),
    );
  }
}
