import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/pages/detail_service_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _itemSearch = TextEditingController();

  bool _isLoading = false;

  List<QueryDocumentSnapshot> _results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Busqueda"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemSearch,
                    decoration: InputDecoration(
                      hintText: "Ingrese servicio o especialidad a buscar",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        onPressed: _perfomSearch,
                        icon: const Icon(Icons.search),
                      ),
                    ),
                    onSubmitted: (_) => _perfomSearch(),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) const Padding(
              padding: EdgeInsets.all(16), child: CircularProgressIndicator())
          else
            if (_results.isEmpty && _itemSearch.text.isNotEmpty) const Padding(
              padding: EdgeInsets.all(16),
              child: Text("No se encontraron resultados.")
            )
          else Expanded(child: ListView.builder(itemCount: _results.length,itemBuilder: (context, index){
              final service = _results[index];
              return buildCard(service);
            }))
        ],
      ),
    );
  }

  void _perfomSearch() async {
    final query = _itemSearch.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot =
      await FirebaseFirestore.instance
          .collection("servicesOfProfessionals")
          .get();

      final filtered =
      snapshot.docs.where((doc) {
        final name = (doc["nameService"] ?? "").toString().toLowerCase();
        final speciality = (doc["specialism"] ?? "").toString().toLowerCase();
        //return name.contains(query) || speciality.contains(query);
        //return name == query || speciality == query;
        return name.startsWith(query) || speciality.startsWith(query);
      }).toList();

      setState(() {
        _results = filtered;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al buscar: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildCard(QueryDocumentSnapshot service) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(service["uidProfesional"])
          .get(),
      builder: (context, snapshot) {
        Widget leading;
        String nameProfesional = "";

        if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final photoUrl = userData?["ulrPicture"];

          nameProfesional = userData?["name"];

          if (photoUrl != null && photoUrl != "") {
            leading = CircleAvatar(
              backgroundImage: NetworkImage(photoUrl),
            );

          } else {
            leading = const CircleAvatar(
              backgroundImage: AssetImage("assets/images/default_profile.jpg"),
            );
          }
        } else {
          leading = const CircleAvatar(
            backgroundImage: AssetImage("assets/images/default_profile.jpg"),
          );
          nameProfesional = "N/A";
        }

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: ListTile(
            leading: leading,
            title: Text(nameProfesional),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${service["nameService"]}" ),
                Text("${service["specialism"] ?? 'N/A'}"),
                Text("Precio: ${service["price"]}"),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailServicePage(service)),
              );
            },
          ),
        );
      },
    );
  }
}
