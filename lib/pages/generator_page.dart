import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/widgets/big_card.dart';


class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
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
                  //appState.addTarefa(_controller.text);
                  appState.salvarTarefaNoFirebase(_controller.text);
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
