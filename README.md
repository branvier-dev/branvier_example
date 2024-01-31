# Architecture

## Feature-driven ✨

```md
- /lib
  - /app
    - /features
      - /feature
        - /models
        - /repositories
        - /stores
        - /views
          - _page.dart
          - _dialog.dart
        - /widgets
    - /services
      - /source
    - /shared
      - /constants 
      - /utils 
      - /extensions
    - app_router.dart
    - app_widget.dart
  - main.dart
```

- Exemplo: [Estoque de Produtos](https://github.com/branvier-dev/branvier_example.git)

## Model

Um modelo é uma representação de um objeto de negócios.

```dart

```dart
class User {
  final int id;
  final String name;
  final String? avatar_url; // nullable para campos opcionais.

  User.fromMap(...); // serialização
}
```

Use a extensão desenvolvida pela Branvier para facilitar a serialização de objetos.

### Instale aqui: [Dart Safe Data Class](https://marketplace.visualstudio.com/items?itemName=ArthurMiranda.dart-safe-data-class)

---

## Service

O Service vai abstrair uma fonte de dados, seja ela um banco de dados, uma API, um arquivo, um sensor etc. Ele é responsável por buscar, processar e salvar dados.

Serviços mais simples, como um armazenamento de chave/valor e funcionalidades bem específicas devem ser abstraídas, para facilitar a troca de implementação.

```dart
abstract class StorageService {
  String? get(String key);
  void set(String key, String value);
}
```
  
```dart
class HiveService extends StorageService { // <- abstract class
  @override
  String? get(String key) => _box.get(key);
}

class SharedPreferencesService extends StorageService { // <- abstract class
  @override
  String? get(String key) => _prefs.getString(key);
}
```

Dessa forma, nosso repositório pode depender de um `StorageService` e não de uma implementação específica.

```dart
/// O provider vai registrar o HiveService como um StorageService.
Provider<StorageService>(create: (_) => HiveService());

/// O ThemeRepository vai solicitar um StorageService, sem saber se é um HiveService ou SharedPreferencesService.
Provider(create: (context) => ThemeRepository(context.read()));
```

```dart
class ThemeRepository {
  ThemeRepository(this.storage);

  final StorageService storage; // <- abstract class (não sabe se é um HiveService ou SharedPreferencesService)

  ThemeMode getTheme() async {
    final value = storage.get('user');
    return value == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }
}
```

Para serviços mais complexos, como um cliente HTTP, ou Firebase, não é necessário abstrair a implementação, pois isso adiciona complexidade desnecessária. Além disso, a abstração pode ser feita em um nível mais alto, como um repositório.

```dart
// Serviços mais completos/complexos não precisam ser abstraídos. Pois fazê-lo adiciona complexidade desnecessária. Além disso, a abstração pode ser feita em um nível mais alto, como um repositório.
class DioService extends DioMixin {}
```

## Repository

O Repository é responsável por gerenciar a fonte de dados, tratá-la e fornecê-la para o resto da aplicação de uma forma mais amigável.

```dart
class AuthRepository {
  AuthRepository(this.dio, this.storage, this.crypto);

  final DioService dio;
  final StorageService storage;
  final CryptoService crypto;

  Future<User> login(LoginDto dto) async {
    final response = await dio.post<Json>('/login', data: dto.toMap());
    await crypto.set('token', response.data!['token']);

    return User.fromMap(response.data!);
  }

  Future<void> rememberPassword(bool value) async {
    await storage.set('remember_password', value.toString());
  }
}
```

## Gerenciamento de Estado

```dart

class ExampleStore extends ChangeNotifier {

  // Variáveis de estado privadas.
  var _count = 0;
  var _books = <Book>[];
  
  // Os getters são a única fonte de verdade.
  int get count => _count; 
  List<Book> get books => List.of(_books);
  
  void increment() {
    _count++;

    // sempre que modificar o estado, chame notifyListeners.
    notifyListeners();
  }
  
  // Não retornamos os livros diretamente, a fonte de verdade é o _books.
  Future<void> getBooks() async {
    _books = await // _repository.getBooks();
    notifyListeners();
  }
}
```

Na view, usamos o `Provider` para acessar o estado.

```dart
Widget build(BuildContext context) {
  // o widget será reconstruído sempre que o estado mudar.
  final example = context.watch<ExampleStore>();

  return Scaffold(
    body: Column(
      children: [
        Text('${example.count}'),
        ElevatedButton(
          onPressed: () => example.increment(),
          child: Text('Increment'),
        ),
      ],
    ),
  );
}
```

### AsyncBuilder

---
Use o `AsyncBuilder` para construir widgets com base em estados assíncronos.

```dart
// Ele resolverá os estados de loading, erro e sucesso.
AsyncBuilder(
  future: controller.getBooks(),
  builder: (context, books) {
    return ListView.builder(...);
  },
)
```

## Page

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static const path = '/login'; // <- o caminho da rota para chegar aqui.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('login.title'.tr)),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go(HomePage.route),
          child: Text('login.button'.tr),
        ),
      ),
    );
  }
}
```

## Widget

```dart
class ThemeButtonWidget extends StatelessWidget {
  ThemeButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {

  final themeStore = context.watch<ThemeStore>();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(54, 180),
        backgroundColor: Colors.purple,
      ),
      onTap: () => themeStore.changeTheme(),
      child: Text('theme.button.change'.tr),
    );
  }
}
```

## Translation

```dart
  MaterialApp(
    localizationsDelegates: context.localizationDelegates, // <- só isso :)
  );
```

Basta criar os arquivos de tradução no formato abaixo na pasta `asset/translations`:

```dart
> asset/translations/en_US.dart

{
  "home.button.increment": "Increase 1", 
  "home.button": "Press", 
}

> asset/translations/pt_BR.dart

{
  "home.button.increment": "Somar 1", 
  "home.button": "Aperte", 
}

```

Ao chamar `'home.button'.tr`, o sistema irá buscar a tradução de acordo com o idioma atual e o valor da chave definidos no arquivo de tradução.

## Convençoes de nome

### - Variáveis

Simplemente use o nome da class:

- userService para `UserService`
- bookRepository para `BookRepository`

Estados são sempre privados e exposos por um getter:

- State: final `_user` = ...;
- Getter: get `user` => _user.value;

### - Functions

Use `get<Value>` when returning data and `on<Value>` on callback events.

Pra funções async: `Future<T> Function()`

- getStories() para `<List<Story>>`
- getStory() para `<Story>`

Pra callbacks: `void Function(T value)`

- onRegisterTap() -> void onRegisterTap()
- onStoryTap() -> void onStoryTap(Story story)

Pro `Repository`, use convenções de CRUD:

- getById(), getAll()
- add(), update()
- deleteById(), deleteAll()
