import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService  {
 

  String nomeUsuario = 'carregando...';
  Future<String> fetchUserName() async {
    // Lógica para pegar o nome do usuário do Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        nomeUsuario = doc['nome'] ?? 'Usuário';
        return nomeUsuario;
      }else{
        return 'Usuário';
      }
    } else {
      return 'Usuário';
    }
  }



}
