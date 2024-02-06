enum Routes {
  initial(caminho: "/"),
  fibonacci(caminho: "/fibonacci"),
  checkconnect(caminho: "/checkconnect");

  final String caminho;
  const Routes({required this.caminho});
}
