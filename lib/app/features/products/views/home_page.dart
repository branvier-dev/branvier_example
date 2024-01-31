import 'package:branvier_teste/app/features/products/stores/product_store.dart';
import 'package:branvier_teste/app/features/products/views/product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_async/flutter_async.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/set_product_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const path = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ProductStore>(builder: (context, store, _) {
          return Text('Total de Produtos: ${store.sumTotal}');
        }),
      ),
      // Aqui, estamos usando o `AsyncBuilder` para buscar os produtos.
      // Ele é um widget que permite que você mostre um `Future` na tela.
      //
      // Ele automaticamente mostra um 'loading' enquanto o `Future` não é
      // resolvido, e um 'error' caso o `Future` retorne um erro.
      body: AsyncBuilder.function(
        skipReloading: true,
        future: context.read<ProductStore>().getProducts,
        builder: (context, _) {
          // Aqui, estamos pegando a instância do `ProductStore` que está no
          // `MultiProvider` do `app_router.dart`.
          //
          // O `context.watch` é um método que permite que você escute mudanças
          // no `ProductStore`.
          //
          // É interessante usar ele aqui no AsyncBuilder, pois ele irá
          // atualizar a UI apenas da ListView, e não de toda a tela.
          final store = context.watch<ProductStore>();

          return ListView.builder(
            itemCount: store.products.length,
            itemBuilder: (context, index) {
              final product = store.products[index];

              return ListTile(
                title: Text(product.name),
                subtitle: Text(product.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(product.total.toString()),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => store.decrementProduct(product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => store.incrementProduct(product),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => store.removeProduct(product),
                    ),
                  ],
                ),
                onTap: () {
                  // Aqui, estamos usando o `GoRouter` para navegar para a página
                  // de detalhes do produto.
                  context.go(ProductPage.path(product.id));
                },
              );
            },
          );
        },
      ),
      // Aqui, estamos usando o `SetProductButton` para adicionar um produto.
      floatingActionButton: const SetProductButton(
        title: Text('Adicionar Produto'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
