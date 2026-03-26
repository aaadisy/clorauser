import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 GOOGLE LOGIN
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
    await GoogleSignIn().signIn();

    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
    await _auth.signInWithCredential(credential);

    return userCredential.user;
  }

  // 🔥 SEND OTP
  Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phone',

      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        print("OTP Error: ${e.message}");
      },

      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // 🔥 VERIFY OTP
  Future<User?> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    final result = await _auth.signInWithCredential(credential);

    return result.user;
  }
}