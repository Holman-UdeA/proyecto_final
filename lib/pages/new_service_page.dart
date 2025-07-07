import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  final _specialism = TextEditingController();
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
                controller: _specialism,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Especialidad",
                  prefixIcon: const Icon(Icons.accessibility),
                  suffixIcon: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Información de especialidad"),
                            content: const Text(
                              "En este campo debes indicar la especialidad o área de experiencia del servicio que ofreces. "
                              "Por ejemplo: Nutricionista, Fisiterapeuta, Deportologo, e.t.c.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Entendido"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF0F8555),
                    ),
                  ),
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
                inputFormatters: [priceFormatter],
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
  final priceFormatter = TextInputFormatter.withFunction(
        (oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isEmpty) return newValue.copyWith(text: '');

      final number = int.parse(text);
      final formatted = NumberFormat.decimalPattern('es_CO').format(number);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    },
  );

  Future<void> _saveService() async {
    var service = ServiceOfProfesional(
      "",
      FirebaseAuth.instance.currentUser!.uid,
      _nameService.text.toLowerCase(),
      _specialism.text.toLowerCase(),
      _description.text,
      _price.text,
      _duration.text,
    );

    var result = await _firebaseApi.createServiceInDB(service);
    if (result == 'network-request-failed') {
      showMsg("Revise su conexión a Internet");
    } else {
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
