import 'package:branvier_teste/app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../stores/product_store.dart';
import '../views/set_product_dialog.dart';

/// Esse é um botão que abre um dialog para adicionar ou editar um produto.
/// Ele é usado na tela de `HomePage` e na tela de `ProductPage`.
///
/// Chamamos isso de componente, e pode ser usado em qualquer lugar do app que
/// o usuário esteja logado.
///
/// Usamos o context para acessar o `ProductStore` e chamar a ação de setar.
///
class SetProductButton extends StatelessWidget {
  const SetProductButton({
    super.key,
    required this.title,
    required this.icon,
    this.product = const ProductModel(),
  });
  final Widget icon;
  final Widget title;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        // Abriremos um dialog para adicionar ou editar um produto.
        final newProduct = await context.pushDialog<ProductModel>(
          SetProductDialog(title: title, product: product),
        );

        // Aqui, estamos verificando se o produto é nulo ou se a tela foi
        // destruída.
        if (newProduct == null || !context.mounted) return;

        // Se não for, chamamos a ação de adicionar/atualizar produto.
        context.read<ProductStore>().setProduct(newProduct);
      },
      child: icon,
    );
  }
}
