import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';


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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      appState.removeTarefa(texto);
                    },
                      padding: EdgeInsets.all(10),
                    icon: Icon(Icons.remove_circle),
                  ),
                  Text(texto,
                    style: style,
                    ),               
                ],        
                ),
      ),
    );
  }
}
