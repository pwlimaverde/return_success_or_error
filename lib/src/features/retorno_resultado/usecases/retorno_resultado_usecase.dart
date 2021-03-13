import '../../../../retorno_sucesso_ou_erro_package.dart';
import '../../../utilitarios/Parametros.dart';

class RetornoResultadoUsecase<T>
    extends UseCase<T, ParametrosRetornoResultado> {
  final Repositorio<T, ParametrosRetornoResultado> repositorio;

  RetornoResultadoUsecase({required this.repositorio});

  @override
  Future<RetornoSucessoOuErro<T>> call({
    required ParametrosRetornoResultado parametros,
  }) async {
    try {
      final resultado = await retornoRepositorio(
        repositorio: repositorio,
        erro: ErroRetornoResultado(
          mensagem: "${parametros.mensagemErro} Cod.01-1",
        ),
        parametros: parametros,
      );
      return resultado;
    } catch (e) {
      return ErroRetorno(
        erro: ErroRetornoResultado(
          mensagem: "${e.toString()} - ${parametros.mensagemErro} Cod.01-2",
        ),
      );
    }
  }
}
