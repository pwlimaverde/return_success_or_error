# Dart — Padrões e Recursos Modernos

> **Versões de referência (mais atuais)**
> - Dart SDK: 3.12.2 (estável, lançada em 10/06/2026)
> - Flutter: 3.44.2 (estável, lançada em 10/06/2026)
> - Documentação consultada em: 2026-06-13
> - Atualize este arquivo ao migrar de versão.

---

## Records (Tuplas Nativas)

**O que são:** Records são tipos anônimos compostos nativos do Dart 3 que permitem agrupar múltiplos valores sem necessidade de declarar uma classe explícita.

**Sintaxe básica:**
```dart
// Record com campos posicionais
var location = (56.1629, 10.2039);

// Record com campos nomeados
var person = (name: 'Alice', age: 30);

// Record misto (posicionais e nomeados)
var mixed = ('first', a: 2, b: true, 'last');

// Record com tipo explícito
(double latitude, double longitude) getLocation(String city) {
  if (city == 'Aarhus') {
    return (56.1629, 10.2039);
  }
  return (0.0, 0.0);
}
```

**Desestruturação:**
```dart
// Desestruturação de campos posicionais
final (lat, long) = getLocation('Aarhus');
print('Localização: $lat, $long');

// Desestruturação com tipo explícito
var (String name, int height) = userInfo({'name': 'Michael', 'height': 180});
print('Usuário $name tem $height cm de altura.');

// Ignorar campos com _
var (_, age) = getPerson(); // ignora o nome
```

**Padrão recomendado:** Use records para retornar múltiplos valores de funções, especialmente em datasources e usecases. Evita a criação de classes DTOs simples e deixa o código mais conciso.

**Exemplo prático para Clean Architecture:**
```dart
sealed class DataSourceResult {
  R map<R>(
    R Function(dynamic data) onSuccess,
    R Function(String error) onFailure,
  );
}

class SuccessResult<T> extends DataSourceResult {
  final T data;
  SuccessResult(this.data);

  @override
  R map<R>(R Function(dynamic) onSuccess, R Function(String) onFailure) =>
      onSuccess(data);
}

// Retornando um record como alternativa simples
Future<(List<User>, DateTime lastFetched)> fetchUsers() async {
  final users = await api.getUsers();
  return (users, DateTime.now());
}
```

---

## Pattern Matching e Switch Expressions

**O que é:** Pattern matching permite decompor estruturas de dados complexas de forma segura e com verificação de tipo. Switch expressions são uma forma mais concisa de switch statements.

**Padrões disponíveis:**
```dart
// Padrão de constante
switch (value) {
  case 1:
    print('um');
  case 2:
    print('dois');
  default:
    print('outro');
}

// Padrão de intervalo
switch (age) {
  case >= 0 && < 13:
    print('criança');
  case >= 13 && < 18:
    print('adolescente');
  case >= 18:
    print('adulto');
  default:
    print('inválido');
}

// Padrão de registro (record)
switch (point) {
  case (0, 0):
    print('origem');
  case (var x, 0):
    print('no eixo X: $x');
  case (0, var y):
    print('no eixo Y: $y');
  case (var x, var y):
    print('ponto: ($x, $y)');
}
```

**Switch expressions:**
```dart
// Sintaxe compacta: substitui switch statements
String describeNumber(int n) => switch (n) {
  0 => 'zero',
  1 || 2 => 'pequeno',
  >= 3 && <= 10 => 'médio',
  > 10 => 'grande',
  _ => 'desconhecido',
};

// Com múltiplas condições
String categorizeValue(dynamic value) => switch (value) {
  int n when n < 0 => 'negativo',
  int n when n > 0 => 'positivo',
  0 => 'zero',
  String s => 'texto',
  List l => 'lista com ${l.length} itens',
  _ => 'desconhecido',
};
```

**Padrão recomendado:** Use switch expressions para código funcional e mais legível. São excelentes para mapear tipos (especialmente com sealed classes) e evitar múltiplos if-else encadeados.

**Exemplo prático:**
```dart
sealed class HttpResponse {
  T when<T>({
    required T Function(dynamic data) onSuccess,
    required T Function(String error) onError,
    required T Function() onLoading,
  });
}

class Success extends HttpResponse {
  final dynamic data;
  Success(this.data);
  // ... implementação
}

// Uso com switch expression
String getStatus(HttpResponse response) => switch (response) {
  Success(data: var d) => 'Sucesso: $d',
  Error(message: var msg) => 'Erro: $msg',
  Loading() => 'Carregando...',
};
```

