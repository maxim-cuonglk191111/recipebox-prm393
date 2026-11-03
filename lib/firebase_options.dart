import 'package:firebase_core/firebase_core.dart';

/// Client-side Firebase config for the web build (no secrets). Android reads
/// android/app/google-services.json instead. tools/bootstrap.sh overwrites this file.
const webFirebaseOptions = FirebaseOptions(
  apiKey: 'TODO',
  appId: 'TODO',
  messagingSenderId: 'TODO',
  projectId: 'TODO',
  authDomain: 'TODO',
  storageBucket: 'TODO',
);
