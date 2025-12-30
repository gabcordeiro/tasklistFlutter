import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/pages/loginCadastro/cadastrar_page.dart';

/// Tela responsável pelo login do usuário utilizando E-mail e Senha.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Chave global para identificar e validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar o texto digitado nos campos
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Variável de estado para controlar o loading (rodinha girando)
  bool _isLoading = false;

  /// Libera a memória dos controladores quando a tela é fechada.
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Função assíncrona que realiza a tentativa de login no Firebase.
  Future<void> _fazerLogin() async {
    // 1. Valida se os campos foram preenchidos corretamente (regras do validator)
    if (!_formKey.currentState!.validate()) return;

    // 2. Atualiza a tela para mostrar o carregamento
    setState(() => _isLoading = true);

    try {
      // 3. Tenta fazer o login no Firebase (Isso demora, por isso o await)
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text
            .trim(), // .trim() remove espaços vazios acidentais
        password: _senhaController.text,
      );

      // --- CORREÇÃO DO ASYNC GAP (O Erro que você viu) ---
      // Verificamos se a tela ainda existe (mounted) após a espera do await acima.
      // Se a tela foi fechada, 'mounted' será false e o código para aqui.
      if (!mounted) return;

      // 4. Se chegou aqui, a tela ainda existe. Podemos usar o context com segurança.

      // Atualiza o estado global (opcional, mas útil para seu Provider)
      context.read<MyAppState>().estaLogado = true;

      // Navega para a tela inicial, removendo a tela de login da pilha (para não voltar ao login)
      // Ajuste para a rota correta da sua Home se necessário.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      // --- TRATAMENTO DE ERRO ---

      // Converte o erro para String para evitar bugs de tipagem no Web
      final erroTexto = e.toString();
      String mensagem = 'Erro ao fazer login.';

      // Verifica palavras-chave no texto do erro para dar uma mensagem amigável
      if (erroTexto.contains('user-not-found') ||
          erroTexto.contains('invalid-credential')) {
        mensagem = 'E-mail ou senha incorretos.';
      } else if (erroTexto.contains('invalid-email')) {
        mensagem = 'O e-mail digitado não é válido.';
      } else if (erroTexto.contains('wrong-password')) {
        mensagem = 'Senha incorreta.';
      } else if (erroTexto.contains('too-many-requests')) {
        mensagem = 'Muitas tentativas. Tente novamente mais tarde.';
      } else if (erroTexto.contains('network-request-failed')) {
        mensagem = 'Verifique sua conexão com a internet.';
      }

      // --- CORREÇÃO DO ASYNC GAP NO CATCH ---
      // Antes de mostrar o SnackBar (que precisa de context), verificamos mounted novamente
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red, // Vermelho para erro
          behavior: SnackBarBehavior.floating, // Fica mais bonito flutuando
        ),
      );
    } finally {
      // O bloco 'finally' executa sempre, dando erro ou sucesso.
      // Aqui usamos para parar o loading.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            width: 400,
            child: Center(
              // SingleChildScrollView evita erro de pixel overflow se o teclado subir
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_person,
                          size: 80, color: Colors.deepPurple),
                      const SizedBox(height: 20),
            
                      // Campo de E-mail
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType
                            .emailAddress, // Teclado otimizado para email
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite seu e-mail';
                          }
                          if (!value.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
            
                      const SizedBox(height: 16),
            
                      // Campo de Senha
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true, // Esconde a senha com bolinhas
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite sua senha';
                          }
                          if (value.length < 6) return 'Senha muito curta';
                          return null;
                        },
                      ),
            
                      const SizedBox(height: 24),
            
                      // Botão de Entrar (mostra loading ou o botão normal)
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity, // Botão ocupa a largura toda
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _fazerLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('ENTRAR'),
                              ),
                            ),
                            const SizedBox(height: 16),
            
                            // Link para tela de cadastro
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const CadastrarPage()),
                                );
                              },
                              child: const Text('Não tem conta? Cadastre-se'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
