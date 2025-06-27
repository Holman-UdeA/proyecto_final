import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/models/service_of_profesional.dart';
import 'package:proyecto_final/repository/firebase_api.dart';

class NewServicePage extends StatefulWidget {
  const NewServicePage({super.key});

  @override
  State<NewServicePage> createState() => _NewServicePageState();
}

class _NewServicePageState extends State<NewServicePage> {
  final FirebaseApi _firebaseApi = FirebaseApi();

  final _nameService = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController();
  final _description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo servicio")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.add_chart_outlined, size: 80),
              const SizedBox(height: 40),
              TextFormField(
                controller: _nameService,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Titulo",
                  prefixIcon: const Icon(Icons.abc),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Precio (COP)",
                  prefixIcon: const Icon(Icons.price_change),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _duration,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Duracion (min)",
                  prefixIcon: const Icon(Icons.av_timer),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Descripción del servicio",
                  prefixIcon: const Icon(Icons.description),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 7,
                minLines: 4,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF0F8555),
                  fixedSize: const Size(400, 60),
                  textStyle: const TextStyle(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saveService,
                child: const Text("Guardar servicio"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveService() async {
    var service = ServiceOfProfesional(
      "",
      FirebaseAuth.instance.currentUser!.uid,
      _nameService.text,
      _description.text,
      _price.text,
      _duration.text,
    );

    var result = await _firebaseApi.createServiceInDB(service);
    if(result == 'network-request-failed'){
      showMsg("Revise su conexión a Internet");
    }else {
      showMsg("Servicio guardado");
      Navigator.pop(context);
    }
  }

  void showMsg(String msg) {
    final scafflold = ScaffoldMessenger.of(context);
    scafflold.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 10),
        action: SnackBarAction(
          label: "Aceptar",
          onPressed: scafflold.hideCurrentSnackBar,
        ),
      ),
    );
  }
}
