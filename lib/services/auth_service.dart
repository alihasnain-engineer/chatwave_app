import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? get currentUID => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login or sign up with email
  /// Uses anonymous auth and ensures UID consistency for messages
  Future<UserModel?> loginWithEmail(String email) async {
    try {
      debugPrint('🔐 Starting login process for email: $email');
      
      // Check if user document exists with this email
      debugPrint('📡 Querying Firestore for user with email: $email');
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('❌ Firestore query timeout');
              throw Exception('Network timeout. Please check your internet connection.');
            },
          );
      
      debugPrint('✅ Firestore query completed. Found ${userQuery.docs.length} user(s)');

      User? firebaseUser;
      String? existingUID;
      String uidToUse;

      if (userQuery.docs.isNotEmpty) {
        // User exists in Firestore - get their UID (document ID)
        existingUID = userQuery.docs.first.id;
        uidToUse = existingUID; // CRITICAL: Always use the existing UID from users collection
        
        debugPrint('✅ Login: User exists with UID: $uidToUse (email: $email)');
        
        // Check if we're already signed in as this user
        if (_auth.currentUser?.uid == existingUID) {
          firebaseUser = _auth.currentUser;
          debugPrint('✅ Login: Already signed in with matching UID');
        } else {
          // Sign out current user if different
          if (_auth.currentUser != null) {
            await _auth.signOut();
          }
          
          // Sign in anonymously (creates new auth UID, but we'll use existingUID for messages)
          debugPrint('🔑 Signing in anonymously...');
          final credential = await _auth.signInAnonymously()
              .timeout(
                const Duration(seconds: 15),
                onTimeout: () {
                  debugPrint('❌ Anonymous sign-in timeout');
                  throw Exception('Authentication timeout. Please try again.');
                },
              );
          firebaseUser = credential.user;
          debugPrint('⚠️ Login: New auth UID created: ${firebaseUser?.uid}, but using stable UID: $uidToUse for messages');
        }
      } else {
        // New user - create anonymous account
        debugPrint('🆕 Login: New user, creating account...');
        if (_auth.currentUser != null) {
          await _auth.signOut();
        }
        debugPrint('🔑 Signing in anonymously for new user...');
        final credential = await _auth.signInAnonymously()
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                debugPrint('❌ Anonymous sign-in timeout for new user');
                throw Exception('Authentication timeout. Please try again.');
              },
            );
        firebaseUser = credential.user;
        uidToUse = firebaseUser!.uid; // Use new auth UID for new users
        debugPrint('🆕 Login: New user created with UID: $uidToUse');
      }

      if (firebaseUser == null) {
        return null;
      }

      // CRITICAL: Always use uidToUse (existingUID if user exists, or new auth UID for new users)
      // This ensures existing users keep their stable UID for message operations
      debugPrint('💾 Login: Saving/updating user document with UID: $uidToUse');
      
      // Get or create user document with stable UID
      debugPrint('📄 Getting/creating user document...');
      final userDoc = _firestore.collection('users').doc(uidToUse);
      final userSnapshot = await userDoc.get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('❌ Get user document timeout');
              throw Exception('Database timeout. Please try again.');
            },
          );

      UserModel userModel;

      if (userSnapshot.exists) {
        // Update email if it's different
        debugPrint('📝 Updating existing user document...');
        final data = userSnapshot.data()!;
        await userDoc.update({'email': email})
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                debugPrint('❌ Update user document timeout');
                throw Exception('Database timeout. Please try again.');
              },
            );
        userModel = UserModel.fromFirestore(
          {...data, 'email': email},
          uidToUse,
        );
        debugPrint('✅ Login: Updated existing user document with UID: $uidToUse');
      } else {
        // Create new user document
        debugPrint('📝 Creating new user document...');
        userModel = UserModel(
          uid: uidToUse,
          fullName: email.split('@')[0], // Use email prefix as default name
          email: email,
        );
        await userDoc.set(userModel.toFirestore())
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                debugPrint('❌ Create user document timeout');
                throw Exception('Database timeout. Please try again.');
              },
            );
        debugPrint('✅ Login: Created new user document with UID: $uidToUse');
      }

      // CRITICAL: If auth UID is different from stable UID, also create/update auth UID document
      // This ensures getCurrentUserUIDFromCollection() can find the user by email
      if (firebaseUser.uid != uidToUse) {
        debugPrint('⚠️ Login: Auth UID (${firebaseUser.uid}) differs from stable UID ($uidToUse)');
        debugPrint('   Creating/updating auth UID document with email for lookup...');
        final authUserDoc = _firestore.collection('users').doc(firebaseUser.uid);
        await authUserDoc.set({
          'email': email,
          'fullName': userModel.fullName,
          // This document is just for lookup - all message operations use uidToUse
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⚠️ Auth UID document creation timeout (non-critical)');
          },
        );
        debugPrint('✅ Login: Created auth UID document for email lookup');
      }

      debugPrint('✅ Login: User logged in successfully');
      debugPrint('   Stable UID (for messages): ${userModel.uid}');
      debugPrint('   Auth UID: ${firebaseUser.uid}');
      return userModel;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  /// Get current user model from Firestore
  /// Returns user model using UID from users collection (by email) if available
  Future<UserModel?> getCurrentUserModel() async {
    final currentAuthUser = currentUser;
    if (currentAuthUser == null) return null;

    try {
      // First, try to find user by email (this gives us the correct UID from users collection)
      // Get email from any existing user document with current auth UID
      final authUserDoc = await _firestore.collection('users').doc(currentAuthUser.uid).get();
      String? email;
      
      if (authUserDoc.exists) {
        email = authUserDoc.data()?['email'] as String?;
      }
      
      // If we have email, find user document by email (this gives us the correct UID)
      if (email != null && email.isNotEmpty) {
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        
        if (userQuery.docs.isNotEmpty) {
          final doc = userQuery.docs.first;
          return UserModel.fromFirestore(doc.data(), doc.id);
        }
      }
      
      // Fallback: use auth UID
      final doc = await _firestore.collection('users').doc(currentAuthUser.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, currentAuthUser.uid);
      }
      return null;
    } catch (e) {
      debugPrint('Get user error: $e');
      return null;
    }
  }

  /// Update user email in Firestore
  Future<void> updateUserEmail(String email) async {
    final uid = currentUID;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({'email': email});
    } catch (e) {
      debugPrint('Update email error: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Auto login - check if user is already authenticated
  Future<UserModel?> autoLogin() async {
    final user = currentUser;
    if (user != null) {
      return await getCurrentUserModel();
    }
    return null;
  }

  /// Get user UID from users collection by email (for message queries)
  /// This ensures we use the correct UID even if auth UID changes
  Future<String?> getUserUIDByEmail(String email) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return userQuery.docs.first.id; // Document ID is the UID
      }
      return null;
    } catch (e) {
      debugPrint('Get user UID by email error: $e');
      return null;
    }
  }

  /// Get current user UID from users collection (preferred over auth UID for message queries)
  /// This ensures messages sent to the user's email are found even if auth UID changes
  /// CRITICAL: Always returns the UID from users collection (document ID) for message operations
  Future<String?> getCurrentUserUIDFromCollection() async {
    final currentAuthUser = currentUser;
    if (currentAuthUser == null) {
      debugPrint('❌ getCurrentUserUIDFromCollection: No current auth user');
      return null;
    }

    debugPrint('🔍 getCurrentUserUIDFromCollection: Auth UID = ${currentAuthUser.uid}');

    try {
      // Step 1: Try to get email from any user document with current auth UID
      final authUserDoc = await _firestore.collection('users').doc(currentAuthUser.uid).get();
      String? email;
      
      if (authUserDoc.exists) {
        email = authUserDoc.data()?['email'] as String?;
        debugPrint('📧 Found email from auth UID document: $email');
      }
      
      // Step 2: If we have email, find user document by email to get stable UID
      if (email != null && email.isNotEmpty) {
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        
        if (userQuery.docs.isNotEmpty) {
          final stableUID = userQuery.docs.first.id;
          debugPrint('✅ Using stable UID from users collection: $stableUID (email: $email)');
          debugPrint('   Auth UID was: ${currentAuthUser.uid}');
          return stableUID;
        }
      }
      
      // Step 3: Fallback - check if auth UID document exists
      if (authUserDoc.exists) {
        debugPrint('⚠️ Using auth UID as fallback: ${currentAuthUser.uid}');
        return currentAuthUser.uid;
      }
      
      debugPrint('❌ No user document found for auth UID: ${currentAuthUser.uid}');
      return null;
    } catch (e) {
      debugPrint('❌ Error in getCurrentUserUIDFromCollection: $e');
      return currentAuthUser.uid; // Fallback to auth UID on error
    }
  }
}
