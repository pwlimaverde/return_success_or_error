import 'package:rx_notifier/rx_notifier.dart';

// atoms
final showProgressState = RxNotifier<bool>(false);
final fibonacciState = RxNotifier<int?>(null);

// actions
final calcFibonacciAction = RxNotifier<int?>(null);
final calcFibonacciIsolateAction = RxNotifier<int?>(null);
