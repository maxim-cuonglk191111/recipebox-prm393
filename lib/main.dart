import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

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

// TODO(exam): when per-user data is needed, wrap MaterialApp in a ChangeNotifierProvider and call
// controller.bind(user?.uid) from an authStateChanges() listener (see reference/practice/lib/main.dart.txt).
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BookShelf', // TODO(exam): exact app name from the spec
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        scaffoldMessengerKey: messengerKey,
        home: const AuthGate(),
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
