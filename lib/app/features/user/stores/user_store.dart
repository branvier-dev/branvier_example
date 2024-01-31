import 'package:flutter/material.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';

/// Uma `Store` é uma classe que contém o estado compartilhado da aplicação.
///
/// Para todos os outros casos em que o estado é local (ou seja, não precisa ser
/// acessado por outras partes da aplicação), use apenas um StatefulWidget.
///
/// Nesse caso, a `UserStore` contém o estado do usuário logado.
///
class UserStore extends ChangeNotifier {
  UserStore(this._repository);

  /// A Classe Store deve apenas gerenciar estados.
  ///
  /// Todas as outras responsabilidades devem ser delegadas para outras classes,
  /// como o `UserRepository`.
  final UserRepository _repository;

  // Este é o estado que queremos compartilhar.
  late User _user;

  // Nosso estado é privado, pois só ações como `getUser` podem alterá-lo.
  User get user => _user;

  Future<void> getUser() async {
    _user = await _repository.getLoggedUser();

    // Toda vez que o estado muda (é setado, como acima fizemos), chamamos:
    notifyListeners();

    // Isso notificará todos os widgets que chamam `context.watch<UserStore>()`.
    // Eles serão reconstruídos com o novo estado do User.
  }
}
