import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/recipes_controller.dart';
import '../logic/recipe.dart';
import '../ui/messenger.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'detail_screen.dart';
import 'recipe_form.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RecipesController>();
    final shown = c.shown;
    return Scaffold(
      appBar: AppBar(
        title: Text(user.email ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text('Logout')),
          const SizedBox(width: Gap.xs),
        ],
      ),
      body: PageBody(children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              maintainState: true,
              tilePadding: const EdgeInsets.symmetric(horizontal: Gap.md),
              childrenPadding: const EdgeInsets.fromLTRB(Gap.md, Gap.sm, Gap.md, Gap.md),
              title: Text('Add a recipe', style: Theme.of(context).textTheme.titleMedium),
              children: [
                RecipeForm(
                  submitLabel: 'Add recipe',
                  successMessage: 'Recipe added',
                  clearOnSuccess: true,
                  onSubmit: c.add,
                ),
              ],
            ),
          ),
        ),
        vGap,
        _Filters(controller: c),
        vGap,
        _SummaryCard(controller: c),
        vGap,
        if (c.loadError != null) MessageBanner(c.loadError!),
        if (c.loading)
          const Padding(padding: EdgeInsets.all(Gap.lg), child: Center(child: CircularProgressIndicator()))
        else if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Gap.lg),
            child: Center(child: Text('No recipes found', style: Theme.of(context).textTheme.titleMedium)),
          )
        else
          for (final r in shown) ...[_RecipeTile(recipe: r, controller: c), vGapSm],
      ]),
    );
  }
}

class _Filters extends StatefulWidget {
  const _Filters({required this.controller});
  final RecipesController controller;

  @override
  State<_Filters> createState() => _FiltersState();
}

class _FiltersState extends State<_Filters> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final f = c.filters;
    if (f.query.isEmpty && _search.text.isNotEmpty) {
      // reset by Clear / account switch (outside the build pass)
      WidgetsBinding.instance.addPostFrameCallback((_) => _search.clear());
    }
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: AppDropdown(
              key: ValueKey('fc${f.category}'),
              label: 'Category',
              placeholder: 'All',
              options: categories,
              value: f.category ?? '',
              onChanged: (v) => c.setFilters(v.isEmpty ? f.copyWith(clearCategory: true) : f.copyWith(category: v)),
            ),
          ),
          const SizedBox(width: Gap.sm),
          Expanded(
            child: AppDropdown(
              key: ValueKey('fd${f.difficulty}'),
              label: 'Difficulty',
              placeholder: 'All',
              options: difficulties,
              value: f.difficulty ?? '',
              onChanged: (v) => c.setFilters(v.isEmpty ? f.copyWith(clearDifficulty: true) : f.copyWith(difficulty: v)),
            ),
          ),
        ]),
        vGapSm,
        AppTextField(
          label: 'Search name or notes',
          controller: _search,
          onChanged: (v) => c.setFilters(f.copyWith(query: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Favorites only'),
          value: f.favoritesOnly,
          onChanged: (v) => c.setFilters(f.copyWith(favoritesOnly: v)),
        ),
        AppButton('Clear', outlined: true, onPressed: c.clearFilters),
      ]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.controller});
  final RecipesController controller;

  @override
  Widget build(BuildContext context) {
    final s = controller.summary;
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Recipes: ${s.total}', style: t.titleMedium),
        const SizedBox(height: Gap.xs),
        Text('Favorites: ${s.favorites}', style: t.titleMedium),
        const SizedBox(height: Gap.xs),
        Text('Total time: ${s.totalTime} min', style: t.titleMedium),
        if (s.byCategory.isNotEmpty) ...[
          vGapSm,
          const Divider(),
          vGapSm,
          for (final e in s.byCategory)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                Expanded(child: Text(e.key, style: t.bodyMedium)),
                Text('${e.value}', style: t.bodyMedium),
              ]),
            ),
        ],
      ]),
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({required this.recipe, required this.controller});
  final Recipe recipe;
  final RecipesController controller;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(Gap.md, Gap.sm, Gap.xs, Gap.sm),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(recipeId: recipe.id))),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(recipe.name, style: t.titleMedium),
            const SizedBox(height: Gap.xs),
            Text('${recipe.category} · ${recipe.difficulty} · ${recipe.cookTime} min', style: t.bodySmall),
          ]),
        ),
        IconButton(
          tooltip: recipe.favorite ? 'Remove from favorites' : 'Add to favorites',
          icon: Icon(recipe.favorite ? Icons.star : Icons.star_border, color: Palette.star),
          onPressed: () async {
            final err = await controller.setFavorite(recipe);
            if (err != null) showToast(err);
          },
        ),
        const Icon(Icons.chevron_right, color: Palette.inkSoft),
        const SizedBox(width: Gap.xs),
      ]),
    );
  }
}
