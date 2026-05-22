import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/app_user.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // Tracks whether GoogleSignIn.instance.initialize() has been awaited once
  // for this app session. v7+ requires explicit initialisation before
  // authenticate().
  static Future<void>? _googleInit;

  Stream<AppUser?> userStream() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL,
      );
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Google Sign-In via google_sign_in 7.x.
  ///
  /// The v7 API splits initialization, authentication, and authorization. We
  /// only need the user's [idToken] to mint a Firebase credential — no extra
  /// OAuth scopes — so we skip the authorization step.
  ///
  /// On iOS the OAuth client is resolved from `GoogleService-Info.plist` +
  /// the `REVERSED_CLIENT_ID` URL scheme in `Info.plist`. On Android it is
  /// resolved from `google-services.json` via the Gradle plugin.
  Future<void> signInWithGoogle() async {
    _googleInit ??= GoogleSignIn.instance.initialize();
    await _googleInit;

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google Sign-In is not supported on this platform.',
      );
    }

    final GoogleSignInAccount account =
        await GoogleSignIn.instance.authenticate();
    final GoogleSignInAuthentication auth = account.authentication;

    final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
    await _auth.signInWithCredential(credential);
  }

  // TODO(post-apple-dev): implement signInWithApple via sign_in_with_apple package.
  // Blocked on Apple Developer Program enrollment + "Sign in with Apple"
  // capability in Xcode. See docs/RELEASE_RUNBOOK.md prerequisites.

  Future<void> signOut() => _auth.signOut();
}
