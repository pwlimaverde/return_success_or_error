# Planejamento de Refatoração — `return_success_or_error`

> Documento de trabalho criado em **13/06/2026** (branch `release/1.0.0`).
> Objetivo: revisar arquivo a arquivo e o fluxo de ponta a ponta, registrar o que cada
> componente faz, como se conecta ao fluxo e quais oportunidades de melhoria existem.
> **Nada aqui foi aplicado ainda** — é o mapa para a próxima rodada de refator/teste.

## Objetivo da lib (recapitulação)

Facilitar o uso dos componentes de uma feature **centralizando o retorno em sucesso ou erro**
(`ReturnSuccessOrError<T>` selado), **separando responsabilidades** (Clean Architecture:
Usecase → Datasource → Resultado) e oferecendo a possibilidade de **isolar o processamento
da feature em uma thread separada** (`callIsolate` via `Isolate.run`), deixando o app mais
fluido.

## Fluxo central (referência)

```
Consumidor
   │  usecase(parameters)            // call posicional
   ▼
UsecaseBaseCallData.call ──► resultDatasource(parameters)   // única ponte
                                   │  try { _datasource(parameters) }   // privado
                                   ▼
                              Datasource.call ──► throw parameters.error  (falha)
                                   │                 └► dado cru (sucesso)
                                   ▼
                       SuccessReturn<D> | ErrorReturn<D>  (erro enriquecido via copyWith)
   ◄───────────────────────────────┘
switch (result) { SuccessReturn / ErrorReturn }  // tratamento exaustivo no usecase
   ▼
ReturnSuccessOrError<T>   →   fold / isSuccess / getOrNull no consumidor
```

Caminho alternativo: `callIsolate(parameters)` executa o `call` acima dentro de
`Isolate.run`, mede com `Stopwatch` e loga o tempo (só em debug).

---

> **Status (13/06/2026):** rodada 1 de refator concluída — todos os itens da lib aplicados e
> validados (`dart analyze` 0 issues · 35 testes). Os 3 apps Flutter de `example/` foram
> **substituídos por um único exemplo Dart puro (CLI)** (`dart analyze` limpo, `dart run`
> executando os fluxos de sucesso/erro/isolate). Docs (README, README-pt, CLAUDE.md,
> CHANGELOG) atualizados. Nada commitado ainda — aguardando teste/validação do usuário.

## Checklist — arquivos da lib

- [x] `lib/return_success_or_error.dart` (barrel) — dartdoc reescrito, export órfão removido
- [x] `lib/src/bases/usecase_base.dart` — `@protected` + constante `_datasourceCatchCode`
- [x] `lib/src/core/return_success_or_error.dart` — campos movidos p/ subclasses (sem `!`)
- [x] ~~`lib/src/core/runtime_milliseconds.dart`~~ — **removido** (API órfã)
- [x] `lib/src/core/service.dart` — `initDependences` → `initDependencies`
- [x] `lib/src/interfaces/datasource.dart` — dartdoc limpo
- [x] `lib/src/interfaces/errors.dart` — `ErrorGeneric` com `==`/`hashCode`
- [x] `lib/src/interfaces/parameters.dart` — interface pura (`AppError get error`)

## Checklist — testes

- [x] `test/src/bases/usecase_base_test.dart`
- [x] ~~`test/src/core/runtime_milliseconds_test.dart`~~ — removido com a classe
- [x] `test/src/core/return_success_or_error_test.dart` — **novo** (fold/isSuccess/getOrNull)
- [x] `test/src/interfaces/datasource_test.dart`
- [x] `test/src/interfaces/errors_test.dart` — + teste de igualdade por valor
- [x] `test/src/interfaces/parameters_test.dart`

## Checklist — conferência de fluxo / integração

- [x] Fluxo Usecase → resultDatasource → Datasource (sucesso e erro)
- [x] Enriquecimento de erro via `copyWith` (`Cod. 02-1` agora em constante nomeada)
- [x] Encapsulamento do `_datasource` (subclasse não acessa)
- [x] `callIsolate` e a restrição de *sendability* no isolate (testado com datasource sendable)
- [x] Coerência barrel/exports × o que é realmente usado
- [x] Coerência doc (README, CLAUDE.md, dartdoc) × API real
- [x] Integração nos 3 examples (DI nomeada, `Service.to`, `callIsolate`)

---

## Análise arquivo a arquivo

### 1. `lib/return_success_or_error.dart` (barrel)

**O que faz:** ponto único de exportação pública da lib. Reexporta `usecase_base`,
`return_success_or_error`, `runtime_milliseconds`, `service`, `datasource`, `errors`,
`parameters`.

**Como se conecta ao fluxo:** é a fronteira da API pública — define exatamente o que os
consumidores (e os filhos que estendem as bases) enxergam.

**Oportunidades de melhoria:**
- ⚠️ **Dartdoc desatualizado.** O comentário de `runtime_milliseconds` fala em "presenter"
  (abstração removida há várias versões). O de `errors` fala em "override the `message`
  parameter", mas `message` agora é getter imutável. Reescrever para a API real.
