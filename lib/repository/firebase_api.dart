import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart' as UserApp;

class FirebaseApi {
  Future<String?> createUser(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException ${e.code}");
      return e.code;
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code;
    }
  }

  Future<String?> signInUser(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException ${e.code}");
      return e.code;
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code;
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void recoveryPassword(String emailAddress) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailAddress);
  }

  Future<bool> validateSession() async {
    return await FirebaseAuth.instance.currentUser == null;
  }

  Future<String> createUserInDB(UserApp.User user) async {
    try {
      var db = FirebaseFirestore.instance;
      final document = await db
          .collection("users")
          .doc(user.uid)
          .set(user.toJson());
      return user.uid;
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code;
    }
  }

  Future<String> createServiceInDB(serviceOfProfesional) async {
    try {
      final db = FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final document =
          await db.collection("users").doc(uid).collection("myServices").doc();

      serviceOfProfesional.idService = document.id;

      await db
          .collection("users")
          .doc(uid)
          .collection("myServices")
          .doc(serviceOfProfesional.idService)
          .set(serviceOfProfesional.toJson());

      await db
          .collection("servicesOfProfessionals")
          .doc(serviceOfProfesional.idService)
          .set(serviceOfProfesional.toJson());

      return document.id;
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code;
    }
  }

  Future<String> deleteService(QueryDocumentSnapshot service) async {
    try {
      final db = FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      await db
          .collection("users")
          .doc(uid)
          .collection("myServices")
          .doc(service.id)
          .delete();

      await db
          .collection("servicesOfProfessionals")
          .doc(service.id)
          .delete();

      return uid!;
    } on FirebaseException catch (e) {
      print("FirebaseException ${e.code}");
      return e.code;
    }
  }
}
