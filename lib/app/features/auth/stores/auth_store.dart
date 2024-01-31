import 'package:branvier_teste/app/features/auth/models/register_dto.dart';
import 'package:flutter/foundation.dart';

import '../models/login_dto.dart';
import '../repositories/auth_repository.dart';

class AuthStore extends ChangeNotifier {
  AuthStore(this._repository);
  final AuthRepository _repository;

  String? _token;

  String? get token => _token;

  bool get isLogged => _token != null;

  Future<void> login({required String email, required String password}) async {
    final dto = LoginDto(email: email, password: password);

    _token = await _repository.login(dto);
    notifyListeners();
  }

  Future<void> register(RegisterDto dto) async {
    _token = await _repository.register(dto);
    notifyListeners();
  }

  void logoff() => _token = null;
}
