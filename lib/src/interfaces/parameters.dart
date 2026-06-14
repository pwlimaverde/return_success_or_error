import 'package:meta/meta.dart';

import '../../return_success_or_error.dart';

/// Carrega os dados necessários para executar a chamada do datasource.
///
/// Interface pura: sua única exigência, e obrigatória, é expor o [AppError]
/// retornado quando a chamada falha — todo objeto de parâmetros precisa carregar
/// o erro que ele exibiria, de modo que as falhas sempre tenham um erro tipado e
/// específico do domínio à mão (sem fallback genérico vazando entre as camadas).
/// Implemente-a com `implements`, declare seus próprios campos (de preferência
/// `final`) e mantenha o objeto imutável, para que os mesmos parâmetros possam
/// ser reexecutados com segurança (por exemplo, em um [Isolate] de background).
///
/// Por ser uma interface consumida com `implements`, ela só consegue obrigar o
/// contrato abstrato ([error]); não entrega nenhum comportamento, então
/// igualdade (`==`/`hashCode`) e `toString` ficam a cargo de cada implementação.
abstract interface class ParametersReturnResult {
  /// O erro retornado quando a chamada falha.
  AppError get error;
}

/// Implementação usada quando o datasource não exige parâmetros extras.
///
/// Recebe o [error] opcionalmente; caso contrário, recorre a um [ErrorGeneric]
/// padrão. O construtor é `const`, então `const NoParams()` é canonicalizado —
/// útil quando os mesmos parâmetros vazios são reutilizados entre chamadas.
@immutable
final class NoParams implements ParametersReturnResult {
  @override
  final AppError error;

  const NoParams({AppError? error})
    : error =
          error ??
          const ErrorGeneric(message: "NoParams: unspecified generic error");
}
