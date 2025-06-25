import 'package:flutter/material.dart';
import 'package:proyecto_final/repository/firebase_api.dart';

class RecoveryPasswordPage extends StatefulWidget {
  const RecoveryPasswordPage({super.key});

  @override
  State<RecoveryPasswordPage> createState() => _RecoveryPasswordPageState();
}

class _RecoveryPasswordPageState extends State<RecoveryPasswordPage> {
  final _email = TextEditingController();

  final FirebaseApi _firebaseApi = FirebaseApi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage("assets/images/logo.png"),
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 64),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    labelText: "Correo electrónico",
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 100),
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
                  onPressed: (){
                    if(_email.text.isEmpty){
                      _showMsg("Debe digitar un correo electrónico");
                    }else{
                      _firebaseApi.recoveryPassword(_email.text);
                      _showMsg("Revise su correo electrónico");
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Recuperar contraseña"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showMsg(String msg) {
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
