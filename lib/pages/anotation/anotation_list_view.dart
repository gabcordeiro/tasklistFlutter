import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/widgets/big_card_tarefa.dart';

class AnotationList extends StatefulWidget {
  const AnotationList({super.key});

  @override
  State<AnotationList> createState() => _AnotationListState();
}

class _AnotationListState extends State<AnotationList> {


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
      return Scaffold( body:Center(child: SizedBox(
        width: 400,
        child:Column(
          children: [
            Text('Lista de Anotações'),
            // Aqui você pode adicionar a lógica para listar as anotações salvas
            Expanded(child:
            ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                appState.reorderTarefa(oldIndex, newIndex);
              },
              children: [for (final anotation in appState.listaAnotation)
                BigCardTarefa(key: ValueKey(anotation.id),titulo: anotation.titulo, onRemove: () {  }, )
              ]
            ),
        ),],
        ),
      ),
      ));
  }
}