- 🔤 Usa crase tipográfica `´´´` em vez de backticks/refs de dartdoc (`` `Datasource` `` ou
  `[Datasource]`). Padronizar e corrigir typo "Exeption" → "Exception".
- ❓ **Reavaliar o export de `runtime_milliseconds`** (ver item 4 — é código órfão). Decidir:
  manter público, ou parar de exportar.

### 2. `lib/src/bases/usecase_base.dart`

**O que faz:** o coração da lib. Define o `base mixin _UsecaseRunner` (contrato `call`
abstrato + `callIsolate` concreto), `UsecaseBase` (regra de negócio pura) e
`UsecaseBaseCallData` (regra com datasource privado + `resultDatasource`).

**Como se conecta ao fluxo:** é a porta de entrada (`call`/`callIsolate`) e a única ponte
para o datasource (`resultDatasource`). Tudo passa por aqui.

**Oportunidades de melhoria:**
- 🏷️ **`resultDatasource` é público mas destina-se só a subclasses.** Anotar com
  `@protected` (de `package:meta`) deixa a intenção explícita e gera aviso de lint se um
  consumidor externo chamá-lo. Avaliar custo de adicionar `meta` como dependência (é leve e
  comum em pacotes).
- 🔢 **Código de erro `"Cod. 02-1"` hardcoded** dentro de `resultDatasource`. Considerar
  extrair para uma constante nomeada (ou documentar o significado), para não virar string
  mágica solta.
- 🧵 **Sendability do isolate não é validada.** `callIsolate` captura `this` (usecase +
  datasource). Se algo não for *sendable*, falha em runtime. Vale um parágrafo de dartdoc
  reforçando a restrição (já há um início) e, se possível, um teste que documente o caso.
- ✅ A correção de medição (Stopwatch + await + log gated por `assert`) e o
  `runtimeType` (no lugar do antigo hack de `toString().split(...)`) já estão bons —
  apenas confirmar cobertura de teste.

### 3. `lib/src/core/return_success_or_error.dart`

**O que faz:** o tipo selado `ReturnSuccessOrError<R>` e seus dois casos `SuccessReturn<R>`
/ `ErrorReturn<R>`, além dos helpers `fold`/`isSuccess`/`isError`/`getOrNull` e dos
singletons `Unit`/`unit` e `Nil`/`nil`.

**Como se conecta ao fluxo:** é o tipo de retorno de **todo** usecase e de
`resultDatasource`. É o "produto final" do fluxo.

**Oportunidades de melhoria:**
- 🧱 **Design legado dos campos.** A classe base guarda `final AppError? _error` e
  `final R? _success` (ambos nullable) e os getters fazem *bang* (`_success!` / `_error!`).
  Mais limpo e type-safe seria **mover cada campo para a sua subclasse**: `SuccessReturn`
  com `final R result;` e `ErrorReturn` com `final AppError result;`, eliminando os
  nullable e os `!`. A base ficaria sem estado. ⚠️ Mexer aqui é sensível — exige rodar toda
  a suíte; é uma melhoria de qualidade interna, não de API.
- ➕ **Helpers adicionais opcionais:** `getOrElse(R Function())`, `mapSuccess`/`mapError`.
  Só adicionar se houver demanda real nos exemplos — não inflar a API à toa.
- 🧪 `Unit`/`Nil` são singletons via `factory`; a identidade já garante `==`. OK como está.

### 4. `lib/src/core/runtime_milliseconds.dart`

**O que faz:** utilitário com `Stopwatch` interno — `startScore`/`finishScore`/
`calculateRuntime`.

**Como se conecta ao fluxo:** ⚠️ **não se conecta.** Busca confirmou que `RuntimeMilliseconds`
**não é usado em nenhum lugar** — nem na lib (o `callIsolate` usa `Stopwatch` direto), nem
nos 3 exemplos. É **código órfão exportado publicamente**, e a documentação do barrel/CLAUDE
descreve-o incorretamente (atribui uso ao "presenter"/`callIsolate`).

**Oportunidades de melhoria (decisão do dono):**
- 🅰️ **Remover** da lib e do barrel (limpeza) — é breaking só no nome, e não há uso interno.
- 🅱️ **Manter** como utilitário público, mas **corrigir a documentação** (não é usado por
  `callIsolate`) e **adicionar um teste de uso real** que justifique a presença.
- Recomendação: decidir 🅰️/🅱️ antes do 1.0.0 estável para não publicar API morta.

### 5. `lib/src/core/service.dart`

**O que faz:** singleton `Service.to` que padroniza `initDependences` (registro de DI) e
`initServices` (inicialização paralela via `Future.wait`).

**Como se conecta ao fluxo:** auxiliar de bootstrap — usado pelos 3 examples no
`start_services.dart`. Não participa do fluxo Usecase/Datasource em si.

**Oportunidades de melhoria:**
- 🔤 **Typo na API pública: `initDependences` → `initDependencies`.** Como ainda estamos no
  branch de release 1.0.0 (pré-publicação), é o momento ideal de corrigir. Impacto: 1 uso no
  example modular (`start_services.dart:7`). Renomear lib + example.
