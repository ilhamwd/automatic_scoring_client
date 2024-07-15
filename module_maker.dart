// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) async {
  String packageName = "";
  final pubspecFile = File("pubspec.yaml");

  if (!await pubspecFile.exists()) {
    return print(
        "Not a Flutter project! Please put this file in the root of your Flutter project (where the pubspec.yaml is located).");
  }

  // Get project's package name
  final pubspec = await pubspecFile.readAsLines();
  final configs = pubspec.map((e) => e.split(":"));

  for (final config in configs) {
    if (config[0] == "name") {
      packageName = config[1].replaceAll(RegExp(r"\s+"), "");
      break;
    }
  }

  final moduleNameTrail = args.indexOf("--name");
  final routePathTrail = args.indexOf("--route");

  if (moduleNameTrail < 0 || args[moduleNameTrail + 1][0] == "-") {
    return print("Name is required. Example \"--name glucose_sensor\"");
  }

  if (routePathTrail < 0 || args[routePathTrail + 1][0] == "-") {
    return print("Route path is required. Example \"--route /sensor/glucose\"");
  }

  final moduleName = args[moduleNameTrail + 1];
  final routePath = args[routePathTrail + 1];
  final moduleNameCamelClassCase = moduleName
      .split("_")
      .map((e) => "${e[0].toUpperCase()}${e.substring(1)}")
      .join();
  final moduleNameCamelVarCase =
      "${moduleNameCamelClassCase[0].toLowerCase()}${moduleNameCamelClassCase.substring(1)}";
  final presentationDir = Directory("lib/presentation");
  final viewsDir = Directory("${presentationDir.path}/views/");
  final controllersDir = Directory("${presentationDir.path}/controllers/");
  final bindingsDir = Directory("${presentationDir.path}/bindings/");
  final utilsDir = Directory("lib/utils");
  final navigationFile = File("${utilsDir.path}/navigation.dart");
  final routesFile = File("${utilsDir.path}/routes.dart");

  if (!await presentationDir.exists()) {
    await presentationDir.create();
  }

  if (!await viewsDir.exists()) {
    await viewsDir.create();
    await generateGitKeep(viewsDir);
  }

  if (!await controllersDir.exists()) {
    await controllersDir.create();
    await generateGitKeep(controllersDir);
  }

  if (!await bindingsDir.exists()) {
    await bindingsDir.create();
    await generateGitKeep(bindingsDir);
  }

  if (!await utilsDir.exists()) {
    await utilsDir.create();
    await generateGitKeep(utilsDir);
  }

  if (!await routesFile.exists()) {
    const routesContent = "abstract class Routes {}";

    await routesFile.writeAsString(routesContent);
  }

  if (!await navigationFile.exists()) {
    final navigationContent =
        "import 'package:get/get.dart'; import 'package:$packageName/utils/routes.dart'; abstract class Navigation {static final pages = [];}";

    await navigationFile.writeAsString(navigationContent);
  }

  // Generate controller
  final controllerScript =
      """import 'package:get/get.dart';class ${moduleNameCamelClassCase}Controller extends GetxController {}""";
  final controller =
      File("${controllersDir.path}/${moduleName}_controller.dart");

  await controller.writeAsString(controllerScript);

  // Generate binding
  final bindingScript =
      """import 'package:get/get.dart';import 'package:$packageName/presentation/controllers/${moduleName}_controller.dart';class ${moduleNameCamelClassCase}Binding extends Bindings {@override void dependencies() {Get.put(${moduleNameCamelClassCase}Controller());}}""";
  final binding = File("${bindingsDir.path}/${moduleName}_binding.dart");

  await binding.writeAsString(bindingScript);

  // Generate view
  final viewScript =
      """import 'package:flutter/material.dart';import 'package:get/get.dart';import 'package:$packageName/presentation/controllers/${moduleName}_controller.dart';class ${moduleNameCamelClassCase}Screen extends GetView<${moduleNameCamelClassCase}Controller> { const ${moduleNameCamelClassCase}Screen({super.key});\n\n@override Widget build(BuildContext context) {throw UnimplementedError();}}""";
  final view = File("${viewsDir.path}/${moduleName}_screen.dart");

  await view.writeAsString(viewScript);

  // Add route
  final routes = await routesFile.readAsString();
  final routeEofOffset = routes.indexOf("}");

  await routesFile.writeAsString(
      "${routes.substring(0, routeEofOffset)}static const $moduleNameCamelVarCase= \"$routePath\";${routes.substring(routeEofOffset)}");

  // Add navigation
  final navigation = await navigationFile.readAsString();
  final navigationEofOffset = navigation.indexOf("]");
  final getPage =
      "GetPage(name: Routes.$moduleNameCamelVarCase, page: () => const ${moduleNameCamelClassCase}Screen(), binding: ${moduleNameCamelClassCase}Binding()),";

  await navigationFile.writeAsString(
      "import 'package:$packageName/presentation/bindings/${moduleName}_binding.dart';import 'package:$packageName/presentation/views/${moduleName}_screen.dart';\n${navigation.substring(0, navigationEofOffset)}$getPage${navigation.substring(navigationEofOffset)}");

  // Format documents
  await Process.run("dart", ["format", controller.path]);
  await Process.run("dart", ["format", binding.path]);
  await Process.run("dart", ["format", view.path]);
  await Process.run("dart", ["format", routesFile.path]);
  await Process.run("dart", ["format", navigationFile.path]);
}

Future<void> generateGitKeep(Directory dir) async {
  final file = File("${dir.path}/.gitkeep");

  await file.writeAsBytes([]);
}
