import 'datasource.dart';
import '../utilitarios/erros.dart';
import '../utilitarios/retorno_sucesso_ou_erro.dart';

abstract class Repositorio<R, Parametros> {
  Future<RetornoSucessoOuErro<R>> call({required Parametros parametros});

  Future<RetornoSucessoOuErro<R>> retornoDatasource({
    required AppErro erro,
    required Parametros parametros,
    required Datasource<R, Parametros> datasource,
  }) async {
    try {
      final R resultado = await datasource(parametros: parametros);
      return SucessoRetorno<R>(resultado: resultado);
    } catch (e) {
      return ErroRetorno<R>(
        erro: erro,
      );
    }
  }
}
