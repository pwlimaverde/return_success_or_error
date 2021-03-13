abstract class AppErro implements Exception {}

class ErroInesperado implements AppErro {
  final String mensagem;

  ErroInesperado({required this.mensagem});

  @override
  String toString() {
    return "ErroInesperado - $mensagem";
  }
}

class ErroRetornoResultado implements AppErro {
  final String mensagem;

  ErroRetornoResultado({required this.mensagem});

  @override
  String toString() {
    return "ErroRetornoResultado - $mensagem";
  }
}
