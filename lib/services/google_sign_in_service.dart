import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleSignInService {
  static GoogleSignIn? _googleSignIn;
  
  static GoogleSignIn get instance {
    _googleSignIn ??= GoogleSignIn(
      // Add your web client ID here (from Google Console)
      clientId: kIsWeb ? '976252022553-9g4u9si5bqesapchdpnc8if910vnjqeg.apps.googleusercontent.com.apps.googleusercontent.com' : null,
      scopes: [
        'email',
        'profile',
      ],
    );
    return _googleSignIn!;
  }

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      // Sign out first to ensure clean state
      await instance.signOut();
      
      // Attempt sign in
      final GoogleSignInAccount? account = await instance.signIn();
      
      if (account != null) {
        debugPrint('Google Sign-In successful: ${account.email}');
        return account;
      } else {
        debugPrint('Google Sign-In cancelled by user');
        return null;
      }
    } catch (error) {
      debugPrint('Google Sign-In error: $error');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await instance.signOut();
      debugPrint('Google Sign-Out successful');
    } catch (error) {
      debugPrint('Google Sign-Out error: $error');
    }
  }

  static Future<bool> isSignedIn() async {
    return await instance.isSignedIn();
  }

  static GoogleSignInAccount? get currentUser => instance.currentUser;
}
