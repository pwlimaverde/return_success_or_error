class RuntimeMilliseconds {
  int start = 0;
  int finish = 0;

  void startScore() {
    start = _momentInMillisecond();
  }

  void finishScore() {
    finish = _momentInMillisecond();
  }

  int calculateRuntime() {
    return finish - start;
  }
}

int _momentInMillisecond() {
  int minute = 0;
  int second = 0;
  int millesecond = 0;
  minute = DateTime.now().minute;
  second = DateTime.now().second;
  millesecond = DateTime.now().millisecond;
  final result = ((minute * 60) * 1000) + (second * 1000) + millesecond;
  return result;
}
