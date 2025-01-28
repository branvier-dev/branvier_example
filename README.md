# Arquitetura

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
        - /widgets
    - /services
      - /service
    - /shared
      - /constants 
      - /extensions
      - /widgets
    - app_analytics.dart
    - app_injector.dart
    - app_router.dart
    - app.dart
  - main.dart
```

Organizamos nossa arquitetura em `/features`, onde cada feature é responsável por uma parte da aplicação. Normalmente, uma feature é uma entidade de negócio, como `User`, `Product`, `Order`, etc.

Já em `/services`, colocamos os serviços que são compartilhados por todas as features, como `DioService`, `CacheService`, `FirebaseFirestore`, etc.

Em `/shared`, colocamos os arquivos que são compartilhados por todas as features, como `constants`, `extensions`, `widgets` (componentes base reutilizados no app inteiro), etc. Não devemos colocar lógica de negócio nessa pasta.

O aplicativo é dividido em camadas, onde cada uma tem uma responsabilidade específica.

> Lógica de negócio: é a lógica que é específica da aplicação (`repositories`, `stores`, por exemplo, todo app vai ter o entidades diferentes, modelos, tabelas, etc, isso são os negócios de cada app). Um componente de negócio deve ser colocado em `/features` (ex `BookButton`, `BookCard`). Um componente genérico deve ser colocado em `/shared` (ex `AppButton`, `AppDrawer`) e não deve depender de nenhuma feature específica ou de um modelo específico. (normalmente usando flutter puro e não possuindo quase nenhum outro import).

### Camadas

- **Model**: Representação de uma entidade. Ex: `User`, `Product`.
- **Service**: Abstração de uma fonte de dados. Ex: `CacheService`, `DioService`.
- **Repository**: Gerenciamento da fonte de dados. Ex: `UserRepository`, `ProductRepository`.
- **Store**: Gerenciamento do estado da aplicação. Ex: `UserStore`, `ProductStore`.
- **View**: Interface com o usuário. Ex: `UserPage`, `ProductPage`.

Uma camada não pode acessar outra camada do mesmo nível diretamente. Ex: `Store` não pode acessar outra `Store`. Sempre
que uma camada precisar de outra, você poderá usar a camada abaixo ou a de cima. 

Por exemplo, você pode salvar os dados do usuário no `UserRepository` e acessá-los em multiplas stores diferentes, ou você pode acessar o `UserStore` em multiplas views diferentes. Fazendo isso, você mantém a responsabilidade de cada camada e evita dependências cíclicas.

## Model

Um modelo é uma representação de um objeto de negócios.

```dart
class User {
  final int id;
  final String name;
  final String? avatarUrl; // nullable (?) para campos opcionais.

  User.fromMap(...); // serialização
}
```

Use a extensão desenvolvida pela Branvier para facilitar a serialização de objetos.

### Instale aqui: [Dart Safe Data Class](https://marketplace.visualstudio.com/items?itemName=ArthurMiranda.dart-safe-data-class)

---

## Service

O Service representa uma funcionalidade específica, como um cliente HTTP, armazenamento cache, ou uma API backend. Normalmente é um package como: cloud_firestore, dio, shared_preferences.

Como o Service é a camada mais externa, ele não deve depender de nenhuma outra camada. Dessa forma, podemos por todos os serviços juntos na pasta `/services`.

Usamos o package `auto_injector` no arquivo `app_injector` para injetar todos os serviços que serão usados no app. Ele resolverá as dependências automaticamente.

```dart
final i = AutoInjector();

// Alguns serviços/packages já trabalham com instancia globais, neste caso, usamos addInstance.
i.addInstance(FirebaseFirestore.instance);

// Na maioria dos casos, as instâncias são criadas pelo construtor, então usamos addLazySingleton e o .new.
i.addLazySingleton(DioService.new);

// O repository depende do DioService, então o auto_injector fornecerá a instância automaticamente, pois ela foi registrada anteriormente. :)
i.addLazySingleton(AuthRepository.new);

// Ao final, chamamos o método commit para finalizar o registro.
i.commit();
```

## Repository

O Repository é responsável por gerenciar a fonte de dados, tratá-la e fornecê-la para o resto da aplicação de uma forma mais amigável.

Cada repository é responsável por uma entidade específica, um Model. É interessante ter uma pasta para cada entidade dentro de `/feature` onde ficarão os arquivos `model`, `repository`, `store`, `view`, `widget` daquela entidade. Ex: `BookModel`, `BookRepository`, `BookStore`, `BookPage`, `BookButton`, `BookCard`, `BookList`, etc.

```dart
// Uma DTO (Data Transfer Object) é um objeto que contém os dados necessários para uma operação específica. Por exemplo, um 
// `LoginDto` contém o email e a senha do usuário, pois são necessários para fazer o login.

class LoginDto {
  final String email;
  final String password;
  const LoginDto(this.email, this.password);
}

class AuthRepository {
  AuthRepository(this.dio, this.cache);

  // Note que ele depende de 2 serviços: `DioService` e `CacheService`. 
  // O `DioService` é responsável por fazer a chamada HTTP e
  // o `CacheService` é responsável por salvar o token de autenticação no cache.
  final DioService dio;
  final CacheService cache;

  // Por exemplo, o método login precisa de um `LoginDto` e retorna um `User`. 
  // O Repository é responsável por fazer a chamada HTTP com os dados da dto, 
  // serializar os dados e retornar esse objeto no formato `User`.
  Future<User> login(LoginDto dto) async {
    final response = await dio.post<Map>('/login', data: dto.toMap());
    await cache.set('token', response.data!['token']);

    return User.fromMap(response.data!);
  }

