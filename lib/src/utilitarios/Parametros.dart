abstract class ParametrosRetornoResultado {
  final String mensagemErro;

  ParametrosRetornoResultado({required this.mensagemErro});
}

class NoParams implements ParametrosRetornoResultado {
  final String mensagemErro;

  NoParams({required this.mensagemErro});
}
