import 'package:flutter/material.dart';

import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _features = [
    ('Track your books', 'Keep one private list of the books you own or want to read.', Icons.menu_book_outlined),
    ('Sort by status', 'To Read, Reading or Finished - see where every book stands.', Icons.checklist_outlined),
    ('Rate your favorites', 'Give a rating from 0 to 5 and star the ones you love.', Icons.star_outline),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('BookShelf'),
          actions: [
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('Register'),
            ),
            const SizedBox(width: Gap.xs),
          ],
        ),
        body: PageBody(children: [
          vGap,
          Text('BookShelf', style: Theme.of(context).textTheme.headlineMedium),
          vGapSm,
          Text(
            'A small, private place for the books you own or want to read - sorted by reading status and genre, with a favorite flag.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          vGap,
          for (final f in _features) ...[
            AppCard(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(f.$3, color: Palette.accent),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.$1, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: Gap.xs),
                    Text(f.$2, style: Theme.of(context).textTheme.bodyMedium),
                  ]),
                ),
              ]),
            ),
            vGapSm,
          ],
        ]),
      );
}
