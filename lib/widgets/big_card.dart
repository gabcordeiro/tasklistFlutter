import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

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