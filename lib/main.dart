import 'package:branvier_teste/app/features/auth/repositories/auth_repository.dart';
import 'package:branvier_teste/app/features/products/repositories/product_repositories.dart';
import 'package:branvier_teste/app/features/user/repositories/user_repository.dart';
import 'package:branvier_teste/app/services/api_service.dart';
import 'package:branvier_teste/app/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/features/auth/stores/auth_store.dart';

void main() {
  runApp(
    /// O MultiProvider é um widget que permite que você defina vários providers.
    /// Isso é útil para evitar a necessidade de aninhar vários providers.
    ///
    /// Essa prática de por uma dependência dentro da outra, através do
    /// construtor da classe é chamada de 'injeção de dependência'.
    ///
    /// O provider é um "service locator", pois ele permite que você registre
    /// e recupere dependências de maneira centralizada, através do `context`.
    ///
    /// Cada camada tem sua própria responsabilidade e não deve saber como
    /// as outras camadas funcionam. Chamamos isso de 'separação de conceitos'.
    ///
    /// Podemos recuperar essas dependências em qualquer lugar
    /// da aplicação usando o `context.read<T>()`. Essa prática é chamada de
    /// 'inversão de controle'.
    ///
    /// Além disso o `Provider` facilita a atualização da UI quando o estado
    /// muda. Isso é feito através do `ChangeNotifier` e do `context.watch<T>()`.
    MultiProvider(
      // Aqui, consideramos todas essas dependências como 'globais'. Pois podem
      // ser acessadas de qualquer lugar da aplicação.
      providers: [
        // Services
        //
        // Aqui estão as fontes de dados da aplicação. Seja um banco de dados,
        // uma API, ou qualquer outra coisa, como sensores, câmera, etc.
        //
        // Normalmente, esses serviços são abstraídos por uma interface pois
        // vem de packages de terceiros e não queremos depender deles diretamente.
        Provider(create: (context) => ApiService()),

        // Repositories
        //
        // Os repositórios orquestram as fontes e envio de dados.
        // Transformam os dados vindos dos serviços em 'modelos de domínio'.
        Provider(create: (context) => AuthRepository(context.read())),
        Provider(create: (context) => UserRepository(context.read())),
        Provider(create: (context) => ProductRepository(context.read())),

        // Stores
        //
        // As stores são responsáveis por gerenciar o estado da aplicação.
        // Usamos um provider especial chamado `ChangeNotifierProvider`, ele
        // é capaz de notificar a UI quando o estado muda, através do:
        // `context.watch<T>()`.
        ChangeNotifierProvider(create: (context) => AuthStore(context.read())),

        // Observe que a `UserStore` não está aqui. Isso é intencional.
        // Queremos que ela seja acessível apenas quando o usuário estiver logado.
        //// ChangeNotifierProvider(create: (context) => UserStore(context.read())),

        // UseCases
        // Algumas vezes vamos nos deparar com lógicas de negócio que não
        // precisam de um estado global. Nesse caso, podemos usar um provider
        // comum.
        // Ex: Provider(create: (context) => GetTermsOfUseUseCase(context.read())),
      ],
      child: const AppWidget(),
    ),
  );
}
