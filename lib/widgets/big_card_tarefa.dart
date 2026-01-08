import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';


class BigCardTarefa extends StatelessWidget {
  const BigCardTarefa({
    super.key,
    required this.titulo, // Recebe apenas o texto
    required this.onRemove, // Recebe a função de remover
  });

  final String titulo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              onPressed: onRemove, // Chama a função passada por parâmetro
              padding: const EdgeInsets.all(10),
              icon: const Icon(Icons.remove_circle),
            ),
            Text(
              titulo,
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}