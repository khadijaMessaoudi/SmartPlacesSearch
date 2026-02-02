import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de l'utilisateur connecté
  Stream<AppUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Convertir FirebaseUser en AppUser
  AppUser? _userFromFirebaseUser(User? user) {
    return user != null
        ? AppUser(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName,
          )
        : null;
  }

  // Créer un compte
  Future<AppUser?> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Mettre à jour le nom d'affichage
        await user.updateDisplayName(displayName);

        // Créer le document utilisateur dans Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return AppUser(uid: user.uid, email: email, displayName: displayName);
      }
    } catch (e) {
      print('Erreur lors de la création du compte: $e');
      throw e;
    }
    return null;
  }

  // Se connecter
  Future<AppUser?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      throw e;
    }
  }

  // Se déconnecter
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => _auth.currentUser != null;

  // Obtenir l'utilisateur actuel
  AppUser? get currentUser => _userFromFirebaseUser(_auth.currentUser);
}
