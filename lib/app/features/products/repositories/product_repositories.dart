import 'dart:math';

import 'package:branvier_teste/app/features/products/models/product_model.dart';
import 'package:branvier_teste/app/services/api_service.dart';

class ProductRepository {
  ProductRepository(this.api);
  final ApiService api;

  Future<List<ProductModel>> getAll() async {
    await Future.delayed(const Duration(seconds: 2));

    // Aqui, estamos simulando uma requisição à uma API.
    // Normalmente, você usaria o `api` para fazer a requisição.
    //
    // Chamamos isso de 'mock'.
    return List.generate(
      15,
      (index) => ProductModel(
        id: index,
        name: 'Product $index',
        description: 'Description of product $index',
        price: Random().nextDouble() * 100,
      ),
    );
  }
}
