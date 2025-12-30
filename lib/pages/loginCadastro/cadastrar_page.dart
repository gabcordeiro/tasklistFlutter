import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/pages/loginCadastro/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tela de Cadastro de novos usuários.
class CadastrarPage extends StatefulWidget {
  const CadastrarPage({super.key});

  @override
  State<CadastrarPage> createState() => _CadastrarPageState();
}

class _CadastrarPageState extends State<CadastrarPage> {
  // Controladores de texto para capturar o que o usuário digita
  final TextEditingController _controllerLogin = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();
  final TextEditingController _controllerRepetirSenha = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerNome = TextEditingController();

  // Chave global para validar o formulário
  final _formKey = GlobalKey<FormState>();

  /// Método chamado quando a tela é destruída (fechada).
  /// Serve para limpar a memória usada pelos controladores.
  @override
  void dispose() {
    _controllerLogin.dispose();
    _controllerSenha.dispose();
    _controllerRepetirSenha.dispose();
    _controllerEmail.dispose();
    _controllerNome.dispose();
    super.dispose();
  }

  // --- VALIDADORES (Regras dos campos) ---

  String? validatorSenha(String? value) {
    if (value == null || value.isEmpty) return 'Insira a senha desejada';
    if (value.contains(' ')) return 'Senha não deve conter espaços';
    if (value.length <= 6) return 'Senha deve ter mais de 6 caracteres';
    return null;
  }
String? validatorNome(String? value) {
    if (value == null || value.isEmpty) return 'Esse campo é obrigatório';
    if (value.contains(' ')) return 'Nome não deve conter espaços';
    if (value.length <= 4) return 'Nome deve ter mais de 4 caracteres';
    return null;
  }
  String? validatorEmail(String? value) {
    if (value == null || value.isEmpty) return 'Esse campo é obrigatório';
    if (value.contains(' ')) return 'Email não deve conter espaços';
    
    // Expressão regular (Regex) para validar formato de e-mail padrão
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Email inválido';
    
    return null;
  }

  String? validatorUser(String? value) {
    if (value == null || value.isEmpty) return 'Esse campo é obrigatório';
    if (value.contains(' ')) return 'Usuario não deve conter espaços';
    if (value.length <= 4) return 'Usuario deve ter mais de 4 caracteres';
    return null;
  }

  String? validarSenhaIgual(String? value) {
    if (_controllerSenha.text != _controllerRepetirSenha.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  /// Função principal que executa a lógica de cadastro no Firebase.
  Future<void> _realizarCadastro() async {
    // 1. Verifica se o formulário é válido (se todos os campos estão ok)
    if (_formKey.currentState!.validate()) {
      
      // Mostra o diálogo de carregamento (Loading...)
      showDialog(
        context: context,
        barrierDismissible: false, // Impede clicar fora para fechar
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // 2. Tenta criar o usuário no Firebase (Operação demorada - await)
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _controllerEmail.text.trim(), // .trim() remove espaços nas pontas
          password: _controllerSenha.text,
        );



        String uuid = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uuid).set({
          'login': _controllerLogin.text,
          'nome': _controllerNome.text,
          'email': _controllerEmail.text.trim(),
        }); 


        await userCredential.user!.updateDisplayName(_controllerLogin.text); 
        // --- CHECAGEM DE SEGURANÇA (mounted) ---
        // Verifica se a tela ainda existe antes de tentar fechá-la ou navegar.
        // Isso resolve o aviso "Don't use BuildContext across async gaps".
        if (!mounted) return;

        // Fecha o diálogo de loading
        Navigator.of(context).pop();

        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Atualiza o estado global do app (via Provider)
        context.read<MyAppState>().estaLogado = true;

        // Navega para a tela de Login (substituindo a tela atual)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );

      } catch (e) {
        // Se der erro, precisamos fechar o loading primeiro
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        // --- TRATAMENTO DE ERRO BLINDADO PARA WEB ---
        final erroTexto = e.toString();
        String mensagem = 'Erro desconhecido.';

        if (erroTexto.contains('weak-password')) {
          mensagem = 'Senha muito fraca.';
        } else if (erroTexto.contains('email-already-in-use')) {
          mensagem = 'Email já cadastrado.';
        } else if (erroTexto.contains('invalid-email')) {
          mensagem = 'Email inválido.';
        } else {
          mensagem = erroTexto; // Mostra o erro técnico caso não seja um dos acima
        }

        // Verifica mounted novamente antes de mostrar o SnackBar de erro
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          child: Center(
            // SingleChildScrollView evita erro de tela cortada se o teclado subir
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Cadastre-se',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        
                        // Campo Usuário
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _controllerLogin,
                            validator: validatorUser,
                            decoration: const InputDecoration(
                              labelText: 'Usuário',
                              helperText: 'Digite seu nome de usuário',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Campo Nome
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _controllerNome,
                            validator: validatorNome,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              helperText: 'Digite seu nome completo',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Campo Senha
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _controllerSenha,
                            validator: validatorSenha,
                            obscureText: true, // Esconde a senha
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              helperText: 'Digite sua senha',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Campo Repetir Senha
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _controllerRepetirSenha,
                            validator: validarSenhaIgual,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Repita a senha',
                              helperText: 'Confirme sua senha',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Campo Email
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _controllerEmail,
                            validator: validatorEmail,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              helperText: 'Digite seu email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Botões de Ação
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Voltar'),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton.icon(
                              // Chama a função separada que criamos acima
                              onPressed: _realizarCadastro,
                              icon: const Icon(Icons.save),
                              label: const Text('Cadastrar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
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
        ),
      ),
    );
  }
}