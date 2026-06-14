import 'package:return_success_or_error/return_success_or_error.dart';

/// Regra de negócio que consome um `Datasource<bool>` e o mapeia para uma
/// mensagem.
///
/// Estende [UsecaseBaseCallData]: `String` é o tipo retornado pelo usecase e
/// `bool` é o tipo cru do datasource. A base faz o fetch do datasource e, em
/// caso de sucesso, chama [process] com o `bool` já desempacotado — a subclasse
/// só implementa a regra de negócio sobre o dado bruto.
final class CheckConnectionUsecase extends UsecaseBaseCallData<String, bool> {
  CheckConnectionUsecase({required super.datasource, super.runInIsolate});

  @override
  ProcessData<String, bool> get process => _process;

  /// Função estática (não captura `this`): recebe o `bool` já carregado pelo
  /// datasource e devolve a mensagem ou um erro de negócio.
  static ReturnSuccessOrError<String> _process(
    bool online,
    ParametersReturnResult parameters,
  ) => online
      ? const SuccessReturn(success: "You are connected")
      : ErrorReturn(
          error: parameters.error.copyWith(message: "You are offline"),
        );
}
