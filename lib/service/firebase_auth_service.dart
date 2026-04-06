import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔥 COMMON: WAIT FOR STABLE USER
  Future<User?> _getStableUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _auth.currentUser?.reload();
    return _auth.currentUser;
  }

// =========================
// 🔥 GOOGLE LOGIN
// =========================
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);

    return await _getStableUser();
  }

// =========================
// 🔥 SEND OTP
// =========================
  Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(User user) onAutoLogin,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        final result = await _auth.signInWithCredential(credential);
        final user = await _getStableUser();

        if (user != null) {
          onAutoLogin(user);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        print("❌ OTP Error: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

// =========================
// 🔥 VERIFY OTP
// =========================
  Future<User?> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    await _auth.signInWithCredential(credential);

    return await _getStableUser();
  }
}
