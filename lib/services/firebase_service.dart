import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../models/user_model.dart';
import '../models/trip_model.dart';
import '../models/emergency_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
        return await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        // Log detailed error for debugging, but do not expose raw text to UI.
        debugPrint('FirebaseService.signInWithEmail error: $e');
        rethrow;
    }
  }

  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user != null) {
          await saveUserData(
            credential.user!.uid,
            name,
            email,
            phone,
          );
        }

        return credential;
      } catch (e) {
        debugPrint('FirebaseService.signUpWithEmail error: $e');
        rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
        if (kIsWeb) {
        // On web use the popup-based sign in which uses the Firebase JS SDK under the hood.
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        final userCredential = await _auth.signInWithPopup(provider);

        // Save user data if new user
        if (userCredential.user != null) {
          final user = userCredential.user!;
          final userData = await getUserData(user.uid);
          if (userData == null) {
            await saveUserData(
              user.uid,
              user.displayName ?? user.email?.split('@')[0] ?? 'User',
              user.email ?? '',
              user.phoneNumber ?? '',
            );
          }
        }

        return userCredential;
      }

      // Mobile (Android / iOS / desktop): Use google_sign_in plugin to obtain the OAuth tokens.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User aborted the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Save user data if new user
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final userData = await getUserData(user.uid);
        if (userData == null) {
          await saveUserData(
            user.uid,
            user.displayName ?? user.email?.split('@')[0] ?? 'User',
            user.email ?? '',
            user.phoneNumber ?? '',
          );
        }
      }

      return userCredential;
    } catch (e) {
        debugPrint('FirebaseService.signInWithGoogle error: $e');
        rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Data
  Future<void> saveUserData(String uid, String name, String email, String phone) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserModel(
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Trip History
  Future<void> saveTrip(TripModel trip, String userId) async {
    await _firestore.collection('trips').add({
      'userId': userId,
      'emergencyType': trip.emergencyType.name,
      'driverName': trip.driverName,
      'vehicleNumber': trip.vehicleNumber,
      'date': trip.date.toIso8601String(),
      'distance': trip.distance,
      'duration': trip.duration,
      'rating': trip.rating,
      'feedback': trip.feedback,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TripModel>> getTripHistory(String userId) {
    return _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TripModel(
          id: doc.id,
          emergencyType: EmergencyType.values.firstWhere(
            (e) => e.name == data['emergencyType'],
            orElse: () => EmergencyType.other,
          ),
          driverName: data['driverName'] ?? '',
          vehicleNumber: data['vehicleNumber'] ?? '',
          date: DateTime.parse(data['date']),
          distance: (data['distance'] ?? 0).toDouble(),
          duration: data['duration'] ?? 0,
          rating: data['rating']?.toDouble(),
          feedback: data['feedback'],
        );
      }).toList();
    });
  }

  Future<int> getTripCount(String userId) async {
    final snapshot = await _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}

