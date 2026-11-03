import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/recipes_controller.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/list_screen.dart';
import 'ui/messenger.dart';
import 'ui/theme.dart';
import 'ui/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android: client config comes from google-services.json; web: firebase_options.dart.
  await Firebase.initializeApp(options: kIsWeb ? webFirebaseOptions : null);
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _recipes = RecipesController();
  StreamSubscription<User?>? _sub;

  @override
  void initState() {
    super.initState();
    // Keep the recipes of the *current* user only; switching accounts drops the old data.
    _sub = FirebaseAuth.instance.authStateChanges().listen((u) => _recipes.bind(u?.uid));
  }

  @override
  void dispose() {
    _sub?.cancel();
    _recipes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: _recipes,
        child: MaterialApp(
          title: 'RecipeBox',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          scaffoldMessengerKey: messengerKey,
          home: const AuthGate(),
        ),
      );
}

/// Root screen. While Firebase restores the session only a loading view is shown, so neither
/// Home nor List flashes. List is the root route => Back never returns to Login/Register.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          final user = snap.data;
          return user == null ? const HomeScreen() : ListScreen(user: user);
        },
      );
}
