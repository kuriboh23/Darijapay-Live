// lib/app/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    // --- CREATE USER DOCUMENT IN FIRESTORE ---
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'displayName': email.split('@')[0], // A simple default display name
      'createdAt': Timestamp.now(),
    });
    
    return userCredential;
  } on FirebaseAuthException catch (e) {
    print("Sign Up Error: ${e.message}");
    return null;
  }
}

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print("Sign In Error: ${e.message}");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}