import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:polling_client/utils/navigation.dart';
import 'package:polling_client/utils/routes.dart';
import 'package:wakelock/wakelock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Wakelock.enable();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: Navigation.pages,
      initialRoute: Routes.home,
    );
  }
}
