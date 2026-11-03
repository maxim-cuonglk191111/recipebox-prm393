import 'package:bookshelf/logic/recipe.dart';
import 'package:bookshelf/screens/home_screen.dart';
import 'package:bookshelf/screens/recipe_form.dart';
import 'package:bookshelf/ui/theme.dart';
import 'package:bookshelf/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpForm(
  WidgetTester t, {
  required Future<String?> Function(RecipeInput) onSubmit,
  Recipe? initial,
  VoidCallback? onCancel,
  double textScale = 1.0,
  Size size = const Size(390, 844),
}) async {
  t.view.physicalSize = size * 2;
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
    theme: buildTheme(),
    builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(textScale)), child: child!),
    home: Scaffold(
      body: PageBody(children: [
        RecipeForm(
          initial: initial,
          submitLabel: initial == null ? 'Add recipe' : 'Save',
          successMessage: 'Recipe added',
          clearOnSuccess: initial == null,
          onSubmit: onSubmit,
          onCancel: onCancel,
        ),
      ]),
    ),
  ));
}

Future<void> choose(WidgetTester t, String from, String item) async {
  await t.tap(find.text(from));
  await t.pumpAndSettle();
  await t.tap(find.text(item).last);
  await t.pumpAndSettle();
}

Future<void> type(WidgetTester t, String label, String text) async {
  await t.enterText(find.widgetWithText(TextFormField, label), text);
  await t.pump();
}

Future<void> tapButton(WidgetTester t, String label) async {
  await t.ensureVisible(find.text(label));
  await t.tap(find.text(label));
  await t.pumpAndSettle();
}

const nameF = 'Name';
const timeF = 'Cook time (minutes)';
const servF = 'Servings (1-20, optional)';
const notesF = 'Notes (optional)';
const errors = [
  'Name is required',
  'Name must be at most 80 characters',
  'Please choose a category',
  'Please choose a difficulty',
  'Cook time is required',
  'Cook time must be a whole number from 1 to 600',
  'Servings must be a whole number from 1 to 20',
  'Notes must be at most 300 characters',
];

