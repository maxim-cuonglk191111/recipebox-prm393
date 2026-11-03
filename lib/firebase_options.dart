import 'package:firebase_core/firebase_core.dart';

/// Client-side Firebase config for the web build (no secrets). Android reads
/// android/app/google-services.json instead.
const webFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDsxacDgkjTsbPLeQHClwHvcMo-ux9CJTQ',
  appId: '1:133333658639:web:da4e9bf212105ccb03c77a',
  messagingSenderId: '133333658639',
  projectId: 'recipebox-he191111-1520',
  authDomain: 'recipebox-he191111-1520.firebaseapp.com',
  storageBucket: 'recipebox-he191111-1520.firebasestorage.app',
);
