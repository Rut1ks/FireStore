import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore/profile.dart';
import 'package:firestore/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var instance = FirebaseFirestore.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Material App Bar'),
          ),
          body: AuthForm()),
    );
  }
}

class AuthForm extends StatefulWidget {
  AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool isReg = false;

  late TextEditingController _emailController,
      _passwordController,
      _nameController,
      _surnameController,
      _patrController,
      _ageController;
  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _patrController = TextEditingController();
    _ageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _patrController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<DocumentReference?> logIn() async {
    var logedUser = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: _emailController.text.trim())
        .where("password", isEqualTo: _passwordController.text.trim())
        .get();
    if (logedUser.docs.isEmpty) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: Text("Пользователь не найден, повторите попытку"),
              ));
      return null;
    } else {
      return logedUser.docs.first.reference;
    }
  }

  Future<DocumentReference?> signIn() async {
    var logedUser = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: _emailController.text.trim())
        .count()
        .get();
    if (logedUser.count != 0) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: Text(
                    "Пользователь с данным адресом электронной почты существует, повторите попытку"),
              ));
    }
    var currentUser = UserModel(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        surname: _surnameController.text.trim(),
        patronymic: _patrController.text.trim());
    var reference = await FirebaseFirestore.instance
        .collection("users")
        .add(currentUser.toMap());

    return reference;
  }

  Future<void> validateForm() async {
    if (_formKey.currentState!.validate()) {
      DocumentReference? user;
      if (isReg) {
        user = await signIn();
      } else {
        user = await logIn();
      }

      if (user != null) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => ProfilePage(
                  user: user!,
                )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isReg)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Регистрация",
                    style: TextStyle(fontSize: 30),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Авторизация",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) =>
                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value ?? "")
                          ? null
                          : "Неверный адрес электронной почты",
                  controller: _emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "E-mail"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) => (value?.trim().length ?? 0) < 5
                      ? "Пароль должен быть длинее 5 символов"
                      : null,
                  controller: _passwordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "Пароль"),
                ),
              ),
              if (isReg)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) => (value?.trim().length ?? 0) == 0
                        ? "Фамилия не должна быть пустой"
                        : null,
                    controller: _surnameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: "Фамилия"),
                  ),
                ),
              if (isReg)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) => (value?.trim().length ?? 0) == 0
                        ? "Имя не должна быть пустое"
                        : null,
                    controller: _nameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: "Имя"),
                  ),
                ),
              if (isReg)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _patrController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: "Отчество"),
                  ),
                ),
              if (isReg)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _ageController,
                    validator: (value) => (int.tryParse(value ?? "0") ?? 0) < 0
                        ? "Возраст должен быть больше нуля"
                        : null,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: "Возраст"),
                  ),
                ),
              if (!isReg)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: validateForm, child: Text("Войти")),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: validateForm,
                      child: Text("Зарегистрироваться")),
                ),
              TextButton(
                  onPressed: () => setState(() {
                        isReg = !isReg;
                      }),
                  child: Text(isReg ? "К авторизации" : "К регистрации"))
            ],
          ),
        ),
      ),
    );
  }
}
