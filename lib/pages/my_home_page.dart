import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/pages/favorites_page.dart';
import 'package:tasklist/pages/generator_page.dart';
import 'package:tasklist/pages/loginCadastro/login_page.dart';
import 'package:tasklist/pages/tarefas_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  Future<void> _logOut() async {
    if (FirebaseAuth.instance.currentUser != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Desconectado!'), backgroundColor: Colors.green),
        );

        context.read<MyAppState>().estaLogado = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } catch (e) {
        if (mounted && Navigator.canPop(context)) Navigator.of(context).pop();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deslogar'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0: page = GeneratorPage(); break;
      case 1: page = FavoritesPage(); break;
      case 2: page = TarefasPage(); break;
      default: throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isExtended = constraints.maxWidth >= 600;

        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: isExtended,
                  // --- SEÇÃO DE PERFIL NO TOPO ---
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        if (isExtended) ...[
                          const SizedBox(height: 8),
                          const Text("Meu Perfil", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                tooltip: "Editar Perfil",
                                onPressed: () {
                                  // Lógica para editar perfil aqui
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout, size: 20, color: Colors.red),
                                tooltip: "Sair",
                                onPressed: _logOut,
                              ),
                            ],
                          ),
                        ] else ...[
                          // Quando a barra está pequena, mostramos apenas um botão de sair rápido
                          IconButton(
                            icon: const Icon(Icons.logout, size: 20),
                            onPressed: _logOut,
                          ),
                        ],
                      ],
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Palavras Salvas'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.task),
                      label: Text('Tarefas Salvas'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}