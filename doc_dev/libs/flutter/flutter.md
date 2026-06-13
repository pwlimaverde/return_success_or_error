# Flutter — Padrões e Estruturas de Widgets Modernos

> **Versões de referência (mais atuais)**
> - Flutter: 3.44.2 (estável, lançada em 10/06/2026)
> - Dart SDK: 3.12.2 (estável, lançada em 10/06/2026)
> - Documentação consultada em: 2026-06-13
> - Atualize este arquivo ao migrar de versão.

---

## Categorias de Widgets Fundamentais

**O que são:** Flutter organiza widgets em categorias baseadas em seu papel na árvore de widgets. Os dois tipos principais são `StatelessWidget` (imutável) e `StatefulWidget` (com estado mutável).

### StatelessWidget

Um widget imutável sem estado interno. Rende a mesma UI para os mesmos parâmetros.

```dart
class HelloWidget extends StatelessWidget {
  final String name;

  const HelloWidget({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}
```

**Características:**
- Construtor sempre `const` (imutável).
- Método `build(BuildContext context)` único obrigatório.
- Ideal para widgets apresentacionais, puramente dependentes de parâmetros.

**Padrão recomendado:** Use StatelessWidget como padrão; este é o tipo mais performático e deve ser a primeira escolha para qualquer widget sem estado interno.

### StatefulWidget

Um widget que pode ter estado mutável. Delega a renderização e gerenciamento de estado para uma classe `State` associada.

```dart
class Counter extends StatefulWidget {
  final int initialValue;

  const Counter({
    super.key,
    this.initialValue = 0,
  });

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialValue;
  }

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Contagem: $_count'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('Incrementar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Limpar recursos aqui
    super.dispose();
  }
}
```

**Estrutura:**
1. Classe `StatefulWidget` com parâmetros imutáveis (props do widget).
2. Método `createState()` que retorna instância da classe `State`.
3. Classe `State<T>` que gerencia estado mutável e constrói a UI.

**Padrão recomendado:** Crie StatefulWidget quando precisar manter estado local. Sempre use classes State com nomenclatura `_WidgetNameState` (privada).

---

## Ciclo de Vida do State

**O que é:** Todo State possui um ciclo de vida com métodos específicos chamados em sequência previsível. Entender esse ciclo é essencial para gerenciar recursos (timers, streams, listeners).

**Sequência do ciclo de vida:**

```
1. createState() → cria a instância de State
   ↓
2. initState() → chamado UMA VEZ quando o State é inserido na árvore
   ↓
3. didChangeDependencies() → chamado quando State depende de InheritedWidget
   ↓
4. build() → chamado quando UI precisa ser renderizada
   ↓
5. didUpdateWidget(oldWidget) → chamado se o widget pai foi reconstruído
   ↓
6. setState() → marca State como "sujo" e agenda rebuild
   ↓
7. deactivate() → widget foi removido da árvore
   ↓
8. dispose() → limpeza final, nunca mais build() será chamado
```

**Exemplo prático com ciclo completo:**

```dart
class LifecycleExample extends StatefulWidget {
  const LifecycleExample({super.key});

  @override
  State<LifecycleExample> createState() => _LifecycleExampleState();
}

class _LifecycleExampleState extends State<LifecycleExample> {
  late StreamSubscription _subscription;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    print('initState: widget inserido na árvore');
    // Aqui: inicializar timers, streams, listeners
    _subscription = Stream.periodic(const Duration(seconds: 1))
        .listen((_) {
          if (mounted) {
            setState(() => _counter++);
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies: dependências do InheritedWidget mudaram');
  }

  @override
  void didUpdateWidget(LifecycleExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget: widget pai foi reconstruído');
  }

  @override
  void deactivate() {
    print('deactivate: widget será removido');
    super.deactivate();
  }

  @override
  void dispose() {
    print('dispose: limpeza final');
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build: renderizando UI');
    return Scaffold(
      body: Center(
        child: Text('Contador: $_counter'),
      ),
    );
  }
}
```

**Padrão recomendado:**
- Use `initState` para inicializar listeners, streams, timers.
- Use `dispose` para cancelar subscriptions, limpar resources.
- Sempre verifique `mounted` antes de chamar `setState` em callbacks assíncronos.
- Não faça operações pesadas no `build()`.

---

## BuildContext e a Árvore de Widgets

**O que é:** `BuildContext` é um handle que referencia a posição de um widget na árvore de elementos (widget tree → element tree → render tree). Fornece acesso a dados herdados, tema, rotas, e mais.

**Estrutura em 3 camadas:**