---

## Switch Exaustivo

**O que é:** O compilador Dart verifica automaticamente se todos os casos possíveis foram cobertos em um switch. Com sealed classes, é possível garantir completude em tempo de compilação.

**Sem exhaustiveness (com default):**
```dart
switch (value) {
  case 1:
    print('um');
  case 2:
    print('dois');
  default:
    print('outro');
}
```

**Com exhaustiveness (sealed classes):**
```dart
sealed class Animal {}

class Cow extends Animal {}

class Sheep extends Animal {}

class Pig extends Animal {}

// Erro de compilação se faltar algum case!
String whatDoesItSay(Animal a) => switch (a) {
  Cow _ => 'muu',
  Sheep _ => 'bê',
  Pig _ => 'oink',
  // Sem default, o compilador verifica todos os subtipos
};
```

**Padrão recomendado:** Sempre use sealed classes com sealed hierarchies para garantir que futures alterações serão detectadas pelo compilador. Isso previne bugs quando novos tipos são adicionados.

---

## Sealed Classes e Class Modifiers

**O que são:** Sealed classes restringem quais classes podem estender ou implementar elas, permitindo ao compilador conhecer todos os subtipos possíveis.

**Declaração de sealed class:**
```dart
sealed class Vehicle {}

class Car extends Vehicle {}

class Truck extends Vehicle {}

class Bicycle extends Vehicle {}

// Erro: Vehicle é sealed e implicitamente abstract
Vehicle v = Vehicle();

// Correto: subclasses podem ser instanciadas
Vehicle car = Car();
```

**Exhaustiveness automática:**
```dart
sealed class Shape {}

class Square implements Shape {
  final double length;
  Square(this.length);
}

class Circle implements Shape {
  final double radius;
  Circle(this.radius);
}

// Switch obrigatoriamente exaustivo
double calculateArea(Shape shape) => switch (shape) {
  Square(length: var l) => l * l,
  Circle(radius: var r) => 3.14159 * r * r,
};
```

**Class modifiers disponíveis:**

| Modificador | Propósito | Restrição |
|-------------|-----------|-----------|
| `sealed` | Cria hierarquia fechada de tipos | Não pode ser estendida/implementada fora da biblioteca |
| `final` | Previne subclasses (herança) | Classe não pode ser estendida |
| `interface` | Define contrato sem implementação | Só oferece interface, não herança |
| `base` | Força que subclasses usem `extends` | Subclasses não podem usar `implements` |

**Exemplo com múltiplos modificadores:**
```dart
// Sealed: uso único para switch exaustivo
sealed class Result {}

class Success extends Result {
  final dynamic data;
  Success(this.data);
}

class Failure extends Result {
  final String error;
  Failure(this.error);
}

// Final: impede subclasses
final class ImmutableData {
  final String value;
  const ImmutableData(this.value);
}

// Interface: define contrato
abstract interface class Logger {
  void log(String message);
}

// Base: força extends
base class BaseRepository {
  Future<List<dynamic>> fetch();
}

class UserRepository extends BaseRepository {
  @override
  Future<List<dynamic>> fetch() async => [];
}
```

**Padrão recomendado:** Use `sealed` para result types (Success/Failure), `final` para DTOs imutáveis, `interface` para contratos puros, e `base` para classes base em repositórios.

---

## Destructuring (Desestruturação)

**O que é:** Processo de extrair valores de estruturas compostas (records, lists, maps) diretamente em variáveis.

**Desestruturação de records:**
```dart
// Posicionais
var (x, y) = (10, 20);

// Nomeados
var (name: name, age: age) = person;

// Misto
var ('prefix', value: v, 'suffix') = complexRecord;
```

**Desestruturação com types:**
```dart
var (String name, int age) = getUserInfo();
```

**Desestruturação de map (map pattern):**
```dart
final config = {'host': 'localhost', 'port': 8080};
if (config case {'host': String host, 'port': int port}) {
  print('$host:$port');
}
```

**Em for loops:**
```dart
final records = [('Alice', 25), ('Bob', 30)];

for (var (name, age) in records) {
  print('$name tem $age anos');
}
```

