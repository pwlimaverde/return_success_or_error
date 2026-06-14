import 'package:return_success_or_error/return_success_or_error.dart';

/// Regra de negócio que consome um `Datasource<bool>` e o mapeia para uma
/// mensagem.
///
/// Estende [UsecaseBaseCallData]: `String` é o tipo retornado pelo usecase e
/// `bool` é o tipo cru do datasource. O datasource é encaminhado pelo construtor
/// (`super.datasource`) e permanece privado — a subclasse apenas chama
/// `resultDatasource` e faz `switch` sobre o resultado.
final class CheckConnectionUsecase extends UsecaseBaseCallData<String, bool> {
  CheckConnectionUsecase({required super.datasource, super.runInIsolate});

  @override
  Future<ReturnSuccessOrError<String>> run(
    ParametersReturnResult parameters,
  ) async {
    final result = await resultDatasource(parameters);

    return switch (result) {
      SuccessReturn<bool>() =>
        result.result
            ? const SuccessReturn(success: "You are connected")
            : ErrorReturn(
                error: parameters.error.copyWith(message: "You are offline"),
              ),
      ErrorReturn<bool>() => ErrorReturn(error: result.result),
    };
  }
}
