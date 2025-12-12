import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/color_generator.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }

      if (credential.user != null) {
        final newUser = credential.user!;

        final avatarColor = generatePleasantColor();

        await _firestore.collection('users').doc(newUser.uid).set({
          'uid': newUser.uid,
          'displayName': displayName ?? '',
          'email': email,
          'avatarColor': avatarColor.toARGB32(),
        });
      }

      await credential.user?.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Weak password.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account with this email already exists.');
      } else {
        throw Exception('An error occurred. Please try again later.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw Exception('Incorrect email or password.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled.');
      } else {
        throw Exception('An error occurred. Please try again later.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
