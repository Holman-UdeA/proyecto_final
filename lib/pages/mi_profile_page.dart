import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_final/pages/detail_service_page.dart';
import 'package:proyecto_final/pages/new_service_page.dart';
import 'package:proyecto_final/repository/firebase_api.dart';

class MiProfilePage extends StatefulWidget {
  const MiProfilePage({super.key});

  @override
  State<MiProfilePage> createState() => _MiProfilePageState();
}

class _MiProfilePageState extends State<MiProfilePage> {
  final FirebaseApi _firebaseApi = FirebaseApi();

  File? image;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>?>>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!.data();
        final isProfessional = user?["rol"] == "Profesional";

        return Scaffold(
          appBar: AppBar(title: const Text("Mi perfil"), centerTitle: true),
          floatingActionButton:
              isProfessional
                  ? FloatingActionButton(
                    onPressed: () {
                      _addButtonClicked();
                    },
                    child: const Icon(Icons.add),
                  )
                  : null,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FOTO + NOMBRE + ROL
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            user?["ulrPicture"] != null &&
                                    user!["ulrPicture"] != ""
                                ? NetworkImage(user["ulrPicture"])
                                : const AssetImage(
                                      "assets/images/default_profile.jpg",
                                    )
                                    as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?["name"] ?? "Nombre no disponible",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?["rol"] ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // INFORMACIÓN PERSONAL
                  Text(
                    "Información personal",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),

                  _infoRow("Correo", user?["email"] ?? "No disponible"),
                  _infoRow("Género", user?["genre"] ?? "No especificado"),
                  _infoRow(
                    "Fecha de nacimiento",
                    _dateConverter((user?["bornDate"]).toDate()),
                  ),

                  const SizedBox(height: 10),
                  const Divider(),

                  // Servicios (solo para profesionales)
                  if (isProfessional) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Servicios que brinda",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection("myServices")
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Text("Loading...");
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) {
                            QueryDocumentSnapshot service =
                                snapshot.data!.docs[index];
                            return buildCard(service);
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _dateConverter(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String dateFormatted = formatter.format(date);
    return dateFormatted;
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  InkWell buildCard(QueryDocumentSnapshot service) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailServicePage(service)),
        );
      },
      onLongPress: () {
        showAlertDialog(context, service);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.fitness_center, color: Color(0xFF0F8555)),
          title: Text(service["nameService"]),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Especialidad: ${service["specialism"] ?? 'N/A'}"),
              Text("Precio: ${service["price"]} COP"),
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, QueryDocumentSnapshot service) {
    AlertDialog alert = AlertDialog(
      title: const Text("Advertencia"),
      content: Text(
        "¿Esta seguro que desea eliminar el servicio ${service["nameService"]}?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, "Cancel"),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed:
              () => {
                _firebaseApi.deleteService(service),
                Navigator.pop(context, "OK"),
              },
          child: const Text("Aceptar"),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _addButtonClicked() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewServicePage()),
    );
  }
}
