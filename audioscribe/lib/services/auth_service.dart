import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Google sign in
  signInWithGoogle() async {
    // begin interactive sign in process
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();

    // obtain auth details from request
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    // create a new credential for user
    final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);

    // sign in
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
