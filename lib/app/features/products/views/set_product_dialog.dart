import 'package:branvier_teste/app/features/products/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_async/flutter_async.dart';
import 'package:formx/formx.dart';
import 'package:go_router/go_router.dart';

class SetProductDialog extends StatelessWidget {
  const SetProductDialog({
    super.key,
    required this.title,
    this.product = const ProductModel(),
  });

  /// Aqui, estamos recebendo o produto que será editado. Por padrão, ele é um
  /// `ProductModel` vazio, caso o usuário esteja criando um novo produto.
  final ProductModel product;
  final Widget title;

  void setProduct(BuildContext context, FormxState state) {
    if (!state.validate()) return;

    // Aqui, estamos convertendo o formulário em um `ProductModel`.
    final product = ProductModel.fromForm(state.form);

    // Aqui, estamos retornando o produto para a rota que chamou o dialog.
    context.pop(product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
      ),
      body: Center(
        child: Formx(
          /// O `onSubmitted` é chamado quando o usuário aperta 'enter'.
          onSubmitted: (state) => setProduct(context, state),
          builder: (context, state) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Aqui, estamos usando o `FormxField` para cada campo do `ProductModel`.
              for (final e in product.toMap().entries)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormxField(
                    tag: e.key,
                    initialValue: '${e.value}',
                  ),
                ),
              ElevatedButton(
                onPressed: () => setProduct(context, state),
                child: const Text('Salvar Produto'),
              ).asAsync(),
            ],
          ),
        ),
      ),
    );
  }
}
