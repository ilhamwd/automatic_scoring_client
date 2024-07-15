import 'package:polling_client/presentation/bindings/dashboard_binding.dart';
import 'package:polling_client/presentation/views/dashboard_screen.dart';
import 'package:polling_client/presentation/bindings/home_binding.dart';
import 'package:polling_client/presentation/views/home_screen.dart';
import 'package:get/get.dart';
import 'package:polling_client/utils/routes.dart';

abstract class Navigation {
  static final pages = [
    GetPage(
        name: Routes.home,
        page: () => const HomeScreen(),
        binding: HomeBinding()),
    GetPage(
        name: Routes.dashboard,
        page: () => const DashboardScreen(),
        binding: DashboardBinding()),
  ];
}
