import 'erros.dart';

abstract class RetornoSucessoOuErro<R> {
  const RetornoSucessoOuErro();
  fold({
    required R Function(SucessoRetorno<R>) sucesso,
    required AppErro Function(ErroRetorno<R>) erro,
  }) {
    final _this = this;
    if (_this is SucessoRetorno<R>) {
      return sucesso(_this);
    } else {
      return erro(_this as ErroRetorno<R>);
    }
  }
}

class SucessoRetorno<R> extends RetornoSucessoOuErro<R> {
  final R resultado;
  const SucessoRetorno({required this.resultado});
}

class ErroRetorno<R> extends RetornoSucessoOuErro<R> {
  final AppErro erro;
  const ErroRetorno({required this.erro});
}
