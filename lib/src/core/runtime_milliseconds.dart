/// Assists in evaluating the performance of a call by measuring elapsed time.
///
/// Backed by a [Stopwatch], so it is accurate across minute/hour boundaries.
final class RuntimeMilliseconds {
  final Stopwatch _stopwatch = Stopwatch();

  /// Starts (or restarts) the measurement.
  void startScore() => _stopwatch
    ..reset()
    ..start();

  /// Stops the measurement.
  void finishScore() => _stopwatch.stop();

  /// Returns the elapsed time, in milliseconds, between start and finish.
  int calculateRuntime() => _stopwatch.elapsedMilliseconds;
}
