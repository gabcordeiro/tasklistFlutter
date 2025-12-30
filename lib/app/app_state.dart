import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Tarefa {
  final String id; // O código único do Firestore (Ex: 4qIKyw...)
  final String titulo; // O texto visível (Ex: asd)

  Tarefa({required this.id, required this.titulo});
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var listaTarefas = <Tarefa>[];

  MyAppState() {
    // Assim que o Provider nasce, ele tenta carregar os dados
    carregarTarefasDoFirebase();
  }

  String usuario = 'Usuário';

  bool estaLogado = false;

//firebase
// No seu MyAppState
// No seu MyAppState
  Future<void> salvarTarefaNoFirebase(String textoTarefa) async {
    if (textoTarefa.isEmpty) return; // Evita salvar texto vazio

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('tarefas')
          .doc();

      await docRef.set({
        'titulo': textoTarefa,
        'criadoEm': Timestamp.now(),
        'concluida': false,
      });

      // --- AMARRAÇÃO IMPORTANTE ---
      // Após salvar na nuvem, adicionamos na lista local para a tela atualizar na hora!
      listaTarefas.add(textoTarefa.isNotEmpty
          ? Tarefa(id: docRef.id, titulo: textoTarefa)
          : Tarefa(id: docRef.id, titulo: 'Sem título'));
      notifyListeners();
    }
  }

  Future<void> carregarTarefasDoFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('tarefas')
          .orderBy('criadoEm', descending: true)
          .get();

      listaTarefas.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // MUDANÇA 2: Criamos o objeto Tarefa com ID e Título
        listaTarefas.add(
          Tarefa(
            id: doc.id, // <--- AQUI ESTÁ A MÁGICA DA UNICIDADE
            titulo: data['titulo'] ?? 'Sem título',
          ),
        );
      }
      notifyListeners();
    }
  }

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

  void addTarefaLocal(Tarefa tarefa) {
    listaTarefas.add(tarefa);
    notifyListeners();
  }

  void reorderTarefa(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = listaTarefas.removeAt(oldIndex);
    listaTarefas.insert(newIndex, item);
    notifyListeners();
  }
}
