import 'package:flutter/material.dart';

import 'src/app_widget.dart';
import 'src/modules/service/start_services.dart';

void main() {
  startServices();
  runApp(
    const AppWidget(),
  );
}
