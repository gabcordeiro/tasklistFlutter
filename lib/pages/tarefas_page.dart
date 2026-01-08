import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/widgets/big_card_tarefa.dart';

class TarefasPage extends StatefulWidget {
  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  @override
  void initState() {
    super.initState();
    // O 'WidgetsBinding' garante que o Flutter termine de desenhar a tela
    // antes de pedir os dados para o Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyAppState>().carregarTarefasDoFirebase();
    });
  }

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
          for (final tarefaObj 
              in appState.listaTarefas) // tarefaObj agora é um objeto
            BigCardTarefa(
              // CORREÇÃO DO ERRO:
              // Usamos o ID único do banco como chave. Nunca repetirá.
              key: ValueKey(tarefaObj.id),

              // O texto a gente pega da propriedade titulo
              titulo: tarefaObj.titulo,
              onRemove: () {
                appState.removeTarefa(tarefaObj);
              },
            ),
        ],
      ),
    );
  }
}
