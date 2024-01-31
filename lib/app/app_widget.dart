import 'package:branvier_teste/app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

/// O `AppWidget` é o widget principal da aplicação.
/// Ele é o ponto de entrada da aplicação.
/// Aqui você pode definir temas, rotas, e outros aspectos da aplicação.
class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    /// O `Formx` é um widget que permite que você modifique a decoração de todos
    /// os `FormxField` que estão dentro dele.
    return Formx(
      decorationModifier: (tag, decoration) {
        return decoration?.copyWith(
          labelText: tag,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
      child: MaterialApp.router(
        routerConfig: appRouter,
        theme: ThemeData(
          /// O esquema de cores é uma forma de definir cores que serão usadas
          /// em toda a aplicação.
          ///
          /// Sempre que for colorir algo, venha aqui antes.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        ),
      ),
    );
  }
}
