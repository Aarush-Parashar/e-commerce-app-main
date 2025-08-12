import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleSignInConfig {
  static GoogleSignIn? _googleSignIn;
  
  // Replace with your actual web client ID from Google Console
  static const String webClientId = '976252022553-9g4u9si5bqesapchdpnc8if910vnjqeg.apps.googleusercontent.com.apps.googleusercontent.com';
  
  static GoogleSignIn get instance {
    _googleSignIn ??= GoogleSignIn(
      // For web, you need to specify the client ID
      clientId: kIsWeb ? webClientId : null,
      scopes: [
        'email',
        'profile',
        'openid',
      ],
      // Force account selection
      forceCodeForRefreshToken: true,
    );
    return _googleSignIn!;
  }

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      debugPrint('Starting Google Sign-In...');
      
      // Check if already signed in
      GoogleSignInAccount? account = instance.currentUser;
      
      if (account == null) {
        // Sign out first to ensure clean state
        await instance.signOut();
        
        // Attempt sign in
        account = await instance.signIn();
      }
      
      if (account != null) {
        debugPrint('Google Sign-In successful: ${account.email}');
        
        // Get authentication details
        final GoogleSignInAuthentication auth = await account.authentication;
        debugPrint('Access token: ${auth.accessToken != null ? "✓" : "✗"}');
        debugPrint('ID token: ${auth.idToken != null ? "✓" : "✗"}');
        
        return account;
      } else {
        debugPrint('Google Sign-In cancelled by user');
        return null;
      }
    } catch (error) {
      debugPrint('Google Sign-In error: $error');
      
      // Handle specific errors
      if (error.toString().contains('sign_in_failed')) {
        debugPrint('Sign-in failed - check SHA-1 fingerprint and package name configuration');
      } else if (error.toString().contains('network_error')) {
        debugPrint('Network error - check internet connection');
      }
      
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
