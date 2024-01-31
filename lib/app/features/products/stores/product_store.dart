import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../repositories/product_repositories.dart';

/// Classe que representa o estado da lista de produtos.
///
/// Pode ser usada para buscar, adicionar, remover e atualizar produtos enquanto
/// logado, ou seja, no MultiProvider do usuário (app_router.dart).
///
class ProductStore extends ChangeNotifier {
  ProductStore(this._repository);

  /// Aqui não precisamos saber como o repositório cria/salva os produtos. Vamos
  /// apenas usá-lo. Isso é chamado de 'inversão de controle'.
  final ProductRepository _repository;

  /// Esse é o estado da lista. É privada e só pode ser modificada aqui.
  var _products = <ProductModel>[];

  /// Lista de produtos. Usamos `List.of` para garantir que a lista não seja
  /// modificada de fora. Enviamos uma cópia da lista.
  ///
  /// Caso contrário, a lista poderia ser modificada de fora da classe com um
  /// simples `add` ou `remove`.
  ///
  /// Esse getter é nossa fonte de verdade, ou seja, é a única forma de acessar
  /// a lista de produtos.
  List<ProductModel> get products => List.of(_products);

  /// Soma total dos produtos. Usamos `fold` para somar todos os totais.
  int get sumTotal => products.fold(0, (prev, e) => prev + e.total);

  /// Ação para buscar os produtos.
  ///
  /// Usamos void para garantir uma única fonte de verdade.
  Future<void> getProducts() async {
    // Aqui, estamos esperando a resposta da requisição.
    // Preferimos por não setar variáveis como `isLoading` ou `hasError` pois
    // isso é responsabilidade da UI.
    //
    // Além disso, o objeto `Future` já tem métodos para lidar com isso posteriormente.
    _products = await _repository.getAll();
    notifyListeners();
  }

  void setProduct(ProductModel product) {
    // Aqui, estamos verificando se o produto já existe na lista.
    final index = _products.indexWhere((e) => e.id == product.id);

    // Se não existir, adicionamos. Se existir, atualizamos.
    index == -1 ? _products.add(product) : _products[index] = product;
    notifyListeners();
  }

  void removeProduct(ProductModel product) {
    // Preferimos `removeWhere` ao `remove`, pois temos `id` no modelo.
    _products.removeWhere((e) => e.id == product.id);
    notifyListeners();
  }

  void incrementProduct(ProductModel item) {
    // Aqui, estamos criando uma cópia do produto e incrementando o total.
    final product = item.copyWith(total: item.total + 1);
    setProduct(product);
  }

  void decrementProduct(ProductModel item) {
    final product = item.copyWith(total: item.total - 1);

    // Note que não chamamos notifyListeners(), pois `setProduct` já faz isso.
    setProduct(product);
  }
}
