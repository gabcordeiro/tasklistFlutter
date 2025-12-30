import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/pages/loginCadastro/cadastrar_page.dart';
import 'package:tasklist/pages/my_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controller = TextEditingController();


  final userEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? validatorUser(String? value) {
    if (value == null || value.isEmpty) {
      return 'Insira o nome de usuário';
    }
    if (value.length != value.replaceAll(' ', '').length) {
      return 'Nome de usuário não deve conter espaços';
    }
    if (value.length < 3) {
      return 'Nome de usuário deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  String? validatorSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Insira a senha';
    }
    if (value.length != value.replaceAll(' ', '').length) {
      return 'Senha não deve conter espaços';
    }
    if (value.length <= 6) {
      return 'Senha deve ter mais de 6 caracteres';
    }
    return null;
  }

Future<bool> login(String user, String password) async {
  await Future.delayed(Duration(seconds: 1));
  return user == 'teste' && password == '1234567';
}

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    bool estaLogado = context.watch<MyAppState>().estaLogado;

    return Scaffold(
      body: Container(
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                if (estaLogado)
                  const Text('Bem-vindo')
                else
                  const Text('Faça login'),
                TextFormField(
                  validator: validatorUser,
                  controller: userEditingController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    helper: Text('Digite seu nome de usuário'),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: validatorSenha,
                  controller: passwordEditingController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    helper: Text('Digite sua senha'),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CadastrarPage(),
                          ),
                        );
                      },
                      icon: Icon(Icons.add),
                      label: Text('Cadastrar'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<MyAppState>().estaLogado = true;
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => MyHomePage()));
                        }
                      },
                      icon: Icon(Icons.login),
                      label: Text('Entrar'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
