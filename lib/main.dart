import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 43, 255, 53)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var listaTarefas = <String>[];


  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
//tarefas
    void removeTarefa(String palavra) {
    listaTarefas.remove(palavra);
    notifyListeners();
  }
  void addTarefa(String palavra) {
    listaTarefas.add(palavra);
    notifyListeners();
  }

  void reorderTarefa(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = listaTarefas.removeAt(oldIndex);
    listaTarefas.insert(newIndex, item);
    notifyListeners();
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;     // ← Add this property.
  



  @override
  
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = TarefasPage(); 
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
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
                  selectedIndex: selectedIndex,    // ← Change to this.
                  onDestinationSelected: (value) {
                     setState(() {
                      selectedIndex = value;
                    });
        
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    final theme = Theme.of(context); 
    final style = theme.textTheme.bodyMedium!.copyWith(
  color: theme.colorScheme.onSecondaryFixed,
  fontSize: 20, );


    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Salvar'),
              ),

              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Proximo'),
              ),
            
            ],
          ),
          SizedBox(height: 40),
          SizedBox(
            width: 300, // largura desejada
            child: Text("Salvar Palavra", textAlign: TextAlign.center)),
          
          SizedBox(height: 10),
          SizedBox(
            width: 300, // largura desejada
            child: TextField(
              controller: _controller,
              style: style,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
                onPressed: () {
                  appState.addTarefa(_controller.text);
                  _controller.clear();
                },
                icon: Icon(Icons.save),
                label: Text('Salvar'),
              ),
        ],
      ),
    );
  }
}




class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();


    return Center(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Voce tem ${appState.favorites.length} palavras favoritas.'),
          ...appState.favorites.map(
            (favorites) => BigCardFavorite(texto: favorites),
          ),
          SizedBox(height: 30),

        ],
      ),
    );
  }
}

class TarefasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();


    return Center(
      child: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
      appState.reorderTarefa(oldIndex, newIndex);
    },
        padding: const EdgeInsets.all(16),
        children: [
        for (final tarefa in appState.listaTarefas)
          BigCardTarefa(
            key: ValueKey(tarefa), // chave única obrigatória
            texto: tarefa,
          ),
      ],
      ),
    );
  }
}


class BigCardTarefa extends StatelessWidget {
  
  const BigCardTarefa({
    super.key,
    required this.texto,
  });

  final String texto;

  @override
  Widget build(BuildContext context) {
      final theme = Theme.of(context); 
      var appState = context.watch<MyAppState>();
      final style = theme.textTheme.bodyMedium!.copyWith(
  color: theme.colorScheme.onSecondaryFixed,
  fontSize: 32,
  
);    
    return Card(
      child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    appState.removeTarefa(texto);
                  },
                  icon: Icon(Icons.remove_circle),
                ),
                Text(texto,
                  style: style,
                  
                  ),
                  
                
              ],
              ),
    );
  }
}

class BigCardFavorite extends StatelessWidget {
  
  const BigCardFavorite({
    super.key,
    required this.texto,
  });

  final WordPair texto;

  @override
  Widget build(BuildContext context) {
      final theme = Theme.of(context); 
      var appState = context.watch<MyAppState>();
      final style = theme.textTheme.bodyMedium!.copyWith(
  color: theme.colorScheme.onSecondaryFixed,
  fontSize: 32,
  
);    
    return Card(
      child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    appState.removeFavorite(texto);
                  },
                  icon: Icon(Icons.remove_circle),
                ),
                Text(texto.asString,
                  style: style,
                  
                  ),
                  
                
              ],
              ),
    );
  }
}

class BigCard extends StatelessWidget {
  
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
      final theme = Theme.of(context); 
      final style = theme.textTheme.bodyMedium!.copyWith(
  color: theme.colorScheme.onPrimary,
  fontSize: 32,
  
);    
    return Card(
        color: theme.colorScheme.secondary,    // ← 
        child: Padding(
        padding: const EdgeInsets.all(30),
         // ↓ Make the following change.
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      )
    );
  }
}