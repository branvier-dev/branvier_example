import 'package:branvier_teste/app/features/auth/views/register_page.dart';
import 'package:branvier_teste/app/features/products/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_async/flutter_async.dart';
import 'package:formx/formx.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../stores/auth_store.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  /// O caminho da rota usado pelo `GoRouter`. Ele é definido no `app_router.dart`.
  static const path = '/login';

  /// Essa é um ação local que valida o formulário e chama a ação de login.
  /// É uma boa prática manter ações de UI em métodos separados.
  ///
  /// Isso facilita a manutenção e a leitura do código.
  Future<void> onLogin(BuildContext context, FormxState state) async {
    // Se o formulário não for válido, não fazemos nada.
    if (!state.validate()) return;

    await context.read<AuthStore>().login(
          email: state.form['email'],
          password: state.form['password'],
        );

    // E, por fim, navegamos para a próxima página.
    // Usamos o context.mounted como boa prática para evitar erros.
    //
    // Imagine que o usuário saiu da página antes do `await` acima terminar.
    // Nesse caso, o widget não existe mais e o user pode estar em outra página.
    // Realizar a navegação nesse caso pode causar frustração ao usuário.
    //
    // Então o `context.mounted` nos garante que nosso widget ainda está vivo
    // e assim podemos navegar com segurança.
    if (context.mounted) context.go(HomePage.path);
  }

  Future<void> onRegister(BuildContext context) async {
    // Aqui, usamos o `GoRouter` para navegar para a página de registro.
    // O `GoRouter` é uma alternativa ao `Navigator` que é mais fácil de usar.
    // Você pode ver mais sobre ele em https://pub.dev/packages/go_router.
    context.go(RegisterPage.path);
  }

  /// No método `build`, usaremos apenas widgets para construir a UI.
  @override
  Widget build(BuildContext context) {
    /// O `Formx` é um widget que gerencia o estado do formulário.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Formx(
            /// O `onSubmitted` é chamado quando o usuário aperta 'enter'.
            onSubmitted: (state) => onLogin(context, state),
            builder: (context, state) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextFormxField(tag: 'email').required(),
                const TextFormxField(tag: 'password').obscure(),
                OutlinedButton(
                  onPressed: () => onLogin(context, state),
                  child: const Text('Login'),
                ).asAsync(),
                // O `asAsync` é um método de extensão do 'flutter_async' que
                // adiciona um loading ao carregar e mostra o erro se houver.

                ElevatedButton(
                  onPressed: () => onRegister(context),
                  child: const Text('Register'),
                ).asAsync(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
