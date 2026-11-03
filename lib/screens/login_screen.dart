import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../logic/validators.dart';
import '../ui/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _mode = AutovalidateMode.disabled;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _mode = AutovalidateMode.onUserInteraction;
      _error = null;
    });
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _password.text);
      if (mounted) Navigator.popUntil(context, (r) => r.isFirst); // AuthGate now shows List
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? e.code);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: PageBody(children: [
          Form(
            key: _form,
            autovalidateMode: _mode,
            child: Column(children: [
              AppTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, validator: validateEmail),
              vGap,
              AppTextField(label: 'Password', controller: _password, obscure: true, validator: validatePassword),
              vGap,
              SizedBox(width: double.infinity, child: AppButton('Login', onPressed: _submit, busy: _busy)),
              if (_error != null) ...[vGap, MessageBanner(_error!)],
            ]),
          ),
        ]),
      );
}
