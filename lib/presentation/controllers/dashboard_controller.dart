import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';

class DashboardController extends GetxController {
  final server = Get.arguments as Socket;
  RxInt packetSent = 0.obs;
  RxInt latency = 0.obs;
  RxInt highestLatency = 0.obs;
  RxDouble speed = 0.0.obs;
  RxDouble highestSpeed = 0.0.obs;
  RxDouble lowestSpeed = 0.0.obs;
  RxInt receivedBytes = 0.obs;
  RxBool isBenchmarking = false.obs;
  DateTime packetSendDate = DateTime.now();
  Rx<Uint8List?> response = Rx<Uint8List?>(null);

  late StreamSubscription<Uint8List> _resultListener;

  @override
  void onInit() {
    super.onInit();

    _resultListener = server.listen((event) {
      response.value = event;
      receivedBytes.value += event.length;
      latency.value = DateTime.now().difference(packetSendDate).inMilliseconds;
      speed.value = 60000 / latency.value;

      if (latency.value > highestLatency.value) {
        highestLatency.value = latency.value;
      }

      if (speed.value < lowestSpeed.value && speed.value > 0) {
        lowestSpeed.value = speed.value;
      }

      if (speed.value > highestSpeed.value) {
        highestSpeed.value = speed.value;
      }
    });
  }

  void beginBenchmarking() async {
    isBenchmarking.value = true;

    while (true) {
      if (!isBenchmarking.value) {
        packetSent.value = 0;

        return;
      }

      packetSendDate = DateTime.now();

      server.writeln(loremIpsum(paragraphs: 3));
      await Future.delayed(const Duration(milliseconds: 100));

      packetSent.value = packetSent.value + 1;
    }
  }

  void stopBenchmarking() {
    isBenchmarking.value = false;
  }

  @override
  void onClose() {
    _resultListener.cancel();
    super.onClose();
  }
}
