import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polling_client/presentation/controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        const Center(child: RadarBackground()),
        Center(
          child: Obx(() {
            if (controller.discoveryServices.isEmpty) {
              return const Text("Scanning...");
            }

            return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: controller.discoveryServices
                    .map((element) => PollingServerWidget(service: element))
                    .toList());
          }),
        ),
      ],
    ));
  }
}

class RadarBackground extends StatelessWidget {
  const RadarBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        children:
            List<Widget>.generate(3, (index) => RadarCircle(index: index + 1)));
  }
}

class RadarCircle extends StatefulWidget {
  const RadarCircle({super.key, required this.index});

  final int index;

  @override
  State<RadarCircle> createState() => _RadarCircleState();
}

class _RadarCircleState extends State<RadarCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(milliseconds: widget.index * 500), () {
            if (mounted) {
              _animationController.forward(from: 0.0);
            }
          });
        }
      })
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = MediaQuery.of(context).size.width;

    return Opacity(
      opacity:
          Tween<double>(begin: 1, end: 0).animate(_animationController).value,
      child: Transform.scale(
        scale: _animationController.value,
        child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCCCCCC), width: 2))),
      ),
    );
  }
}

class PollingServerWidget extends StatefulWidget {
  const PollingServerWidget({
    super.key,
    required this.service,
  });

  final BonsoirService service;

  @override
  State<PollingServerWidget> createState() => _PollingServerWidgetState();
}

class _PollingServerWidgetState extends State<PollingServerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      })
      ..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<HomeController>().connectDiscoveryService(widget.service);
      },
      child: Opacity(
        opacity: _animationController.value,
        child: Column(
          children: [
            Transform.scale(
              scale: CurvedAnimation(
                      parent: Tween<double>(begin: .4, end: 1)
                          .animate(_animationController),
                      curve: Curves.bounceOut)
                  .value,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(
                  Icons.radar,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(widget.service.name)
          ],
        ),
      ),
    );
  }
}
