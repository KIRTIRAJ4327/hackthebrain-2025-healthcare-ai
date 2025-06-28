import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication State
sealed class AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

/// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Auth State Notifier with Google Sign-In Support
class AuthNotifier extends StateNotifier<AuthState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '881487619712-duej6k7eafl73dllukn312mim5fut2u0.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  AuthNotifier() : super(AuthLoading()) {
    _init();
  }

  void _init() {
    // Clear any existing auth state and force refresh
    FirebaseAuth.instance.signOut().then((_) {
      // Listen to auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          // Verify token is still valid
          user.getIdToken(true).then((_) {
            state = AuthAuthenticated(user);
          }).catchError((error) {
            // Token expired or invalid, sign out
            FirebaseAuth.instance.signOut();
            state = AuthUnauthenticated();
          });
        } else {
          state = AuthUnauthenticated();
        }
      });
    }).catchError((error) {
      // If signOut fails, still continue with auth state listening
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          state = AuthAuthenticated(user);
        } else {
          state = AuthUnauthenticated();
        }
      });
    });
  }

  /// Sign in with Google
  /// Note: Using signIn() method which is deprecated for web but still functional
  /// TODO: Migrate to renderButton() for web in future update
  Future<void> signInWithGoogle() async {
    try {
      state = AuthLoading();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        state = AuthUnauthenticated();
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await userCredential.user!.getIdToken(true);
        // State will be updated by the auth state listener
      } else {
        state = AuthError('Google sign in failed: No user returned');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Google sign in failed';

      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'An account already exists with the same email but different sign-in credentials.';
          break;
        case 'invalid-credential':
          errorMessage = 'The credential received is malformed or has expired.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google sign-in is not enabled for this project.';
          break;
        case 'user-disabled':
          errorMessage = 'The user account has been disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found for the given credentials.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage = e.message ??
              'An unexpected error occurred during Google sign in.';
      }

      state = AuthError(errorMessage);
    } catch (e) {
      state = AuthError('Google sign in failed: ${e.toString()}');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = AuthLoading();
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify the user and token are valid
      if (credential.user != null) {
        await credential.user!.getIdToken(true);
        // State will be updated by the auth state listener
      } else {
        state = AuthError('Sign in failed: No user returned');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign in failed';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'invalid-credential':
          errorMessage =
              'Invalid credentials. Please check your email and password.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage = e.message ?? 'An unexpected error occurred.';
      }

      state = AuthError(errorMessage);
    } catch (e) {
      state = AuthError('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = AuthLoading();
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify the user and token are valid
      if (credential.user != null) {
        await credential.user!.getIdToken(true);
        // State will be updated by the auth state listener
      } else {
        state = AuthError('Sign up failed: No user returned');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign up failed';

      switch (e.code) {
        case 'weak-password':
          errorMessage =
              'Password is too weak. Please use at least 6 characters.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage = e.message ?? 'An unexpected error occurred.';
      }

      state = AuthError(errorMessage);
    } catch (e) {
      state = AuthError('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from both Firebase and Google
      await Future.wait([
        FirebaseAuth.instance.signOut(),
        _googleSignIn.signOut(),
      ]);
      // State will be updated by the auth state listener
    } catch (e) {
      state = AuthError('Sign out failed: ${e.toString()}');
    }
  }

  /// Clear error state and return to unauthenticated
  void clearError() {
    if (state is AuthError) {
      state = AuthUnauthenticated();
    }
  }

  /// Force refresh authentication state
  Future<void> refreshAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.getIdToken(true);
        state = AuthAuthenticated(user);
      } catch (e) {
        await FirebaseAuth.instance.signOut();
        state = AuthUnauthenticated();
      }
    } else {
      state = AuthUnauthenticated();
    }
  }

  /// Check if current user signed in with Google
  bool isGoogleUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.providerData.any((info) => info.providerId == 'google.com');
    }
    return false;
  }
}
