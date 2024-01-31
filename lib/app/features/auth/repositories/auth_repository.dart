import 'package:branvier_teste/app/features/auth/models/register_dto.dart';
import 'package:branvier_teste/app/services/api_service.dart';

import '../models/login_dto.dart';

/// O Repositório é a camada que faz a comunicação entre a aplicação e o servidor.
///
/// Ele só pode ser chamado por uma `Store` ou um `UseCase`.
///
class AuthRepository {
  const AuthRepository(this.api);

  /// Idealmente, você chamaria um serviço http para fazer as requisições.
  ///
  /// Ex: `api.post('http://api.com/login', data: dto.toMap());`
  ///
  final ApiService api;

  /// Faz login e retorna um token de autenticação.
  Future<String> login(LoginDto dto) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'token-1ouD31ue12Foiddpmf9';
  }

  /// Registra um novo usuário e retorna um token de autenticação.
  Future<String> register(RegisterDto dto) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'token-1ouD31ue12Foiddpmf9';
  }
}
