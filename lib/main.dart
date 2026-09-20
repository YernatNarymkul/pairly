import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'progress.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final store = ProgressStore();
  await store.load();
  runApp(PairlyApp(store: store));
}

class PairlyApp extends StatelessWidget {
  const PairlyApp({super.key, required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      store: store,
      child: MaterialApp(
        title: 'Pairly',
        debugShowCheckedModeBanner: false,
        theme: buildPairlyTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
