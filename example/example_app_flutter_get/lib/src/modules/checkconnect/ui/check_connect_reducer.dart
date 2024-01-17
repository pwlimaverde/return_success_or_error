// import 'package:flutter_modular/flutter_modular.dart';
// import 'package:return_success_or_error/return_success_or_error.dart';
// import 'package:rx_notifier/rx_notifier.dart';

// import '../features/check_connect/domain/model/check_connect_model.dart';
// import 'check_connect_state.dart';

// class CheckConnectReducer extends RxReducer {
//   CheckConnectReducer() {
//     on(() => [checarConnecaoAction], _checkConnectReducer);
//   }

//   void _checkConnectReducer() async {
//     final usecase =
//         Modular.get<UsecaseBaseCallData<String, CheckConnecModel>>();
//     final status = await usecase(NoParams());
//     switch (status) {
//       case SuccessReturn<String>():
//         checarConeccaoState.value = status.result;
//       case ErrorReturn<String>():
//         checarConeccaoState.value = status.result.message;
//     }
//   }

//   @override
//   void dispose() {
//     checarConeccaoState.value = null;
//     super.dispose();
//   }
// }
