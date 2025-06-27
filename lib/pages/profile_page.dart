import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_final/pages/mi_profile_page.dart';
import 'package:proyecto_final/pages/sign_in_page.dart';
import 'package:proyecto_final/repository/firebase_api.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseApi _firebaseApi = FirebaseApi();

  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Perfil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>?>>(
          stream:
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading...");
            }
            var user = snapshot.data!.data();
            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            image != null
                                ? FileImage(image!)
                                : (user?["ulrPicture"] != ""
                                    ? NetworkImage(user!["ulrPicture"])
                                    : const AssetImage(
                                      "assets/images/default_profile.jpg",
                                    )),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => pickImage(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F8555),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "${user?["name"]}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _ProfileOption(
                          icon: Icons.person,
                          label: 'Mi Perfil',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MiProfilePage(),
                              ),
                            );
                          },
                        ),
                        _ProfileOption(
                          icon: Icons.help_center,
                          label: 'Centro de ayuda',
                          onTap: () {
                            // Navegar a centro de ayuda
                          },
                        ),
                        _ProfileOption(
                          icon: Icons.settings,
                          label: 'Configuración',
                          onTap: () {
                            // Navegar a configuración
                          },
                        ),
                        _ProfileOption(
                          icon: Icons.privacy_tip,
                          label: 'Política de privacidad',
                          onTap: () {
                            // Navegar a política de privacidad
                          },
                        ),
                        _ProfileOption(
                          icon: Icons.payment,
                          label: 'Métodos de pago',
                          onTap: () {
                            // Navegar a métodos de pago
                          },
                        ),
                        _ProfileOption(
                          icon: Icons.lock,
                          label: 'Gestionar contraseña',
                          onTap: () {
                            // Navegar a gestión de contraseña
                          },
                        ),
                        _ProfileOption(
                          icon: Icons.logout,
                          label: 'Cerrar sesión',
                          onTap: () => _onSignOutButtonClicked(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage == null) return;

      final imageTemp = File(pickedImage.path);

      setState(() {
        image = imageTemp;
      });

      // SUBIR A FIREBASE STORAGE
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final fileName = '$userId.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/$fileName',
      );

      await storageRef.putFile(imageTemp);

      final imageUrl = await storageRef.getDownloadURL();

      // GUARDAR URL EN FIRESTORE
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        'ulrPicture': imageUrl,
      });
    } on PlatformException catch (e) {
      print("Error al seleccionar imagen: $e");
    } catch (e) {
      print("Error al subir imagen: $e");
    }
  }

  void _onSignOutButtonClicked() {
    _firebaseApi.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF0F8555)),
      title: Text(label),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Color(0xFF0F8555),
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
