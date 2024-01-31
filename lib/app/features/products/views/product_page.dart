import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../stores/product_store.dart';
import '../widgets/set_product_button.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.id});
  final int id;

  /// Aqui o `id` é passado como parâmetro para a rota.
  static String path(int id) => '/product/$id';

  @override
  Widget build(BuildContext context) {
    final store = context.read<ProductStore>();

    /// Aqui, estamos pegando o produto com o `id` passado como parâmetro.
    final product = store.products.firstWhere((e) => e.id == id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Product $id'),
      ),
      body: Center(
        child: Text('''
        id: ${product.id},
        name: ${product.name},
        description: ${product.description},
        price: ${product.price},
        total: ${product.total},
        '''),
      ),
      // Aqui, mais uma vez, estamos usando o `SetProductButton` para editar o
      // produto.
      floatingActionButton: SetProductButton(
        title: const Text('Editar Produto'),
        icon: const Icon(Icons.edit),
        product: product,
      ),
    );
  }
}
