import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key, required this.user}) : super(key: key);
  DocumentReference user;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;
  late TextEditingController _emailController,
      _passwordController,
      _nameController,
      _surnameController,
      _patrController,
      _ageController;
  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    widget.user.get().then((value) {
      setState(() {
        _user = UserModel.fromMap(value.data()! as Map<String, dynamic>);
        _emailController.text = _user!.email;
        _passwordController.text = _user!.password;
        _nameController.text = _user!.name;
        _surnameController.text = _user!.surname;
        _patrController.text = _user?.patronymic ?? "";
        _ageController.text = _user!.age.toString();
      });
    });
    widget.user.snapshots().listen((event) {
      setState(() {
        _user = UserModel.fromMap(event.data()! as Map<String, dynamic>);
        _emailController.text = _user!.email;
        _passwordController.text = _user!.password;
        _nameController.text = _user!.name;
        _surnameController.text = _user!.surname;
        _patrController.text = _user?.patronymic ?? "";
        _ageController.text = _user!.age.toString();
      });
    });
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

  void deleteUser() {
    widget.user.delete();
    Navigator.pop(context);
  }

  void validateForm() async {
    if (_formKey.currentState!.validate()) {
      var currentUser = UserModel(
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          surname: _surnameController.text.trim(),
          patronymic: _patrController.text);
      widget.user.set(currentUser.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Профиль",
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _patrController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Отчество"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _ageController,
                        validator: (value) =>
                            (int.tryParse(value ?? "0") ?? 0) < 0
                                ? "Возраст должен быть больше нуля"
                                : null,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: "Возраст"),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: validateForm, child: Text("Изменить")),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: deleteUser, child: Text("Удалить")),
                      ),
                    ],
                  ),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Выйти"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