**Padrão recomendado:** Use desestruturação para deixar código mais legível, especialmente ao trabalhar com retornos de funções que usam records.

---

## Null Safety Consolidado

**O que é:** Dart 3.x mantém e aprofunda o null safety introduzido em versões anteriores. Todos os tipos são non-nullable por padrão.

**Operadores úteis:**
```dart
// Null coalescing: usa valor padrão se null
var value = data ?? 'padrão';

// Null-aware access: acessa propriedade apenas se não null
String? name = user?.name;

// Null-aware call: chama método apenas se não null
user?.printInfo();

// Forced unwrap (cuidado!)
String name = user!.name; // Erro em runtime se user for null
```

**Type promotion:**
```dart
if (value is String) {
  // Dentro do bloco, value é String (não mais dynamic)
  print(value.length);
}

if (value != null) {
  // Aqui value é promovido de String? para String
  print(value.length);
}
```

**Padrão recomendado:** Sempre marque parâmetros e retornos com `?` se puderem ser null. Use operadores null-aware para evitar cascatas de null checks.

---

## Null-Aware Elements em Coleções (Dart 3.8)

**O que é:** Permite incluir condicionalmente um elemento em uma coleção quando o valor não é `null`, sem precisar de `if` dentro do literal. Diferente do spread null-aware (`...?`), que opera sobre coleções inteiras, o null-aware element opera sobre um único valor com o operador `?`.

```dart
String? meio;
final nomes = ['início', ?meio, 'fim'];
// Se `meio` for null, o elemento simplesmente não entra na lista.

// Antes (Dart < 3.8) era preciso usar if-element:
final nomesAntigo = ['início', if (meio != null) meio, 'fim'];

// Também funciona em map (chave e/ou valor) e set:
final config = {
  'host': host,
  if (porta != null) 'porta': porta, // forma antiga
  ?chaveOpcional: ?valorOpcional,     // forma nova (3.8)
};
```

**Padrão recomendado:** Use `?elemento` para montar listas/maps a partir de campos opcionais (ex.: payloads de request), deixando o literal mais limpo do que com `if`.

---

## Dot Shorthands (Dart 3.10)

**O que é:** Quando o tipo do contexto é conhecido, é possível omitir o nome do tipo e começar direto com `.`, acessando valores de enum, membros estáticos e construtores. Reduz repetição sem perder a inferência de tipo.

**Enums (uso ideal):**
```dart
enum Status { none, running, stopped, paused }

Status currentStatus = .running; // em vez de Status.running

String colorCode(LogLevel level) => switch (level) {
  .debug => 'gray',
  .info => 'blue',
  .warning => 'orange',
  .error => 'red',
};
```

**Membros estáticos e construtores:**
```dart
int port = .parse('80');           // int.parse('80')
BigInt zero = .zero;               // BigInt.zero

Point origem = .origin();          // construtor nomeado
Point p = .new(5.0, 3.0);          // construtor sem nome
List<int> lista = .filled(5, 0);   // genérico com inferência
```

**Em inicialização de campos (muito útil em State do Flutter):**
```dart
class _PageState extends State<Page> {
  late final AnimationController _controller = .new(vsync: this);
  final ScrollController _scroll = .new();
}
```

**Padrão recomendado:** Use dot shorthands principalmente com enums e em `switch` para encurtar os casos. Em construtores (`.new`, `.origin()`) use com bom senso — só onde o tipo já está explícito na declaração, para não prejudicar a leitura.

---

## Separadores de Dígitos (Dart 3.10)

**O que é:** Literais numéricos podem usar `_` como separador visual de milhares/grupos, sem afetar o valor.

```dart
const int umMilhao = 1_000_000;
const int cartao = 1234_5678_9012_3456;
const double pi = 3.141_592_653_589_793;
const int bytes = 0xFF_EC_DE_5E;
```

**Padrão recomendado:** Use em constantes grandes (valores monetários, máscaras de bits, timeouts em microssegundos) para melhorar a legibilidade.

---

## Private Named Parameters (Dart 3.12)

**O que é:** Construtores agora podem inicializar campos privados (`_campo`) diretamente via `this._campo` em parâmetros nomeados. O chamador continua usando o nome público (sem o `_`), eliminando a lista de inicialização repetitiva.