```
Widget Tree (build methods)
    ↓
Element Tree (runtime instances)
    ↓
Render Tree (layout e paint)
```

Quando você chama `build(BuildContext context)`, esse `context` aponta para o **Element** que representa seu widget naquela posição.

**Operações comuns com BuildContext:**

```dart
@override
Widget build(BuildContext context) {
  // Acessar tema
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // Acessar MediaQuery (dimensões de tela)
  final size = MediaQuery.of(context).size;
  final padding = MediaQuery.of(context).padding;

  // Acessar rota/navegação
  Navigator.of(context).push(MaterialPageRoute(...));

  // Acessar InheritedWidget
  final appModel = Provider.of<AppModel>(context);

  // Disparar animação
  showDialog(context: context, builder: ...);

  return Scaffold(...);
}
```

**Padrão recomendado:**
- Não armazene `BuildContext` como atributo de classe (pode virar stale).
- Passe `context` como parâmetro para funções que o precisem.
- Use `BuildContext.read()` vs `BuildContext.watch()` (quando disponível via packages como Provider) com cuidado para entender quando rebuild acontece.

---

## setState() e Reconstrução de Widgets

**O que é:** `setState()` notifica o framework que o estado interno de um State mudou e a UI deve ser reconstruída.

**Mecanismo:**

```dart
void _increment() {
  setState(() {
    _counter++;  // Marcar como "sujo"
  });
  // Após setState, build() é agendado para ser chamado novamente
}
```

Quando `setState()` é chamado:
1. O callback é executado (estado é atualizado).
2. Framework marca o State como "sujo".
3. `build()` é agendado para ser chamado na próxima frame.
4. Apenas os widgets afetados são reconstruídos (diffing eficiente).

**Padrão recomendado:**
- Chame `setState()` apenas quando o estado **realmente** mudou.
- Evite chamar `setState()` dentro de `build()` (causa loop infinito).
- Prefira `setState` para estado local simples; use abordagens mais robustas (Provider, Bloc, Riverpod) para estado global ou complexo.

---

## Gerenciamento de Estado Moderno

**Panorama:** Flutter oferece várias abordagens nativas e externas para gerenciar estado. A escolha depende da complexidade e escopo.

### 1. setState() — Estado Local Simples

Para componentes com estado local simples (toggles, campos de entrada).

```dart
class SimpleToggle extends StatefulWidget {
  const SimpleToggle({super.key});

  @override
  State<SimpleToggle> createState() => _SimpleToggleState();
}

class _SimpleToggleState extends State<SimpleToggle> {
  bool _isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isEnabled,
      onChanged: (value) {
        setState(() {
          _isEnabled = value;
        });
      },
    );
  }
}
```

### 2. ValueNotifier + ListenableBuilder — Estado Reativo Local

Para estado local que precisa ser observado sem rebuild de toda a árvore.

```dart
class CounterWithValueNotifier extends StatefulWidget {
  const CounterWithValueNotifier({super.key});

  @override
  State<CounterWithValueNotifier> createState() =>
      _CounterWithValueNotifierState();
}

class _CounterWithValueNotifierState
    extends State<CounterWithValueNotifier> {
  late final ValueNotifier<int> _counter = ValueNotifier(0);

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListenableBuilder(
          listenable: _counter,
          builder: (context, _) {
            return Text('Contador: ${_counter.value}');
          },
        ),
        ElevatedButton(
          onPressed: () {
            _counter.value++;
          },
          child: const Text('Incrementar'),
        ),
      ],
    );
  }
}
```

**Vantagem:** Reconstrução eficiente — apenas a parte que escuta `ListenableBuilder` é reconstruída.

### 3. InheritedWidget — Passar Dados pela Árvore

Para compartilhar dados com descendentes sem passar por constructores.

```dart
class ThemeProvider extends InheritedWidget {
  final ThemeData theme;

  const ThemeProvider({
    required this.theme,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}

// Uso em descendentes:
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = ThemeProvider.of(context);
    return Container(
      color: provider.theme.primaryColor,
      child: const Text('Usando tema herdado'),
    );
  }
}
```

### 4. Abordagens Externas (Panorama)

Para estado global ou lógica complexa, considere:

- **Provider** (`package:provider`): Simples, performático, baseado em InheritedWidget.
- **Bloc** (`package:flutter_bloc`): Padrão arquitetural completo, event-driven, ótimo para lógica complexa.
- **Riverpod** (`package:riverpod`): Evolução do Provider, reativo, com suporte a assincronismo nativo.

