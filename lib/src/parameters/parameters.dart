import 'package:meta/meta.dart';

/// Parâmetros de uma chamada como **valor** imutável — carrega **apenas dados**.
///
/// Atravessa as três camadas (`Datasource` → `Repository` → `Usecase`) sem nunca
/// carregar o erro: quem decide a falha é cada camada — o `RepositoryBase`
/// traduz exceções técnicas via `mapError`, e o `process` do usecase devolve os
/// erros de negócio.
///
/// > **Mudança em relação à v2:** o antigo `ParametersReturnResult` obrigava
/// > todo parâmetro a expor um `AppError`, e a base usava esse erro como
/// > *fallback* ao capturar exceções. Com o erro parametrizado e o `mapError`
/// > obrigatório, esse acoplamento não existe mais.
///
/// Estenda-a declarando seus próprios campos `final` e mantenha o objeto
/// imutável: os mesmos parâmetros podem ser reenviados a um `Isolate` de
/// background, e só valores imutáveis atravessam essa fronteira com segurança.
///
/// ```dart
/// final class SalesParameters extends Parameters {
///   final DateTime inicio;
///   final DateTime fim;
///
///   const SalesParameters({required this.inicio, required this.fim});
/// }
/// ```
@immutable
abstract base class Parameters {
  const Parameters();
}
