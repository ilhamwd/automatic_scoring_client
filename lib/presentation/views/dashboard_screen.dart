import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:polling_client/presentation/controllers/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Connected to ${controller.server.address.address}:${controller.server.port}"),
                      const SizedBox(height: 10),
                      FilledButton(
                          onPressed: controller.isBenchmarking.value
                              ? controller.stopBenchmarking
                              : controller.beginBenchmarking,
                          child: Text(controller.isBenchmarking.value
                              ? "Stop Benchmarking"
                              : "Begin Benchmarking")),
                      const SizedBox(height: 10),
                      if (controller.isBenchmarking.value) ...[
                        Text("${controller.packetSent.value} packets sent"),
                        const SizedBox(height: 5),
                        Text("${controller.latency.value}ms latency"),
                        const SizedBox(height: 5),
                        Text(
                            "${controller.highestLatency.value}ms highest latency"),
                        const SizedBox(height: 5),
                        Text(
                            "${controller.speed.value.round()} message/minute speed"),
                        const SizedBox(height: 5),
                        Text(
                            "${controller.lowestSpeed.value.round()} message/minute lowest speed"),
                        const SizedBox(height: 5),
                        Text(
                            "${controller.highestSpeed.value.round()} message/minute highest speed"),
                        const SizedBox(height: 5),
                        Text(
                            "Received ${NumberFormat("#,###").format(controller.receivedBytes.value / 1000000)} megabytes"),
                      ],
                      if (controller.response.value != null) ...[
                        const SizedBox(height: 5),
                        const Text("Image Response"),
                        const SizedBox(height: 10),
                        Image.memory(
                          controller.response.value!,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      ]
                    ],
                  );
                }))));
  }
}
