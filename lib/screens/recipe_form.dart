import 'package:flutter/material.dart';

import '../logic/recipe.dart';
import '../logic/recipe_validators.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

/// The one recipe form: used by "Add a recipe" on List and by Edit on Detail,
/// so both share the same fields, rules and messages.
class RecipeForm extends StatefulWidget {
  const RecipeForm({
    super.key,
    this.initial,
    required this.submitLabel,
    required this.onSubmit,
    this.onCancel,
    this.successMessage,
    this.clearOnSuccess = false,
  });

  final Recipe? initial;
  final String submitLabel;

  /// Returns null on success, otherwise the error message to show on the form.
  final Future<String?> Function(RecipeInput input) onSubmit;
  final VoidCallback? onCancel;
  final String? successMessage;
  final bool clearOnSuccess;

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _cookTime = TextEditingController(text: widget.initial?.cookTime.toString() ?? '');
  late final _servings = TextEditingController(text: widget.initial?.servings?.toString() ?? '');
  late final _notes = TextEditingController(text: widget.initial?.notes ?? '');
  late var _category = widget.initial?.category ?? '';
  late var _difficulty = widget.initial?.difficulty ?? '';
  var _mode = AutovalidateMode.disabled; // validation starts at the first submit
  var _resets = 0;
  var _busy = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    for (final c in [_name, _cookTime, _servings, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _mode = AutovalidateMode.onUserInteraction;
      _error = null;
      _success = null;
    });
    if (!_form.currentState!.validate()) return;
    final servings = _servings.text.trim();
    final input = RecipeInput(
      name: _name.text.trim(),
      category: _category,
      difficulty: _difficulty,
      cookTime: int.parse(_cookTime.text.trim()),
      servings: servings.isEmpty ? null : int.parse(servings),
      notes: _notes.text.trim(),
    );
    setState(() => _busy = true);
    final error = await widget.onSubmit(input);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
      if (error == null && widget.clearOnSuccess) {
        for (final c in [_name, _cookTime, _servings, _notes]) {
          c.clear();
        }
        _category = '';
        _difficulty = '';
        _mode = AutovalidateMode.disabled;
        _resets++; // rebuilds the dropdowns with the empty choice
        _success = widget.successMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Form(
        key: _form,
        autovalidateMode: _mode,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppTextField(label: 'Name', controller: _name, validator: validateName),
          vGap,
          AppDropdown(
            key: ValueKey('category$_resets'),
            label: 'Category',
            placeholder: 'Choose category',
            options: categories,
            value: _category,
            validator: validateCategory,
            onChanged: (v) => _category = v,
          ),
          vGap,
          AppDropdown(
            key: ValueKey('difficulty$_resets'),
            label: 'Difficulty',
            placeholder: 'Choose difficulty',
            options: difficulties,
            value: _difficulty,
            validator: validateDifficulty,
            onChanged: (v) => _difficulty = v,
          ),
          vGap,
          AppTextField(
            label: 'Cook time (minutes)',
            controller: _cookTime,
            keyboardType: TextInputType.number,
            validator: validateCookTime,
          ),
          vGap,
          AppTextField(
            label: 'Servings (1-20, optional)',
            controller: _servings,
            keyboardType: TextInputType.number,
            validator: validateServings,
          ),
          vGap,
          AppTextField(label: 'Notes (optional)', controller: _notes, maxLines: 3, validator: validateNotes),
          vGap,
          if (widget.onCancel == null)
            AppButton(widget.submitLabel, onPressed: _submit, busy: _busy)
          else
            Row(children: [
              Expanded(child: AppButton(widget.submitLabel, onPressed: _submit, busy: _busy)),
              const SizedBox(width: Gap.sm),
              Expanded(child: AppButton('Cancel', outlined: true, onPressed: _busy ? null : widget.onCancel)),
            ]),
          if (_error != null) ...[vGap, MessageBanner(_error!)],
          if (_success != null) ...[vGap, MessageBanner(_success!, isError: false)],
        ]),
      );
}
