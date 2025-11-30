import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'database_service.dart';
import '../models/user.dart' as app_models;

/// Service d'authentification
class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DatabaseService _db = DatabaseService.instance;
  
  // Clés de stockage sécurisé
  static const String _keyEmail = 'cached_email';
  static const String _keyPassword = 'cached_password';
  
  /// Utilisateur Firebase actuel
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;
  
  /// Stream d'état d'authentification
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  /// Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => currentFirebaseUser != null;
  
  // ============== EMAIL/PASSWORD AUTH ==============
  
  /// Inscription avec email et mot de passe
  Future<app_models.User?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Mettre à jour le profil
        if (displayName != null) {
          await credential.user!.updateDisplayName(displayName);
        }
        
        // Créer l'utilisateur dans la DB locale
        final user = app_models.User(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName ?? email.split('@')[0],
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await _db.saveUser(user);
        
        // Sauvegarder les credentials pour connexion offline
        await _saveCredentials(email, password);
        
        return user;
      }
      
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    }
  }
  
  /// Connexion avec email et mot de passe
  Future<app_models.User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Récupérer ou créer l'utilisateur local
        var user = await _db.getUserByUid(credential.user!.uid);
        
        if (user == null) {
          user = app_models.User(
            uid: credential.user!.uid,
            email: email,
            displayName: credential.user!.displayName ?? email.split('@')[0],
            photoUrl: credential.user!.photoURL,
            createdAt: DateTime.now(),
          );
        }
        
        user.lastLoginAt = DateTime.now();
        user.isOnlineMode = true;
        await _db.saveUser(user);
        
        // Sauvegarder les credentials pour connexion offline
        await _saveCredentials(email, password);
        
        return user;
      }
      
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    }
  }
  
  /// Connexion offline avec credentials sauvegardés
  Future<app_models.User?> signInOffline({
    required String email,
    required String password,
  }) async {
    final cachedEmail = await _secureStorage.read(key: _keyEmail);
    final cachedPassword = await _secureStorage.read(key: _keyPassword);
    
    if (cachedEmail == email && cachedPassword == password) {
      // Récupérer l'utilisateur de la DB locale
      final users = await _db.isar.users.filter().emailEqualTo(email).findAll();
      
      if (users.isNotEmpty) {
        final user = users.first;
        user.lastLoginAt = DateTime.now();
        user.isOnlineMode = false;
        await _db.saveUser(user);
        return user;
      }
    }
    
    throw Exception('Identifiants invalides ou aucune session offline disponible.');
  }
  
  // ============== GOOGLE AUTH ==============
  
  /// Connexion avec Google
  Future<app_models.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null; // L'utilisateur a annulé
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Créer ou mettre à jour l'utilisateur local
        var user = await _db.getUserByUid(userCredential.user!.uid);
        
        if (user == null) {
          user = app_models.User(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName: userCredential.user!.displayName,
            photoUrl: userCredential.user!.photoURL,
            createdAt: DateTime.now(),
          );
        }
        
        user.lastLoginAt = DateTime.now();
        await _db.saveUser(user);
        
        return user;
      }
      
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la connexion Google: $e');
    }
  }
  
  // ============== FACEBOOK AUTH ==============
  
  /// Connexion avec Facebook
  Future<app_models.User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        
        if (accessToken != null) {
          final credential = firebase_auth.FacebookAuthProvider.credential(
            accessToken.tokenString,
          );
          
          final userCredential = await _firebaseAuth.signInWithCredential(credential);
          
          if (userCredential.user != null) {
            var user = await _db.getUserByUid(userCredential.user!.uid);
            
            if (user == null) {
              user = app_models.User(
                uid: userCredential.user!.uid,
                email: userCredential.user!.email ?? '',
                displayName: userCredential.user!.displayName,
                photoUrl: userCredential.user!.photoURL,
                createdAt: DateTime.now(),
              );
            }
            
            user.lastLoginAt = DateTime.now();
            await _db.saveUser(user);
            
            return user;
          }
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la connexion Facebook: $e');
    }
  }
  
  // ============== LOGOUT ==============
  
  /// Déconnexion
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
  }
  
  // ============== PASSWORD RESET ==============
  
  /// Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    }
  }
  
  // ============== HELPERS ==============
  
  /// Sauvegarder les credentials de manière sécurisée
  Future<void> _saveCredentials(String email, String password) async {
    await _secureStorage.write(key: _keyEmail, value: email);
    await _secureStorage.write(key: _keyPassword, value: password);
  }
  
  /// Supprimer les credentials sauvegardés
  Future<void> _clearCredentials() async {
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyPassword);
  }
  
  /// Gérer les exceptions Firebase
  String _handleFirebaseException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Email invalide.';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion.';
      default:
        return 'Erreur d\'authentification: ${e.message}';
    }
  }
}
