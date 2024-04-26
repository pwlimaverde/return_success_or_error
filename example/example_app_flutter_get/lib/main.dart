import 'package:flutter/material.dart';

import 'src/app_widget.dart';
import 'src/modules/service/init_service.dart';

void main() {
  initServices();
  runApp(
    const AppWidget(),
  );
}
