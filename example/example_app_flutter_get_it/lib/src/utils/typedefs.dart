


import 'package:return_success_or_error/return_success_or_error.dart';

import '../modules/checkconnect/features/check_connect/domain/model/check_connect_model.dart';

typedef CCUsecase = UsecaseBaseCallData<String, CheckConnectModel>;
typedef CCData = Datasource<CheckConnectModel>;

typedef FBUsecase = UsecaseBase<int>;