- 🧩 `initDependences` apenas encaminha `await registerDependencies()` — questionar se
  agrega valor ou se existe só por simetria. Manter, mas documentar o porquê.

### 6. `lib/src/interfaces/datasource.dart`

**O que faz:** `abstract interface class Datasource<TypeDatasource>` com um único
`call(parameters)`.

**Como se conecta ao fluxo:** é o contrato da chamada externa; implementado fora da lib e
invocado (privadamente) por `resultDatasource`.

**Oportunidades de melhoria:**
- 🔤 Dartdoc com crase tipográfica `´´´` — padronizar para refs (`[ParametersReturnResult]`,
  `[AppError]`). Conteúdo está correto.

### 7. `lib/src/interfaces/errors.dart`

**O que faz:** `AppError` (contrato imutável: `String get message` + `copyWith`) e
`ErrorGeneric` (impl. concreta `const`).

**Como se conecta ao fluxo:** o `error` viaja dentro de `ParametersReturnResult` e é o
payload de `ErrorReturn`. `resultDatasource` enriquece via `copyWith`.

**Oportunidades de melhoria:**
- ⚖️ **`ErrorGeneric` sem `==`/`hashCode`.** Dois `ErrorGeneric` com a mesma mensagem não são
  iguais por valor — atrapalha asserts de teste e comparações. Adicionar igualdade por valor
  (ou documentar a ausência intencional).
- 📝 `AppError.toString()` (`"Error - $message"`) vs `ErrorGeneric.toString()`
  (`"ErrorGeneric - $message"`) — pequena duplicação/sobreposição; confirmar qual é o
  desejado e manter consistência.

### 8. `lib/src/interfaces/parameters.dart`

**O que faz:** `abstract interface class ParametersReturnResult` exigindo `AppError error`, e
`NoParams` (implementação pronta para chamadas sem dados extras).

**Como se conecta ao fluxo:** é o input de `call`/`resultDatasource`/`Datasource.call`;
carrega o `error` que será retornado em caso de falha.

**Oportunidades de melhoria:**
- 🧱 **Incoerência `interface` × construtor/campo.** Está declarada como `abstract interface
  class` mas tem `final AppError error` **e** um construtor. Quem usa `implements` (como
  `NoParams`) **não herda** nada disso e precisa redeclarar `error` — então o campo+construtor
  na "interface" são inertes/confusos. Escolher um modelo:
  - Interface pura: trocar para `AppError get error;` (sem campo nem construtor); ou
  - Base reutilizável: virar `abstract base class` com o campo/construtor de fato herdados.
- 📝 `NoParams` usa mensagem default `"Error General Error"` (texto redundante/estranho).
  Ajustar para algo claro como `"NoParams: erro genérico não especificado"`.

---

## Conferência de fluxo / integração

1. **Sucesso/erro Usecase→Datasource:** `resultDatasource` cobre os dois ramos
   (`SuccessReturn` no try, `ErrorReturn` enriquecido no catch). ✔️ Confirmar nos testes que
   o `copyWith` preserva o tipo concreto de `AppError` (não rebaixa para `ErrorGeneric`).
2. **Encapsulamento `_datasource`:** garantido por privacidade de biblioteca + private named
   parameter. ✔️ Já validado no refactor anterior; manter teste que prove que subclasse só
   usa `resultDatasource`.
3. **`callIsolate`/sendability:** ⚠️ ponto frágil de integração — documentar e, se viável,
   cobrir com teste. Verificar se os usecases de Fibonacci dos exemplos são sendable.
4. **Barrel × uso real:** `RuntimeMilliseconds` órfão (item 4). Resolver antes do 1.0.0.
5. **Doc × API:** dartdoc do barrel, README e CLAUDE.md têm pontos defasados (presenter,
   `message` mutável). Alinhar tudo na fonte de verdade (`lib/` + `test/`).
6. **Examples:** após mexer em `Service.initDependences` (typo) e/ou em `RuntimeMilliseconds`,
   rodar `flutter analyze` nos 3 apps.

## Critérios de verificação (a cada item concluído)

- Pacote: `dart analyze` → 0 issues · `dart test` → tudo verde · `dart pub publish --dry-run`
  sem warnings.
- Examples: `flutter pub get` + `flutter analyze` (0 issues) nos 3 apps.
- Coerência doc: README/README-pt/CLAUDE.md/dartdoc refletindo exatamente a API real.

## Priorização sugerida

1. **Decisões de API antes do 1.0.0** (breaking-friendly agora): `RuntimeMilliseconds`
   (manter/remover), `initDependences`→`initDependencies`, modelo de `ParametersReturnResult`.
2. **Robustez/qualidade interna:** redesenho dos campos de `ReturnSuccessOrError`, `==` em
   `ErrorGeneric`, `@protected` em `resultDatasource`, constante para `Cod. 02-1`.
3. **Documentação:** dartdoc do barrel + datasource, alinhar README/CLAUDE.
4. **Cobertura de teste:** `callIsolate`/sendability, igualdade de erros, helpers do selado.
