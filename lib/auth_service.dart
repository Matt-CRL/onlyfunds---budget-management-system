import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn ({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createAccount ({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword ({
    required String email,
  }) async {
    return await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername ({
    required String username,
  }) async {
    await currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({ required String password }) async {
  try {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) throw Exception("No user logged in");

    final credential = EmailAuthProvider.credential(
      email: currentUser.email!,
      password: password,
    );

    await currentUser.reauthenticateWithCredential(credential);

    await deleteUserData(); // delete all Firestore data
    await currentUser.delete(); // delete auth account
    await firebaseAuth.signOut();
  } on FirebaseAuthException catch (e) {
    debugPrint("Auth error: ${e.message}");
    rethrow;
  } catch (e) {
    debugPrint("Unexpected error: $e");
    rethrow;
  }
}

  Future<void> deleteUserData() async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final userRef = firestore.collection("users").doc(user.uid);

    // Get all monthly records
    final monthlyRecords = await userRef.collection("monthly_records").get();

    for (final monthDoc in monthlyRecords.docs) {
      final monthRef = monthDoc.reference;

      // Delete all transactions
      final transactions =
          await monthRef.collection("transactions").get();
      for (final doc in transactions.docs) {
        await doc.reference.delete();
      }

      // Delete all goals
      final goals = await monthRef.collection("goals").get();
      for (final doc in goals.docs) {
        await doc.reference.delete();
      }

      // Delete all summary docs
      final summary = await monthRef.collection("summary").get();
      for (final doc in summary.docs) {
        await doc.reference.delete();
      }

      // Delete the month document itself
      await monthRef.delete();
    }

    // Finally delete the user document
    await userRef.delete();
  }


  Future<void> resetPasswordFromCurrentPassword ({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
   AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
   await currentUser!.reauthenticateWithCredential(credential);
   await currentUser!.updatePassword(newPassword);
  }
}