class TempoExecucao {
  int inicio = 0;
  int fim = 0;

  void iniciar() {
    inicio = _momentoEmMilesegundos();
  }

  void terminar() {
    fim = _momentoEmMilesegundos();
  }

  int calcularExecucao() {
    return fim - inicio;
  }
}

int _momentoEmMilesegundos() {
  int minuto = 0;
  int segundo = 0;
  int milesegundo = 0;
  minuto = DateTime.now().minute;
  segundo = DateTime.now().second;
  milesegundo = DateTime.now().millisecond;
  final resultado = ((minuto * 60) * 1000) + (segundo * 1000) + milesegundo;
  return resultado;
}