**Padrão recomendado:**
- Use `setState()` apenas para estado efêmero local.
- Use `ValueNotifier` + `ListenableBuilder` para estado reativo local simples.
- Use `InheritedWidget` para dados que precisam ser compartilhados pela árvore.
- Use packages externos (Provider/Bloc/Riverpod) para estado global ou lógica de negócio.

---

## Material 3 e Tema Moderno

**O que é:** Material 3 é a linguagem de design do Flutter baseada em princípios do Material Design 3 do Google. Oferece cores dinâmicas, componentes modernos e alta customização.

### Habilitar Material 3

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App',
      theme: ThemeData(
        useMaterial3: true,  // ← Ativar Material 3
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
```

### ColorScheme e Cores Dinâmicas

`ColorScheme` define a paleta de cores do app de forma estruturada.

```dart
// Cores padrão baseadas em seed
final colorScheme = ColorScheme.fromSeed(
  seedColor: Colors.deepPurple,
  brightness: Brightness.light,
);

// Cores personalizadas
final customColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.blue,
  onPrimary: Colors.white,
  secondary: Colors.amber,
  onSecondary: Colors.black,
  error: Colors.red,
  onError: Colors.white,
  surface: Colors.grey[50]!,
  onSurface: Colors.black,
);
```

### ThemeData Moderno

```dart
final theme = ThemeData(
  useMaterial3: true,
  colorScheme: colorScheme,
  appBarTheme: const AppBarTheme(
    elevation: 0,  // Sem sombra
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.all(16),
  ),
);
```

**Padrão recomendado:**
- Use `useMaterial3: true` para todos os novos projetos.
- Prefira `ColorScheme.fromSeed()` para coerência automática de cores.
- Customize `AppBarTheme`, `ElevatedButtonTheme`, `InputDecorationTheme` para consistência global.

---

## Performance: Const Constructors e Keys

**O que é:** Performance em Flutter depende de limitar rebuilds desnecessários e de otimizar a difusão de mudanças na árvore de widgets.

### Const Constructors

Marque construtores com `const` para que Flutter reutilize instâncias.

```dart
// ❌ Ruim: cria nova instância a cada rebuild
Widget build(BuildContext context) {
  return Column(
    children: [
      const Text('Título'),  // ✓ Const (reutilizado)
      MyWidget(),             // ❌ Nova instância cada vez
      Icon(Icons.add),        // ❌ Deveria ser const
    ],
  );
}

// ✓ Bom: const onde possível
Widget build(BuildContext context) {
  return Column(
    children: const [
      Text('Título'),
      SizedBox(height: 16),
      Icon(Icons.add),
    ],
  );
}
```

**Padrão recomendado:**
- Sempre use `const` em construtores imutáveis.
- Declare parâmetros como `final` para garantir imutabilidade.
- Analise a árvore com DevTools para identificar rebuilds desnecessários.

### Keys

Ajudam Flutter a identificar quais widgets mudaram em listas.

```dart
// ❌ Sem key: ao reordenar a lista, os States ficam associados
// ao widget errado e o estado interno "vaza" entre itens.
ListView(
  children: [
    MyStatefulWidget(item: item1),
    MyStatefulWidget(item: item2),
  ],
)

// ✓ Com key: Flutter rastreia widgets corretamente
ListView(
  children: items.map((item) {
    return MyStatefulWidget(
      key: ValueKey(item.id),  // Identifica este widget
      item: item,
    );
  }).toList(),
)
```

**Tipos de key:**
- `ValueKey<T>(value)`: Para dados únicos simples (IDs, strings).
- `ObjectKey(object)`: Para objetos que implementam `==`.
- `UniqueKey()`: Força recriação cada vez (raramente útil).

**Padrão recomendado:**
- Use `ValueKey` com IDs únicos em listas.
- Evite índices como keys (quebra quando ordem muda).
- Se widgets são puramente apresentacionais sem estado, keys são opcionais.

---

## Composição de Widgets e Arquitetura

**O que é:** A composição hierárquica de widgets é o coração da arquitetura Flutter. Pequenos widgets compostos em widgets maiores criam aplicações complexas.

### Extrair Widgets Pequenos

Decomponha árvores grandes em widgets menores e reutilizáveis.

```dart
// ❌ Tudo em um build() gigante
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Home')),
    body: Column(
      children: [
        // 100 linhas de UI...
      ],
    ),
  );
}

// ✓ Decomposição clara
Widget build(BuildContext context) {
  return Scaffold(
    appBar: const MyAppBar(),
    body: Column(
      children: [
        const HeaderSection(),
        const ContentList(),
        const Footer(),
      ],
    ),
  );
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Bem-vindo!'),
    );
  }
}
```

### Padrão de Widget Builder

Para widgets complexos com múltiplos estados.

```dart
class LoadableWidget extends StatefulWidget {
  final Future<Data> dataFuture;

