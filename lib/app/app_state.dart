import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var listaTarefas = <String>[];


  String usuario = 'Usuário';
  
  bool estaLogado = false;

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
