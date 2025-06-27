import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailServicePage extends StatefulWidget {
  final QueryDocumentSnapshot service;

  const DetailServicePage(this.service, {super.key});

  @override
  State<DetailServicePage> createState() => _DetailServicePageState(service);
}

class _DetailServicePageState extends State<DetailServicePage> {
  final QueryDocumentSnapshot service;

  _DetailServicePageState(this.service);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del Servicio"),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getProfessionalData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          final photoUrl = userData?["ulrPicture"];
          final name = userData?["name"] ?? "Nombre no disponible";
          final email = userData?["email"] ?? "Email no disponible";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto del profesional
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (photoUrl != null && photoUrl != "")
                          ? NetworkImage(photoUrl)
                          : const AssetImage(
                                "assets/images/default_profile.jpg",
                              )
                              as ImageProvider,
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F8555),
                  ),
                ),
                Text(
                  "${service["specialism"]}",
                  style: const TextStyle(fontSize: 17, color: Colors.black),
                ),
                const SizedBox(height: 20),
                // Card con datos del servicio
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  color: const Color(0xFFF5F5F5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow("Servicio", service["nameService"]),
                        _detailRow("Precio", "${service["price"]} COP"),
                        _detailRow(
                          "Duración",
                          "${service["duration"]} minutos",
                        ),
                        _detailRow("Contacto", email),
                        const SizedBox(height: 12),
                        const Text(
                          "Descripción",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F8555),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service["description"] ?? "Sin descripción.",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if(service["uidProfesional"]!=FirebaseAuth.instance.currentUser?.uid)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8555),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    _launchEmail(email);
                  },
                  icon: const Icon(Icons.mail),
                  label: const Text("Contactar profesional"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> _getProfessionalData() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(service["uidProfesional"])
        .get();
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  void _launchEmail(email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull(
        "subject=Información sobre el servicio ${service["nameService"]}&body=Hola, me gustaría obtener más información sobre el servicio que ofreces.",
      ),
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      final Uri gmailUri = Uri.parse(
        'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=${Uri.encodeComponent("Consulta de servicio")}&body=${Uri.encodeComponent("Hola, me gustaría obtener más información sobre el servicio que ofreces.")}',
      );
      if (await canLaunchUrl(gmailUri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "No hay app predeterminada para correos, abriendo Gmail web. Correo destinatario copiado.",
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        Clipboard.setData(ClipboardData(text: email));
        await Future.delayed(const Duration(seconds: 3));
        await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No se pudo abrir un cliente de correo ni Gmail web.",
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