void main() {
  testWidgets('first load shows no error; dropdowns start on the empty choice', (t) async {
    await pumpForm(t, onSubmit: (_) async => null);
    for (final e in errors) {
      expect(find.text(e), findsNothing);
    }
    expect(find.text('Choose category'), findsOneWidget);
    expect(find.text('Choose difficulty'), findsOneWidget);
  });

  testWidgets('empty submit shows name, category, difficulty, cook time messages only; they clear as fields become valid', (t) async {
    var calls = 0;
    await pumpForm(t, onSubmit: (_) async {
      calls++;
      return null;
    });
    await tapButton(t, 'Add recipe');
    expect(calls, 0);
    for (final e in ['Name is required', 'Please choose a category', 'Please choose a difficulty', 'Cook time is required']) {
      expect(find.text(e), findsOneWidget, reason: e);
    }
    expect(find.text('Servings must be a whole number from 1 to 20'), findsNothing);
    expect(find.text('Notes must be at most 300 characters'), findsNothing);

    await type(t, nameF, 'Pho Bo');
    expect(find.text('Name is required'), findsNothing);
    expect(find.text('Cook time is required'), findsOneWidget);
    await type(t, timeF, '45');
    expect(find.text('Cook time is required'), findsNothing);
    await choose(t, 'Choose category', 'Dinner');
    expect(find.text('Please choose a category'), findsNothing);
    expect(find.text('Please choose a difficulty'), findsOneWidget);
  });

  testWidgets('spaces only is empty; length / number rules', (t) async {
    await pumpForm(t, onSubmit: (_) async => null);
    await type(t, nameF, '      ');
    await type(t, timeF, '   ');
    await tapButton(t, 'Add recipe');
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Cook time is required'), findsOneWidget);

    await type(t, nameF, 'a' * 81);
    await type(t, timeF, '601');
    await type(t, servF, '21');
    await type(t, notesF, 'n' * 301);
    await tapButton(t, 'Add recipe');
    expect(find.text('Name must be at most 80 characters'), findsOneWidget);
    expect(find.text('Cook time must be a whole number from 1 to 600'), findsOneWidget);
    expect(find.text('Servings must be a whole number from 1 to 20'), findsOneWidget);
    expect(find.text('Notes must be at most 300 characters'), findsOneWidget);

    await type(t, nameF, 'a' * 80);
    await type(t, timeF, '600');
    await type(t, servF, '20');
    await type(t, notesF, 'n' * 300);
    for (final e in errors.where((e) => !e.contains('choose'))) {
      expect(find.text(e), findsNothing, reason: e);
    }
  });

  testWidgets('valid submit sends trimmed/parsed values, clears the form, shows Recipe added and no errors', (t) async {
    RecipeInput? got;
    await pumpForm(t, onSubmit: (i) async {
      got = i;
      return null;
    });
    await type(t, nameF, '  Pho Bo ');
    await choose(t, 'Choose category', 'Dinner');
    await choose(t, 'Choose difficulty', 'Medium');
    await type(t, timeF, ' 45 ');
    await type(t, servF, '4');
    await type(t, notesF, ' slow broth ');
    await tapButton(t, 'Add recipe');

    expect(got, isNotNull);
    expect([got!.name, got!.category, got!.difficulty, got!.cookTime, got!.servings, got!.notes],
        ['Pho Bo', 'Dinner', 'Medium', 45, 4, 'slow broth']);
    expect(find.text('Recipe added'), findsOneWidget);
    expect(find.text('Choose category'), findsOneWidget);
    expect(find.text('Choose difficulty'), findsOneWidget);
    for (final e in errors) {
      expect(find.text(e), findsNothing);
    }
    expect(find.text('Pho Bo'), findsNothing); // fields were cleared
  });

  testWidgets('servings left empty is sent as null', (t) async {
    RecipeInput? got;
    await pumpForm(t, onSubmit: (i) async {
      got = i;
      return null;
    });
    await type(t, nameF, 'Toast');
    await choose(t, 'Choose category', 'Breakfast');
    await choose(t, 'Choose difficulty', 'Easy');
    await type(t, timeF, '5');
    await tapButton(t, 'Add recipe');
    expect(got!.servings, isNull);
    expect(got!.notes, '');
  });

  testWidgets('a Firestore error is shown on the form and nothing is cleared', (t) async {
    await pumpForm(t, onSubmit: (_) async => 'Missing or insufficient permissions.');
    await type(t, nameF, 'Pho Bo');
    await choose(t, 'Choose category', 'Dinner');
    await choose(t, 'Choose difficulty', 'Hard');
    await type(t, timeF, '90');
    await tapButton(t, 'Add recipe');
    expect(find.text('Missing or insufficient permissions.'), findsOneWidget);
    expect(find.text('Recipe added'), findsNothing);
    expect(find.text('Pho Bo'), findsOneWidget);
  });

  testWidgets('edit mode starts from the recipe, validates the same way, and Cancel works', (t) async {
    var cancelled = false;
    const recipe = Recipe(
        id: 'x', userId: 'u', name: 'Pho Bo', category: 'Dinner', difficulty: 'Medium', cookTime: 45, servings: 4, notes: 'Broth');
    await pumpForm(t, initial: recipe, onSubmit: (_) async => null, onCancel: () => cancelled = true);
    expect(find.text('Pho Bo'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    await type(t, nameF, '');
    await type(t, timeF, '0');
    await tapButton(t, 'Save');
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Cook time must be a whole number from 1 to 600'), findsOneWidget);
    await tapButton(t, 'Cancel');
    expect(cancelled, isTrue);
  });

  for (final size in const [Size(360, 640), Size(390, 844)]) {
    for (final scale in const [1.0, 1.3]) {
      testWidgets('no overflow: form with errors at $size and ${scale}x text', (t) async {
        await pumpForm(t, onSubmit: (_) async => null, textScale: scale, size: size);
        await tapButton(t, 'Add recipe');
        expect(t.takeException(), isNull);
      });

      testWidgets('no overflow: Home at $size and ${scale}x text', (t) async {
        t.view.physicalSize = size * 2;
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        await t.pumpWidget(MaterialApp(
          theme: buildTheme(),
          builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
          home: const HomeScreen(),
        ));
        expect(t.takeException(), isNull);
        expect(find.text('RecipeBox'), findsWidgets);
        expect(find.text('Login'), findsOneWidget);
        expect(find.text('Register'), findsOneWidget);
      });
    }
  }
}
