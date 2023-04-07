import 'dart:convert';

class UserModel {
  String name;
  int age;
  String email;
  String password;
  String surname;
  String? patronymic;
  UserModel({
    required this.name,
    required this.age,
    required this.email,
    required this.password,
    required this.surname,
    this.patronymic,
  });

  UserModel copyWith({
    String? name,
    int? age,
    String? email,
    String? password,
    String? surname,
    String? patronymic,
  }) {
    return UserModel(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      password: password ?? this.password,
      surname: surname ?? this.surname,
      patronymic: patronymic ?? this.patronymic,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      
      'name': name,
      'age': age,
      'email': email,
      'password': password,
      'surname': surname,
      'patronymic': patronymic,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(

      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      surname: map['surname'] ?? '',
      patronymic: map['patronymic'],
    );
  }
}
