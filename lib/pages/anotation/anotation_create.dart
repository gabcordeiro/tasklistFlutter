import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/app/my_app.dart';

class AnotationCreate extends StatefulWidget {
  const AnotationCreate({super.key});

  @override
  State<AnotationCreate> createState() => _AnotationCreateState();
}

class _AnotationCreateState extends State<AnotationCreate> {
  TextEditingController _TextController = TextEditingController();

  @override
  void dispose() {
    _TextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SizedBox(
                width: 400,
                child: Form(
                    child: Column(children: [
                  TextField(
                    controller: _TextController,
                    decoration: InputDecoration(
                      labelText: 'Digite sua anotação',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Lógica para salvar a anotação
                      context
                          .read<MyAppState>()
                          .salvarAnotation(_TextController.text);
                      _TextController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anotação guardada!')),
                      );
                    },
                    child: Text('Salvar Anotação'),
                  ),
                ])))));
  }
}
