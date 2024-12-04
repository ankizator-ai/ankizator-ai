import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnkizatorAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow.shade700),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("AnkizatorAI"),
      ),
      body: GridView.count(
          childAspectRatio: 4 / 6,
          crossAxisCount: 3,
          children: const <Widget>[
            Center(
              child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipOval(
                            child: Image(
                            image: NetworkImage(
                                "https://merula.pl/kos/wp-content/uploads/2014/10/merula_logo4@2x.png")
                            ),
                          ),
                        ),
                        Text("Some example test")
                      ],
                    ),
                  )
              ),
            )
          ]
      ),
    );
  }
}
