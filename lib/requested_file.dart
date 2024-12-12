import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RequestedFile extends StatelessWidget {
  const RequestedFile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'AnkizatorAI',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow.shade700),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Download an Anki deck'),
            leading: BackButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Text("ASD"),
                    ),
                  );
                }
            ),
          ),
          body: const Center(
            // child: FutureBuilder<List<WordsPair>>(
            //   future: F,
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return Text('${snapshot.data}');
            //     } else if (snapshot.hasError) {
            //       return Text('${snapshot.error}');
            //     }
            //     // By default, show a loading spinner.
            //     return const CircularProgressIndicator();
            //   },
            // )
          ),
        )
    );
  }
}