  const LoadableWidget({
    super.key,
    required this.dataFuture,
  });

  @override
  State<LoadableWidget> createState() => _LoadableWidgetState();
}

class _LoadableWidgetState extends State<LoadableWidget> {
  late Future<Data> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = widget.dataFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Data>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ContentWidget(data: snapshot.data!);
        } else {
          return const Center(child: Text('Sem dados'));
        }
      },
    );
  }
}
```

**Padrão recomendado:**
- Crie widgets pequenos e focados (single responsibility).
- Use composição para construir UIs complexas.
- Extraia widgets apresentacionais (`StatelessWidget`) quando possível.
- Reserve `StatefulWidget` apenas para estado efêmero necessário.

---

## Novidades das Versões Recentes (Flutter 3.35 → 3.44)

Mudanças relevantes acumuladas até o Flutter 3.44 (Google I/O 2026).

### Material e Cupertino saindo do core (3.44) — IMPORTANTE

Os widgets de **Material** e **Cupertino** estão sendo desacoplados do repositório `flutter/flutter` e migrados para pacotes independentes no pub.dev: **`material_ui`** e **`cupertino_ui`**. Eles deixarão de seguir o ciclo de release de 3 meses do SDK, recebendo novidades de Material 3 e correções de Cupertino assim que prontas.

**Impacto para esta lib:** como `return_success_or_error` é um pacote de domínio (Clean Architecture) e **não** depende de widgets, isso não a afeta diretamente. Mas apps que a consomem podem, no futuro, precisar declarar `material_ui`/`cupertino_ui` como dependências explícitas.

### Dot shorthands no código Flutter (via Dart 3.10)

Com o Dart 3.10+, o código Flutter pode usar dot shorthands para enums e construtores quando o tipo é conhecido (ver `dart.md`). Exemplos típicos em UI:

```dart
MainAxisAlignment alignment = .center;       // em vez de MainAxisAlignment.center
final controller = .new();                   // ScrollController inferido pelo tipo do campo
return switch (state) {                       // enums/sealed em switch ficam mais curtos
  .loading => const CircularProgressIndicator(),
  .error => const Text('Erro'),
  .ready => const HomeView(),
};
```

### Atualizações de widgets Material 3 (3.44)

- **`Slider`** atualizado para a especificação Material 3: nova altura, gap entre track ativo/inativo e indicador de parada (stop indicator). É uma breaking change visual — revise telas que usam `Slider`.
- **`Expansible`** (que dá base ao `ExpansionTile`) ganhou método `toggle()` em `ExpansibleController` e `ExpansionTileController`, permitindo abrir/fechar programaticamente.
- `ListTile`, `RadioListTile`, `CheckboxListTile` e `SwitchListTile` agora aceitam `WidgetStatesController`, dando controle programático sobre os estados visuais (hovered, pressed, selected, etc.).

### Outras mudanças relevantes

- **Hot reload na Web** (3.35+) disponível sem flag experimental.
- **Widget Previewer** — pré-visualização de widgets no IDE (VS Code, IntelliJ, Android Studio) e no Chrome.
- **iOS/macOS:** Swift Package Manager passou a ser o gerenciador de dependências padrão (migração automática do projeto Xcode); suporte a iOS 26 / Xcode 26 e ao ciclo de vida `UIScene` (requer migração).
- **Apple Silicon:** não é mais necessário instalar o Rosetta para rodar o Flutter.
- **DevTools:** compilado em WASM por padrão; menor uso de memória nos Widget Previews.

**Padrão recomendado:** ao atualizar o SDK, sempre consulte o guia de breaking changes oficial (`docs.flutter.dev/release/breaking-changes`), em especial as mudanças do `Slider` e a migração de Material 3.

---

## Resumo de Boas Práticas

1. **Widgets:** Use `StatelessWidget` como padrão; `StatefulWidget` apenas se houver estado local.
2. **Ciclo de vida:** Inicialize em `initState()`, limpe em `dispose()`, sempre verifique `mounted`.
3. **State management:** Use `setState` para estado local, `ValueNotifier`/`ListenableBuilder` para reatividade, packages externos para estado global.
4. **BuildContext:** Nunca armazene; passe como parâmetro.
5. **Material 3:** Ative com `useMaterial3: true`, use `ColorScheme.fromSeed()`.
6. **Performance:** Sempre use `const`, adicione `ValueKey` em listas, analise rebuilds com DevTools.
7. **Composição:** Decomponha em widgets pequenos e reutilizáveis.
