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

  Future<void> updateUserData(Map<String, dynamic> data) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User is not authenticated.");
    }
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception("Failed to update user data: $e");
    }
  }

  Future<void> updateDisplayName(String newName) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }
    try {
      await user.updateDisplayName(newName);
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': newName,
      });
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to update display name: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  Future<void> updateUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception("User is not authenticated or email is missing.");
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Incorrect current password.');
      } else if (e.code == 'weak-password') {
        throw Exception('The new password is too weak.');
      } else {
        throw Exception('An error occurred: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
