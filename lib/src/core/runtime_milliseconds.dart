///Assists in evaluating the performance of the datasource implementation.
class RuntimeMilliseconds {
  int start = 0;
  int finish = 0;

  ///Captures the start time.
  void startScore() {
    start = _momentInMillisecond();
  }

  ///Captures the final time.
  void finishScore() {
    finish = _momentInMillisecond();
  }

  ///Calculates the time elapsed between the beginning and the end.
  int calculateRuntime() {
    return finish - start;
  }
}

///Converts the moment to mileseconds.
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
