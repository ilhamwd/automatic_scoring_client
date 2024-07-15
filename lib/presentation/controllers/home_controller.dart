import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polling_client/domain/models/discovery_server_payload.dart';
import 'package:polling_client/utils/routes.dart';

class HomeController extends GetxController {
  late final BonsoirDiscovery discovery;
  final RxList<BonsoirService> discoveryServices = <BonsoirService>[].obs;
  BonsoirService? discoveryService;
  Socket? server;

  void connectDiscoveryService(BonsoirService service) async {
    final timeout = Timer(const Duration(seconds: 15), () => {});

    Get.dialog(
        AlertDialog(
            title: Text(service.name),
            content: const Row(children: [
              CircularProgressIndicator(),
              SizedBox(width: 30),
              Text("Connecting...")
            ])),
        barrierDismissible: false);

    await service.resolve(discovery.serviceResolver);

    while (server == null) {
      if (!timeout.isActive) break;

      await Future.delayed(const Duration(seconds: 1));
    }

    Get.back();
    Get.back();
    Get.toNamed(Routes.dashboard, arguments: server!);
  }

  void connectServer(DiscoveryServerPayloadModel payload) async {
    log("Connecting to ${payload.ipAddress}:${payload.port}");
    server = await Socket.connect(payload.ipAddress, payload.port);

    server!.writeln("User-Agent");
    await discovery.stop();
  }

  @override
  void onInit() async {
    super.onInit();

    discovery = BonsoirDiscovery(type: "_pollingdiscover._tcp");

    await discovery.ready;

    discovery.eventStream!.listen((event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        if (event.service != null) {
          discoveryServices.add(event.service!);
        }
      }

      if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        if (event.service != null) {
          discoveryServices.value = [
            ...discoveryServices.where((p0) => p0.name != event.service!.name)
          ];
        }
      }

      if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        discoveryService = event.service;

        connectServer(
            DiscoveryServerPayloadModel.fromJson(discoveryService!.attributes));
      }
    });

    discovery.start();
  }
}
