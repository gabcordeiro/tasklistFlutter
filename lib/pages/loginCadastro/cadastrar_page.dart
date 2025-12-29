import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';


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

   String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length != value.replaceAll(' ', '').length) {
      return 'Username must not contain any spaces';
    }
    if (int.tryParse(value[0]) != null) {
      return 'Username must not start with a number';
    }
    if (value.length <= 2) {
      return 'Username should be at least 3 characters long';
    }
    return null;
  }

  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              Form(child: Column(
                children: [
              Text('Cadastre-se'),
              SizedBox(height: 20),
              TextFormField(
                  controller: _controllerLogin,
                  validator: validator,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    helper: Text('Digite seu nome de usuário'),
                  ), 
                  ),
              SizedBox(height: 20),
              TextFormField(
                  controller: _controllerSenha,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    helper: Text('Digite sua senha'),
                  ), 
                  ),
              SizedBox(height: 20),
              TextFormField(
                  controller: _controllerRepetirSenha,
                  decoration: const InputDecoration(
                    labelText: 'Repita a senha',
                    helper: Text('Repita sua senha'),
                  ), 
                  ),
              SizedBox(height: 20),
              TextFormField(
                  controller: _controllerEmail,
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
                  context.read<MyAppState>().estaLogado = true;
                },
                icon: Icon(Icons.skip_previous),
                label: Text('Voltar'),
              ),              
              SizedBox(width: 20),

                    ElevatedButton.icon(
                onPressed: () {
                  context.read<MyAppState>().estaLogado = true;
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
