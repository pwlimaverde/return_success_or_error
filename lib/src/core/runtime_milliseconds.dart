///Assists in evaluating the performance of the datasource implementation.
final class RuntimeMilliseconds {
  int _start = 0;
  int _finish = 0;

  ///Captures the start time.
  void startScore() {
    _start = _momentInMillisecond();
  }

  ///Captures the final time.
  void finishScore() {
    _finish = _momentInMillisecond();
  }

  ///Calculates the time elapsed between the beginning and the end.
  int calculateRuntime() {
    return _finish - _start;
  }
}

///Converts the moment to mileseconds.
int _momentInMillisecond() {
  int _minute = 0;
  int _second = 0;
  int millesecond = 0;
  _minute = DateTime.now().minute;
  _second = DateTime.now().second;
  millesecond = DateTime.now().millisecond;
  final _result = ((_minute * 60) * 1000) + (_second * 1000) + millesecond;
  return _result;
}
