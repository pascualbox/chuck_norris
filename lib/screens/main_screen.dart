import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:norris/screens/see_joke.dart';
import 'package:norris/utilities/urls.dart';

import '../classes/joke.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class Debouncer {
  int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(
      Duration(milliseconds: Duration.millisecondsPerSecond),
      action,
    );
  }
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final _debouncer = Debouncer();
  final textController = TextEditingController();
  List<Joke> jokeList = [];
  List<Joke> jokeLists = [];
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    WidgetsBinding.instance.removeObserver(this);
    textController.dispose();
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final isClosing = state = AppLifecycleState.detached;
  }

  Future<List<Joke>> fetchJoke() async {
    try {
      final response =
          await http.get(Uri.parse(NorrisUrls.api + textController.text));

      if (response.statusCode == 200) {
        for (var joke in jsonDecode(response.body)['result']) {
          jokeList.add(Joke.fromJson(joke));
        }
        _debouncer.run(() {
          setState(() {
            jokeLists = jokeList.toList();
          });
        });
        return jokeList;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load Joke');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchJoke().then((jokesFromServer) {
      setState(() {
        jokeList = jokesFromServer;
        jokeLists = jokeList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime timeBackPressed = DateTime.now();
    return WillPopScope(
        onWillPop: () async {
          final difference = DateTime.now().difference(timeBackPressed);
          final isExitWarning = difference >= Duration(seconds: 2);
          timeBackPressed = DateTime.now();
          if (isExitWarning) {
            final message = "Press again to exit!!!!";
            Fluttertoast.showToast(msg: message);
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
            body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              children: [
                TextField(
                  controller: textController,
                ),
                MaterialButton(
                  onPressed: () {
                    fetchJoke();
                  },
                  child: Text("See Joke"),
                  color: Colors.indigo,
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.all(5),
                    itemCount: jokeLists.length,
                    itemBuilder: (BuildContext context, int index) {
                      return MaterialButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      SeeJoke(joke: jokeLists[index])));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    jokeLists[index].id,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  subtitle: Text(
                                    jokeLists[index].value ?? "null",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        )));
  }
}
