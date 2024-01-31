import 'package:branvier_teste/app/features/auth/models/register_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_async/flutter_async.dart';
import 'package:formx/formx.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../stores/auth_store.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  /// O caminho da rota passa pelo 'login' antes, como definido no `app_router.dart`.
  static const path = '/login/register';

  Future<void> onRegister(BuildContext context, FormxState state) async {
    // Se o formulário não for válido, não fazemos nada.
    if (!state.validate()) return;

    // O `RegisterDto` é uma classe que representa os dados que serão
    // transferidos da aplicação paro o servidor.
    //
    // Usaremos o `fromMap` para converter o `state.form` em um `RegisterDto`.
    final dto = RegisterDto.fromMap(state.form);

    // Agora, chamamos a ação de registro.
    await context.read<AuthStore>().register(dto);

    // E, por fim, navegamos para a próxima página.
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: Formx(
          /// O `onSubmitted` é chamado quando o usuário aperta 'enter'.
          onSubmitted: (state) => onRegister(context, state),
          builder: (context, state) => Column(
            children: [
              const TextFormxField(tag: 'name').required(),
              const TextFormxField(tag: 'email').required(),
              const TextFormxField(tag: 'gender'),
              const TextFormxField(tag: 'telephone'),
              const TextFormxField(tag: 'password').obscure(),
              const TextFormxField(tag: 'confirm_password').obscure(),
              ElevatedButton(
                onPressed: () => onRegister(context, state),
                child: const Text('Register'),
              ).asAsync(),
              // O `asAsync` é um método de extensão do 'flutter_async' que
              // adiciona um loading ao carregar e mostra o erro se houver.
            ],
          ),
        ),
      ),
    );
  }
}
