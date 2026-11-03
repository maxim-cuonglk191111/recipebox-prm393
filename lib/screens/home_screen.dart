import 'package:flutter/material.dart';

import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _features = [
    ('Save your recipes', 'Keep one private collection of the recipes you cook or want to try.', Icons.menu_book_outlined),
    ('Sort by cooking time', 'Shortest first - see what fits the time you have.', Icons.timer_outlined),
    ('Mark your favorites', 'Star the recipes you love and filter them in one tap.', Icons.star_outline),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('RecipeBox'),
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
          Text('RecipeBox', style: Theme.of(context).textTheme.headlineMedium),
          vGapSm,
          Text(
            'A small, private place for the recipes you cook or want to try - sorted into meal categories and difficulty levels, with a favorite flag.',
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
