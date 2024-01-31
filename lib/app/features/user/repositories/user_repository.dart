import 'package:branvier_teste/app/services/api_service.dart';

import '../models/user.dart';

class UserRepository {
  const UserRepository(this.api);
  final ApiService api;

  Future<User> getUserById(int id) async {
    return User(
      id: id,
      name: 'John Doe',
      email: '$id@email.com',
    );
  }

  Future<User> getLoggedUser() async {
    return const User(
      id: 1,
      name: 'John Doe',
      email: 'logged@email.com',
    );
  }
}
