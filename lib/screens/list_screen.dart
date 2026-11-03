import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ui/theme.dart';
import '../ui/widgets.dart';

/// Placeholder for the protected main screen. Header = user's e-mail + Logout.
/// TODO(exam): replace the body (see reference/practice/lib/screens/list_screen.dart.txt).
class ListScreen extends StatelessWidget {
  const ListScreen({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(user.email ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
          actions: [
            TextButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text('Logout')),
            const SizedBox(width: Gap.xs),
          ],
        ),
        body: const PageBody(children: [Text('TODO')]),
      );
}
