import 'package:branvier_teste/app/features/auth/stores/auth_store.dart';
import 'package:branvier_teste/app/features/products/stores/product_store.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app/features/auth/views/login_page.dart';
import 'app/features/auth/views/register_page.dart';
import 'app/features/products/views/home_page.dart';
import 'app/features/products/views/product_page.dart';
import 'app/features/user/stores/user_store.dart';
import 'app/features/user/views/user_shell.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
      routes: [
        // Aqui, estamos aninhando rotas.
        // Com isso haverá uma animação de pop quando a rota voltar para login.
        GoRoute(
          path: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
      ],
    ),
    ShellRoute(
      // O `ShellRoute` é um tipo especial de rota que permite que você coloque
      // um widget em torno de suas rotas.
      //
      // Nesse caso, usaremos o widget `MultiProvider`.
      //
      // Assim, apenas as rotas daqui terão acesso a UserStore!
      //
      builder: (context, state, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => UserStore(ctx.read())),
          ChangeNotifierProvider(create: (ctx) => ProductStore(ctx.read())),
        ],
        child: UserShell(child: child),
      ),
      // E aqui estão as rotas que estarão dentro do `ShellRoute`.
      routes: [
        GoRoute(
            path: '/',
            redirect: (context, state) {
              // Aqui, estamos redirecionando para a rota de login caso o usuário não
              // esteja logado.
              //
              // O `context.read<UserStore>().isLogged` é um getter que retorna `true`
              // caso o usuário esteja logado.
              if (!context.read<AuthStore>().isLogged) return '/login';

              // Caso contrário, não precisamos redirecionar para lugar nenhum:
              return null;
            },
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: 'product/:id',
                builder: (context, state) {
                  // Aqui, estamos pegando o id da rota e passando para a página.
                  final id = int.parse(state.pathParameters['id']!);
                  return ProductPage(id: id);
                },
              ),
            ]),
      ],
    )
  ],
);
