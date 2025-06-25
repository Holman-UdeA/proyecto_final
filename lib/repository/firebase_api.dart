import 'package:firebase_auth/firebase_auth.dart';

class FirebaseApi {
  Future<bool> validateSession() async {
    return await FirebaseAuth.instance.currentUser == null;
  }
}
