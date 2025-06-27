import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_final/repository/firebase_api.dart';

import '../models/user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

enum Genre { male, female }

enum Rol { Profesional, Deportista }

class _SignUpPageState extends State<SignUpPage> {
  Genre? _genre = Genre.male;
  Rol? _rol = Rol.Profesional;

  bool _isPasswordObscure = true;
  bool _isRepPasswordObscure = true;

  String buttonMsg = "Fecha de nacimiento";

  DateTime _bornDate = DateTime.now();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repPassword = TextEditingController();

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
                const SizedBox(height: 50),
                const Text(
                  "Registro",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  "Ingrese los datos solicitados",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 70),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Nombre",
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Correo electrónico",
                    prefixIcon: Icon(Icons.mail),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Dabe digitar un correo electrónico";
                    } else {
                      if (!value.isValidEmail()) {
                        return "El correo no es válido";
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _isPasswordObscure,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          _isPasswordObscure = !_isPasswordObscure;
                        });
                      },
                    ),
                    labelText: "Contraseña",
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _repPassword,
                  obscureText: _isRepPasswordObscure,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isRepPasswordObscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          _isRepPasswordObscure = !_isRepPasswordObscure;
                        });
                      },
                    ),
                    labelText: "Repita la constraseña",
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _showSelectedDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_bornDate),
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 9),
                    const Text("Género:"),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RadioListTile(
                        activeColor: Color(0xFF0F8555),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          "Masculino",
                          overflow: TextOverflow.ellipsis,
                        ),
                        value: Genre.male,
                        groupValue: _genre,
                        onChanged: (Genre? value) {
                          setState(() {
                            _genre = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: RadioListTile(
                        activeColor: Color(0xFF0F8555),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Femenino"),
                        value: Genre.female,
                        groupValue: _genre,
                        onChanged: (Genre? value) {
                          setState(() {
                            _genre = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const SizedBox(width: 9),
                    const Text("Rol:"),
                    const SizedBox(width: 35),
                    Expanded(
                      child: RadioListTile(
                        activeColor: Color(0xFF0F8555),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          "Profesional",
                          overflow: TextOverflow.ellipsis,
                        ),
                        value: Rol.Profesional,
                        groupValue: _rol,
                        onChanged: (Rol? value) {
                          setState(() {
                            _rol = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: RadioListTile(
                        activeColor: Color(0xFF0F8555),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Deportista"),
                        value: Rol.Deportista,
                        groupValue: _rol,
                        onChanged: (Rol? value) {
                          setState(() {
                            _rol = value;
                          });
                        },
                      ),
                    ),
                  ],
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
                  onPressed: () {
                    _onRegisterButtonClicked();
                  },

                  child: Text("Registrarse"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onRegisterButtonClicked() {
    if (_email.text.isEmpty ||
        _password.text.isEmpty ||
        _repPassword.text.isEmpty) {
      showMsg("Debe digitar todos los campos");
    } else if (_password.text != _repPassword.text) {
      showMsg("Las contraseñas deben de ser iguales");
    } else if (_password.text.length < 6) {
      showMsg("La contraseña debe tener mínimo 6 caracteres");
    } else {
      createUser(_email.text, _password.text);
    }
  }

  void createUser(String email, String password) async {
    var result = await _firebaseApi.createUser(email, password);
    if (result == 'weak password') {
      showMsg("La contraseña debe tener minimo 6 caracteres");
    } else if (result == 'email-already-in-use') {
      showMsg("Ya exite una cuenta con ese correo electrónico");
    } else if (result == 'invalid email') {
      showMsg("El correo electrónico está mal escrito");
    } else if (result == 'network-request-failed') {
      showMsg("Revise su conexión a internet");
    } else {
      var genre = (_genre == Genre.male) ? "Masculino" : "Femenino";
      var rol = (_rol == Rol.Profesional) ? "Profesional" : "Deportista";
      var _user = User(
        result,
        _name.text,
        _email.text,
        genre,
        rol,
        _bornDate,
        "",
      );
      _createUserInDB(_user);
    }
  }

  _createUserInDB(User user) async {
    var result = await _firebaseApi.createUserInDB(user);
    if (result == 'network-request-failed') {
      showMsg("Revise su conexión a Internet");
    } else {
      showMsg("Usuario registrado exitosamente");
      Navigator.pop(context);
    }
  }

  void showMsg(String msg) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 10),
        action: SnackBarAction(
          label: "Aceptar",
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  }

  void _showSelectedDate() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1925, 1),
      lastDate: DateTime.now(),
    );
    if (newDate != null && newDate != _bornDate) {
      setState(() {
        _bornDate = newDate;
      });
    }
  }
}

extension on String {
  bool isValidEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }
}
