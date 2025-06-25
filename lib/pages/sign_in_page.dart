import 'package:flutter/material.dart';
import 'package:proyecto_final/pages/home_navigation_bar_page.dart';
import 'package:proyecto_final/pages/recovery_password_page.dart';
import 'package:proyecto_final/pages/sign_up_page.dart';
import 'package:proyecto_final/repository/firebase_api.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  final FirebaseApi _firebaseApi = FirebaseApi();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage("assets/images/logo.png"),
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.contact_mail),
                      labelText: "Correo electrónico",
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.password_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      labelText: "Contraseña",
                    ),
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 30),
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
                    onPressed: _onSignInButtonClicked,
                    child: const Text("Iniciar sesión"),
                  ),
                  const SizedBox(height: 80),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF0F8555).withValues(alpha: 0.7),
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text("¿Primera vez en SportLink? Registrate"),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF0F8555).withValues(alpha: 0.7),
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecoveryPasswordPage(),
                        ),
                      );
                    },
                    child: Text("¿Olvidaste tu contraseña?"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSignInButtonClicked() async{
    if(_email.text.isEmpty || _password.text.isEmpty){
      showMsg("Debe completar todos los campos");
    }else{
      var result = await _firebaseApi.signInUser(_email.text, _password.text);
      if (result == 'invalid-credential') {
        showMsg("Correo electrónico o contraseña incorrecta.");
      } else if (result == 'invalid-email') {
        showMsg("El correo electronico está mal escrito");
      } else if (result == 'network-request-failed') {
        showMsg("Revise su conexion a Internet");
      } else {
        showMsg("Bienvenido");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeNavigationBarPage()),
        );
      }
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
