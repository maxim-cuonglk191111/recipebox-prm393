import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../logic/validators.dart';
import '../ui/messenger.dart';
import '../ui/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _mode = AutovalidateMode.disabled; // nothing is shown before the first submit
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _mode = AutovalidateMode.onUserInteraction; // errors clear as soon as a field is valid
      _error = null;
    });
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email.text.trim(), password: _password.text);
      showToast('Registration successful');
      if (mounted) Navigator.popUntil(context, (r) => r.isFirst); // AuthGate now shows List
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? e.code);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: PageBody(children: [
          Form(
            key: _form,
            autovalidateMode: _mode,
            child: Column(children: [
              AppTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, validator: validateEmail),
              vGap,
              AppTextField(
                label: 'Password',
                controller: _password,
                obscure: true,
                validator: (v) => validatePassword(v, requireMinLength: true),
              ),
              vGap,
              AppTextField(
                label: 'Confirm password',
                controller: _confirm,
                obscure: true,
                validator: (v) => validateConfirmPassword(v, _password.text),
              ),
              vGap,
              SizedBox(width: double.infinity, child: AppButton('Register', onPressed: _submit, busy: _busy)),
              if (_error != null) ...[vGap, MessageBanner(_error!)],
            ]),
          ),
        ]),
      );
}
