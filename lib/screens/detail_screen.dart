import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/recipes_controller.dart';
import '../logic/recipe.dart';
import '../ui/messenger.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'recipe_form.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.recipeId});
  final String recipeId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late String _id = widget.recipeId;
  Recipe? _last; // keeps the screen steady while a rename swaps the document id
  var _editing = false;
  var _leaving = false; // deleting: do not react to the recipe disappearing
  var _awaitingId = false; // saved under a new id that the live stream has not delivered yet

  Future<String?> _save(RecipesController c, RecipeInput input) async {
    final old = _id;
    final newId = recipeKey(c.uid!, input.name);
    setState(() => _id = newId);
    final err = await c.update(old, input);
    if (!mounted) return err;
    if (err != null) {
      setState(() => _id = old);
    } else {
      setState(() {
        _editing = false;
        _awaitingId = _id != old;
      });
    }
    return err;
  }

  Future<void> _confirmDelete(RecipesController c, Recipe recipe) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this recipe?'),
        content: Text('"${recipe.name}" will be removed from your list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Palette.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _leaving = true);
    final err = await c.delete(recipe);
    if (!mounted) return;
    if (err != null) {
      setState(() => _leaving = false);
      showToast(err);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RecipesController>();
    final found = c.byId(_id);
    if (found != null) _awaitingId = false;
    final recipe = found ?? (_editing || _leaving || _awaitingId ? _last : null);
    if (recipe == null) {
      // The recipe is gone (e.g. deleted elsewhere): go back to the list.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_leaving) Navigator.maybePop(context);
      });
      return const LoadingView();
    }
    _last = recipe;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe details')),
      body: PageBody(children: [
        if (_editing)
          RecipeForm(
            initial: recipe,
            submitLabel: 'Save',
            onSubmit: (i) => _save(c, i),
            onCancel: () => setState(() => _editing = false),
          )
        else ...[
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(recipe.name, style: t.headlineMedium?.copyWith(fontSize: 22))),
                IconButton(
                  tooltip: recipe.favorite ? 'Remove from favorites' : 'Add to favorites',
                  icon: Icon(recipe.favorite ? Icons.star : Icons.star_border, color: Palette.star),
                  onPressed: () async {
                    final err = await c.setFavorite(recipe);
                    if (err != null) showToast(err);
                  },
                ),
              ]),
              const Divider(),
              _Field('Category', recipe.category),
              _Field('Difficulty', recipe.difficulty),
              _Field('Cook time', '${recipe.cookTime} min'),
              _Field('Servings', recipe.servings?.toString() ?? '-'),
              _Field('Notes', recipe.notes.isEmpty ? '-' : recipe.notes),
            ]),
          ),
          vGap,
          Row(children: [
            Expanded(child: AppButton('Edit', onPressed: () => setState(() => _editing = true))),
            const SizedBox(width: Gap.sm),
            Expanded(child: AppButton('Delete', outlined: true, onPressed: () => _confirmDelete(c, recipe))),
          ]),
        ],
      ]),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.sm),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: t.bodySmall),
        Text(value, style: t.bodyMedium),
      ]),
    );
  }
}