  Future<void> rememberPassword(bool value) async {
    await cache.set('remember_password', value.toString());
  }
}
```

## Store

A Store é responsável por gerenciar o estado da aplicação. Ela é a única camada que pode alterar o estado da aplicação.

A Store depende do Repository para acessar os dados e de extender o `ChangeNotifier` para notificar os widgets que o estado foi alterado.

```dart

class BookStore extends ChangeNotifier {
  BookStore(this.repository) {
    // Todo construtor pode ter um método para inicializar algo junto com ele.
    // Aqui, chamamos getBooks() para carregar os livros junto com a inicialização do BookStore.
    getBooks();
  }
  final BookRepository repository; // dependemos do BookRepository para baixar os livros.

  // Variáveis de estado privadas, pois só podem ser alteradas aqui.
  var _books = <Book>[];
  
  // Usamos um getter para expor o estado. Permitindo apenas a leitura e não a alteração.
  List<Book> get books => _books;
  
  // Sempre `Future<void>` ou `void` ao invés de `Future<List<Book>>`, pois 
  // nossa fonte de verdade deve ser o getter `books`.
  Future<void> getBooks() async {
    _books = await _repository.getBooks();

    // chamamos notifyListeners() para notificar os widgets que estão escutando as mudanças devem ser reconstruídos.
    notifyListeners();
  }
}
```

Usamos o package `provider` para injetar a Store na árvore de widgets. Dessa forma, ganhamos o poder de acessar o estado facilmente através do `context`. Usando o `context.read` ou `context.watch` para acessar o estado.

Mas para que ele funcione, precisamos adicionar um `StoreProvider` na árvore de widgets. Normalmente adicionamos ele em uma rota, dessa forma ele poderá ser acessado por todas as páginas daquela rota.

No arquivo `app_router.dart`, escolha qual parte da árvore de rota você quer adicionar o `StoreProvider`, e adicione ele lá:

```dart
  GoProviderRoute(
    providers: [
      StoreProvider(create: (_) => BookStore(i())), // esse i() é o auto_injector que irá fornecer o BookRepository.
    ],
    ...
  ),
```

Para facilitar o acesso ao repositórios registrados no `auto_injector`, usamos o atalho `i`:
```dart
  static Locator get i => AppInjector.instance;
```

Agora na view, usamos o package `provider` para finalmente acessar e escutar o estado.

```dart
Widget build(BuildContext context) {
  // usamos .watch para escutar as mudanças no estado, ou seja, 
  // sempre que notifyListeners() for chamado, esse widget será reconstruído.
  // 
  // você sempre usa o .watch quando for ler um estado, mas se apenas for 
  // apenas chamar um método da stora, use o .read.
  final books = context.watch<BookStore>().books;

  return Scaffold(
    body: Column(
      children: [
        for (final book in books) Text(book.title),
      ],
    ),
  );
}
```

## Page

As páginas são responsáveis por exibir a interface do usuário. Elas são o widget mais alto na árvore de widgets de uma rota. Aproveitamos para adicionar as suas configurações de rota aqui também, como seu nome e a função dizendo como navegar até ela.

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const name = 'login';
  static void go(BuildContext context) => context.goNamed(name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('login.title'.tr)),
      body: Center(
        child: ElevatedButton(
          onPressed: () => HomePage.go(context),
          child: Text('login.button'.tr),
        ),
      ),
    );
  }
}
```

## Widget (componentes)

Os widgets são responsáveis por exibir uma parte da interface com o usuário.

É interessante criar widgets para representar os componentes, como botões, cards, inputs, etc.

```dart
class ThemeButton extends StatelessWidget {
  ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(54, 180),
        backgroundColor: Colors.purple,
      ),
      // aqui usamos context.read para acessar a store e chamar o método changeTheme.
      // não precisamos escutar o estado (.watch), pois não estamos lendo nada, apenas chamando um método.
      onTap: () => context.read<ThemeStore>().changeTheme(),
      child: Text('theme.button.change'.tr),
    );
  }
}
```

## Translation

Você deve ter notado o `.tr` no código acima. Isso é uma extensão que criamos para facilitar a tradução de textos.

```dart
  // aqui conectamos o package `tr_extension`.
  localizationsDelegates: TrDelegate().toList(),

  // aqui habilitamos a gerência de estado da tradução atual.
  locale: context.locale,

  // aqui definimos os idiomas suportados.
  supportedLocales: const [
    Locale('pt', 'BR'),
  ],
```

Basta criar os arquivos de tradução no formato abaixo na pasta `assets/translations`:

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

Pronto! Ao chamar `'home.button'.tr`, o sistema irá buscar a tradução de acordo com o idioma atual e o valor da chave definidos no arquivo de tradução.

## Convençoes de nome

### - Variáveis

Simplemente use o nome da class:

- userService para `UserService`
- bookRepository para `BookRepository`

Estados são sempre privados e exposos por um getter:

- State: final `_user` = ...;
- Getter: get `user` => _user;

### - Functions

Funções são ações e representamos com um verbo na frente:

Use `get<Value>` ou `set<Value>` on callback events:

- getStories() para `<List<Story>>`
- getStory() para `<Story>`

Pra callbacks: `void Function(T value)`

- register() -> void register()
- openStory() -> void openStory(Story story)

Pro `Repository`, use convenções de CRUD:

- getById(), getAll()
- add(), update()
- deleteById(), deleteAll()