```dart
// Antes (boilerplate):
class Hummingbird {
  final String _petName;
  final int _wingbeatsPerSecond;

  Hummingbird({required String petName, required int wingbeatsPerSecond})
      : _petName = petName,
        _wingbeatsPerSecond = wingbeatsPerSecond;
}

// Dart 3.12:
class Hummingbird {
  final String _petName;
  final int _wingbeatsPerSecond;

  Hummingbird({required this._petName, required this._wingbeatsPerSecond});
}

// Chamada (usa o nome público, sem o "_"):
final bird = Hummingbird(petName: 'Dash', wingbeatsPerSecond: 75);
```

**Padrão recomendado:** Adote para classes de estado/modelos com campos privados — reduz drasticamente o boilerplate de construtores mantendo o encapsulamento.

---

## Primary Constructors — Experimental (Dart 3.12)

**O que é:** Permite declarar os parâmetros do construtor diretamente no cabeçalho da classe, virando campos automaticamente. **É experimental** — habilite com `--enable-experiment=primary-constructors`.

```dart
// Forma tradicional:
class Point {
  final int x;
  final int y;
  Point(this.x, this.y);
}

// Primary constructor:
class Point(final int x, final int y);

// Com construtores nomeados e herança:
class Pet {
  String name;
  new() : name = 'Fluffy';
  new withName(this.name);
}

class Dog extends Pet;
```

**Padrão recomendado:** Por ser experimental, **não use em código de produção** desta lib ainda. Acompanhe a estabilização antes de adotar. Documentado aqui para referência futura.

---

## Extensões (Extensions)

**O que são:** Permitem adicionar métodos a tipos existentes sem modificá-los.

```dart
extension StringExtensions on String {
  bool get isNumeric => double.tryParse(this) != null;
  
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

// Uso
print('123'.isNumeric); // true
print('hello'.capitalize()); // Hello
```

**Padrão recomendado:** Use extensões para adicionar métodos utilitários, conversões de tipo, e validações. Especialmente útil para `Result`, `Future`, e `String`.

**Exemplo prático:**
```dart
extension ResultExt<T> on Future<Result<T>> {
  Future<R> fold<R>(
    R Function(T) onSuccess,
    R Function(String) onFailure,
  ) async {
    final result = await this;
    return switch (result) {
      Success(data: var d) => onSuccess(d),
      Failure(error: var e) => onFailure(e),
    };
  }
}

// Uso elegante
await fetchUsers().fold(
  (users) => print('Sucesso: $users'),
  (error) => print('Erro: $error'),
);
```

---

## Dicas para Modernização de Clean Architecture

1. **Result Types:** Substitua `Either` por sealed classes + records
   ```dart
   sealed class Result<T> {}
   class Success<T> extends Result<T> {
     final T value;
     Success(this.value);
   }
   class Failure<T> extends Result<T> {
     final String error;
     Failure(this.error);
   }
   ```

2. **Use Cases:** Retorne records em vez de DTOs simples
   ```dart
   Future<(User user, DateTime timestamp)> getUser(String id) async {
     final user = await repository.fetch(id);
     return (user, DateTime.now());
   }
   ```

3. **Pattern Matching em Listeners:** Use switch expressions para tratar estados
   ```dart
   BlocListener<UserBloc, UserState>(
     listener: (context, state) {
       final message = switch (state) {
         UserLoadingState() => 'Carregando...',
         UserSuccessState(:final user) => 'Bem-vindo, ${user.name}',
         UserErrorState(:final error) => 'Erro: $error',
       };
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
     },
   )
   ```

4. **Sealed Hierarchies:** Modele fluxos de dados com sealed classes
   ```dart
   sealed class HttpEvent {}
   class OnSuccess extends HttpEvent { final dynamic data; ... }
   class OnError extends HttpEvent { final String error; ... }
   class OnLoading extends HttpEvent {}
   ```

---

## Referências e Leitura Adicional

- **Documentação oficial:** https://dart.dev/language
- **Records:** https://dart.dev/language/records
- **Patterns:** https://dart.dev/language/patterns
- **Class Modifiers:** https://dart.dev/language/class-modifiers
- **Dot Shorthands:** https://dart.dev/language/dot-shorthands
- **Anúncio Dart 3.12:** https://dart.dev/blog/announcing-dart-3-12
- **Whats New:** https://dart.dev/resources/whats-new
