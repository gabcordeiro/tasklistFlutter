import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/widgets/big_card_tarefa.dart';


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
