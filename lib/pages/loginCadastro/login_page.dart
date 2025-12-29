import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/pages/loginCadastro/cadastrar_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    bool estaLogado = context.watch<MyAppState>().estaLogado;

    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              if (estaLogado)
                const Text('Bem-vindo')
              else
                const Text('Faça login'),
              Form(
                  child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  helper: Text('Digite seu nome de usuário'),
                ),
              )),
              SizedBox(height: 20),
              Form(
                  child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  helper: Text('Digite sua senha'),
                ),
              )),
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
                    onPressed: () {},
                    icon: Icon(Icons.login),
                    label: Text('Entrar'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
