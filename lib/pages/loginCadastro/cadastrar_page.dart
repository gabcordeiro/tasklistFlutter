import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/pages/loginCadastro/login_page.dart';

class CadastrarPage extends StatefulWidget {
  const CadastrarPage({super.key});

  @override
  State<CadastrarPage> createState() => _CadastrarPageState();
}

class _CadastrarPageState extends State<CadastrarPage> {
  final TextEditingController _controllerLogin = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();
  final TextEditingController _controllerRepetirSenha = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();

  @override
  void dispose() {
    _controllerLogin.dispose();
    _controllerSenha.dispose();
    _controllerRepetirSenha.dispose();
    _controllerEmail.dispose();
    super.dispose();
  }

  String? validatorSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Insira a senha desejada';
    }
    if (value.length != value.replaceAll(' ', '').length) {
      return 'Senha não deve conter espaços';
    }
    if (value.length <= 6) {
      return 'Senha deve ter mais de 6 caracteres';
    }
    return null;
  }

  String? validatorEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Esse campo é obrigatório';
    }

    if (value.contains(' ')) {
      return 'Email não deve conter espaços';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }

  String? validatorUser(String? value) {
    if (value == null || value.isEmpty) {
      return 'Esse campo é obrigatório';
    }
    if (value.length != value.replaceAll(' ', '').length) {
      return 'Usuario não deve conter espaços';
    }
    if (value.length <= 4) {
      return 'Usuario deve ter mais de 4 caracteres';
    }
    return null;
  }

  String? validarSenhaIgual(String? value) {
    if (_controllerSenha.text != _controllerRepetirSenha.text) {
      return 'As senhas não coincidem';
    }
        if (_controllerSenha.text == "") {
      return 'Escreva a senha acima primeiro';
    }
        if (_controllerRepetirSenha.text == "") {
      return 'Escreva a senha acima primeiro';
    }
    return null;
  }

  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text('Cadastre-se'),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _controllerLogin,
                      validator: validatorUser,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        helper: Text('Digite seu nome de usuário'),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _controllerSenha,
                      validator: validatorSenha,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        helper: Text('Digite sua senha'),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _controllerRepetirSenha,
                      validator: validarSenhaIgual,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Repita a senha',
                        helper: Text('Repita sua senha'),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _controllerEmail,
                      validator: validatorEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        helper: Text('Digite seu email'),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginPage(),
                              ),
                            );
                          },
                          icon: Icon(Icons.skip_previous),
                          label: Text('Voltar'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<MyAppState>().estaLogado = true;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginPage(),
                                ),
                              );
                            }
                          },
                          icon: Icon(Icons.save),
                          label: Text('Cadastrar'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
