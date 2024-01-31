import 'package:branvier_teste/app/features/auth/stores/auth_store.dart';
import 'package:branvier_teste/app/features/auth/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Esse é um widget que coloca um `Scaffold` em volta das rotas do user.
/// Esse Scaffold vai aparecer em todas as rotas que estiverem dentro do `ShellRoute`.
class UserShell extends StatelessWidget {
  const UserShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estoque de Produtos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.yellow,
              ),
              child: Text('Branvier'),
            ),
            ListTile(
              title: const Text('Sair'),
              onTap: () {
                context.read<AuthStore>().logoff();
                // Aqui, estamos usando o `GoRouter` para navegar para deslogar
                context.go(LoginPage.path);
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
