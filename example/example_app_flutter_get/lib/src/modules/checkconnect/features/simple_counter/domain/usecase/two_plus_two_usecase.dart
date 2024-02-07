import 'package:return_success_or_error/return_success_or_error.dart';

final class TwoPlusTowUsecase extends UsecaseBase<int> {
  @override
  Future<ReturnSuccessOrError<int>> call(NoParams parameters) async {
    const sum = 2 + 2;
    return SuccessReturn<int>(success: sum);
  }
}
